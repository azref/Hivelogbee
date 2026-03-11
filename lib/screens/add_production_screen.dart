import 'package:flutter/material.dart';
import '../utils/app_theme.dart';
import '../utils/responsive_helper.dart';
import '../widgets/custom_app_bar.dart';
import '../services/ad_service.dart';

class AddProductionScreen extends StatefulWidget {
  final String? productionId;

  const AddProductionScreen({
    super.key,
    this.productionId,
  });

  @override
  State<AddProductionScreen> createState() => _AddProductionScreenState();
}

class _AddProductionScreenState extends State<AddProductionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _quantityController = TextEditingController();
  final _priceController = TextEditingController();
  final _buyerController = TextEditingController();
  final _notesController = TextEditingController();

  String? _selectedHiveId;
  String _productType = 'honey';
  String _unit = 'كيلو';
  DateTime _harvestDate = DateTime.now();
  String _quality = 'good';
  String _season = 'spring';
  double _moistureContent = 18.0;
  String _currency = 'ريال';
  bool _isSold = false;
  bool _isLoading = false;

  final Map<String, String> _productTypes = {
    'honey': 'عسل',
    'wax': 'شمع',
    'propolis': 'عكبر',
    'pollen': 'حبوب لقاح',
    'royal_jelly': 'غذاء ملكات',
    'other': 'أخرى',
  };

  final Map<String, List<String>> _units = {
    'honey': ['كيلو', 'جرام', 'لتر'],
    'wax': ['كيلو', 'جرام'],
    'propolis': ['جرام', 'كيلو'],
    'pollen': ['جرام', 'كيلو'],
    'royal_jelly': ['جرام'],
    'other': ['كيلو', 'جرام', 'قطعة'],
  };

  final Map<String, String> _qualities = {
    'excellent': 'ممتاز',
    'good': 'جيد',
    'fair': 'مقبول',
    'poor': 'ضعيف',
  };

  final Map<String, String> _seasons = {
    'spring': 'ربيع',
    'summer': 'صيف',
    'autumn': 'خريف',
    'winter': 'شتاء',
  };

  @override
  void initState() {
    super.initState();
    // Corrected AdScreen values
    AdManager.onScreenChange(AdScreen.addHive, AdScreen.hiveList);
    if (widget.productionId != null) {
      _loadProductionData();
    }
    _updateSeason();
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _priceController.dispose();
    _buyerController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.productionId != null;

    return AdAwareScaffold(
      screen: AdScreen.addHive, // Corrected AdScreen value
      appBar: CustomAppBar(
        title: isEditing ? 'تعديل الإنتاج' : 'تسجيل إنتاج جديد',
      ),
      body: ResponsiveContainer(
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildHiveSelection(),
              _buildProductType(),
              _buildQuantityAndUnit(),
              _buildQualityAndMoisture(),
              _buildHarvestDate(),
              _buildSeasonSelection(),
              _buildPriceSection(),
              _buildNotes(),
              SizedBox(height: ResponsiveHelper.getCardSpacing(context) * 2),
              _buildSaveButton(isEditing),
              SizedBox(height: ResponsiveHelper.getCardSpacing(context) * 4),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHiveSelection() {
    return Padding(
      padding: ResponsiveHelper.getScreenPadding(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ResponsiveText(
            'اختيار الخلية',
            style: AppTheme.labelText,
          ),
          SizedBox(height: ResponsiveHelper.getCardSpacing(context)),
          GestureDetector(
            onTap: () => _showHiveSelector(),
            child: Container(
              width: double.infinity,
              padding: ResponsiveHelper.getButtonPadding(context),
              child: ResponsiveText(
                _selectedHiveId != null ? 'خلية رقم $_selectedHiveId' : 'اختر خلية',
                style: AppTheme.bodyText.copyWith(
                  color: _selectedHiveId != null ? AppTheme.darkBrown : Colors.grey,
                ),
              ),
            ),
          ),
          Container(
            height: 1,
            color: AppTheme.primaryYellow,
            margin: EdgeInsets.only(top: ResponsiveHelper.getCardSpacing(context)),
          ),
        ],
      ),
    );
  }

  Widget _buildProductType() {
    return Padding(
      padding: ResponsiveHelper.getScreenPadding(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ResponsiveText(
            'نوع المنتج',
            style: AppTheme.labelText,
          ),
          SizedBox(height: ResponsiveHelper.getCardSpacing(context)),
          Wrap(
            spacing: ResponsiveHelper.getCardSpacing(context),
            runSpacing: ResponsiveHelper.getCardSpacing(context) / 2,
            children: _productTypes.entries.map((entry) {
              final isSelected = _productType == entry.key;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _productType = entry.key;
                    _unit = _units[entry.key]?.first ?? 'كيلو';
                  });
                },
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: ResponsiveHelper.getCardSpacing(context),
                    vertical: ResponsiveHelper.getCardSpacing(context) / 2,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected ? AppTheme.primaryYellow.withAlpha(51) : Colors.transparent, // Adjusted for opacity
                    border: Border.all(
                      color: isSelected ? AppTheme.primaryYellow : Colors.grey.shade300,
                    ),
                  ),
                  child: ResponsiveText(
                    entry.value,
                    style: AppTheme.smallText.copyWith(
                      color: isSelected ? AppTheme.darkBrown : Colors.grey.shade600,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildQuantityAndUnit() {
    final availableUnits = _units[_productType] ?? ['كيلو'];

    return Padding(
      padding: ResponsiveHelper.getScreenPadding(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ResponsiveText(
            'الكمية والوحدة',
            style: AppTheme.labelText,
          ),
          SizedBox(height: ResponsiveHelper.getCardSpacing(context)),
          ResponsiveRow(
            children: [
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ResponsiveText(
                      'الكمية',
                      style: AppTheme.smallText.copyWith(color: Colors.grey.shade600),
                    ),
                    SizedBox(height: ResponsiveHelper.getCardSpacing(context) / 2),
                    TextField(
                      controller: _quantityController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: '0.0',
                        hintStyle: AppTheme.smallText.copyWith(color: Colors.grey),
                        border: InputBorder.none,
                        contentPadding: ResponsiveHelper.getButtonPadding(context),
                      ),
                      style: AppTheme.bodyText,
                    ),
                    Container(
                      height: 1,
                      color: AppTheme.primaryYellow,
                    ),
                  ],
                ),
              ),
              SizedBox(width: ResponsiveHelper.getCardSpacing(context)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ResponsiveText(
                      'الوحدة',
                      style: AppTheme.smallText.copyWith(color: Colors.grey.shade600),
                    ),
                    SizedBox(height: ResponsiveHelper.getCardSpacing(context) / 2),
                    GestureDetector(
                      onTap: () => _showUnitSelector(availableUnits),
                      child: Container(
                        width: double.infinity,
                        padding: ResponsiveHelper.getButtonPadding(context),
                        child: ResponsiveText(
                          _unit,
                          style: AppTheme.bodyText,
                        ),
                      ),
                    ),
                    Container(
                      height: 1,
                      color: AppTheme.primaryYellow,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQualityAndMoisture() {
    return Padding(
      padding: ResponsiveHelper.getScreenPadding(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ResponsiveText(
            'الجودة والخصائص',
            style: AppTheme.labelText,
          ),
          SizedBox(height: ResponsiveHelper.getCardSpacing(context)),
          ResponsiveText(
            'الجودة',
            style: AppTheme.smallText.copyWith(color: Colors.grey.shade600),
          ),
          SizedBox(height: ResponsiveHelper.getCardSpacing(context) / 2),
          Wrap(
            spacing: ResponsiveHelper.getCardSpacing(context) / 2,
            children: _qualities.entries.map((entry) {
              final isSelected = _quality == entry.key;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _quality = entry.key;
                  });
                },
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: ResponsiveHelper.getCardSpacing(context),
                    vertical: ResponsiveHelper.getCardSpacing(context) / 2,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected ? AppTheme.primaryYellow.withAlpha(51) : Colors.transparent, // Adjusted for opacity
                    border: Border.all(
                      color: isSelected ? AppTheme.primaryYellow : Colors.grey.shade300,
                    ),
                  ),
                  child: ResponsiveText(
                    entry.value,
                    style: AppTheme.smallText.copyWith(
                      color: isSelected ? AppTheme.darkBrown : Colors.grey.shade600,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          if (_productType == 'honey') ...[
            SizedBox(height: ResponsiveHelper.getCardSpacing(context)),
            ResponsiveText(
              'نسبة الرطوبة: ${_moistureContent.toStringAsFixed(1)}%',
              style: AppTheme.smallText.copyWith(color: Colors.grey.shade600),
            ),
            Slider(
              value: _moistureContent,
              min: 15.0,
              max: 25.0,
              divisions: 100,
              activeColor: AppTheme.primaryYellow,
              onChanged: (value) {
                setState(() {
                  _moistureContent = value;
                });
              },
            ),
            ResponsiveText(
              _moistureContent <= 18.5 ? 'رطوبة ممتازة' :
              _moistureContent <= 20.0 ? 'رطوبة جيدة' : 'رطوبة عالية',
              style: AppTheme.smallText.copyWith(
                color: _moistureContent <= 18.5 ? AppTheme.successColor :
                _moistureContent <= 20.0 ? AppTheme.warningColor : AppTheme.errorColor,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildHarvestDate() {
    return Padding(
      padding: ResponsiveHelper.getScreenPadding(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ResponsiveText(
            'تاريخ الحصاد',
            style: AppTheme.labelText,
          ),
          SizedBox(height: ResponsiveHelper.getCardSpacing(context)),
          GestureDetector(
            onTap: () => _selectDate(),
            child: Container(
              width: double.infinity,
              padding: ResponsiveHelper.getButtonPadding(context),
              child: ResponsiveText(
                '${_harvestDate.day}/${_harvestDate.month}/${_harvestDate.year}',
                style: AppTheme.bodyText,
              ),
            ),
          ),
          Container(
            height: 1,
            color: AppTheme.primaryYellow,
            margin: EdgeInsets.only(top: ResponsiveHelper.getCardSpacing(context)),
          ),
        ],
      ),
    );
  }

  Widget _buildSeasonSelection() {
    return Padding(
      padding: ResponsiveHelper.getScreenPadding(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ResponsiveText(
            'الموسم',
            style: AppTheme.labelText,
          ),
          SizedBox(height: ResponsiveHelper.getCardSpacing(context)),
          ResponsiveRow(
            children: _seasons.entries.map((entry) {
              final isSelected = _season == entry.key;
              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _season = entry.key;
                    });
                  },
                  child: Container(
                    padding: ResponsiveHelper.getButtonPadding(context),
                    margin: EdgeInsets.symmetric(horizontal: ResponsiveHelper.getCardSpacing(context) / 2),
                    decoration: BoxDecoration(
                      color: isSelected ? AppTheme.primaryYellow.withAlpha(51) : Colors.transparent, // Adjusted for opacity
                      border: Border.all(
                        color: isSelected ? AppTheme.primaryYellow : Colors.grey.shade300,
                      ),
                    ),
                    child: ResponsiveText(
                      entry.value,
                      style: AppTheme.smallText.copyWith(
                        color: isSelected ? AppTheme.darkBrown : Colors.grey.shade600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceSection() {
    return Padding(
      padding: ResponsiveHelper.getScreenPadding(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ResponsiveText(
            'معلومات البيع',
            style: AppTheme.labelText,
          ),
          SizedBox(height: ResponsiveHelper.getCardSpacing(context)),
          ResponsiveRow(
            children: [
              Expanded(
                child: ResponsiveText(
                  'تم البيع',
                  style: AppTheme.bodyText,
                ),
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    _isSold = !_isSold;
                  });
                },
                child: Container(
                  width: ResponsiveHelper.getIconSize(context, 1.5), // Added context
                  height: ResponsiveHelper.getIconSize(context, 1.0), // Added context
                  decoration: BoxDecoration(
                    color: _isSold ? AppTheme.primaryYellow : Colors.transparent,
                    border: Border.all(
                      color: _isSold ? AppTheme.primaryYellow : Colors.grey.shade400,
                    ),
                  ),
                  child: _isSold
                      ? ResponsiveIcon(
                    Icons.check,
                    color: AppTheme.darkBrown,
                  )
                      : null,
                ),
              ),
            ],
          ),
          if (_isSold) ...[
            SizedBox(height: ResponsiveHelper.getCardSpacing(context)),
            ResponsiveRow(
              children: [
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ResponsiveText(
                        'السعر',
                        style: AppTheme.smallText.copyWith(color: Colors.grey.shade600),
                      ),
                      SizedBox(height: ResponsiveHelper.getCardSpacing(context) / 2),
                      TextField(
                        controller: _priceController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          hintText: '0.00',
                          hintStyle: AppTheme.smallText.copyWith(color: Colors.grey),
                          border: InputBorder.none,
                          contentPadding: ResponsiveHelper.getButtonPadding(context),
                        ),
                        style: AppTheme.bodyText,
                      ),
                      Container(
                        height: 1,
                        color: AppTheme.primaryYellow,
                      ),
                    ],
                  ),
                ),
                SizedBox(width: ResponsiveHelper.getCardSpacing(context)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ResponsiveText(
                        'العملة',
                        style: AppTheme.smallText.copyWith(color: Colors.grey.shade600),
                      ),
                      SizedBox(height: ResponsiveHelper.getCardSpacing(context) / 2),
                      GestureDetector(
                        onTap: () => _showCurrencySelector(),
                        child: Container(
                          width: double.infinity,
                          padding: ResponsiveHelper.getButtonPadding(context),
                          child: ResponsiveText(
                            _currency,
                            style: AppTheme.bodyText,
                          ),
                        ),
                      ),
                      Container(
                        height: 1,
                        color: AppTheme.primaryYellow,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: ResponsiveHelper.getCardSpacing(context)),
            ResponsiveText(
              'المشتري (اختياري)',
              style: AppTheme.smallText.copyWith(color: Colors.grey.shade600),
            ),
            SizedBox(height: ResponsiveHelper.getCardSpacing(context) / 2),
            TextField(
              controller: _buyerController,
              decoration: InputDecoration(
                hintText: 'اسم المشتري أو الشركة...',
                hintStyle: AppTheme.smallText.copyWith(color: Colors.grey),
                border: InputBorder.none,
                contentPadding: ResponsiveHelper.getButtonPadding(context),
              ),
              style: AppTheme.bodyText,
            ),
            Container(
              height: 1,
              color: AppTheme.primaryYellow,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildNotes() {
    return Padding(
      padding: ResponsiveHelper.getScreenPadding(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ResponsiveText(
            'ملاحظات إضافية',
            style: AppTheme.labelText,
          ),
          SizedBox(height: ResponsiveHelper.getCardSpacing(context)),
          TextField(
            controller: _notesController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'ملاحظات حول المنتج، اللون، الطعم، مصدر الرحيق...',
              hintStyle: AppTheme.smallText.copyWith(color: Colors.grey),
              border: InputBorder.none,
              contentPadding: ResponsiveHelper.getButtonPadding(context),
            ),
            style: AppTheme.bodyText,
          ),
          Container(
            height: 1,
            color: AppTheme.primaryYellow,
          ),
        ],
      ),
    );
  }

  Widget _buildSaveButton(bool isEditing) {
    return Padding(
      padding: ResponsiveHelper.getScreenPadding(context),
      child: ResponsiveButton(
        text: _isLoading
            ? 'جاري الحفظ...'
            : isEditing
            ? 'تحديث الإنتاج'
            : 'حفظ الإنتاج',
        onPressed: _isLoading ? null : _saveProduction,
        backgroundColor: AppTheme.successColor,
        foregroundColor: Colors.white,
        icon: isEditing ? Icons.update : Icons.save,
      ),
    );
  }

  void _showHiveSelector() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: ResponsiveHelper.getScreenPadding(context),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ResponsiveText(
                'اختر خلية',
                style: AppTheme.titleText,
              ),
              SizedBox(height: ResponsiveHelper.getCardSpacing(context)),
              ...List.generate(5, (index) {
                final hiveNumber = index + 1;
                return ListTile(
                  title: ResponsiveText(
                    'خلية رقم $hiveNumber',
                    style: AppTheme.bodyText,
                  ),
                  subtitle: ResponsiveText(
                    'نشطة - 8 إطارات',
                    style: AppTheme.smallText.copyWith(color: Colors.grey.shade600),
                  ),
                  onTap: () {
                    setState(() {
                      _selectedHiveId = hiveNumber.toString();
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

  void _showUnitSelector(List<String> units) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: ResponsiveHelper.getScreenPadding(context),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ResponsiveText(
                'اختر الوحدة',
                style: AppTheme.titleText,
              ),
              SizedBox(height: ResponsiveHelper.getCardSpacing(context)),
              ...units.map((unit) {
                return ListTile(
                  title: ResponsiveText(
                    unit,
                    style: AppTheme.bodyText,
                  ),
                  onTap: () {
                    setState(() {
                      _unit = unit;
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

  void _showCurrencySelector() {
    final currencies = ['ريال', 'دولار', 'يورو', 'درهم'];

    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: ResponsiveHelper.getScreenPadding(context),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ResponsiveText(
                'اختر العملة',
                style: AppTheme.titleText,
              ),
              SizedBox(height: ResponsiveHelper.getCardSpacing(context)),
              ...currencies.map((currency) {
                return ListTile(
                  title: ResponsiveText(
                    currency,
                    style: AppTheme.bodyText,
                  ),
                  onTap: () {
                    setState(() {
                      _currency = currency;
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

  void _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _harvestDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (date != null) {
      setState(() {
        _harvestDate = date;
        _updateSeason();
      });
    }
  }

  void _updateSeason() {
    final month = _harvestDate.month;
    if (month >= 3 && month <= 5) {
      _season = 'spring';
    } else if (month >= 6 && month <= 8) {
      _season = 'summer';
    } else if (month >= 9 && month <= 11) {
      _season = 'autumn';
    } else {
      _season = 'winter';
    }
  }

  void _loadProductionData() {
    setState(() {
      _selectedHiveId = '1';
      _productType = 'honey';
      _quantityController.text = '25.5';
      _unit = 'كيلو';
      _quality = 'excellent';
      _moistureContent = 18.2;
      _priceController.text = '150.0';
      _currency = 'ريال';
      _buyerController.text = 'محل العسل الطبيعي';
      _notesController.text = 'عسل سدر ممتاز، لون ذهبي فاتح';
      _isSold = true;
    });
  }

  void _saveProduction() async {
    if (_formKey.currentState!.validate() &&
        _selectedHiveId != null &&
        _quantityController.text.isNotEmpty) {

      setState(() {
        _isLoading = true;
      });

      try {
        await Future.delayed(const Duration(seconds: 2));

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: ResponsiveText(
                  widget.productionId != null
                      ? 'تم تحديث الإنتاج بنجاح'
                      : 'تم حفظ الإنتاج بنجاح'
              ),
              backgroundColor: AppTheme.successColor,
            ),
          );

          Navigator.pop(context, true);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: ResponsiveText('حدث خطأ أثناء الحفظ'),
              backgroundColor: AppTheme.errorColor,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: ResponsiveText('يرجى ملء جميع الحقول المطلوبة'),
          backgroundColor: AppTheme.warningColor,
        ),
      );
    }
  }
}
