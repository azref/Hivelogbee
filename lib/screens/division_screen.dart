import 'package:flutter/material.dart';
import '../utils/app_theme.dart';
import '../utils/responsive_helper.dart';
import '../widgets/custom_app_bar.dart';
import '../services/ad_service.dart';
import '../l10n/app_localizations.dart';
import 'add_division_screen.dart';

class DivisionScreen extends StatefulWidget {
  const DivisionScreen({super.key});

  @override
  State<DivisionScreen> createState() => _DivisionScreenState();
}

class _DivisionScreenState extends State<DivisionScreen> {
  String _searchQuery = '';
  String _selectedFilter = 'all';
  bool _isLoading = false;

  final List<Map<String, dynamic>> _divisions = [
    {
      'id': '1',
      'parentHiveId': '1',
      'parentHiveName': 'خلية رقم 1',
      'nucleusId': '6',
      'nucleusName': 'طرد رقم 6',
      'divisionDate': DateTime.now().subtract(const Duration(days: 20)),
      'frameCount': 4,
      'queenStatus': 'accepted',
      'queenType': 'natural',
      'queenAge': 20,
      'strength': 'medium',
      'status': 'growing',
      'notes': 'طرد قوي، الملكة مقبولة والحضنة جيدة',
      'expectedUpgrade': DateTime.now().add(const Duration(days: 25)),
      'isReadyForUpgrade': false,
    },
    {
      'id': '2',
      'parentHiveId': '2',
      'parentHiveName': 'خلية رقم 2',
      'nucleusId': '7',
      'nucleusName': 'طرد رقم 7',
      'divisionDate': DateTime.now().subtract(const Duration(days: 45)),
      'frameCount': 5,
      'queenStatus': 'laying',
      'queenType': 'introduced',
      'queenAge': 45,
      'strength': 'strong',
      'status': 'ready_upgrade',
      'notes': 'جاهز للترقية، 5 إطارات ممتلئة',
      'expectedUpgrade': DateTime.now(),
      'isReadyForUpgrade': true,
    },
    {
      'id': '3',
      'parentHiveId': '1',
      'parentHiveName': 'خلية رقم 1',
      'nucleusId': '8',
      'nucleusName': 'طرد رقم 8',
      'divisionDate': DateTime.now().subtract(const Duration(days: 60)),
      'frameCount': 6,
      'queenStatus': 'laying',
      'queenType': 'natural',
      'queenAge': 60,
      'strength': 'strong',
      'status': 'upgraded',
      'notes': 'تم ترقيته لخلية مستقلة',
      'upgradeDate': DateTime.now().subtract(const Duration(days: 5)),
      'newHiveId': '9',
      'isReadyForUpgrade': false,
    },
  ];

