import 'package:flutter/material.dart';
import '../utils/app_theme.dart';
import '../utils/responsive_helper.dart';
import '../widgets/custom_app_bar.dart';
import '../services/ad_service.dart';
import '../l10n/app_localizations.dart';
import 'add_production_screen.dart';

class ProductionScreen extends StatefulWidget {
  const ProductionScreen({super.key});

  @override
  State<ProductionScreen> createState() => _ProductionScreenState();
}

class _ProductionScreenState extends State<ProductionScreen> {
  String _searchQuery = '';
  String _selectedFilter = 'all';
  String _selectedYear = DateTime.now().year.toString();
  bool _isLoading = false;

  final List<Map<String, dynamic>> _productions = [
    {
      'id': '1',
      'hiveId': '1',
      'hiveName': 'خلية رقم 1',
      'productType': 'honey',
      'quantity': 25.5,
      'unit': 'كيلو',
      'date': DateTime.now().subtract(const Duration(days: 10)),
      'quality': 'excellent',
      'moistureContent': 18.2,
      'price': 150.0,
      'currency': 'ريال',
      'buyer': 'محل العسل الطبيعي',
      'notes': 'عسل سدر ممتاز، لون ذهبي فاتح',
      'season': 'spring',
    },
    {
      'id': '2',
      'hiveId': '2',
      'hiveName': 'خلية رقم 2',
      'productType': 'wax',
      'quantity': 2.8,
      'unit': 'كيلو',
      'date': DateTime.now().subtract(const Duration(days: 25)),
      'quality': 'good',
      'moistureContent': null,
      'price': 80.0,
      'currency': 'ريال',
      'buyer': 'مصنع الشموع',
      'notes': 'شمع نظيف، لون أصفر طبيعي',
      'season': 'spring',
    },
    {
      'id': '3',
      'hiveId': '3',
      'hiveName': 'خلية رقم 3',
      'productType': 'honey',
      'quantity': 18.0,
      'unit': 'كيلو',
      'date': DateTime.now().subtract(const Duration(days: 45)),
      'quality': 'good',
      'moistureContent': 19.1,
      'price': 120.0,
      'currency': 'ريال',
      'buyer': null,
      'notes': 'عسل زهور برية، طعم مميز',
      'season': 'winter',
    },
  ];

