import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../providers/auth_provider.dart';
import '../utils/app_theme.dart';
import '../services/dashboard_service.dart';
import '../l10n/app_localizations.dart';

// تعريف حالات التحميل
enum LoadingState { loading, loaded, error }

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final DashboardService _dashboardService = DashboardService();
  DashboardStats? _stats;
  LoadingState _loadingState = LoadingState.loading;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _loadData();
    timeago.setLocaleMessages('ar', timeago.ArMessages());
  }

  Future<void> _loadData() async {
    if (_loadingState != LoadingState.loaded) {
      setState(() { _loadingState = LoadingState.loading; });
    }
    try {
      final data = await _dashboardService.getDashboardStats();
      if (mounted) {
        setState(() {
          _stats = data;
          _loadingState = LoadingState.loaded;
        });
        _animationController.forward();
      }
    } catch (e) {
      if (mounted) {
        setState(() { _loadingState = LoadingState.error; });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('فشل في تحديث البيانات: ${e.toString()}'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  void _setupAnimations() {
    _animationController = AnimationController(duration: const Duration(milliseconds: 800), vsync: this);
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeOut));
    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // --- *** تم التعديل هنا: build() لم تعد تحتوي على Scaffold أو AppBar *** ---
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      decoration: AppTheme.gradientDecoration,
      child: RefreshIndicator(
        onRefresh: _loadData,
        color: AppTheme.primaryYellow,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildWelcomeSection(l10n),
              const SizedBox(height: 24),
              _buildQuickStats(l10n),
              const SizedBox(height: 24),
              // قسم الإجراءات السريعة الذي اتفقنا على إزالته من هنا
              // _buildQuickActions(l10n),
              // const SizedBox(height: 24),
              _buildRecentActivity(l10n),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  // باقي دوال البناء (_buildWelcomeSection, _buildQuickStats, etc.) تبقى كما هي
  // ... (الكود الخاص بباقي الويدجتس الفرعية موجود في الردود السابقة، لا حاجة لتكراره هنا)
  Widget _buildWelcomeSection(AppLocalizations l10n) { /* ... no change ... */ return Consumer<AuthProvider>(builder: (context, authProvider, child) { final user = authProvider.user; final timeOfDay = _getTimeOfDay(); return Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(gradient: LinearGradient(colors: [AppTheme.primaryYellow, AppTheme.primaryYellow.withAlpha(204)], begin: Alignment.topLeft, end: Alignment.bottomRight), borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: AppTheme.primaryYellow.withAlpha(76), blurRadius: 15, offset: const Offset(0, 8))]), child: Row(children: [Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('$timeOfDay ${user?.displayName ?? 'النحال'}', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.darkBrown)), const SizedBox(height: 8), Text('مرحباً بك في HiveLog Bee', style: TextStyle(fontSize: 16, color: AppTheme.darkBrown.withAlpha(204)) )])), Container(width: 60, height: 60, decoration: BoxDecoration(color: Colors.white.withAlpha(51), borderRadius: BorderRadius.circular(15)), child: const Icon(Icons.hive, size: 35, color: AppTheme.darkBrown))]));});}
  String _getTimeOfDay() { final hour = DateTime.now().hour; if (hour < 12) return 'صباح الخير'; if (hour < 17) return 'مساء الخير'; return 'مساء الخير'; }
  Widget _buildQuickStats(AppLocalizations l10n) { return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Row(children: [const Text('إحصائيات سريعة', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.darkBrown)), if (_loadingState == LoadingState.error) ...[const SizedBox(width: 8), const Icon(Icons.error_outline, color: AppTheme.errorColor, size: 20)]]), const SizedBox(height: 16), if (_loadingState == LoadingState.loaded && _stats != null) _buildStatsContent(l10n, _stats!) else _buildStatsShimmer(l10n)]); }
  Widget _buildStatsContent(AppLocalizations l10n, DashboardStats stats) { return FadeTransition(opacity: _fadeAnimation, child: SlideTransition(position: _slideAnimation, child: Column(children: [Row(children: [Expanded(child: _buildStatCard(title: l10n.total_hives, value: stats.totalHives.toString(), icon: Icons.hive, color: AppTheme.primaryYellow)), const SizedBox(width: 12), Expanded(child: _buildStatCard(title: l10n.total_production, value: '${stats.totalProduction.toStringAsFixed(1)} ${l10n.kg}', icon: Icons.opacity, color: AppTheme.honeyOrange))]), const SizedBox(height: 12), Row(children: [Expanded(child: _buildStatCard(title: l10n.active_treatments, value: stats.activeTreatments.toString(), icon: Icons.medical_services, color: AppTheme.errorColor)), const SizedBox(width: 12), Expanded(child: _buildStatCard(title: l10n.pending_inspections, value: stats.pendingInspections.toString(), icon: Icons.search, color: AppTheme.successColor))])]))); }
  Widget _buildStatsShimmer(AppLocalizations l10n) { return Shimmer.fromColors(baseColor: Colors.grey[300]!, highlightColor: Colors.grey[100]!, child: Column(children: [Row(children: [Expanded(child: _buildStatCard(title: l10n.total_hives, value: ' ', icon: Icons.hive, color: Colors.grey)), const SizedBox(width: 12), Expanded(child: _buildStatCard(title: l10n.total_production, value: ' ', icon: Icons.opacity, color: Colors.grey))]), const SizedBox(height: 12), Row(children: [Expanded(child: _buildStatCard(title: l10n.active_treatments, value: ' ', icon: Icons.medical_services, color: Colors.grey)), const SizedBox(width: 12), Expanded(child: _buildStatCard(title: l10n.pending_inspections, value: ' ', icon: Icons.search, color: Colors.grey))])])); }
  Widget _buildStatCard({required String title, required String value, required IconData icon, required Color color}) { return Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withAlpha(12), blurRadius: 10, offset: const Offset(0, 4))]), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Icon(icon, color: color, size: 24), Container(padding: const EdgeInsets.all(4), decoration: BoxDecoration(color: color.withAlpha(25), borderRadius: BorderRadius.circular(8)), child: Icon(Icons.trending_up, color: color, size: 16))]), const SizedBox(height: 12), Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.darkBrown)), const SizedBox(height: 4), Text(title, style: TextStyle(fontSize: 12, color: AppTheme.darkBrown.withAlpha(153)), maxLines: 1, overflow: TextOverflow.ellipsis)]));}
  Widget _buildRecentActivity(AppLocalizations l10n) { if (_loadingState == LoadingState.loaded && (_stats?.recentActivity.isEmpty ?? true)) { return const SizedBox.shrink(); } return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('النشاط الأخير', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.darkBrown)), const SizedBox(height: 16), if (_loadingState == LoadingState.loaded && _stats != null) _buildActivityContent(_stats!) else _buildActivityShimmer()]); }
  Widget _buildActivityContent(DashboardStats stats) { return FadeTransition(opacity: _fadeAnimation, child: Container(decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withAlpha(12), blurRadius: 10, offset: const Offset(0, 4))]), child: Column(children: List.generate(stats.recentActivity.length, (index) { final activity = stats.recentActivity[index]; final type = activity['type'] as String; final title = activity['title'] as String; final date = DateTime.parse(activity['created_at'] as String); return _buildActivityItem(title: title, subtitle: timeago.format(date, locale: 'ar'), icon: _getIconForActivityType(type), color: _getColorForActivityType(type), isLast: index == stats.recentActivity.length - 1); })))); }
  Widget _buildActivityShimmer() { return Shimmer.fromColors(baseColor: Colors.grey[300]!, highlightColor: Colors.grey[100]!, child: Container(decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)), child: Column(children: List.generate(3, (index) => _buildActivityItem(title: ' ', subtitle: ' ', icon: Icons.hourglass_empty, color: Colors.grey, isLast: index == 2))))); }
  Widget _buildActivityItem({required String title, required String subtitle, required IconData icon, required Color color, bool isLast = false}) { return Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(border: isLast ? null : Border(bottom: BorderSide(color: Colors.grey.withAlpha(25), width: 1))), child: Row(children: [Container(width: 40, height: 40, decoration: BoxDecoration(color: color.withAlpha(25), borderRadius: BorderRadius.circular(10)), child: Icon(icon, color: color, size: 20)), const SizedBox(width: 16), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.darkBrown)), const SizedBox(height: 4), Text(subtitle, style: TextStyle(fontSize: 12, color: AppTheme.darkBrown.withAlpha(153)))])), Icon(Icons.arrow_forward_ios, size: 16, color: AppTheme.darkBrown.withAlpha(76))])); }
  IconData _getIconForActivityType(String type) { switch (type) { case 'inspection': return Icons.search; case 'treatment': return Icons.medical_services; case 'production': return Icons.opacity; default: return Icons.task; } }
  Color _getColorForActivityType(String type) { switch (type) { case 'inspection': return AppTheme.successColor; case 'treatment': return AppTheme.errorColor; case 'production': return AppTheme.honeyOrange; default: return Colors.grey; } }
}
