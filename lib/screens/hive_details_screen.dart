import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/hive_model.dart';
import '../providers/hive_provider.dart';
import '../utils/app_theme.dart';
import '../services/ad_service.dart';
import '../widgets/custom_app_bar.dart';
import '../l10n/app_localizations.dart';

class HiveDetailsScreen extends StatefulWidget {
  final String hiveId;

  const HiveDetailsScreen({
    super.key,
    required this.hiveId,
  });

  @override
  State<HiveDetailsScreen> createState() => _HiveDetailsScreenState();
}

class _HiveDetailsScreenState extends State<HiveDetailsScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    AdManager.onScreenChange(AdScreen.hiveDetails, AdScreen.hiveList);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    // --- *** هذا هو الإصلاح الوحيد الذي تم إجراؤه *** ---
    return Consumer<HiveProvider>(
      builder: (context, hiveProvider, child) {

        // البحث عن الخلية في القائمة الكاملة للـ provider
        HiveModel? hive;
        try {
          hive = hiveProvider.hives.firstWhere((h) => h.id == widget.hiveId);
        } catch (e) {
          hive = null;
        }

        // إذا لم يتم العثور على الخلية، اعرض شاشة خطأ
        if (hive == null) {
          return AdAwareScaffold(
            screen: AdScreen.hiveDetails,
            appBar: CustomAppBar(title: 'خطأ'),
            body: const Center(
              child: Text('لم يتم العثور على الخلية'),
            ),
          );
        }

        // إذا تم العثور على الخلية، اعرض الواجهة الكاملة
        return AdAwareScaffold(
          screen: AdScreen.hiveDetails,
          appBar: CustomAppBar(
            title: '${l10n.hive_number} ${hive.hiveNumber}',
            additionalActions: [
              PopupMenuButton<String>(
                onSelected: (action) => _handleMenuAction(action, hive!),
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'inspect',
                    child: Row(
                      children: [
                        const Icon(Icons.search, size: 20),
                        const SizedBox(width: 8),
                        Text(l10n.add_inspection),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'treat',
                    child: Row(
                      children: [
                        const Icon(Icons.medical_services, size: 20),
                        const SizedBox(width: 8),
                        Text(l10n.add_treatment),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'split',
                    child: Row(
                      children: [
                        const Icon(Icons.call_split, size: 20),
                        const SizedBox(width: 8),
                        const Text('تقسيم الخلية'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        const Icon(Icons.edit, size: 20),
                        const SizedBox(width: 8),
                        Text(l10n.edit),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          body: Container(
            decoration: AppTheme.gradientDecoration,
            child: Column(
              children: [
                _buildHiveHeader(hive),
                _buildTabBar(),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildOverviewTab(hive),
                      _buildInspectionsTab(hive),
                      _buildTreatmentsTab(hive),
                      _buildProductionTab(hive),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHiveHeader(HiveModel hive) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _getStatusColor(hive.status),
            _getStatusColor(hive.status).withAlpha(204),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: _getStatusColor(hive.status).withAlpha(76),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(51),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(
                  _getHiveIcon(hive.isNucleus),
                  size: 35,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'خلية رقم ${hive.hiveNumber}',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      hive.statusDisplayName,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white.withAlpha(230),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(51),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  hive.typeDisplayName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildHeaderStat(
                  icon: Icons.layers,
                  label: 'الإطارات',
                  value: '${hive.frameCount}',
                ),
              ),
              Expanded(
                child: _buildHeaderStat(
                  icon: Icons.female,
                  label: 'الملكة',
                  value: hive.queenStatusDisplayName,
                ),
              ),
              Expanded(
                child: _buildHeaderStat(
                  icon: Icons.opacity,
                  label: 'الإنتاج',
                  value: 'N/A', // تحتاج إلى جلب هذه البيانات
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderStat({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Icon(
          icon,
          color: Colors.white,
          size: 24,
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.white.withAlpha(204),
          ),
        ),
      ],
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(12),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TabBar(
        controller: _tabController,
        labelColor: AppTheme.primaryYellow,
        unselectedLabelColor: Colors.grey,
        indicatorColor: AppTheme.primaryYellow,
        indicatorWeight: 3,
        labelStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
        tabs: const [
          Tab(text: 'نظرة عامة'),
          Tab(text: 'الفحوصات'),
          Tab(text: 'العلاجات'),
          Tab(text: 'الإنتاج'),
        ],
      ),
    );
  }

  Widget _buildOverviewTab(HiveModel hive) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoSection(hive),
          const SizedBox(height: 16),
          _buildLocationSection(hive),
          const SizedBox(height: 16),
          _buildQueenSection(hive),
          const SizedBox(height: 16),
          _buildFramesSection(hive),
          const SizedBox(height: 16),
          _buildRelationshipsSection(hive),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildInfoSection(HiveModel hive) {
    return _buildCard(
      title: 'معلومات عامة',
      child: Column(
        children: [
          _buildInfoRow('تاريخ التركيب', _formatDate(hive.createdDate)),
          _buildInfoRow('آخر فحص', _formatDate(hive.lastInspection)),
          _buildInfoRow('عدد الفحوصات', 'N/A'),
          _buildInfoRow('العلاجات النشطة', 'N/A'),
          if (hive.notes != null && hive.notes!.isNotEmpty)
            _buildInfoRow('الملاحظات', hive.notes!),
        ],
      ),
    );
  }

  Widget _buildLocationSection(HiveModel hive) {
    return _buildCard(
      title: 'الموقع',
      child: Column(
        children: [
          if (hive.location != null) _buildInfoRow('المنطقة', hive.location!),
          if (hive.latitude != null && hive.longitude != null)
            _buildInfoRow('الإحداثيات', '${hive.latitude}, ${hive.longitude}'),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            height: 50,
            decoration: BoxDecoration(
              color: AppTheme.primaryYellow.withAlpha(25),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.primaryYellow),
            ),
            child: InkWell(
              onTap: _openMap,
              borderRadius: BorderRadius.circular(12),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.map, color: AppTheme.primaryYellow),
                  SizedBox(width: 8),
                  Text(
                    'عرض على الخريطة',
                    style: TextStyle(
                      color: AppTheme.primaryYellow,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQueenSection(HiveModel hive) {
    return _buildCard(
      title: 'معلومات الملكة',
      child: Column(
        children: [
          _buildInfoRow('الحالة', hive.queenStatusDisplayName),
          _buildInfoRow('السلالة', hive.breedDisplayName),
        ],
      ),
    );
  }

  Widget _buildFramesSection(HiveModel hive) {
    return _buildCard(
      title: 'توزيع الإطارات',
      child: Column(
        children: [
          _buildFrameBar(
            label: 'إطارات العسل',
            count: hive.honeyFrames,
            total: hive.frameCount,
            color: AppTheme.honeyOrange,
          ),
          const SizedBox(height: 12),
          _buildFrameBar(
            label: 'إطارات الحضنة',
            count: hive.broodFrames,
            total: hive.frameCount,
            color: AppTheme.primaryYellow,
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'إجمالي الإطارات: ${hive.frameCount}',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.darkBrown,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFrameBar({
    required String label,
    required int count,
    required int total,
    required Color color,
  }) {
    final percentage = total > 0 ? count / total : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: AppTheme.darkBrown,
              ),
            ),
            Text(
              '$count من $total',
              style: TextStyle(
                color: AppTheme.darkBrown.withAlpha(178),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          height: 8,
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(4),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: percentage,
            child: Container(
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRelationshipsSection(HiveModel hive) {
    if (hive.parentHiveId == null) { // && children are not available directly
      return const SizedBox.shrink();
    }

    return _buildCard(
      title: 'العلاقات الأسرية',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (hive.parentHiveId != null) ...[
            const Text(
              'الخلية الأم:',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: AppTheme.darkBrown,
              ),
            ),
            const SizedBox(height: 8),
            _buildRelationshipChip(
              'خلية رقم ${hive.parentHiveId}',
              Icons.hive,
              AppTheme.primaryYellow,
            ),
            const SizedBox(height: 16),
          ],
        ],
      ),
    );
  }

  Widget _buildRelationshipChip(String label, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withAlpha(25),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withAlpha(76)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInspectionsTab(HiveModel hive) {
    return const Center(child: Text('قيد التطوير'));
  }

  Widget _buildTreatmentsTab(HiveModel hive) {
    return const Center(child: Text('قيد التطوير'));
  }

  Widget _buildProductionTab(HiveModel hive) {
    return const Center(child: Text('قيد التطوير'));
  }

  Widget _buildCard({
    required String title,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(12),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.darkBrown,
            ),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: AppTheme.darkBrown.withAlpha(178),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: AppTheme.darkBrown,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(HiveStatus status) {
    switch (status) {
      case HiveStatus.active:
        return AppTheme.successColor;
      case HiveStatus.weak:
        return Colors.orange;
      case HiveStatus.sick:
        return AppTheme.errorColor;
      default:
        return Colors.grey;
    }
  }

  IconData _getHiveIcon(bool isNucleus) {
    return isNucleus ? Icons.egg : Icons.hive;
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _handleMenuAction(String action, HiveModel hive) {
    // Handle actions
  }

  void _openMap() {
    // Handle map opening
  }
}
