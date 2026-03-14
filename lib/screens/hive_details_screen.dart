import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/hive_model.dart';
import '../models/inspection_model.dart';
import '../providers/hive_provider.dart';
import '../providers/inspection_provider.dart';
import '../utils/app_theme.dart';
import '../l10n/app_localizations.dart';
import 'inspection_list_screen.dart';

// --- HiveOverviewTab ---
class HiveOverviewTab extends StatelessWidget {
  final HiveModel hive;
  final InspectionModel? latestInspection;
  final List<InspectionModel> inspections;

  const HiveOverviewTab({
    super.key,
    required this.hive,
    this.latestInspection,
    required this.inspections,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoSection(context, hive, latestInspection, inspections),
          const SizedBox(height: 24),
          _buildQueenSection(context, hive, latestInspection),
          const SizedBox(height: 24),
          _buildFramesSection(hive, latestInspection),
          const SizedBox(height: 24),
          _buildNotesSection(hive, latestInspection),
          const SizedBox(height: 24),
          if (latestInspection != null &&
              (latestInspection!.temperature != null || latestInspection!.humidity != null))
            _buildEnvironmentalSection(context, latestInspection!),
          if (latestInspection != null &&
              (latestInspection!.temperature != null || latestInspection!.humidity != null))
            const SizedBox(height: 24),
          _buildActionsSection(context, latestInspection),
          const SizedBox(height: 24),
          _buildIssuesSection(context, latestInspection),
          const SizedBox(height: 24),
          _buildRelationshipsSection(hive),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildInfoSection(BuildContext context, HiveModel hive, InspectionModel? latestInspection, List<InspectionModel> inspections) {
    final l10n = AppLocalizations.of(context)!;
    return _buildCard(
      title: 'معلومات عامة',
      icon: Icons.info_outline,
      child: Column(
        children: [
          _buildInfoRow(l10n.installation_date, _formatDate(hive.createdDate)),
          _buildInfoRow('آخر فحص', latestInspection != null ? _formatDate(latestInspection.date) : 'لا يوجد'),
          _buildInfoRow('عدد الفحوصات', inspections.length.toString()),
          _buildInfoRow('العلاجات النشطة', 'N/A'),
        ],
      ),
    );
  }
  Widget _buildNotesSection(HiveModel hive, InspectionModel? inspection) {
    final notes = inspection?.notes != null && inspection!.notes!.isNotEmpty
        ? inspection.notes
        : hive.notes;
    if (notes == null || notes.isEmpty) return const SizedBox.shrink();
    return _buildCard(
      title: 'الملاحظات',
      icon: Icons.note_alt_outlined,
      child: Text(notes, style: const TextStyle(fontSize: 16, color: AppTheme.darkBrown, height: 1.5)),
    );
  }
  Widget _buildQueenSection(BuildContext context, HiveModel hive, InspectionModel? inspection) {
    final l10n = AppLocalizations.of(context)!;
    final queenPresence = inspection?.queenPresence;
    final queenStatusText = queenPresence != null
        ? _getTranslatedQueenPresence(queenPresence, l10n)
        : hive.queenStatusDisplayName;

    return _buildCard(
      title: 'معلومات الملكة',
      icon: Icons.female,
      child: Column(
        children: [
          _buildInfoRow('الحالة', queenStatusText),
          _buildInfoRow(l10n.bee_breed, hive.breedDisplayName),
        ],
      ),
    );
  }

  Widget _buildFramesSection(HiveModel hive, InspectionModel? inspection) {
    final broodFrames = inspection?.broodFrames ?? hive.broodFrames;
    final honeyFrames = inspection?.honeyFrames ?? hive.honeyFrames;
    final pollenFrames = inspection?.pollenFrames ?? hive.pollenFrames;
    final emptyFrames = inspection?.emptyFrames ?? hive.emptyFrames;

    // قراءة الحقلين مباشرة من inspection
    int foundationFrames = inspection?.foundationFrames ?? 0;
    int drawnFrames = inspection?.drawnFrames ?? 0;

    // إذا لم تكن القيم موجودة في النموذج، نبحث في الإجراءات (للتوافق مع البيانات القديمة)
    if (inspection != null && inspection.actions.isNotEmpty && foundationFrames == 0 && drawnFrames == 0) {
      for (var action in inspection.actions) {
        if (action['action'] == 'add_frames') {
          if (action['type'] == 'foundation') {
            foundationFrames += (action['count'] as num).toInt();
          } else if (action['type'] == 'drawn') {
            drawnFrames += (action['count'] as num).toInt();
          }
        }
      }
    }

    final totalFrames = broodFrames + honeyFrames + pollenFrames + emptyFrames + foundationFrames + drawnFrames;

    return _buildCard(
      title: 'توزيع الإطارات',
      icon: Icons.layers,
      child: Column(
        children: [
          _buildFrameBar(label: 'حضنة', count: broodFrames, total: totalFrames, color: AppTheme.primaryYellow),
          const SizedBox(height: 12),
          _buildFrameBar(label: 'عسل', count: honeyFrames, total: totalFrames, color: AppTheme.honeyOrange),
          const SizedBox(height: 12),
          _buildFrameBar(label: 'حبوب لقاح', count: pollenFrames, total: totalFrames, color: Colors.green),
          const SizedBox(height: 12),
          _buildFrameBar(label: 'فارغة', count: emptyFrames, total: totalFrames, color: Colors.grey.shade400),
          if (foundationFrames > 0) ...[
            const SizedBox(height: 12),
            _buildFrameBar(label: 'شمع أساس', count: foundationFrames, total: totalFrames, color: Colors.blueGrey),
          ],
          if (drawnFrames > 0) ...[
            const SizedBox(height: 12),
            _buildFrameBar(label: 'شمع ممطوط', count: drawnFrames, total: totalFrames, color: Colors.brown.shade300),
          ],
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('إجمالي الإطارات', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.darkBrown)),
              Text('$totalFrames', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.darkBrown)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEnvironmentalSection(BuildContext context, InspectionModel inspection) {
    return _buildCard(
      title: 'البيانات البيئية',
      icon: Icons.thermostat,
      child: Row(
        children: [
          if (inspection.temperature != null)
            Expanded(
              child: Column(
                children: [
                  Icon(Icons.thermostat, color: Colors.orange.shade700, size: 28),
                  const SizedBox(height: 8),
                  Text('${inspection.temperature!.round()}°C',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const Text('درجة الحرارة', style: TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),
            ),
          if (inspection.temperature != null && inspection.humidity != null)
            const SizedBox(width: 16),
          if (inspection.humidity != null)
            Expanded(
              child: Column(
                children: [
                  Icon(Icons.water_drop, color: Colors.blue.shade700, size: 28),
                  const SizedBox(height: 8),
                  Text('${inspection.humidity!.round()}%',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const Text('الرطوبة', style: TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildActionsSection(BuildContext context, InspectionModel? inspection) {
    if (inspection == null || inspection.actions.isEmpty) {
      return const SizedBox.shrink();
    }
    return _buildCard(
      title: 'الإجراءات المتخذة',
      icon: Icons.build,
      child: Wrap(
        spacing: 8.0,
        runSpacing: 8.0,
        children: inspection.actions.map((action) => Chip(
          label: Text(
            _getActionText(action),
            style: const TextStyle(fontSize: 12, fontFamily: 'Cairo'),
          ),
          backgroundColor: AppTheme.primaryYellow.withAlpha(30),
        )).toList(),
      ),
    );
  }

  Widget _buildIssuesSection(BuildContext context, InspectionModel? inspection) {
    if (inspection == null || inspection.issues.isEmpty) {
      return const SizedBox.shrink();
    }
    final l10n = AppLocalizations.of(context)!;
    return _buildCard(
      title: 'المشاكل المكتشفة',
      icon: Icons.warning_amber_rounded,
      child: Wrap(
        spacing: 8.0,
        runSpacing: 8.0,
        children: inspection.issues.map((issue) => Chip(label: Text(_getIssueText(issue, l10n), style: const TextStyle(fontSize: 12)), backgroundColor: AppTheme.errorColor.withAlpha(50))).toList(),
      ),
    );
  }

  Widget _buildFrameBar({required String label, required int count, required int total, required Color color}) {
    final percentage = total > 0 ? count / total : 0.0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppTheme.darkBrown)),
            Text('$count', style: TextStyle(fontSize: 15, color: AppTheme.darkBrown.withAlpha(178))),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(value: percentage, minHeight: 10, backgroundColor: Colors.grey.shade300, color: color),
        ),
      ],
    );
  }

  Widget _buildRelationshipsSection(HiveModel hive) {
    if (hive.parentHiveId == null) return const SizedBox.shrink();
    return _buildCard(
      title: 'العلاقات الأسرية',
      icon: Icons.family_restroom,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('الخلية الأم:', style: TextStyle(fontWeight: FontWeight.w600, color: AppTheme.darkBrown)),
          const SizedBox(height: 8),
          _buildRelationshipChip('خلية رقم ${hive.parentHiveId}', Icons.hive, AppTheme.primaryYellow),
        ],
      ),
    );
  }

  Widget _buildRelationshipChip(String label, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(color: color.withAlpha(25), borderRadius: BorderRadius.circular(12), border: Border.all(color: color.withAlpha(76))),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: 8),
          Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildCard({required String title, required IconData icon, required Widget child}) {
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
                Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.darkBrown)),
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
            child: Text('$label:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppTheme.darkBrown.withAlpha(178))),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(fontSize: 16, color: AppTheme.darkBrown), softWrap: true),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _getTranslatedQueenPresence(QueenPresence status, AppLocalizations l10n) {
    switch (status) {
      case QueenPresence.present: return "موجودة";
      case QueenPresence.absent: return "غائبة";
      case QueenPresence.newQueen: return "ملكة جديدة";
      case QueenPresence.unseen: return "لم يتم رؤيتها";
    }
  }

  String _getActionText(Map<String, dynamic> action) {
    switch (action['action']) {
      case 'add_frames':
        String type = action['type'] == 'foundation' ? 'أساس' : 'ممطوط';
        return 'أضاف ${action['count']} إطارات ($type)';
      case 'add_feeding': return 'أضاف تغذية ${action['type'] == 'sugar' ? 'سكري' : 'بروتين'}';
      case 'add_super': return 'أضاف عاسلة';
      case 'remove_super': return 'أزال عاسلة';
      case 'add_queen_excluder': return 'أضاف حاجز ملكي';
      case 'remove_queen_excluder': return 'أزال حاجز ملكي';
      case 'replace_queen': return 'استبدل الملكة';
      case 'set_entrance': return 'ضبط المدخل';
      default: return action['action'].toString();
    }
  }

  String _getIssueText(InspectionIssue issue, AppLocalizations l10n) {
    switch (issue) {
      case InspectionIssue.varroa: return "فاروا";
      case InspectionIssue.nosema: return "نوزيما";
      case InspectionIssue.chalkbrood: return "حضنة طباشيرية";
      case InspectionIssue.foulbrood: return "تعفن الحضنة";
      case InspectionIssue.queenless: return "بدون ملكة";
      case InspectionIssue.swarming: return "تطريد";
      case InspectionIssue.smallHiveBeetle: return "خنفساء الخلية";
      case InspectionIssue.waxMoth: return "عثة الشمع";
      default: return issue.name;
    }
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

  @override
  Widget build(BuildContext context) {
    return Consumer2<HiveProvider, InspectionProvider>(
      builder: (context, hiveProvider, inspectionProvider, child) {
        final HiveModel? hive = hiveProvider.getHiveById(widget.hiveId);

        if (hive == null) {
          return const Center(child: CircularProgressIndicator(color: AppTheme.primaryYellow));
        }

        final hiveInspections = inspectionProvider.getInspectionsByHive(widget.hiveId);
        final InspectionModel? latestInspection = hiveInspections.isNotEmpty ? hiveInspections.first : null;

        return Container(
          decoration: const BoxDecoration(
            image: DecorationImage(image: AssetImage("assets/images/honey_background.png"), fit: BoxFit.cover),
          ),
          child: Stack(
            children: [
              NestedScrollView(
                headerSliverBuilder: (context, innerBoxIsScrolled) {
                  return [
                    SliverToBoxAdapter(
                      child: _buildHiveHeader(hive, latestInspection),
                    ),
                  ];
                },
                body: IndexedStack(
                  index: _getTabIndex(widget.activeTabId),
                  children: [
                    HiveOverviewTab(
                      hive: hive,
                      latestInspection: latestInspection,
                      inspections: hiveInspections,
                    ),
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
                        child: Row(children: [const Icon(Icons.search, size: 20), const SizedBox(width: 8), Text(AppLocalizations.of(context)!.add_inspection)]),
                      ),
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
      case 'overview': return 0;
      case 'inspections': return 1;
      case 'treatments': return 2;
      case 'production': return 3;
      default: return 0;
    }
  }

  Widget _buildHiveHeader(HiveModel hive, InspectionModel? inspection) {
    final l10n = AppLocalizations.of(context)!;
    final statusText = inspection != null ? _getTranslatedHiveHealth(inspection.hiveHealth, l10n) : hive.statusDisplayName;
    final statusColor = _getStatusColor(inspection?.hiveHealth, hive.status);

    // حساب الإجمالي في الهيدر ليشمل الحقول الجديدة أيضاً
    int foundation = 0;
    int drawn = 0;
    if (inspection != null) {
      // قراءة القيم مباشرة من inspection أولاً
      foundation = inspection.foundationFrames;
      drawn = inspection.drawnFrames;

      // إذا كانت القيم صفراً، نبحث في الإجراءات (للتوافق)
      if (foundation == 0 && drawn == 0) {
        for (var a in inspection.actions) {
          if (a['action'] == 'add_frames') {
            if (a['type'] == 'foundation') foundation += (a['count'] as num).toInt();
            else if (a['type'] == 'drawn') drawn += (a['count'] as num).toInt();
          }
        }
      }
    }

    final totalFrames = (inspection?.broodFrames ?? hive.broodFrames) +
        (inspection?.honeyFrames ?? hive.honeyFrames) +
        (inspection?.pollenFrames ?? hive.pollenFrames) +
        (inspection?.emptyFrames ?? hive.emptyFrames) + foundation + drawn;

    final queenStatusText = inspection != null ? _getTranslatedQueenPresence(inspection.queenPresence, l10n) : hive.queenStatusDisplayName;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [statusColor, statusColor.withAlpha(204)], begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: statusColor.withAlpha(76), blurRadius: 15, offset: const Offset(0, 8))],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 60, height: 60,
                decoration: BoxDecoration(color: Colors.white.withAlpha(51), borderRadius: BorderRadius.circular(15)),
                child: Icon(_getHiveIcon(hive.isNucleus), size: 35, color: Colors.white),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${hive.isNucleus ? 'طرد' : 'خلية'} رقم ${hive.hiveNumber}', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
                    const SizedBox(height: 4),
                    Text(statusText, style: TextStyle(fontSize: 16, color: Colors.white.withAlpha(230))),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: Colors.white.withAlpha(51), borderRadius: BorderRadius.circular(12)),
                child: Text(hive.typeDisplayName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(child: _buildHeaderStat(icon: Icons.layers, label: 'الإطارات', value: '$totalFrames')),
              Expanded(child: _buildHeaderStat(icon: Icons.female, label: 'الملكة', value: queenStatusText)),
              Expanded(child: _buildHeaderStat(icon: Icons.opacity, label: 'الإنتاج', value: 'N/A')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderStat({required IconData icon, required String label, required String value}) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 24),
        const SizedBox(height: 8),
        Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.white.withAlpha(204))),
      ],
    );
  }

  Color _getStatusColor(HiveHealth? inspectionHealth, HiveStatus hiveStatus) {
    if (inspectionHealth != null) {
      switch (inspectionHealth) {
        case HiveHealth.strong: return AppTheme.successColor;
        case HiveHealth.average: return AppTheme.primaryYellow;
        case HiveHealth.weak: return AppTheme.errorColor;
      }
    }
    switch (hiveStatus) {
      case HiveStatus.active: return AppTheme.successColor;
      case HiveStatus.weak: return Colors.orange;
      case HiveStatus.sick: return AppTheme.errorColor;
      default: return Colors.grey;
    }
  }

  IconData _getHiveIcon(bool isNucleus) {
    return isNucleus ? Icons.egg : Icons.hive;
  }

  String _getTranslatedQueenPresence(QueenPresence status, AppLocalizations l10n) {
    switch (status) {
      case QueenPresence.present: return "موجودة";
      case QueenPresence.absent: return "غائبة";
      case QueenPresence.newQueen: return "ملكة جديدة";
      case QueenPresence.unseen: return "لم يتم رؤيتها";
    }
  }

  String _getTranslatedHiveHealth(HiveHealth health, AppLocalizations l10n) {
    switch (health) {
      case HiveHealth.strong: return "قوي";
      case HiveHealth.average: return "متوسط";
      case HiveHealth.weak: return "ضعيف";
    }
  }
}