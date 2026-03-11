import 'package:flutter/material.dart';
import '../utils/app_theme.dart';
import '../utils/responsive_helper.dart';
import '../widgets/custom_app_bar.dart';
import '../services/ad_service.dart';

class AddTreatmentScreen extends StatefulWidget {
  final String? treatmentId;

  const AddTreatmentScreen({
    super.key,
    this.treatmentId,
  });

  @override
  State<AddTreatmentScreen> createState() => _AddTreatmentScreenState();
}

class _AddTreatmentScreenState extends State<AddTreatmentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _treatmentNameController = TextEditingController();
  final _dosageController = TextEditingController();
  final _reasonController = TextEditingController();
  final _notesController = TextEditingController();

  String? _selectedHiveId;
  String _treatmentType = 'varroa';
  DateTime _startDate = DateTime.now();
  int _durationWeeks = 4;
  bool _setReminder = true;
  bool _isLoading = false;

  final Map<String, String> _treatmentTypes = {
    'varroa': 'علاج الفاروا',
    'nosema': 'علاج النوزيما',
    'antibiotic': 'مضاد حيوي',
    'antifungal': 'مضاد فطري',
    'nutritional': 'مكمل غذائي',
    'preventive': 'علاج وقائي',
    'other': 'أخرى',
  };

  final Map<String, List<String>> _commonTreatments = {
    'varroa': ['أبيستان', 'أبيفار', 'فاروميت', 'بايفارول', 'أميتراز'],
    'nosema': ['فوماجيلين', 'نوزيفيت', 'فوماستوب'],
    'antibiotic': ['تيراميسين', 'أوكسي تتراسيكلين', 'كلورامفينيكول'],
    'antifungal': ['نيستاتين', 'أمفوتيريسين ب'],
    'nutritional': ['بروتين باتي', 'فيتامين سي', 'أحماض أمينية'],
    'preventive': ['زيت الثيمول', 'حمض الفورميك', 'حمض الأوكساليك'],
    'other': [],
  };

  @override
  void initState() {
    super.initState();
    // Corrected AdScreen values
    AdManager.onScreenChange(AdScreen.addHive, AdScreen.hiveList);
    if (widget.treatmentId != null) {
      _loadTreatmentData();
    }
  }

  @override
  void dispose() {
    _treatmentNameController.dispose();
    _dosageController.dispose();
    _reasonController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.treatmentId != null;

    return AdAwareScaffold(
      screen: AdScreen.addHive, // Corrected AdScreen value
      appBar: CustomAppBar(
        title: isEditing ? 'تعديل العلاج' : 'إضافة علاج جديد',
      ),
      body: ResponsiveContainer(
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildHiveSelection(),
              _buildTreatmentType(),
              _buildTreatmentName(),
              _buildDosage(),
              _buildDateAndDuration(),
              _buildReason(),
              _buildReminderOption(),
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

  Widget _buildTreatmentType() {
    return Padding(
      padding: ResponsiveHelper.getScreenPadding(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ResponsiveText(
            'نوع العلاج',
            style: AppTheme.labelText,
          ),
          SizedBox(height: ResponsiveHelper.getCardSpacing(context)),
          Wrap(
            spacing: ResponsiveHelper.getCardSpacing(context),
            runSpacing: ResponsiveHelper.getCardSpacing(context) / 2,
            children: _treatmentTypes.entries.map((entry) {
              final isSelected = _treatmentType == entry.key;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _treatmentType = entry.key;
                    _treatmentNameController.clear();
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

  Widget _buildTreatmentName() {
    final commonTreatments = _commonTreatments[_treatmentType] ?? [];

    return Padding(
      padding: ResponsiveHelper.getScreenPadding(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ResponsiveText(
            'اسم العلاج',
            style: AppTheme.labelText,
          ),
          SizedBox(height: ResponsiveHelper.getCardSpacing(context)),
          if (commonTreatments.isNotEmpty) ...[
            ResponsiveText(
              'اختر من القائمة أو اكتب اسم مخصص:',
              style: AppTheme.smallText.copyWith(color: Colors.grey.shade600),
            ),
            SizedBox(height: ResponsiveHelper.getCardSpacing(context) / 2),
            Wrap(
              spacing: ResponsiveHelper.getCardSpacing(context) / 2,
              runSpacing: ResponsiveHelper.getCardSpacing(context) / 2,
              children: commonTreatments.map((treatment) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _treatmentNameController.text = treatment;
                    });
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: ResponsiveHelper.getCardSpacing(context) / 2,
                      vertical: ResponsiveHelper.getCardSpacing(context) / 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryYellow.withAlpha(25), // Adjusted for opacity
                      border: Border.all(color: AppTheme.primaryYellow.withAlpha(76)), // Adjusted for opacity
                    ),
                    child: ResponsiveText(
                      treatment,
                      style: AppTheme.smallText,
                    ),
                  ),
                );
              }).toList(),
            ),
            SizedBox(height: ResponsiveHelper.getCardSpacing(context)),
          ],
          TextField(
            controller: _treatmentNameController,
            decoration: InputDecoration(
              hintText: 'اكتب اسم العلاج...',
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

  Widget _buildDosage() {
    return Padding(
      padding: ResponsiveHelper.getScreenPadding(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ResponsiveText(
            'الجرعة والطريقة',
            style: AppTheme.labelText,
          ),
          SizedBox(height: ResponsiveHelper.getCardSpacing(context)),
          TextField(
            controller: _dosageController,
            decoration: InputDecoration(
              hintText: 'مثال: 2 شريط، 1 جرام/لتر، 200 مجم...',
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

  Widget _buildDateAndDuration() {
    return Padding(
      padding: ResponsiveHelper.getScreenPadding(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ResponsiveText(
            'تاريخ البدء والمدة',
            style: AppTheme.labelText,
          ),
          SizedBox(height: ResponsiveHelper.getCardSpacing(context)),
          ResponsiveRow(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ResponsiveText(
                      'تاريخ البدء',
                      style: AppTheme.smallText.copyWith(color: Colors.grey.shade600),
                    ),
                    SizedBox(height: ResponsiveHelper.getCardSpacing(context) / 2),
                    GestureDetector(
                      onTap: () => _selectDate(),
                      child: Container(
                        width: double.infinity,
                        padding: ResponsiveHelper.getButtonPadding(context),
                        child: ResponsiveText(
                          '${_startDate.day}/${_startDate.month}/${_startDate.year}',
                          style: AppTheme.bodyText,
                        ),
                      ),
                    ),
                    Container(
                      height: 1,
                      color: AppTheme.primaryYellow,
                      margin: EdgeInsets.only(top: ResponsiveHelper.getCardSpacing(context) / 2),
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
                      'المدة (أسابيع)',
                      style: AppTheme.smallText.copyWith(color: Colors.grey.shade600),
                    ),
                    SizedBox(height: ResponsiveHelper.getCardSpacing(context) / 2),
                    ResponsiveRow(
                      children: [
                        GestureDetector(
                          onTap: () {
                            if (_durationWeeks > 1) {
                              setState(() {
                                _durationWeeks--;
                              });
                            }
                          },
                          child: Container(
                            padding: EdgeInsets.all(ResponsiveHelper.getCardSpacing(context) / 2),
                            decoration: BoxDecoration(
                              border: Border.all(color: AppTheme.primaryYellow),
                            ),
                            child: ResponsiveIcon(
                              Icons.remove,
                              color: AppTheme.primaryYellow,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            padding: ResponsiveHelper.getButtonPadding(context),
                            child: ResponsiveText(
                              '$_durationWeeks',
                              style: AppTheme.bodyText,
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _durationWeeks++;
                            });
                          },
                          child: Container(
                            padding: EdgeInsets.all(ResponsiveHelper.getCardSpacing(context) / 2),
                            decoration: BoxDecoration(
                              border: Border.all(color: AppTheme.primaryYellow),
                            ),
                            child: ResponsiveIcon(
                              Icons.add,
                              color: AppTheme.primaryYellow,
                            ),
                          ),
                        ),
                      ],
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

  Widget _buildReason() {
    return Padding(
      padding: ResponsiveHelper.getScreenPadding(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ResponsiveText(
            'سبب العلاج',
            style: AppTheme.labelText,
          ),
          SizedBox(height: ResponsiveHelper.getCardSpacing(context)),
          TextField(
            controller: _reasonController,
            decoration: InputDecoration(
              hintText: 'مثال: ظهور أعراض الفاروا، وقاية من الأمراض...',
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

  Widget _buildReminderOption() {
    return Padding(
      padding: ResponsiveHelper.getScreenPadding(context),
      child: ResponsiveRow(
        children: [
          Expanded(
            child: ResponsiveText(
              'تذكير بانتهاء العلاج',
              style: AppTheme.bodyText,
            ),
          ),
          GestureDetector(
            onTap: () {
              setState(() {
                _setReminder = !_setReminder;
              });
            },
            child: Container(
              width: ResponsiveHelper.getIconSize(context, 1.5), // Added context
              height: ResponsiveHelper.getIconSize(context, 1.0), // Added context
              decoration: BoxDecoration(
                color: _setReminder ? AppTheme.primaryYellow : Colors.transparent,
                border: Border.all(
                  color: _setReminder ? AppTheme.primaryYellow : Colors.grey.shade400,
                ),
              ),
              child: _setReminder
                  ? ResponsiveIcon(
                Icons.check,
                color: AppTheme.darkBrown,
              )
                  : null,
            ),
          ),
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
              hintText: 'ملاحظات حول العلاج، طريقة التطبيق، النتائج المتوقعة...',
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
            ? 'تحديث العلاج'
            : 'حفظ العلاج',
        onPressed: _isLoading ? null : _saveTreatment,
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

  void _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (date != null) {
      setState(() {
        _startDate = date;
      });
    }
  }

  void _loadTreatmentData() {
    setState(() {
      _selectedHiveId = '1';
      _treatmentType = 'varroa';
      _treatmentNameController.text = 'أبيستان';
      _dosageController.text = '2 شريط';
      _reasonController.text = 'علاج الفاروا';
      _notesController.text = 'تم وضع الشرائط في الجزء العلوي من الخلية';
      _durationWeeks = 6;
      _setReminder = true;
    });
  }

  void _saveTreatment() async {
    if (_formKey.currentState!.validate() &&
        _selectedHiveId != null &&
        _treatmentNameController.text.isNotEmpty) {

      setState(() {
        _isLoading = true;
      });

      try {
        await Future.delayed(const Duration(seconds: 2));

        await AdManager.onTreatmentAdded();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: ResponsiveText(
                  widget.treatmentId != null
                      ? 'تم تحديث العلاج بنجاح'
                      : 'تم حفظ العلاج بنجاح'
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
