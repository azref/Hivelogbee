import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/inspection_model.dart';
import '../providers/inspection_provider.dart';
import '../providers/auth_provider.dart';
import '../utils/app_theme.dart';
import '../utils/responsive_helper.dart';
import '../widgets/custom_app_bar.dart';
import '../services/ad_service.dart';
import '../l10n/app_localizations.dart';

class AddInspectionScreen extends StatefulWidget {
  final String? hiveId;

  const AddInspectionScreen({
    super.key,
    this.hiveId,
  });

  @override
  State<AddInspectionScreen> createState() => _AddInspectionScreenState();
}

class _AddInspectionScreenState extends State<AddInspectionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _notesController = TextEditingController();

  String? _selectedHiveId;
  DateTime _inspectionDate = DateTime.now();
  QueenPresence _queenStatus = QueenPresence.present;
  BroodPattern _broodPattern = BroodPattern.good;
  HiveHealth _hiveHealth = HiveHealth.strong;
  final Temperament _temperament = Temperament.calm;
  double _temperature = 25.0;
  double _humidity = 60.0;
  final List<InspectionIssue> _selectedIssues = [];
  final bool _eggsSeen = false;
  final bool _queenCellsSeen = false;
  bool _isLoading = false;

  // تم تحويلها لتتوافق مع الـ enum
  final List<InspectionIssue> _availableIssues = InspectionIssue.values;

  @override
  void initState() {
    super.initState();
    _selectedHiveId = widget.hiveId;
    AdManager.onScreenChange(AdScreen.addInspection, null);
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return AdAwareScaffold(
      screen: AdScreen.addInspection,
      appBar: CustomAppBar(
        title: l10n.add_inspection,
      ),
      body: ResponsiveContainer(
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildHiveSelection(l10n),
              _buildDateSelection(l10n),
              _buildQueenStatus(l10n),
              _buildBroodStatus(l10n),
              _buildEnvironmentalData(l10n),
              _buildOverallStatus(l10n),
              _buildIssuesSelection(l10n),
              _buildNotesField(l10n),
              SizedBox(height: ResponsiveHelper.getCardSpacing(context) * 2),
              _buildSaveButton(l10n),
              SizedBox(height: ResponsiveHelper.getCardSpacing(context) * 4),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHiveSelection(AppLocalizations l10n) {
    return Padding(
      padding: ResponsiveHelper.getScreenPadding(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ResponsiveText(
            'اختيار الخلية', // لا يوجد مفتاح ترجمة لهذا في ملف .arb
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

  Widget _buildDateSelection(AppLocalizations l10n) {
    return Padding(
      padding: ResponsiveHelper.getScreenPadding(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ResponsiveText(
            l10n.date,
            style: AppTheme.labelText,
          ),
          SizedBox(height: ResponsiveHelper.getCardSpacing(context)),
          GestureDetector(
            onTap: () => _selectDate(),
            child: Container(
              width: double.infinity,
              padding: ResponsiveHelper.getButtonPadding(context),
              child: ResponsiveText(
                '${_inspectionDate.day}/${_inspectionDate.month}/${_inspectionDate.year}',
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

  Widget _buildQueenStatus(AppLocalizations l10n) {
    return Padding(
      padding: ResponsiveHelper.getScreenPadding(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ResponsiveText(
            l10n.queen_status,
            style: AppTheme.labelText,
          ),
          SizedBox(height: ResponsiveHelper.getCardSpacing(context)),
          ResponsiveRow(
            children: QueenPresence.values.map((status) {
              return _buildStatusOption<QueenPresence>(
                status.name, // يمكنك إضافة دالة ترجمة هنا
                status,
                _queenStatus,
                    (value) => setState(() => _queenStatus = value!),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildBroodStatus(AppLocalizations l10n) {
    return Padding(
      padding: ResponsiveHelper.getScreenPadding(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ResponsiveText(
            'حالة الحضنة', // لا يوجد مفتاح ترجمة لهذا
            style: AppTheme.labelText,
          ),
          SizedBox(height: ResponsiveHelper.getCardSpacing(context)),
          ResponsiveRow(
            children: BroodPattern.values.map((pattern) {
              return _buildStatusOption<BroodPattern>(
                pattern.name, // يمكنك إضافة دالة ترجمة هنا
                pattern,
                _broodPattern,
                    (value) => setState(() => _broodPattern = value!),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildEnvironmentalData(AppLocalizations l10n) {
    return Padding(
      padding: ResponsiveHelper.getScreenPadding(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ResponsiveText(
            'البيانات البيئية', // لا يوجد مفتاح ترجمة لهذا
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
                      l10n.temperature,
                      style: AppTheme.smallText,
                    ),
                    SizedBox(height: ResponsiveHelper.getCardSpacing(context) / 2),
                    Slider(
                      value: _temperature,
                      min: 0,
                      max: 50,
                      divisions: 50,
                      activeColor: AppTheme.primaryYellow,
                      inactiveColor: Colors.grey.shade300,
                      onChanged: (value) {
                        setState(() {
                          _temperature = value;
                        });
                      },
                    ),
                    ResponsiveText(
                      '${_temperature.round()}°C',
                      style: AppTheme.bodyText,
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
                      l10n.humidity,
                      style: AppTheme.smallText,
                    ),
                    SizedBox(height: ResponsiveHelper.getCardSpacing(context) / 2),
                    Slider(
                      value: _humidity,
                      min: 0,
                      max: 100,
                      divisions: 100,
                      activeColor: AppTheme.primaryYellow,
                      inactiveColor: Colors.grey.shade300,
                      onChanged: (value) {
                        setState(() {
                          _humidity = value;
                        });
                      },
                    ),
                    ResponsiveText(
                      '${_humidity.round()}%',
                      style: AppTheme.bodyText,
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

  Widget _buildOverallStatus(AppLocalizations l10n) {
    return Padding(
      padding: ResponsiveHelper.getScreenPadding(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ResponsiveText(
            'الحالة العامة', // لا يوجد مفتاح ترجمة لهذا
            style: AppTheme.labelText,
          ),
          SizedBox(height: ResponsiveHelper.getCardSpacing(context)),
          ResponsiveRow(
            children: HiveHealth.values.map((health) {
              return _buildStatusOption<HiveHealth>(
                health.name, // يمكنك إضافة دالة ترجمة هنا
                health,
                _hiveHealth,
                    (value) => setState(() => _hiveHealth = value!),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildIssuesSelection(AppLocalizations l10n) {
    return Padding(
      padding: ResponsiveHelper.getScreenPadding(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ResponsiveText(
            'المشاكل المكتشفة', // لا يوجد مفتاح ترجمة لهذا
            style: AppTheme.labelText,
          ),
          SizedBox(height: ResponsiveHelper.getCardSpacing(context)),
          Wrap(
            spacing: ResponsiveHelper.getCardSpacing(context),
            runSpacing: ResponsiveHelper.getCardSpacing(context) / 2,
            children: _availableIssues.map((issue) {
              final isSelected = _selectedIssues.contains(issue);
              return GestureDetector(
                onTap: () {
                  setState(() {
                    if (isSelected) {
                      _selectedIssues.remove(issue);
                    } else {
                      _selectedIssues.add(issue);
                    }
                  });
                },
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: ResponsiveHelper.getCardSpacing(context),
                    vertical: ResponsiveHelper.getCardSpacing(context) / 2,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected ? AppTheme.primaryYellow.withAlpha(51) : Colors.transparent,
                    border: Border.all(
                      color: isSelected ? AppTheme.primaryYellow : Colors.grey.shade300,
                    ),
                  ),
                  child: ResponsiveText(
                    issue.name, // يمكنك إضافة دالة ترجمة هنا
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

  Widget _buildNotesField(AppLocalizations l10n) {
    return Padding(
      padding: ResponsiveHelper.getScreenPadding(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ResponsiveText(
            l10n.notes,
            style: AppTheme.labelText,
          ),
          SizedBox(height: ResponsiveHelper.getCardSpacing(context)),
          TextField(
            controller: _notesController,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: 'اكتب ملاحظاتك هنا...',
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

  Widget _buildStatusOption<T>(String label, T value, T currentValue, Function(T?) onChanged) {
    final isSelected = currentValue == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => onChanged(value),
        child: Container(
          padding: ResponsiveHelper.getButtonPadding(context),
          margin: EdgeInsets.symmetric(horizontal: ResponsiveHelper.getCardSpacing(context) / 2),
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.primaryYellow.withAlpha(51) : Colors.transparent,
            border: Border.all(
              color: isSelected ? AppTheme.primaryYellow : Colors.grey.shade300,
            ),
          ),
          child: ResponsiveText(
            label,
            style: AppTheme.smallText.copyWith(
              color: isSelected ? AppTheme.darkBrown : Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  Widget _buildSaveButton(AppLocalizations l10n) {
    return Padding(
      padding: ResponsiveHelper.getScreenPadding(context),
      child: ResponsiveButton(
        text: _isLoading ? 'جاري الحفظ...' : l10n.save,
        onPressed: _isLoading ? null : _saveInspection,
        backgroundColor: AppTheme.successColor,
        foregroundColor: Colors.white,
        icon: Icons.save,
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
      initialDate: _inspectionDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (date != null) {
      setState(() {
        _inspectionDate = date;
      });
    }
  }

  void _saveInspection() async {
    if (_formKey.currentState!.validate() && _selectedHiveId != null) {
      setState(() {
        _isLoading = true;
      });

      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final userId = authProvider.user?.id;

      if (userId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('خطأ: المستخدم غير مسجل الدخول')),
        );
        setState(() => _isLoading = false);
        return;
      }

      try {
        final newInspection = InspectionModel(
          id: '',
          userId: userId,
          hiveId: _selectedHiveId!,
          date: _inspectionDate,
          hiveHealth: _hiveHealth,
          temperament: _temperament,
          queenPresence: _queenStatus,
          queenCellsSeen: _queenCellsSeen,
          eggsSeen: _eggsSeen,
          broodPattern: _broodPattern,
          broodFrames: 0,
          honeyFrames: 0,
          issues: _selectedIssues,
          notes: _notesController.text.trim(),
          temperature: _temperature,
          humidity: _humidity,
        );

        await Provider.of<InspectionProvider>(context, listen: false)
            .addInspection(newInspection);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('تم حفظ الفحص بنجاح'),
              backgroundColor: AppTheme.successColor,
            ),
          );
          Navigator.pop(context, true);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('حدث خطأ أثناء الحفظ: ${e.toString()}'),
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
          content: ResponsiveText('يرجى اختيار خلية أولاً'),
          backgroundColor: AppTheme.warningColor,
        ),
      );
    }
  }
}
