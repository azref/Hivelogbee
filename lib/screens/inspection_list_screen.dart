import 'package:flutter/material.dart';
import '../utils/app_theme.dart';
import '../services/ad_service.dart';
import '../widgets/custom_app_bar.dart';
import '../l10n/app_localizations.dart';
import 'add_inspection_screen.dart';

class InspectionListScreen extends StatefulWidget {
  const InspectionListScreen({super.key});

  @override
  State<InspectionListScreen> createState() => _InspectionListScreenState();
}

class _InspectionListScreenState extends State<InspectionListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedFilter = 'all';
  final String _sortBy = 'date'; // Changed to final

  @override
  void initState() {
    super.initState();
    AdManager.onScreenChange(AdScreen.inspectionList, AdScreen.home);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return AdAwareScaffold(
      screen: AdScreen.inspectionList,
      appBar: CustomAppBar(
        title: l10n.inspections,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToAddInspection(),
        backgroundColor: AppTheme.successColor,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
      body: Container(
        decoration: AppTheme.gradientDecoration,
        child: Column(
          children: [
            _buildSearchAndFilter(l10n),
            Expanded(
              child: _buildInspectionsList(l10n),
            ),
          ],
        ),
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
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  _searchController.clear();
                  setState(() {
                    _searchQuery = '';
                  });
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
              setState(() {
                _searchQuery = value;
              });
            },
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildFilterChip(
                  label: 'الكل',
                  value: 'all',
                  isSelected: _selectedFilter == 'all',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildFilterChip(
                  label: 'هذا الأسبوع',
                  value: 'week',
                  isSelected: _selectedFilter == 'week',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildFilterChip(
                  label: 'هذا الشهر',
                  value: 'month',
                  isSelected: _selectedFilter == 'month',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildFilterChip(
                  label: 'مشاكل',
                  value: 'issues',
                  isSelected: _selectedFilter == 'issues',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required String value,
    required bool isSelected,
  }) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilter = value;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.successColor : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppTheme.successColor : Colors.grey.shade300,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey.shade600,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            fontSize: 12,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildInspectionsList(AppLocalizations l10n) {
    final mockInspections = _getMockInspections();
    final filteredInspections = _filterInspections(mockInspections);

    if (filteredInspections.isEmpty) {
      return _buildEmptyState(l10n);
    }

    return RefreshIndicator(
      onRefresh: _refreshInspections,
      color: AppTheme.successColor,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: filteredInspections.length,
        itemBuilder: (context, index) {
          final inspection = filteredInspections[index];
          return _buildInspectionCard(inspection, l10n);
        },
      ),
    );
  }

  Widget _buildInspectionCard(Map<String, dynamic> inspection, AppLocalizations l10n) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Card(
        elevation: 4,
        shadowColor: Colors.black12,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: InkWell(
          onTap: () => _viewInspectionDetails(inspection),
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
                        color: _getOverallStatusColor(inspection['overallStatus']).withAlpha(25), // Adjusted for opacity
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.search,
                        color: _getOverallStatusColor(inspection['overallStatus']),
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
                                'خلية رقم ${inspection['hiveNumber']}',
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
                                  color: _getOverallStatusColor(inspection['overallStatus']).withAlpha(25), // Adjusted for opacity
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  _getOverallStatusText(inspection['overallStatus']),
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: _getOverallStatusColor(inspection['overallStatus']),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _formatDate(inspection['date']),
                            style: TextStyle(
                              fontSize: 14,
                              color: AppTheme.darkBrown.withAlpha(153), // Adjusted for opacity
                            ),
                          ),
                        ],
                      ),
                    ),
                    PopupMenuButton<String>(
                      onSelected: (value) => _handleMenuAction(value, inspection),
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          value: 'view',
                          child: Row(
                            children: [
                              const Icon(Icons.visibility, size: 20),
                              const SizedBox(width: 8),
                              Text(l10n.viewDetails), // Corrected to viewDetails
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
                        PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              const Icon(Icons.delete, size: 20, color: Colors.red),
                              const SizedBox(width: 8),
                              Text(l10n.delete, style: const TextStyle(color: Colors.red)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _buildStatusChip(
                      icon: Icons.female,
                      label: _getQueenStatusText(inspection['queenStatus']),
                      color: _getQueenStatusColor(inspection['queenStatus']),
                    ),
                    const SizedBox(width: 8),
                    _buildStatusChip(
                      icon: Icons.child_care,
                      label: _getBroodStatusText(inspection['broodStatus']),
                      color: _getBroodStatusColor(inspection['broodStatus']),
                    ),
                    const SizedBox(width: 8),
                    _buildStatusChip(
                      icon: Icons.thermostat,
                      label: '${inspection['temperature']}°م',
                      color: Colors.blue,
                    ),
                  ],
                ),
                if (inspection['notes'] != null && inspection['notes'].isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.note,
                          size: 16,
                          color: Colors.grey.shade600,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            inspection['notes'],
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                if (inspection['issues'] != null && (inspection['issues'] as List).isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.errorColor.withAlpha(25), // Adjusted for opacity
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppTheme.errorColor.withAlpha(76)), // Adjusted for opacity
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.warning,
                          size: 16,
                          color: AppTheme.errorColor,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'مشاكل: ${(inspection['issues'] as List).join(', ')}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppTheme.errorColor,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(25), // Adjusted for opacity
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
            onPressed: () => _navigateToAddInspection(),
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

  List<Map<String, dynamic>> _getMockInspections() {
    return [
      {
        'id': '1',
        'hiveNumber': 1,
        'date': DateTime(2024, 11, 14),
        'queenStatus': 'present',
        'broodStatus': 'good',
        'temperature': 25,
        'humidity': 65,
        'overallStatus': 'good',
        'notes': 'خلية في حالة ممتازة، إنتاج جيد',
        'issues': [],
        'inspector': 'أحمد محمد',
      },
      {
        'id': '2',
        'hiveNumber': 2,
        'date': DateTime(2024, 11, 12),
        'queenStatus': 'missing',
        'broodStatus': 'poor',
        'temperature': 23,
        'humidity': 70,
        'overallStatus': 'issues',
        'notes': 'لم أجد الملكة، الحضنة قليلة',
        'issues': ['فقدان الملكة', 'ضعف الحضنة'],
        'inspector': 'أحمد محمد',
      },
      {
        'id': '3',
        'hiveNumber': 3,
        'date': DateTime(2024, 11, 10),
        'queenStatus': 'present',
        'broodStatus': 'excellent',
        'temperature': 26,
        'humidity': 60,
        'overallStatus': 'excellent',
        'notes': 'خلية قوية جداً، جاهزة للتقسيم',
        'issues': [],
        'inspector': 'أحمد محمد',
      },
    ];
  }

  List<Map<String, dynamic>> _filterInspections(List<Map<String, dynamic>> inspections) {
    var filtered = inspections.where((inspection) {
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final hiveNumber = inspection['hiveNumber'].toString();
        final notes = (inspection['notes'] ?? '').toLowerCase();
        final inspector = (inspection['inspector'] ?? '').toLowerCase();

        if (!hiveNumber.contains(query) &&
            !notes.contains(query) &&
            !inspector.contains(query)) {
          return false;
        }
      }

      if (_selectedFilter != 'all') {
        final date = inspection['date'] as DateTime;
        final now = DateTime.now();

        switch (_selectedFilter) {
          case 'week':
            if (now.difference(date).inDays > 7) return false;
            break;
          case 'month':
            if (now.difference(date).inDays > 30) return false;
            break;
          case 'issues':
            if (inspection['overallStatus'] != 'issues') return false;
            break;
        }
      }

      return true;
    }).toList();

    filtered.sort((a, b) {
      switch (_sortBy) {
        case 'date':
          return (b['date'] as DateTime).compareTo(a['date'] as DateTime);
        case 'hive':
          return a['hiveNumber'].compareTo(b['hiveNumber']);
        case 'status':
          return a['overallStatus'].compareTo(b['overallStatus']);
        default:
          return 0;
      }
    });

    return filtered;
  }

  Color _getOverallStatusColor(String status) {
    switch (status) {
      case 'excellent':
        return AppTheme.successColor;
      case 'good':
        return Colors.green;
      case 'fair':
        return AppTheme.primaryYellow;
      case 'issues':
        return AppTheme.errorColor;
      default:
        return Colors.grey;
    }
  }

  String _getOverallStatusText(String status) {
    switch (status) {
      case 'excellent':
        return 'ممتازة';
      case 'good':
        return 'جيدة';
      case 'fair':
        return 'مقبولة';
      case 'issues':
        return 'مشاكل';
      default:
        return 'غير محدد';
    }
  }

  Color _getQueenStatusColor(String status) {
    switch (status) {
      case 'present':
        return AppTheme.successColor;
      case 'missing':
        return AppTheme.errorColor;
      case 'new':
        return AppTheme.primaryYellow;
      default:
        return Colors.grey;
    }
  }

  String _getQueenStatusText(String status) {
    switch (status) {
      case 'present':
        return 'ملكة موجودة';
      case 'missing':
        return 'ملكة مفقودة';
      case 'new':
        return 'ملكة جديدة';
      default:
        return 'غير محدد';
    }
  }

  Color _getBroodStatusColor(String status) {
    switch (status) {
      case 'excellent':
        return AppTheme.successColor;
      case 'good':
        return Colors.green;
      case 'fair':
        return AppTheme.primaryYellow;
      case 'poor':
        return AppTheme.errorColor;
      default:
        return Colors.grey;
    }
  }

  String _getBroodStatusText(String status) {
    switch (status) {
      case 'excellent':
        return 'حضنة ممتازة';
      case 'good':
        return 'حضنة جيدة';
      case 'fair':
        return 'حضنة مقبولة';
      case 'poor':
        return 'حضنة ضعيفة';
      default:
        return 'غير محدد';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _handleMenuAction(String action, Map<String, dynamic> inspection) {
    switch (action) {
      case 'view':
        _viewInspectionDetails(inspection);
        break;
      case 'edit':
        break;
      case 'delete':
        _showDeleteConfirmation(inspection);
        break;
    }
  }

  void _showDeleteConfirmation(Map<String, dynamic> inspection) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: Text('هل أنت متأكد من حذف فحص الخلية رقم ${inspection['hiveNumber']}؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
            ),
            child: const Text('حذف'),
          ),
        ],
      ),
    );
  }

  void _navigateToAddInspection() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddInspectionScreen(),
      ),
    );

    if (result == true) {
      await AdManager.onInspectionAdded();
      setState(() {});
    }
  }

  void _viewInspectionDetails(Map<String, dynamic> inspection) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('فحص خلية رقم ${inspection['hiveNumber']}'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('التاريخ: ${_formatDate(inspection['date'])}'),
              const SizedBox(height: 8),
              Text('الفاحص: ${inspection['inspector']}'),
              const SizedBox(height: 8),
              Text('حالة الملكة: ${_getQueenStatusText(inspection['queenStatus'])}'),
              const SizedBox(height: 8),
              Text('حالة الحضنة: ${_getBroodStatusText(inspection['broodStatus'])}'),
              const SizedBox(height: 8),
              Text('درجة الحرارة: ${inspection['temperature']}°م'),
              const SizedBox(height: 8),
              Text('الرطوبة: ${inspection['humidity']}%'),
              if (inspection['notes'] != null && inspection['notes'].isNotEmpty) ...[
                const SizedBox(height: 8),
                Text('الملاحظات: ${inspection['notes']}'),
              ],
              if (inspection['issues'] != null && (inspection['issues'] as List).isNotEmpty) ...[
                const SizedBox(height: 8),
                Text('المشاكل: ${(inspection['issues'] as List).join(', ')}'),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إغلاق'),
          ),
        ],
      ),
    );
  }

  Future<void> _refreshInspections() async {
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) {
      setState(() {});
    }
  }
}