  @override
  void initState() {
    super.initState();
    AdManager.onScreenChange(AdScreen.production, AdScreen.home);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final filteredProductions = _getFilteredProductions();
    final stats = _calculateStats(filteredProductions);

    return AdAwareScaffold(
      screen: AdScreen.production,
      appBar: CustomAppBar(
        title: 'الإنتاج والحصاد',
        showBackButton: true,
      ),
      body: ResponsiveContainer(
        child: Column(
          children: [
            _buildSearchField(),
            _buildStatsCards(stats),
            _buildFilters(),
            Expanded(
              child: _isLoading
                  ? _buildLoadingState()
                  : filteredProductions.isEmpty
                  ? _buildEmptyState(l10n)
                  : _buildProductionsList(filteredProductions),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _addNewProduction(),
        icon: const Icon(Icons.add),
        label: const Text('تسجيل إنتاج'),
      ),
    );
  }

  // --- دالة حقل البحث المضافة ---
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
          hintText: 'بحث عن منتج...',
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
            'إجمالي العسل',
            '${stats['totalHoney']} كيلو',
            Icons.opacity,
            AppTheme.primaryYellow,
          ),
          _buildStatCard(
            'إجمالي الشمع',
            '${stats['totalWax']} كيلو',
            Icons.circle,
            Colors.orange.shade300,
          ),
          _buildStatCard(
            'إجمالي الإيرادات',
            '${stats['totalRevenue']} ريال',
            Icons.attach_money,
            AppTheme.successColor,
          ),
          _buildStatCard(
            'متوسط الإنتاج',
            '${stats['avgProduction']} كيلو/خلية',
            Icons.trending_up,
            Colors.blue.shade300,
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: ResponsiveHelper.getCardPadding(context),
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

  Widget _buildFilters() {
    return Container(
      padding: ResponsiveHelper.getScreenPadding(context),
      child: Column(
        children: [
          ResponsiveRow(
            children: [
              _buildFilterTab('الكل', 'all'),
              _buildFilterTab('عسل', 'honey'),
              _buildFilterTab('شمع', 'wax'),
              _buildFilterTab('أخرى', 'other'),
            ],
          ),
          SizedBox(height: ResponsiveHelper.getCardSpacing(context)),
          ResponsiveRow(
            children: [
              Expanded(
                child: ResponsiveText(
                  'السنة:',
                  style: AppTheme.bodyText,
                ),
              ),
              GestureDetector(
                onTap: () => _showYearSelector(),
                child: Container(
                  padding: ResponsiveHelper.getButtonPadding(context),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppTheme.primaryYellow),
                  ),
                  child: ResponsiveText(
                    _selectedYear,
                    style: AppTheme.bodyText,
                  ),
                ),
              ),
            ],
          ),
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
            'جاري تحميل بيانات الإنتاج...',
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
            Icons.opacity,
            size: ResponsiveHelper.getIconSize(context, 24),
            color: Colors.grey.shade400,
          ),
          SizedBox(height: ResponsiveHelper.getCardSpacing(context)),
          ResponsiveText(
            _searchQuery.isNotEmpty
                ? 'لا توجد منتجات تطابق البحث'
                : 'لا توجد منتجات مسجلة',
            style: AppTheme.bodyText.copyWith(color: Colors.grey.shade600),
          ),
          SizedBox(height: ResponsiveHelper.getCardSpacing(context)),
          ResponsiveButton(
            text: 'تسجيل إنتاج جديد',
            onPressed: () => _addNewProduction(),
            backgroundColor: AppTheme.primaryYellow,
            foregroundColor: AppTheme.darkBrown,
            icon: Icons.add,
          ),
        ],
      ),
    );
  }

  Widget _buildProductionsList(List<Map<String, dynamic>> productions) {
    return RefreshIndicator(
      onRefresh: _refreshProductions,
      color: AppTheme.primaryYellow,
      child: ListView.builder(
        padding: ResponsiveHelper.getScreenPadding(context),
        itemCount: productions.length,
        itemBuilder: (context, index) {
          final production = productions[index];
          return _buildProductionCard(production);
        },
      ),
    );
  }

