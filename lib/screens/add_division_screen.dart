import 'package:flutter/material.dart';
import '../utils/app_theme.dart';
import '../utils/responsive_helper.dart';
import '../widgets/custom_app_bar.dart';
import '../services/ad_service.dart';

class AddDivisionScreen extends StatefulWidget {
  final String? divisionId;

  const AddDivisionScreen({
    super.key,
    this.divisionId,
  });

  @override
  State<AddDivisionScreen> createState() => _AddDivisionScreenState();
}

class _AddDivisionScreenState extends State<AddDivisionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nucleusNameController = TextEditingController();
  final _notesController = TextEditingController();

  String? _selectedParentHiveId;
  DateTime _divisionDate = DateTime.now();
  int _frameCount = 3;
  String _queenStatus = 'accepted';
  String _queenType = 'natural';
  String _strength = 'medium';
  bool _hasQueen = true;
  bool _isLoading = false;

  final Map<String, String> _queenStatuses = {
    'accepted': 'مقبولة',
    'laying': 'تبيض',
    'missing': 'مفقودة',
    'rejected': 'مرفوضة',
  };

  final Map<String, String> _queenTypes = {
    'natural': 'طبيعية (خلية أم)',
    'introduced': 'مدخلة',
    'virgin': 'عذراء',
  };

  final Map<String, String> _strengths = {
    'weak': 'ضعيف',
    'medium': 'متوسط',
    'strong': 'قوي',
  };

  @override
  void initState() {
    super.initState();
    // Corrected AdScreen values
    AdManager.onScreenChange(AdScreen.addHive, AdScreen.hiveList);
    if (widget.divisionId != null) {
      _loadDivisionData();
    }
  }

  @override
  void dispose() {
    _nucleusNameController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.divisionId != null;

    return AdAwareScaffold(
      screen: AdScreen.addHive, // Corrected AdScreen value
      appBar: CustomAppBar(
        title: isEditing ? 'تعديل التقسيم' : 'إنشاء تقسيم جديد',
      ),
      body: ResponsiveContainer(
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildParentHiveSelection(),
              _buildNucleusName(),
              _buildDivisionDate(),
              _buildFrameCount(),
              _buildQueenSection(),
              _buildStrengthSelection(),
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

  Widget _buildParentHiveSelection() {
    return Padding(
      padding: ResponsiveHelper.getScreenPadding(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ResponsiveText(
            'الخلية الأم للتقسيم',
            style: AppTheme.labelText,
          ),
          SizedBox(height: ResponsiveHelper.getCardSpacing(context)),
          GestureDetector(
            onTap: () => _showParentHiveSelector(),
            child: Container(
              width: double.infinity,
              padding: ResponsiveHelper.getButtonPadding(context),
              child: ResponsiveText(
                _selectedParentHiveId != null ? 'خلية رقم $_selectedParentHiveId' : 'اختر الخلية الأم',
                style: AppTheme.bodyText.copyWith(
                  color: _selectedParentHiveId != null ? AppTheme.darkBrown : Colors.grey,
                ),
              ),
            ),
          ),
          Container(
            height: 1,
            color: AppTheme.primaryYellow,
            margin: EdgeInsets.only(top: ResponsiveHelper.getCardSpacing(context)),
          ),
          if (_selectedParentHiveId != null) ...[
            SizedBox(height: ResponsiveHelper.getCardSpacing(context) / 2),
            Container(
              padding: const EdgeInsets.all(16.0), // Replaced getCardPadding
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: ResponsiveRow(
                children: [
                  ResponsiveIcon(
                    Icons.info_outline,
                    color: Colors.blue.shade600,
                  ),
                  SizedBox(width: ResponsiveHelper.getCardSpacing(context)),
                  Expanded(
                    child: ResponsiveText(
                      'سيتم ربط الطرد الجديد بهذه الخلية وتتبع نموه حتى الترقية',
                      style: AppTheme.smallText.copyWith(color: Colors.blue.shade700),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildNucleusName() {
    return Padding(
      padding: ResponsiveHelper.getScreenPadding(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ResponsiveText(
            'اسم الطرد الجديد',
            style: AppTheme.labelText,
          ),
          SizedBox(height: ResponsiveHelper.getCardSpacing(context)),
          TextField(
            controller: _nucleusNameController,
            decoration: InputDecoration(
              hintText: 'مثال: طرد رقم 6، طرد الربيع 2024...',
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

  Widget _buildDivisionDate() {
    return Padding(
      padding: ResponsiveHelper.getScreenPadding(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ResponsiveText(
            'تاريخ التقسيم',
            style: AppTheme.labelText,
          ),
          SizedBox(height: ResponsiveHelper.getCardSpacing(context)),
          GestureDetector(
            onTap: () => _selectDate(),
            child: Container(
              width: double.infinity,
              padding: ResponsiveHelper.getButtonPadding(context),
              child: ResponsiveText(
                '${_divisionDate.day}/${_divisionDate.month}/${_divisionDate.year}',
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

  Widget _buildFrameCount() {
    return Padding(
      padding: ResponsiveHelper.getScreenPadding(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ResponsiveText(
            'عدد الإطارات في الطرد',
            style: AppTheme.labelText,
          ),
          SizedBox(height: ResponsiveHelper.getCardSpacing(context)),
          ResponsiveRow(
            children: [
              GestureDetector(
                onTap: () {
                  if (_frameCount > 1) {
                    setState(() {
                      _frameCount--;
                    });
                  }
                },
                child: Container(
                  padding: EdgeInsets.all(ResponsiveHelper.getCardSpacing(context)),
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
                    '$_frameCount إطار',
                    style: AppTheme.titleText,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  if (_frameCount < 6) {
                    setState(() {
                      _frameCount++;
                    });
                  }
                },
                child: Container(
                  padding: EdgeInsets.all(ResponsiveHelper.getCardSpacing(context)),
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
          SizedBox(height: ResponsiveHelper.getCardSpacing(context) / 2),
          if (_frameCount >= 5) ...[
            Container(
              padding: const EdgeInsets.all(16.0), // Replaced getCardPadding
              decoration: BoxDecoration(
                color: AppTheme.successColor.withAlpha(25), // Adjusted for opacity
                border: Border.all(color: AppTheme.successColor),
              ),
              child: ResponsiveRow(
                children: [
                  ResponsiveIcon(
                    Icons.trending_up,
                    color: AppTheme.successColor,
                  ),
                  SizedBox(width: ResponsiveHelper.getCardSpacing(context)),
                  Expanded(
                    child: ResponsiveText(
                      'هذا الطرد جاهز للترقية إلى خلية مستقلة!',
                      style: AppTheme.smallText.copyWith(color: AppTheme.successColor),
                    ),
                  ),
                ],
              ),
            ),
          ] else ...[
            ResponsiveText(
              'سيكون جاهزاً للترقية عند الوصول لـ 5-6 إطارات',
              style: AppTheme.smallText.copyWith(color: Colors.grey.shade600),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildQueenSection() {
    return Padding(
      padding: ResponsiveHelper.getScreenPadding(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ResponsiveText(
            'معلومات الملكة',
            style: AppTheme.labelText,
          ),
          SizedBox(height: ResponsiveHelper.getCardSpacing(context)),
          ResponsiveRow(
            children: [
              Expanded(
                child: ResponsiveText(
                  'يحتوي على ملكة',
                  style: AppTheme.bodyText,
                ),
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    _hasQueen = !_hasQueen;
                  });
                },
                child: Container(
                  width: ResponsiveHelper.getIconSize(context, 1.5), // Added context
                  height: ResponsiveHelper.getIconSize(context, 1.0), // Added context
                  decoration: BoxDecoration(
                    color: _hasQueen ? AppTheme.primaryYellow : Colors.transparent,
                    border: Border.all(
                      color: _hasQueen ? AppTheme.primaryYellow : Colors.grey.shade400,
                    ),
                  ),
                  child: _hasQueen
                      ? ResponsiveIcon(
                    Icons.check,
                    color: AppTheme.darkBrown,
                  )
                      : null,
                ),
              ),
            ],
          ),
          if (_hasQueen) ...[
            SizedBox(height: ResponsiveHelper.getCardSpacing(context)),
            ResponsiveText(
              'نوع الملكة',
              style: AppTheme.smallText.copyWith(color: Colors.grey.shade600),
            ),
            SizedBox(height: ResponsiveHelper.getCardSpacing(context) / 2),
            Wrap(
              spacing: ResponsiveHelper.getCardSpacing(context) / 2,
              runSpacing: ResponsiveHelper.getCardSpacing(context) / 2,
              children: _queenTypes.entries.map((entry) {
                final isSelected = _queenType == entry.key;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _queenType = entry.key;
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
            SizedBox(height: ResponsiveHelper.getCardSpacing(context)),
            ResponsiveText(
              'حالة الملكة',
              style: AppTheme.smallText.copyWith(color: Colors.grey.shade600),
            ),
            SizedBox(height: ResponsiveHelper.getCardSpacing(context) / 2),
            Wrap(
              spacing: ResponsiveHelper.getCardSpacing(context) / 2,
              runSpacing: ResponsiveHelper.getCardSpacing(context) / 2,
              children: _queenStatuses.entries.map((entry) {
                final isSelected = _queenStatus == entry.key;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _queenStatus = entry.key;
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
        ],
      ),
    );
  }

  Widget _buildStrengthSelection() {
    return Padding(
      padding: ResponsiveHelper.getScreenPadding(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ResponsiveText(
            'قوة الطرد',
            style: AppTheme.labelText,
          ),
          SizedBox(height: ResponsiveHelper.getCardSpacing(context)),
          ResponsiveRow(
            children: _strengths.entries.map((entry) {
              final isSelected = _strength == entry.key;
              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _strength = entry.key;
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

  Widget _buildNotes() {
    return Padding(
      padding: ResponsiveHelper.getScreenPadding(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ResponsiveText(
            'ملاحظات التقسيم',
            style: AppTheme.labelText,
          ),
          SizedBox(height: ResponsiveHelper.getCardSpacing(context)),
          TextField(
            controller: _notesController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'ملاحظات حول التقسيم، حالة الحضنة، قوة النحل، توقعات النمو...',
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
            ? 'تحديث التقسيم'
            : 'حفظ التقسيم',
        onPressed: _isLoading ? null : _saveDivision,
        backgroundColor: AppTheme.successColor,
        foregroundColor: Colors.white,
        icon: isEditing ? Icons.update : Icons.save,
      ),
    );
  }

  void _showParentHiveSelector() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: ResponsiveHelper.getScreenPadding(context),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ResponsiveText(
                'اختر الخلية الأم',
                style: AppTheme.titleText,
              ),
              SizedBox(height: ResponsiveHelper.getCardSpacing(context)),
              ResponsiveText(
                'اختر الخلية القوية التي ستقسم منها',
                style: AppTheme.smallText.copyWith(color: Colors.grey.shade600),
              ),
              SizedBox(height: ResponsiveHelper.getCardSpacing(context)),
              ...List.generate(5, (index) {
                final hiveNumber = index + 1;
                final isStrong = index < 3;
                return ListTile(
                  leading: ResponsiveIcon(
                    Icons.hive,
                    color: isStrong ? AppTheme.successColor : AppTheme.warningColor,
                  ),
                  title: ResponsiveText(
                    'خلية رقم $hiveNumber',
                    style: AppTheme.bodyText,
                  ),
                  subtitle: ResponsiveText(
                    isStrong ? 'قوية - 10 إطارات - جاهزة للتقسيم' : 'متوسطة - 7 إطارات',
                    style: AppTheme.smallText.copyWith(
                      color: isStrong ? AppTheme.successColor : AppTheme.warningColor,
                    ),
                  ),
                  enabled: isStrong,
                  onTap: isStrong ? () {
                    setState(() {
                      _selectedParentHiveId = hiveNumber.toString();
                    });
                    Navigator.pop(context);
                  } : null,
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
      initialDate: _divisionDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (date != null) {
      setState(() {
        _divisionDate = date;
      });
    }
  }

  void _loadDivisionData() {
    setState(() {
      _selectedParentHiveId = '1';
      _nucleusNameController.text = 'طرد رقم 6';
      _frameCount = 4;
      _queenStatus = 'accepted';
      _queenType = 'natural';
      _strength = 'medium';
      _hasQueen = true;
      _notesController.text = 'طرد قوي، الملكة مقبولة والحضنة جيدة';
    });
  }

  void _saveDivision() async {
    if (_formKey.currentState!.validate() &&
        _selectedParentHiveId != null &&
        _nucleusNameController.text.isNotEmpty) {

      setState(() {
        _isLoading = true;
      });

      try {
        await Future.delayed(const Duration(seconds: 2));

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: ResponsiveText(
                  widget.divisionId != null
                      ? 'تم تحديث التقسيم بنجاح'
                      : 'تم حفظ التقسيم بنجاح'
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
