import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/hive_model.dart';
import '../providers/hive_provider.dart';
import '../utils/app_theme.dart';
import '../l10n/app_localizations.dart';
import 'inspection_list_screen.dart';

// --- HiveOverviewTab ---
class HiveOverviewTab extends StatelessWidget {
  final HiveModel hive;
  const HiveOverviewTab({super.key, required this.hive});

  // داخل كلاس HiveOverviewTab
  @override
  Widget build(BuildContext context) {
    // --- *** هذا هو السطر الذي أضفته للتحقق *** ---
    print("--- بناء HiveOverviewTab ---");
    print("عدد الإطارات المستلم: ${hive.frameCount}");
    // --- *** نهاية سطر التحقق *** ---

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoSection(hive),
          const SizedBox(height: 24),
          _buildQueenSection(hive),
          const SizedBox(height: 24),
          _buildFramesSection(hive),
          const SizedBox(height: 24),
          _buildNotesSection(hive),
          const SizedBox(height: 24),
          _buildRelationshipsSection(hive),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildInfoSection(HiveModel hive) {
    return _buildCard(
      title: 'معلومات عامة',
      icon: Icons.info_outline,
      child: Column(
        children: [
          _buildInfoRow('تاريخ التركيب', _formatDate(hive.createdDate)),
          _buildInfoRow('آخر فحص', _formatDate(hive.lastInspection)),
          _buildInfoRow('عدد الفحوصات', 'N/A'),
          _buildInfoRow('العلاجات النشطة', 'N/A'),
        ],
      ),
    );
  }

  Widget _buildNotesSection(HiveModel hive) {
    if (hive.notes == null || hive.notes!.isEmpty) {
      return const SizedBox.shrink();
    }
    return _buildCard(
      title: 'الملاحظات',
      icon: Icons.note_alt_outlined,
      child: Text(
        hive.notes!,
        style: const TextStyle(
          fontSize: 16,
          color: AppTheme.darkBrown,
          height: 1.5,
        ),
      ),
    );
  }

  Widget _buildQueenSection(HiveModel hive) {
    return _buildCard(
      title: 'معلومات الملكة',
      icon: Icons.female,
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
      icon: Icons.layers,
      child: Column(
        children: [
          _buildFrameBar(
            label: 'إطارات الحضنة',
            count: hive.broodFrames,
            total: hive.frameCount,
            color: AppTheme.primaryYellow,
          ),
          const SizedBox(height: 16),
          _buildFrameBar(
            label: 'إطارات العسل',
            count: hive.honeyFrames,
            total: hive.frameCount,
            color: AppTheme.honeyOrange,
          ),
          const SizedBox(height: 16),
          _buildFrameBar(
            label: 'إطارات حبوب اللقاح',
            count: hive.pollenFrames,
            total: hive.frameCount,
            color: Colors.green,
          ),
          const SizedBox(height: 16),
          _buildFrameBar(
            label: 'إطارات فارغة',
            count: hive.emptyFrames,
            total: hive.frameCount,
            color: Colors.grey.shade400,
          ),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'إجمالي الإطارات',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.darkBrown,
                ),
              ),
              Text(
                '${hive.frameCount}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
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
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppTheme.darkBrown,
              ),
            ),
            Text(
              '$count',
              style: TextStyle(
                fontSize: 16,
                color: AppTheme.darkBrown.withAlpha(178),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: percentage,
            minHeight: 12,
            backgroundColor: Colors.grey.shade300,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildRelationshipsSection(HiveModel hive) {
    if (hive.parentHiveId == null) {
      return const SizedBox.shrink();
    }
    return _buildCard(
      title: 'العلاقات الأسرية',
      icon: Icons.family_restroom,
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
          Icon(icon, size: 20, color: color),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Card(
      elevation: 8,
      shadowColor: Colors.black.withAlpha(128),
      color: Colors.white.withAlpha(217),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: AppTheme.darkBrown, size: 24),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.darkBrown,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            child,
          ],
        ),
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
            width: 140,
            child: Text(
              '$label:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppTheme.darkBrown.withAlpha(178),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                color: AppTheme.darkBrown,
              ),
              softWrap: true,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

// --- HiveTreatmentsTab & HiveProductionTab ---
class HiveTreatmentsTab extends StatelessWidget {
  final HiveModel hive;
  const HiveTreatmentsTab({super.key, required this.hive});
  @override
  Widget build(BuildContext context) => Center(child: Text('علاجات الخلية: ${hive.hiveNumber}'));
}

class HiveProductionTab extends StatelessWidget {
  final HiveModel hive;
  const HiveProductionTab({super.key, required this.hive});
  @override
  Widget build(BuildContext context) => Center(child: Text('إنتاج الخلية: ${hive.hiveNumber}'));
}

// --- HiveDetailsScreen ---
class HiveDetailsScreen extends StatefulWidget {
  final String hiveId;
  final String activeTabId;
  final Function(String, HiveModel) onActionSelected;

  const HiveDetailsScreen({
    super.key,
    required this.hiveId,
    required this.activeTabId,
    required this.onActionSelected,
  });

  @override
  State<HiveDetailsScreen> createState() => _HiveDetailsScreenState();
}

class _HiveDetailsScreenState extends State<HiveDetailsScreen> {

  // --- *** هذه هي دالة build الصحيحة التي يجب أن تكون لديك *** ---
  @override
  Widget build(BuildContext context) {
    return Consumer<HiveProvider>(
      builder: (context, hiveProvider, child) {
        final HiveModel? hive = hiveProvider.getHiveById(widget.hiveId);

        if (hive == null) {
          return const Center(
            child: CircularProgressIndicator(color: AppTheme.primaryYellow),
          );
        }

        return Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/images/honey_background.png"),
              fit: BoxFit.cover,
            ),
          ),
          child: Stack(
            children: [
              NestedScrollView(
                headerSliverBuilder: (context, innerBoxIsScrolled) {
                  return [
                    SliverToBoxAdapter(
                      child: _buildHiveHeader(hive),
                    ),
                  ];
                },
                body: IndexedStack(
                  index: _getTabIndex(widget.activeTabId),
                  children: [
                    HiveOverviewTab(hive: hive),
                    InspectionListScreen(hiveId: hive.id),
                    HiveTreatmentsTab(hive: hive),
                    HiveProductionTab(hive: hive),
                  ],
                ),
              ),
              Positioned(
                top: 0,
                left: 0,
                child: SafeArea(
                  child: PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert, color: Colors.white),
                    onSelected: (action) => widget.onActionSelected(action, hive),
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'inspect',
                        child: Row(
                          children: [
                            const Icon(Icons.search, size: 20),
                            const SizedBox(width: 8),
                            Text(AppLocalizations.of(context)!.add_inspection),
                          ],
                        ),
                      ),
                      // ... other menu items
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  int _getTabIndex(String tabId) {
    switch (tabId) {
      case 'overview':
        return 0;
      case 'inspections':
        return 1;
      case 'treatments':
        return 2;
      case 'production':
        return 3;
      default:
        return 0;
    }
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
                      '${hive.isNucleus ? 'طرد' : 'خلية'} رقم ${hive.hiveNumber}',
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
                  value: 'N/A',
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
}