  Widget _buildProductionCard(Map<String, dynamic> production) {
    final productType = production['productType'] as String;
    final quality = production['quality'] as String;

    Color typeColor = AppTheme.primaryYellow;
    IconData typeIcon = Icons.opacity;

    switch (productType) {
      case 'honey':
        typeColor = AppTheme.primaryYellow;
        typeIcon = Icons.opacity;
        break;
      case 'wax':
        typeColor = Colors.orange.shade300;
        typeIcon = Icons.circle;
        break;
      case 'propolis':
        typeColor = Colors.brown.shade300;
        typeIcon = Icons.healing;
        break;
      case 'pollen':
        typeColor = Colors.yellow.shade600;
        typeIcon = Icons.grain;
        break;
    }

    Color qualityColor = AppTheme.successColor;
    switch (quality) {
      case 'excellent':
        qualityColor = AppTheme.successColor;
        break;
      case 'good':
        qualityColor = AppTheme.warningColor;
        break;
      case 'fair':
        qualityColor = Colors.orange;
        break;
      case 'poor':
        qualityColor = AppTheme.errorColor;
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
                typeIcon,
                color: typeColor,
              ),
              SizedBox(width: ResponsiveHelper.getCardSpacing(context)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ResponsiveText(
                      '${production['quantity']} ${production['unit']} ${_getProductTypeText(productType)}',
                      style: AppTheme.titleText,
                    ),
                    SizedBox(height: ResponsiveHelper.getCardSpacing(context) / 2),
                    ResponsiveText(
                      production['hiveName'],
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
                  color: qualityColor.withAlpha(25),
                  border: Border.all(color: qualityColor),
                ),
                child: ResponsiveText(
                  _getQualityText(quality),
                  style: AppTheme.smallText.copyWith(color: qualityColor),
                ),
              ),
            ],
          ),
          SizedBox(height: ResponsiveHelper.getCardSpacing(context)),
          ResponsiveRow(
            children: [
              Expanded(
                child: _buildInfoItem('التاريخ', _formatDate(production['date'])),
              ),
              Expanded(
                child: _buildInfoItem('الموسم', _getSeasonText(production['season'])),
              ),
            ],
          ),
          if (production['moistureContent'] != null) ...[
            SizedBox(height: ResponsiveHelper.getCardSpacing(context) / 2),
            ResponsiveRow(
              children: [
                Expanded(
                  child: _buildInfoItem('نسبة الرطوبة', '${production['moistureContent']}%'),
                ),
                Expanded(
                  child: _buildInfoItem('السعر', '${production['price']} ${production['currency']}'),
                ),
              ],
            ),
          ] else ...[
            SizedBox(height: ResponsiveHelper.getCardSpacing(context) / 2),
            _buildInfoItem('السعر', '${production['price']} ${production['currency']}'),
          ],
          if (production['buyer'] != null) ...[
            SizedBox(height: ResponsiveHelper.getCardSpacing(context) / 2),
            _buildInfoItem('المشتري', production['buyer']),
          ],
          if (production['notes'].isNotEmpty) ...[
            SizedBox(height: ResponsiveHelper.getCardSpacing(context) / 2),
            ResponsiveText(
              production['notes'],
              style: AppTheme.smallText.copyWith(color: Colors.grey.shade600),
            ),
          ],
          SizedBox(height: ResponsiveHelper.getCardSpacing(context)),
          ResponsiveRow(
            children: [
              ResponsiveButton(
                text: 'عرض',
                onPressed: () => _viewProduction(production),
                backgroundColor: Colors.transparent,
                foregroundColor: AppTheme.primaryYellow,
                icon: Icons.visibility,
              ),
              SizedBox(width: ResponsiveHelper.getCardSpacing(context)),
              ResponsiveButton(
                text: 'تعديل',
                onPressed: () => _editProduction(production),
                backgroundColor: Colors.transparent,
                foregroundColor: AppTheme.warningColor,
                icon: Icons.edit,
              ),
              SizedBox(width: ResponsiveHelper.getCardSpacing(context)),
              ResponsiveButton(
                text: 'حذف',
                onPressed: () => _deleteProduction(production),
                backgroundColor: Colors.transparent,
                foregroundColor: AppTheme.errorColor,
                icon: Icons.delete,
              ),
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

  List<Map<String, dynamic>> _getFilteredProductions() {
    var filtered = _productions.where((production) {
      final matchesSearch = _searchQuery.isEmpty ||
          production['hiveName'].toLowerCase().contains(_searchQuery.toLowerCase()) ||
          production['notes'].toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (production['buyer'] ?? '').toLowerCase().contains(_searchQuery.toLowerCase());

      final matchesFilter = _selectedFilter == 'all' ||
          production['productType'] == _selectedFilter;

      final matchesYear = (production['date'] as DateTime).year.toString() == _selectedYear;

      return matchesSearch && matchesFilter && matchesYear;
    }).toList();

    filtered.sort((a, b) => (b['date'] as DateTime).compareTo(a['date'] as DateTime));
    return filtered;
  }

  Map<String, dynamic> _calculateStats(List<Map<String, dynamic>> productions) {
    double totalHoney = 0;
    double totalWax = 0;
    double totalRevenue = 0;
    int hiveCount = 0;

    final hiveIds = <String>{};

    for (final production in productions) {
      hiveIds.add(production['hiveId']);
      totalRevenue += production['price'] as double;

      switch (production['productType']) {
        case 'honey':
          totalHoney += production['quantity'] as double;
          break;
        case 'wax':
          totalWax += production['quantity'] as double;
          break;
      }
    }

    hiveCount = hiveIds.length;
    final avgProduction = hiveCount > 0 ? (totalHoney + totalWax) / hiveCount : 0;

    return {
      'totalHoney': totalHoney.toStringAsFixed(1),
      'totalWax': totalWax.toStringAsFixed(1),
      'totalRevenue': totalRevenue.toStringAsFixed(0),
      'avgProduction': avgProduction.toStringAsFixed(1),
    };
  }

  String _getProductTypeText(String type) {
    switch (type) {
      case 'honey':
        return 'عسل';
      case 'wax':
        return 'شمع';
      case 'propolis':
        return 'عكبر';
      case 'pollen':
        return 'حبوب لقاح';
      default:
        return 'منتج';
    }
  }

  String _getQualityText(String quality) {
    switch (quality) {
      case 'excellent':
        return 'ممتاز';
      case 'good':
        return 'جيد';
      case 'fair':
        return 'مقبول';
      case 'poor':
        return 'ضعيف';
      default:
        return 'غير محدد';
    }
  }

  String _getSeasonText(String season) {
    switch (season) {
      case 'spring':
        return 'ربيع';
      case 'summer':
        return 'صيف';
      case 'autumn':
        return 'خريف';
      case 'winter':
        return 'شتاء';
      default:
        return 'غير محدد';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showYearSelector() {
    final currentYear = DateTime.now().year;
    final years = List.generate(10, (index) => (currentYear - index).toString());

    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: ResponsiveHelper.getScreenPadding(context),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ResponsiveText(
                'اختر السنة',
                style: AppTheme.titleText,
              ),
              SizedBox(height: ResponsiveHelper.getCardSpacing(context)),
              ...years.map((year) {
                return ListTile(
                  title: ResponsiveText(
                    year,
                    style: AppTheme.bodyText,
                  ),
                  onTap: () {
                    setState(() {
                      _selectedYear = year;
                    });
                    Navigator.pop(context);
                  },
                );
              }),
            ],
          ),
        );
      },
    );
  }

  Future<void> _refreshProductions() async {
    setState(() {
      _isLoading = true;
    });

    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      _isLoading = false;
    });
  }

  void _addNewProduction() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddProductionScreen(),
      ),
    );

    if (result == true) {
      _refreshProductions();
    }
  }

  void _viewProduction(Map<String, dynamic> production) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => _buildProductionDetailsSheet(production),
    );
  }

  Widget _buildProductionDetailsSheet(Map<String, dynamic> production) {
    return Container(
      padding: ResponsiveHelper.getScreenPadding(context),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ResponsiveText(
            'تفاصيل الإنتاج',
            style: AppTheme.titleText,
          ),
          SizedBox(height: ResponsiveHelper.getCardSpacing(context)),
          _buildDetailRow('النوع', _getProductTypeText(production['productType'])),
          _buildDetailRow('الكمية', '${production['quantity']} ${production['unit']}'),
          _buildDetailRow('الخلية', production['hiveName']),
          _buildDetailRow('الجودة', _getQualityText(production['quality'])),
          _buildDetailRow('التاريخ', _formatDate(production['date'])),
          _buildDetailRow('الموسم', _getSeasonText(production['season'])),
          if (production['moistureContent'] != null)
            _buildDetailRow('نسبة الرطوبة', '${production['moistureContent']}%'),
          _buildDetailRow('السعر', '${production['price']} ${production['currency']}'),
          if (production['buyer'] != null)
            _buildDetailRow('المشتري', production['buyer']),
          if (production['notes'].isNotEmpty)
            _buildDetailRow('ملاحظات', production['notes']),
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

  void _editProduction(Map<String, dynamic> production) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddProductionScreen(productionId: production['id']),
      ),
    );
  }

  void _deleteProduction(Map<String, dynamic> production) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: ResponsiveText('حذف الإنتاج', style: AppTheme.titleText),
        content: ResponsiveText(
          'هل أنت متأكد من حذف هذا السجل؟',
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
                  content: ResponsiveText('تم حذف السجل'),
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