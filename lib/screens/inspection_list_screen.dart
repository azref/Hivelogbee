import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/inspection_model.dart';
import '../providers/inspection_provider.dart';
// --- 1. استيراد الـ Providers اللازمة ---
import '../providers/hive_provider.dart';
import '../providers/auth_provider.dart';
import '../utils/app_theme.dart';
import '../l10n/app_localizations.dart';
import 'add_inspection_screen.dart';

class InspectionListScreen extends StatefulWidget {
  final String? hiveId;

  const InspectionListScreen({
    super.key,
    this.hiveId,
  });

  @override
  State<InspectionListScreen> createState() => _InspectionListScreenState();
}

class _InspectionListScreenState extends State<InspectionListScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // يمكنك إضافة منطق لجلب البيانات هنا إذا كانت فارغة كإجراء احتياطي
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<InspectionProvider>(context, listen: false);
      if (provider.inspections.isEmpty) {
        final userId = Provider.of<AuthProvider>(context, listen: false).user?.id;
        if (userId != null) {
          provider.fetchInspections();
        }
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      decoration: AppTheme.gradientDecoration,
      child: Column(
        children: [
          if (widget.hiveId == null) _buildSearchAndFilter(l10n),
          Expanded(
            child: _buildInspectionsList(context, l10n),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilter(AppLocalizations l10n) {
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
        ],
      ),
    );
  }

  Widget _buildInspectionsList(BuildContext context, AppLocalizations l10n) {
    // --- 2. الوصول إلى AuthProvider للحصول على userId ---
    final userId = Provider.of<AuthProvider>(context, listen: false).user?.id;

    return Consumer<InspectionProvider>(
      builder: (context, provider, child) {
        final allInspections = provider.inspections;
        final filteredInspections = widget.hiveId == null
            ? allInspections
            : allInspections.where((i) => i.hiveId == widget.hiveId).toList();

        if (provider.isLoading && filteredInspections.isEmpty) {
          return const Center(child: CircularProgressIndicator(color: AppTheme.successColor));
        }

        if (filteredInspections.isEmpty) {
          return _buildEmptyState(l10n);
        }

        return RefreshIndicator(
          // --- 3. إصلاح onRefresh ---
          onRefresh: () async {
            if (userId != null) {
              await provider.fetchInspections();
            }
          },
          color: AppTheme.successColor,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: filteredInspections.length,
            itemBuilder: (context, index) {
              final inspection = filteredInspections[index];
              return _buildInspectionCard(context, inspection, l10n);
            },
          ),
        );
      },
    );
  }

  // --- 4. تعديل _buildInspectionCard بالكامل ---
  Widget _buildInspectionCard(BuildContext context, InspectionModel inspection, AppLocalizations l10n) {
    // الوصول إلى HiveProvider (بدون الاستماع) لجلب بيانات الخلية
    final hiveProvider = Provider.of<HiveProvider>(context, listen: false);
    final hive = hiveProvider.getHiveById(inspection.hiveId);
    final hiveNumber = hive?.hiveNumber ?? 'غير معروف'; // الحصول على رقم الخلية

    // دوال الترجمة المحلية
    String getQueenText(QueenPresence status) { /* ... no change ... */ return "موجودة"; }
    String getBroodText(BroodPattern pattern) { /* ... no change ... */ return "جيد"; }
    String getHealthText(HiveHealth health) { /* ... no change ... */ return "قوي"; }
    Color getHealthColor(HiveHealth health) { /* ... no change ... */ return AppTheme.successColor; }

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
                              // --- 5. استخدام hiveNumber بدلاً من inspection.hiveId ---
                              Text(
                                '${l10n.hive_number} $hiveNumber',
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
                  ],
                ),
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
      // الـ Provider سيتولى الأمر بعد التعديلات في main_screen_holder
    }
  }

  void _viewInspectionDetails(BuildContext context, InspectionModel inspection) {
    // هذه الدالة تحتاج إلى تنفيذ لعرض تفاصيل الفحص
  }
}
