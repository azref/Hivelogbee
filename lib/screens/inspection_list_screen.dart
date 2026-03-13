import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/inspection_model.dart'; // استيراد النموذج الحقيقي
import '../providers/inspection_provider.dart'; // استيراد الـ Provider
import '../utils/app_theme.dart';
import '../l10n/app_localizations.dart';
import 'add_inspection_screen.dart';

class InspectionListScreen extends StatefulWidget {
  // --- 1. إضافة hiveId الاختياري ---
  final String? hiveId;

  const InspectionListScreen({
    super.key,
    this.hiveId, // جعله اختياريًا
  });

  @override
  State<InspectionListScreen> createState() => _InspectionListScreenState();
}

class _InspectionListScreenState extends State<InspectionListScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // لا حاجة لـ AdManager هنا بعد الآن
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    // --- 2. إزالة Scaffold و AppBar ---
    // الشاشة الآن عبارة عن Column بسيط
    return Container(
      decoration: AppTheme.gradientDecoration,
      child: Column(
        children: [
          // إذا لم يتم تمرير hiveId، نعرض حقل البحث والفلاتر
          if (widget.hiveId == null) _buildSearchAndFilter(l10n),
          Expanded(
            child: _buildInspectionsList(context, l10n),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilter(AppLocalizations l10n) {
    // ... (هذه الدالة تبقى كما هي)
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: '${l10n.search}...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  _searchController.clear();
                  Provider.of<InspectionProvider>(context, listen: false).setSearchQuery('');
                },
              )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Colors.white,
            ),
            onChanged: (value) {
              Provider.of<InspectionProvider>(context, listen: false).setSearchQuery(value);
            },
          ),
          const SizedBox(height: 12),
          // ... (كود الفلاتر يبقى كما هو)
        ],
      ),
    );
  }

  // --- 3. تعديل _buildInspectionsList ليعمل مع Provider ---
  Widget _buildInspectionsList(BuildContext context, AppLocalizations l10n) {
    return Consumer<InspectionProvider>(
      builder: (context, provider, child) {
        // 4. الحصول على قائمة الفحوصات المفلترة
        final allInspections = provider.inspections;
        final filteredInspections = widget.hiveId == null
            ? allInspections // إذا كنا في الشاشة العامة، اعرض الكل
            : allInspections.where((i) => i.hiveId == widget.hiveId).toList(); // إذا كنا في التفاصيل، قم بالفلترة

        if (provider.isLoading && filteredInspections.isEmpty) {
          return const Center(child: CircularProgressIndicator(color: AppTheme.successColor));
        }

        if (filteredInspections.isEmpty) {
          return _buildEmptyState(l10n);
        }

        return RefreshIndicator(
          onRefresh: () => provider.refreshInspections(provider.inspections.first.userId), // يحتاج إلى userId
          color: AppTheme.successColor,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: filteredInspections.length,
            itemBuilder: (context, index) {
              final inspection = filteredInspections[index];
              // 5. استدعاء دالة بناء البطاقة الجديدة
              return _buildInspectionCard(context, inspection, l10n);
            },
          ),
        );
      },
    );
  }

  // --- 6. تعديل _buildInspectionCard ليعمل مع InspectionModel ---
  Widget _buildInspectionCard(BuildContext context, InspectionModel inspection, AppLocalizations l10n) {
    // دوال الترجمة المحلية
    String getQueenText(QueenPresence status) {
      switch (status) {
        case QueenPresence.present: return "موجودة";
        case QueenPresence.absent: return "غائبة";
        case QueenPresence.newQueen: return "جديدة";
        case QueenPresence.unseen: return "لم تر";
      }
    }

    String getBroodText(BroodPattern pattern) {
      switch (pattern) {
        case BroodPattern.good: return "جيد";
        case BroodPattern.spotty: return "متقطع";
        case BroodPattern.poor: return "ضعيف";
        case BroodPattern.none: return "لا يوجد";
      }
    }

    String getHealthText(HiveHealth health) {
      switch (health) {
        case HiveHealth.strong: return "قوي";
        case HiveHealth.average: return "متوسط";
        case HiveHealth.weak: return "ضعيف";
      }
    }

    Color getHealthColor(HiveHealth health) {
      switch (health) {
        case HiveHealth.strong: return AppTheme.successColor;
        case HiveHealth.average: return AppTheme.primaryYellow;
        case HiveHealth.weak: return AppTheme.errorColor;
      }
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Card(
        elevation: 4,
        shadowColor: Colors.black12,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: InkWell(
          onTap: () => _viewInspectionDetails(context, inspection),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: getHealthColor(inspection.hiveHealth).withAlpha(25),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.search,
                        color: getHealthColor(inspection.hiveHealth),
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                '${l10n.hive_number} ${inspection.hiveId}', // عرض معرف الخلية
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.darkBrown,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: getHealthColor(inspection.hiveHealth).withAlpha(25),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  getHealthText(inspection.hiveHealth),
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: getHealthColor(inspection.hiveHealth),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _formatDate(inspection.date),
                            style: TextStyle(
                              fontSize: 14,
                              color: AppTheme.darkBrown.withAlpha(153),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // ... (كود PopupMenuButton يبقى كما هو)
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _buildStatusChip(
                      icon: Icons.female,
                      label: getQueenText(inspection.queenPresence),
                      color: inspection.queenPresence == QueenPresence.present ? AppTheme.successColor : AppTheme.errorColor,
                    ),
                    const SizedBox(width: 8),
                    _buildStatusChip(
                      icon: Icons.child_care,
                      label: getBroodText(inspection.broodPattern),
                      color: inspection.broodPattern == BroodPattern.good ? AppTheme.successColor : AppTheme.warningColor,
                    ),
                    // ... (يمكن إضافة المزيد من الـ Chips هنا)
                  ],
                ),
                if (inspection.notes != null && inspection.notes!.isNotEmpty) ...[
                  // ... (كود عرض الملاحظات يبقى كما هو)
                ],
                if (inspection.issues.isNotEmpty) ...[
                  // ... (كود عرض المشاكل يبقى كما هو)
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }


  Widget _buildStatusChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    // ... (هذه الدالة تبقى كما هي)
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(25),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(AppLocalizations l10n) {
    // ... (هذه الدالة تبقى كما هي)
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search,
            size: 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'لا توجد فحوصات بعد',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'ابدأ بإضافة فحص جديد لخلاياك',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _navigateToAddInspection(context),
            icon: const Icon(Icons.add),
            label: Text(l10n.add_inspection),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.successColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _navigateToAddInspection(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddInspectionScreen(hiveId: widget.hiveId),
      ),
    );

    if (result == true && mounted) {
      // لا حاجة لـ setState هنا، الـ Provider سيتولى الأمر
    }
  }

  void _viewInspectionDetails(BuildContext context, InspectionModel inspection) {
    // ... (هذه الدالة تحتاج إلى تحديث لتعرض التفاصيل من النموذج الحقيقي)
  }
}
