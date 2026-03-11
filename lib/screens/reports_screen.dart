import 'package:flutter/material.dart';
import '../services/dashboard_service.dart';
import '../utils/app_theme.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  final DashboardService _dashboardService = DashboardService();
  Future<DashboardStats>? _statsFuture;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _statsFuture = _dashboardService.getDashboardStats();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildTabBar(),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildOverviewTab(),
              _buildProductionTab(),
              _buildHealthTab(),
              _buildFinancialTab(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTabBar() {
    return TabBar(
      controller: _tabController,
      labelColor: AppTheme.primaryYellow,
      unselectedLabelColor: Colors.grey[600],
      indicatorColor: AppTheme.primaryYellow,
      tabs: const [
        Tab(text: 'نظرة عامة'),
        Tab(text: 'الإنتاج'),
        Tab(text: 'الصحة'),
        Tab(text: 'المالية'),
      ],
    );
  }

  Widget _buildOverviewTab() {
    return FutureBuilder<DashboardStats>(
      future: _statsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: AppTheme.primaryYellow));
        }
        if (snapshot.hasError) {
          return Center(child: Text('خطأ في تحميل الإحصائيات: ${snapshot.error}'));
        }
        if (!snapshot.hasData) {
          return const Center(child: Text('لا توجد بيانات لعرضها'));
        }
        final stats = snapshot.data!;
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: _buildOverviewCards(stats),
        );
      },
    );
  }

  Widget _buildOverviewCards(DashboardStats stats) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      childAspectRatio: 2.5,
      children: [
        _buildStatCard('إجمالي الخلايا', '${stats.totalHives}', Icons.hive, Colors.blue),
        _buildStatCard('علاجات نشطة', '${stats.activeTreatments}', Icons.medical_services, Colors.red),
        _buildStatCard('إنتاج السنة', '${stats.totalProduction.toStringAsFixed(1)} كغ', Icons.opacity, Colors.amber),
        _buildStatCard('فحوصات قادمة', '${stats.pendingInspections}', Icons.search, Colors.purple),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 4),
              Expanded(child: Text(title, style: const TextStyle(fontSize: 8, color: Colors.grey))),
            ],
          ),
          const SizedBox(height: 4),
          Text(value, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }

  Widget _buildProductionTab() => const Center(child: Text('تبويب الإنتاج قيد التطوير'));
  Widget _buildHealthTab() => const Center(child: Text('تبويب الصحة قيد التطوير'));
  Widget _buildFinancialTab() => const Center(child: Text('تبويب المالية قيد التطوير'));
}
