import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/inspection_model.dart';
import '../providers/inspection_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/hive_provider.dart'; // لاستدعاء قائمة الخلايا
import '../utils/app_theme.dart';
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

  // --- *** 1. تعديل المتغيرات *** ---
  String? _selectedHiveNumber; // سنحفظ رقم الخلية للعرض
  String? _selectedHiveId;     // سنحفظ معرف الخلية للحفظ في قاعدة البيانات

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

  @override
  void initState() {
    super.initState();
    // إذا تم تمرير معرف الخلية، قم بجلب رقمها
    if (widget.hiveId != null) {
      _selectedHiveId = widget.hiveId;
      // نحتاج إلى طريقة لجلب رقم الخلية من المعرف
      // سنفترض أن HiveProvider يمكنه القيام بذلك
      final hive = Provider.of<HiveProvider>(context, listen: false).getHiveById(widget.hiveId!);
      if (hive != null) {
        _selectedHiveNumber = hive.hiveNumber;
      }
    }
    AdManager.onScreenChange(AdScreen.addInspection, null);
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  // ... (دوال الترجمة تبقى كما هي)
  String _getQueenPresenceText(QueenPresence status, AppLocalizations l10n) {
    switch (status) {
      case QueenPresence.present:
        return "موجودة";
      case QueenPresence.absent:
        return "غائبة";
      case QueenPresence.newQueen:
        return "ملكة جديدة";
      case QueenPresence.unseen:
        return "لم يتم رؤيتها";
    }
  }

  String _getBroodPatternText(BroodPattern pattern, AppLocalizations l10n) {
    switch (pattern) {
      case BroodPattern.good:
        return "جيد";
      case BroodPattern.spotty:
        return "متقطع";
      case BroodPattern.poor:
        return "ضعيف";
      case BroodPattern.none:
        return "لا يوجد";
    }
  }

  String _getHiveHealthText(HiveHealth health, AppLocalizations l10n) {
    switch (health) {
      case HiveHealth.strong:
        return "قوي";
      case HiveHealth.average:
        return "متوسط";
      case HiveHealth.weak:
        return "ضعيف";
    }
  }

  String _getInspectionIssueText(InspectionIssue issue, AppLocalizations l10n) {
    switch (issue) {
      case InspectionIssue.varroa:
        return "فاروا";
      case InspectionIssue.nosema:
        return "نوزيما";
      case InspectionIssue.chalkbrood:
        return "حضنة طباشيرية";
      case InspectionIssue.foulbrood:
        return "تعفن الحضنة";
      case InspectionIssue.queenless:
        return "بدون ملكة";
      case InspectionIssue.swarming:
        return "تطريد";
      case InspectionIssue.smallHiveBeetle:
        return "خنفساء الخلية الصغيرة";
      case InspectionIssue.waxMoth:
        return "عثة الشمع";
      case InspectionIssue.americanFoulbrood:
        return "تعفن الحضنة الأمريكي";
      case InspectionIssue.europeanFoulbrood:
        return "تعفن الحضنة الأوروبي";
      case InspectionIssue.sacbrood:
        return "الحضنة الكيسية";
      case InspectionIssue.queenIssues:
        return "مشاكل في الملكة";
      case InspectionIssue.robbing:
        return "سرقة";
      case InspectionIssue.pesticidePoisoning:
        return "تسمم بالمبيدات";
      case InspectionIssue.other:
        return "أخرى";
    }
  }


  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return AdAwareScaffold(
      screen: AdScreen.addInspection,
      appBar: CustomAppBar(
        title: l10n.add_inspection,
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/honey_background.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              _buildTitledCard(
                title: l10n.select_hive,
                child: Row(
                  children: [
                    Expanded(
                      child: _buildSelectionField(
                        // --- 2. عرض رقم الخلية بدلاً من المعرف ---
                        displayText: _selectedHiveNumber != null
                            ? '${l10n.hive_number} $_selectedHiveNumber'
                            : l10n.select_hive_placeholder,
                        onTap: () async {
                          final selectedHive = await _showHiveSelectionDialog(context, l10n);
                          if (selectedHive != null) {
                            setState(() {
                              // 3. حفظ كل من الرقم والمعرف
                              _selectedHiveNumber = selectedHive['number'];
                              _selectedHiveId = selectedHive['id'];
                            });
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    InkWell(
                      onTap: _selectDate,
                      child: Column(
                        children: [
                          const Icon(Icons.calendar_today, color: AppTheme.darkBrown),
                          const SizedBox(height: 4),
                          Text(
                            '${_inspectionDate.day}/${_inspectionDate.month}/${_inspectionDate.year}',
                            style: const TextStyle(fontFamily: 'Cairo', color: AppTheme.darkBrown, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // ... (باقي الحاويات تبقى كما هي)
              _buildTitledCard(
                title: l10n.queen_status,
                child: _buildSelectionField(
                  displayText: _getQueenPresenceText(_queenStatus, l10n),
                  onTap: () => _showOptionsDialog<QueenPresence>(
                    context: context,
                    title: l10n.queen_status,
                    options: QueenPresence.values,
                    currentValue: _queenStatus,
                    onSelected: (value) => setState(() => _queenStatus = value),
                    itemTextBuilder: (value) => _getQueenPresenceText(value, l10n),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              _buildTitledCard(
                title: l10n.brood_status,
                child: _buildSelectionField(
                  displayText: _getBroodPatternText(_broodPattern, l10n),
                  onTap: () => _showOptionsDialog<BroodPattern>(
                    context: context,
                    title: l10n.brood_status,
                    options: BroodPattern.values,
                    currentValue: _broodPattern,
                    onSelected: (value) => setState(() => _broodPattern = value),
                    itemTextBuilder: (value) => _getBroodPatternText(value, l10n),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              _buildTitledCard(
                title: l10n.overall_status,
                child: _buildSelectionField(
                  displayText: _getHiveHealthText(_hiveHealth, l10n),
                  onTap: () => _showOptionsDialog<HiveHealth>(
                    context: context,
                    title: l10n.overall_status,
                    options: HiveHealth.values,
                    currentValue: _hiveHealth,
                    onSelected: (value) => setState(() => _hiveHealth = value),
                    itemTextBuilder: (value) => _getHiveHealthText(value, l10n),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              _buildTitledCard(
                title: l10n.detected_issues,
                child: _buildSelectionField(
                  displayText: _selectedIssues.isEmpty
                      ? l10n.select_issues_placeholder
                      : _selectedIssues.map((e) => _getInspectionIssueText(e, l10n)).join(', '),
                  onTap: () => _showMultiSelectOptionsDialog(
                    context: context,
                    l10n: l10n,
                    title: l10n.detected_issues,
                    options: InspectionIssue.values,
                    selectedValues: _selectedIssues,
                    onSelected: (values) => setState(() => _selectedIssues
                      ..clear()
                      ..addAll(values)),
                    itemTextBuilder: (value) => _getInspectionIssueText(value, l10n),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              _buildTitledCard(
                title: l10n.notes,
                child: TextFormField(
                  controller: _notesController,
                  maxLines: 5,
                  style: const TextStyle(fontFamily: 'Cairo', fontSize: 16),
                  decoration: InputDecoration(
                    hintText: l10n.notes_placeholder,
                    hintStyle: const TextStyle(fontFamily: 'Cairo'),
                    border: InputBorder.none,
                    filled: false,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              _buildTitledCard(
                title: l10n.environmental_data,
                child: Column(
                  children: [
                    _buildSlider(
                      label: l10n.temperature,
                      value: _temperature,
                      min: 0,
                      max: 50,
                      divisions: 50,
                      displayValue: '${_temperature.round()}°C',
                      onChanged: (val) => setState(() => _temperature = val),
                    ),
                    const SizedBox(height: 16),
                    _buildSlider(
                      label: l10n.humidity,
                      value: _humidity,
                      min: 0,
                      max: 100,
                      divisions: 100,
                      displayValue: '${_humidity.round()}%',
                      onChanged: (val) => setState(() => _humidity = val),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              _buildSaveButton(l10n),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTitledCard({required String title, required Widget child}) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12.0),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(235),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(40),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // تم اعتماد إزاحة 10 بكسل من الأعلى بناءً على طلبك
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
            child: Text(
              title,
              style: const TextStyle(
                fontFamily: 'Cairo',
                color: AppTheme.darkBrown,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(5, 0, 0, 5),
            child: child,
          ),
        ],
      ),
    );
  }

  Widget _buildSelectionField({required String displayText, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: Colors.grey)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                displayText,
                style: const TextStyle(fontFamily: 'Cairo', fontSize: 16, color: AppTheme.darkBrown),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const Icon(Icons.arrow_drop_down, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildSlider({
    required String label,
    required double value,
    required double min,
    required double max,
    required int divisions,
    required String displayValue,
    required ValueChanged<double> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontFamily: 'Cairo', fontSize: 16, fontWeight: FontWeight.w500)),
            Text(displayValue, style: const TextStyle(fontFamily: 'Cairo', fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
        Slider(
          value: value,
          min: min,
          max: max,
          divisions: divisions,
          activeColor: AppTheme.primaryYellow,
          inactiveColor: Colors.grey.shade300,
          onChanged: onChanged,
        ),
      ],
    );
  }

  // --- 4. تعديل دالة عرض القائمة لتعيد خريطة (Map) ---
  Future<Map<String, String>?> _showHiveSelectionDialog(BuildContext context, AppLocalizations l10n) async {
    final hives = Provider.of<HiveProvider>(context, listen: false).hives;
    return showDialog<Map<String, String>>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.primaryYellow,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Center(child: Text(l10n.select_hive, style: const TextStyle(fontFamily: 'Cairo', color: AppTheme.darkBrown, fontWeight: FontWeight.bold))),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: hives.length,
            itemBuilder: (context, index) {
              final hive = hives[index];
              return ListTile(
                title: Text('${l10n.hive_number} ${hive.hiveNumber}', style: const TextStyle(fontFamily: 'Cairo', color: AppTheme.darkBrown, fontWeight: FontWeight.w600)),
                onTap: () {
                  // 5. إعادة خريطة تحتوي على المعرف والرقم
                  Navigator.pop(context, {'id': hive.id, 'number': hive.hiveNumber});
                },
              );
            },
          ),
        ),
      ),
    );
  }

  void _showOptionsDialog<T>({
    required BuildContext context,
    required String title,
    required List<T> options,
    required T currentValue,
    required ValueChanged<T> onSelected,
    required String Function(T) itemTextBuilder,
  }) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.primaryYellow,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Center(child: Text(title, style: const TextStyle(fontFamily: 'Cairo', color: AppTheme.darkBrown, fontWeight: FontWeight.bold))),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: options.map((option) {
            return RadioListTile<T>(
              title: Text(itemTextBuilder(option), style: const TextStyle(fontFamily: 'Cairo', color: AppTheme.darkBrown)),
              value: option,
              groupValue: currentValue,
              onChanged: (value) {
                if (value != null) {
                  onSelected(value);
                  Navigator.pop(context);
                }
              },
              activeColor: AppTheme.darkBrown,
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showMultiSelectOptionsDialog<T>({
    required BuildContext context,
    required AppLocalizations l10n,
    required String title,
    required List<T> options,
    required List<T> selectedValues,
    required ValueChanged<List<T>> onSelected,
    required String Function(T) itemTextBuilder,
  }) {
    showDialog(
      context: context,
      builder: (context) {
        final tempSelectedValues = List<T>.from(selectedValues);
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: AppTheme.primaryYellow,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: Center(child: Text(title, style: const TextStyle(fontFamily: 'Cairo', color: AppTheme.darkBrown, fontWeight: FontWeight.bold))),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: options.map((option) {
                    final isSelected = tempSelectedValues.contains(option);
                    return CheckboxListTile(
                      title: Text(itemTextBuilder(option), style: const TextStyle(fontFamily: 'Cairo', color: AppTheme.darkBrown)),
                      value: isSelected,
                      onChanged: (bool? value) {
                        setState(() {
                          if (value == true) {
                            tempSelectedValues.add(option);
                          } else {
                            tempSelectedValues.remove(option);
                          }
                        });
                      },
                      activeColor: AppTheme.darkBrown,
                    );
                  }).toList(),
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.cancel, style: const TextStyle(fontFamily: 'Cairo', color: AppTheme.darkBrown))),
                ElevatedButton(
                  onPressed: () {
                    onSelected(tempSelectedValues);
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: AppTheme.darkBrown),
                  child: Text(l10n.save, style: const TextStyle(fontFamily: 'Cairo', color: AppTheme.primaryYellow)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildSaveButton(AppLocalizations l10n) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton.icon(
        icon: const Icon(Icons.save),
        label: Text(l10n.save, style: const TextStyle(fontFamily: 'Cairo', fontSize: 18, fontWeight: FontWeight.bold)),
        onPressed: _isLoading ? null : _saveInspection,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.successColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  void _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _inspectionDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            textTheme: const TextTheme(
              bodyLarge: TextStyle(fontFamily: 'Cairo'),
              bodyMedium: TextStyle(fontFamily: 'Cairo'),
              labelSmall: TextStyle(fontFamily: 'Cairo'),
            ),
            colorScheme: const ColorScheme.light(
              primary: AppTheme.primaryYellow,
              onPrimary: AppTheme.darkBrown,
            ),
          ),
          child: child!,
        );
      },
    );

    if (date != null) {
      setState(() {
        _inspectionDate = date;
      });
    }
  }

  void _saveInspection() async {
    if (_selectedHiveId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.error_select_hive, style: const TextStyle(fontFamily: 'Cairo')),
          backgroundColor: AppTheme.warningColor,
        ),
      );
      return;
    }

    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userId = authProvider.user?.id;

    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.error_login_required, style: const TextStyle(fontFamily: 'Cairo'))),
      );
      setState(() => _isLoading = false);
      return;
    }

    try {
      final newInspection = InspectionModel(
        id: '',
        userId: userId,
        hiveId: _selectedHiveId!, // 6. استخدام المعرف الصحيح عند الحفظ
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

      await Provider.of<InspectionProvider>(context, listen: false).addInspection(newInspection);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.inspection_saved_success, style: const TextStyle(fontFamily: 'Cairo')),
            backgroundColor: AppTheme.successColor,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'خطأ: ${e.toString()}',
              style: const TextStyle(
                fontFamily: 'Cairo',
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            backgroundColor: AppTheme.errorColor,
            duration: const Duration(seconds: 10),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}