  @override
  void initState() {
    super.initState();
    AdManager.onScreenChange(AdScreen.hiveList, AdScreen.home);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final filteredDivisions = _getFilteredDivisions();
    final stats = _calculateStats(filteredDivisions);

    return AdAwareScaffold(
      screen: AdScreen.hiveList,
      appBar: CustomAppBar(
        title: 'التقسيمات والطرود',
        showBackButton: true,
      ),
      body: ResponsiveContainer(
        child: Column(
          children: [
            _buildSearchField(), // تم إضافة حقل البحث هنا
            _buildStatsCards(stats),
            _buildFilterTabs(),
            Expanded(
              child: _isLoading
                  ? _buildLoadingState()
                  : filteredDivisions.isEmpty
                  ? _buildEmptyState(l10n)
                  : _buildDivisionsList(filteredDivisions),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _addNewDivision(),
        icon: const Icon(Icons.call_split),
        label: const Text('تقسيم جديد'),
        backgroundColor: AppTheme.primaryYellow,
      ),
    );
  }

  // --- دالة جديدة لحقل البحث ---
  Widget _buildSearchField() {
    return Container(
      padding: ResponsiveHelper.getScreenPadding(context),
      child: TextField(
        onChanged: (query) {
          setState(() {
            _searchQuery = query;
          });
        },
        decoration: InputDecoration(
          hintText: 'بحث عن طرد...',
          prefixIcon: const Icon(Icons.search, color: AppTheme.primaryYellow),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
            icon: const Icon(Icons.clear, color: Colors.grey),
            onPressed: () {
              setState(() {
                _searchQuery = '';
              });
            },
          )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.grey.shade100,
          contentPadding: const EdgeInsets.symmetric(vertical: 0),
        ),
      ),
    );
  }

  Widget _buildStatsCards(Map<String, dynamic> stats) {
    return Container(
      padding: ResponsiveHelper.getScreenPadding(context),
      child: ResponsiveGrid(
        crossAxisCount: 2,
        children: [
          _buildStatCard(
            'إجمالي الطرود',
            '${stats['totalNucleus']}',
            Icons.hive,
            AppTheme.primaryYellow,
          ),
          _buildStatCard(
            'جاهز للترقية',
            '${stats['readyForUpgrade']}',
            Icons.trending_up,
            AppTheme.successColor,
          ),
          _buildStatCard(
            'قيد النمو',
            '${stats['growing']}',
            Icons.eco,
            Colors.green.shade300,
          ),
          _buildStatCard(
            'تم الترقية',
            '${stats['upgraded']}',
            Icons.check_circle,
            Colors.blue.shade300,
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: color.withAlpha(25),
        border: Border.all(color: color.withAlpha(76)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ResponsiveIcon(
            icon,
            color: color,
          ),
          SizedBox(height: ResponsiveHelper.getCardSpacing(context) / 2),
          ResponsiveText(
            title,
            style: AppTheme.smallText.copyWith(color: Colors.grey.shade600),
          ),
          ResponsiveText(
            value,
            style: AppTheme.titleText.copyWith(color: color),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterTabs() {
    return Container(
      padding: ResponsiveHelper.getScreenPadding(context),
      child: ResponsiveRow(
        children: [
          _buildFilterTab('الكل', 'all'),
          _buildFilterTab('نامي', 'growing'),
          _buildFilterTab('جاهز', 'ready_upgrade'),
          _buildFilterTab('مرقى', 'upgraded'),
        ],
      ),
    );
  }

  Widget _buildFilterTab(String label, String value) {
    final isSelected = _selectedFilter == value;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedFilter = value;
          });
        },
        child: Container(
          padding: ResponsiveHelper.getButtonPadding(context),
          margin: EdgeInsets.symmetric(horizontal: ResponsiveHelper.getCardSpacing(context) / 2),
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.primaryYellow.withAlpha(51) : Colors.transparent,
            border: Border(
              bottom: BorderSide(
                color: isSelected ? AppTheme.primaryYellow : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          child: ResponsiveText(
            label,
            style: AppTheme.smallText.copyWith(
              color: isSelected ? AppTheme.darkBrown : Colors.grey.shade600,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            color: AppTheme.primaryYellow,
          ),
          SizedBox(height: ResponsiveHelper.getCardSpacing(context)),
          ResponsiveText(
            'جاري تحميل التقسيمات...',
            style: AppTheme.bodyText,
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
          ResponsiveIcon(
            Icons.call_split,
            size: ResponsiveHelper.getIconSize(context, 3),
            color: Colors.grey.shade400,
          ),
          SizedBox(height: ResponsiveHelper.getCardSpacing(context)),
          ResponsiveText(
            _searchQuery.isNotEmpty
                ? 'لا توجد تقسيمات تطابق البحث'
                : 'لا توجد تقسيمات مسجلة',
            style: AppTheme.bodyText.copyWith(color: Colors.grey.shade600),
          ),
          SizedBox(height: ResponsiveHelper.getCardSpacing(context)),
          ResponsiveButton(
            text: 'إنشاء تقسيم جديد',
            onPressed: () => _addNewDivision(),
            backgroundColor: AppTheme.primaryYellow,
            foregroundColor: AppTheme.darkBrown,
            icon: Icons.call_split,
          ),
        ],
      ),
    );
  }

  Widget _buildDivisionsList(List<Map<String, dynamic>> divisions) {
    return RefreshIndicator(
      onRefresh: _refreshDivisions,
      color: AppTheme.primaryYellow,
      child: ListView.builder(
        padding: ResponsiveHelper.getScreenPadding(context),
        itemCount: divisions.length,
        itemBuilder: (context, index) {
          final division = divisions[index];
          return _buildDivisionCard(division);
        },
      ),
    );
  }

  Widget _buildDivisionCard(Map<String, dynamic> division) {
    final status = division['status'] as String;
    final frameCount = division['frameCount'] as int;

    Color statusColor = AppTheme.warningColor;
    String statusText = 'قيد النمو';
    IconData statusIcon = Icons.eco;

    switch (status) {
      case 'growing':
        statusColor = Colors.green.shade300;
        statusText = 'قيد النمو';
        statusIcon = Icons.eco;
        break;
      case 'ready_upgrade':
        statusColor = AppTheme.successColor;
        statusText = 'جاهز للترقية';
        statusIcon = Icons.trending_up;
        break;
      case 'upgraded':
        statusColor = Colors.blue.shade300;
        statusText = 'تم الترقية';
        statusIcon = Icons.check_circle;
        break;
    }

    return Container(
      margin: EdgeInsets.only(bottom: ResponsiveHelper.getCardSpacing(context)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ResponsiveRow(
            children: [
              ResponsiveIcon(
                statusIcon,
                color: statusColor,
              ),
              SizedBox(width: ResponsiveHelper.getCardSpacing(context)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ResponsiveText(
                      division['nucleusName'],
                      style: AppTheme.titleText,
                    ),
                    SizedBox(height: ResponsiveHelper.getCardSpacing(context) / 2),
                    ResponsiveText(
                      'من ${division['parentHiveName']}',
                      style: AppTheme.smallText.copyWith(color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: ResponsiveHelper.getCardSpacing(context),
                  vertical: ResponsiveHelper.getCardSpacing(context) / 2,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withAlpha(25),
                  border: Border.all(color: statusColor),
                ),
                child: ResponsiveText(
                  statusText,
                  style: AppTheme.smallText.copyWith(color: statusColor),
                ),
              ),
            ],
          ),
          SizedBox(height: ResponsiveHelper.getCardSpacing(context)),
          ResponsiveRow(
            children: [
              Expanded(
                child: _buildInfoItem('عدد الإطارات', '$frameCount إطار'),
              ),
              Expanded(
                child: _buildInfoItem('عمر الملكة', '${division['queenAge']} يوم'),
              ),
            ],
          ),
          SizedBox(height: ResponsiveHelper.getCardSpacing(context) / 2),
          ResponsiveRow(
            children: [
              Expanded(
                child: _buildInfoItem('تاريخ التقسيم', _formatDate(division['divisionDate'])),
              ),
              Expanded(
                child: _buildInfoItem('حالة الملكة', _getQueenStatusText(division['queenStatus'])),
              ),
            ],
          ),
          if (frameCount >= 5) ...[
            SizedBox(height: ResponsiveHelper.getCardSpacing(context) / 2),
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: AppTheme.successColor.withAlpha(25),
                border: Border.all(color: AppTheme.successColor),
              ),
              child: ResponsiveRow(
                children: [
                  const ResponsiveIcon(
                    Icons.notification_important,
                    color: AppTheme.successColor,
                  ),
                  SizedBox(width: ResponsiveHelper.getCardSpacing(context)),
                  Expanded(
                    child: ResponsiveText(
                      'جاهز للترقية إلى خلية مستقلة!',
                      style: AppTheme.smallText.copyWith(color: AppTheme.successColor),
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (division['expectedUpgrade'] != null && status != 'upgraded') ...[
            SizedBox(height: ResponsiveHelper.getCardSpacing(context) / 2),
            _buildInfoItem('الترقية المتوقعة', _formatDate(division['expectedUpgrade'])),
          ],
          if (division['upgradeDate'] != null) ...[
            SizedBox(height: ResponsiveHelper.getCardSpacing(context) / 2),
            _buildInfoItem('تاريخ الترقية', _formatDate(division['upgradeDate'])),
          ],
          if (division['notes'].isNotEmpty) ...[
            SizedBox(height: ResponsiveHelper.getCardSpacing(context) / 2),
            ResponsiveText(
              division['notes'],
              style: AppTheme.smallText.copyWith(color: Colors.grey.shade600),
            ),
          ],
          SizedBox(height: ResponsiveHelper.getCardSpacing(context)),
          ResponsiveRow(
            children: [
              ResponsiveButton(
                text: 'عرض',
                onPressed: () => _viewDivision(division),
                backgroundColor: Colors.transparent,
                foregroundColor: AppTheme.primaryYellow,
                icon: Icons.visibility,
              ),
              SizedBox(width: ResponsiveHelper.getCardSpacing(context)),
              if (status != 'upgraded') ...[
                ResponsiveButton(
                  text: 'تعديل',
                  onPressed: () => _editDivision(division),
                  backgroundColor: Colors.transparent,
                  foregroundColor: AppTheme.warningColor,
                  icon: Icons.edit,
                ),
                SizedBox(width: ResponsiveHelper.getCardSpacing(context)),
              ],
              if (frameCount >= 5 && status != 'upgraded') ...[
                ResponsiveButton(
                  text: 'ترقية',
                  onPressed: () => _upgradeDivision(division),
                  backgroundColor: Colors.transparent,
                  foregroundColor: AppTheme.successColor,
                  icon: Icons.upgrade,
                ),
              ] else ...[
                ResponsiveButton(
                  text: 'حذف',
                  onPressed: () => _deleteDivision(division),
                  backgroundColor: Colors.transparent,
                  foregroundColor: AppTheme.errorColor,
                  icon: Icons.delete,
                ),
              ],
            ],
          ),
          Container(
            height: 1,
            color: Colors.grey.shade200,
            margin: EdgeInsets.only(top: ResponsiveHelper.getCardSpacing(context)),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ResponsiveText(
          label,
          style: AppTheme.smallText.copyWith(color: Colors.grey.shade600),
        ),
        ResponsiveText(
          value,
          style: AppTheme.bodyText,
        ),
      ],
    );
  }

  List<Map<String, dynamic>> _getFilteredDivisions() {
    var filtered = _divisions.where((division) {
      final matchesSearch = _searchQuery.isEmpty ||
          division['nucleusName'].toLowerCase().contains(_searchQuery.toLowerCase()) ||
          division['parentHiveName'].toLowerCase().contains(_searchQuery.toLowerCase()) ||
          division['notes'].toLowerCase().contains(_searchQuery.toLowerCase());

      final matchesFilter = _selectedFilter == 'all' ||
          division['status'] == _selectedFilter;

      return matchesSearch && matchesFilter;
    }).toList();

    filtered.sort((a, b) => (b['divisionDate'] as DateTime).compareTo(a['divisionDate'] as DateTime));
    return filtered;
  }

  Map<String, dynamic> _calculateStats(List<Map<String, dynamic>> divisions) {
    int totalNucleus = divisions.length;
    int readyForUpgrade = divisions.where((d) => d['status'] == 'ready_upgrade' || d['frameCount'] >= 5).length;
    int growing = divisions.where((d) => d['status'] == 'growing').length;
    int upgraded = divisions.where((d) => d['status'] == 'upgraded').length;

    return {
      'totalNucleus': totalNucleus,
      'readyForUpgrade': readyForUpgrade,
      'growing': growing,
      'upgraded': upgraded,
    };
  }

  String _getQueenStatusText(String status) {
    switch (status) {
      case 'accepted':
        return 'مقبولة';
      case 'laying':
        return 'تبيض';
      case 'missing':
        return 'مفقودة';
      case 'rejected':
        return 'مرفوضة';
      default:
        return 'غير معروف';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Future<void> _refreshDivisions() async {
    setState(() {
      _isLoading = true;
    });

    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      _isLoading = false;
    });
  }

  void _addNewDivision() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddDivisionScreen(),
      ),
    );

    if (result == true) {
      _refreshDivisions();
    }
  }

  void _viewDivision(Map<String, dynamic> division) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => _buildDivisionDetailsSheet(division),
    );
  }

  Widget _buildDivisionDetailsSheet(Map<String, dynamic> division) {
    return Container(
      padding: ResponsiveHelper.getScreenPadding(context),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ResponsiveText(
            'تفاصيل التقسيم',
            style: AppTheme.titleText,
          ),
          SizedBox(height: ResponsiveHelper.getCardSpacing(context)),
          _buildDetailRow('اسم الطرد', division['nucleusName']),
          _buildDetailRow('الخلية الأم', division['parentHiveName']),
          _buildDetailRow('تاريخ التقسيم', _formatDate(division['divisionDate'])),
          _buildDetailRow('عدد الإطارات', '${division['frameCount']} إطار'),
          _buildDetailRow('حالة الملكة', _getQueenStatusText(division['queenStatus'])),
          _buildDetailRow('عمر الملكة', '${division['queenAge']} يوم'),
          _buildDetailRow('قوة الطرد', _getStrengthText(division['strength'])),
          _buildDetailRow('الحالة', _getStatusText(division['status'])),
          if (division['expectedUpgrade'] != null)
            _buildDetailRow('الترقية المتوقعة', _formatDate(division['expectedUpgrade'])),
          if (division['upgradeDate'] != null)
            _buildDetailRow('تاريخ الترقية', _formatDate(division['upgradeDate'])),
          if (division['notes'].isNotEmpty)
            _buildDetailRow('ملاحظات', division['notes']),
          SizedBox(height: ResponsiveHelper.getCardSpacing(context) * 2),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: ResponsiveHelper.getCardSpacing(context)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ResponsiveText(
            label,
            style: AppTheme.smallText.copyWith(color: Colors.grey.shade600),
          ),
          ResponsiveText(
            value,
            style: AppTheme.bodyText,
          ),
          Container(
            height: 1,
            color: Colors.grey.shade200,
            margin: EdgeInsets.only(top: ResponsiveHelper.getCardSpacing(context) / 2),
          ),
        ],
      ),
    );
  }

  String _getStrengthText(String strength) {
    switch (strength) {
      case 'weak':
        return 'ضعيف';
      case 'medium':
        return 'متوسط';
      case 'strong':
        return 'قوي';
      default:
        return 'غير محدد';
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'growing':
        return 'قيد النمو';
      case 'ready_upgrade':
        return 'جاهز للترقية';
      case 'upgraded':
        return 'تم الترقية';
      default:
        return 'غير محدد';
    }
  }

  void _editDivision(Map<String, dynamic> division) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddDivisionScreen(divisionId: division['id']),
      ),
    );
  }

  void _upgradeDivision(Map<String, dynamic> division) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: ResponsiveText('ترقية الطرد', style: AppTheme.titleText),
        content: ResponsiveText(
          'هل تريد ترقية "${division['nucleusName']}" إلى خلية مستقلة؟\n\nسيتم قطع الربط مع الخلية الأم وإنشاء خلية جديدة.',
          style: AppTheme.bodyText,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: ResponsiveText('إلغاء', style: AppTheme.bodyText),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: ResponsiveText('تم ترقية الطرد إلى خلية مستقلة'),
                  backgroundColor: AppTheme.successColor,
                ),
              );
            },
            child: ResponsiveText(
              'ترقية',
              style: AppTheme.bodyText.copyWith(color: AppTheme.successColor),
            ),
          ),
        ],
      ),
    );
  }

  void _deleteDivision(Map<String, dynamic> division) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: ResponsiveText('حذف التقسيم', style: AppTheme.titleText),
        content: ResponsiveText(
          'هل أنت متأكد من حذف "${division['nucleusName']}"؟',
          style: AppTheme.bodyText,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: ResponsiveText('إلغاء', style: AppTheme.bodyText),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: ResponsiveText('تم حذف التقسيم'),
                  backgroundColor: AppTheme.successColor,
                ),
              );
            },
            child: ResponsiveText(
              'حذف',
              style: AppTheme.bodyText.copyWith(color: AppTheme.errorColor),
            ),
          ),
        ],
      ),
    );
  }
}