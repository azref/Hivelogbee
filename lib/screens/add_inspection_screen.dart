import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/hive_model.dart';
import '../models/inspection_model.dart';
import '../providers/inspection_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/hive_provider.dart';
import '../utils/app_theme.dart';
import '../widgets/custom_app_bar.dart';
import '../services/ad_service.dart';
import '../l10n/app_localizations.dart';
import '../widgets/add_inspection_widgets.dart';

class AddInspectionScreen extends StatefulWidget {
  final String? hiveId;
  const AddInspectionScreen({super.key, this.hiveId});

  @override
  State<AddInspectionScreen> createState() => _AddInspectionScreenState();
}

class _AddInspectionScreenState extends State<AddInspectionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _notesController = TextEditingController();
  final _broodFramesController = TextEditingController(text: '0');
  final _honeyFramesController = TextEditingController(text: '0');
  final _pollenFramesController = TextEditingController(text: '0');
  final _emptyFramesController = TextEditingController(text: '0');

  // حقول الشمع الجديدة
  final _foundationFramesController = TextEditingController(text: '0');
  final _drawnFramesController = TextEditingController(text: '0');

  String? _selectedHiveNumber;
  String? _selectedHiveId;
  DateTime _inspectionDate = DateTime.now();
  QueenPresence _queenStatus = QueenPresence.present;
  BroodPattern _broodPattern = BroodPattern.good;
  HiveHealth _hiveHealth = HiveHealth.strong;
  Temperament _temperament = Temperament.calm;
  double _temperature = 25.0;
  double _humidity = 60.0;
  final List<InspectionIssue> _selectedIssues = [];
  bool _eggsSeen = false;
  bool _queenCellsSeen = false;
  bool _isLoading = false;
  final List<Map<String, dynamic>> _takenActions = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.hiveId != null) {
        _loadInitialDataForHive(widget.hiveId!);
      }
    });
    AdManager.onScreenChange(AdScreen.addInspection, null);
  }

  Future<void> _loadInitialDataForHive(String hiveId) async {
    final hiveProvider = Provider.of<HiveProvider>(context, listen: false);
    final inspectionProvider = Provider.of<InspectionProvider>(context, listen: false);

    final hive = hiveProvider.getHiveById(hiveId);
    if (hive == null) return;

    final lastInspections = inspectionProvider.getInspectionsByHive(hiveId);
    InspectionModel? lastInspection = lastInspections.isNotEmpty ? lastInspections.first : null;

    setState(() {
      _selectedHiveId = hive.id;
      _selectedHiveNumber = hive.hiveNumber;

      if (lastInspection != null) {
        _broodFramesController.text = lastInspection.broodFrames.toString();
        _honeyFramesController.text = lastInspection.honeyFrames.toString();
        _pollenFramesController.text = lastInspection.pollenFrames.toString();
        _emptyFramesController.text = lastInspection.emptyFrames.toString();
        _queenStatus = lastInspection.queenPresence;
        _broodPattern = lastInspection.broodPattern;
        _hiveHealth = lastInspection.hiveHealth;
        _temperament = lastInspection.temperament;
        _notesController.text = lastInspection.notes ?? '';
      } else {
        _broodFramesController.text = hive.broodFrames.toString();
        _honeyFramesController.text = hive.honeyFrames.toString();
        _pollenFramesController.text = hive.pollenFrames.toString();
        _emptyFramesController.text = hive.emptyFrames.toString();
        _notesController.text = hive.notes ?? '';
        _queenStatus = QueenPresence.present;
        _broodPattern = BroodPattern.good;
        _hiveHealth = HiveHealth.strong;
        _temperament = Temperament.calm;
      }
    });
  }

  @override
  void dispose() {
    _notesController.dispose();
    _broodFramesController.dispose();
    _honeyFramesController.dispose();
    _pollenFramesController.dispose();
    _emptyFramesController.dispose();
    _foundationFramesController.dispose();
    _drawnFramesController.dispose();
    super.dispose();
  }

  String _getQueenPresenceText(QueenPresence status, AppLocalizations l10n) {
    switch (status) {
      case QueenPresence.present: return "موجودة";
      case QueenPresence.absent: return "غائبة";
      case QueenPresence.newQueen: return "ملكة جديدة";
      case QueenPresence.unseen: return "لم يتم رؤيتها";
    }
  }

  String _getBroodPatternText(BroodPattern pattern, AppLocalizations l10n) {
    switch (pattern) {
      case BroodPattern.good: return "جيد";
      case BroodPattern.spotty: return "متقطع";
      case BroodPattern.poor: return "ضعيف";
      case BroodPattern.none: return "لا يوجد";
    }
  }

  String _getHiveHealthText(HiveHealth health, AppLocalizations l10n) {
    switch (health) {
      case HiveHealth.strong: return "قوي";
      case HiveHealth.average: return "متوسط";
      case HiveHealth.weak: return "ضعيف";
    }
  }

  String _getInspectionIssueText(InspectionIssue issue, AppLocalizations l10n) {
    switch (issue) {
      case InspectionIssue.varroa: return "فاروا";
      case InspectionIssue.nosema: return "نوزيما";
      case InspectionIssue.chalkbrood: return "حضنة طباشيرية";
      case InspectionIssue.foulbrood: return "تعفن الحضنة";
      case InspectionIssue.queenless: return "بدون ملكة";
      case InspectionIssue.swarming: return "تطريد";
      case InspectionIssue.smallHiveBeetle: return "خنفساء الخلية الصغيرة";
      case InspectionIssue.waxMoth: return "عثة الشمع";
      case InspectionIssue.americanFoulbrood: return "تعفن الحضنة الأمريكي";
      case InspectionIssue.europeanFoulbrood: return "تعفن الحضنة الأوروبي";
      case InspectionIssue.sacbrood: return "الحضنة الكيسية";
      case InspectionIssue.queenIssues: return "مشاكل في الملكة";
      case InspectionIssue.robbing: return "سرقة";
      case InspectionIssue.pesticidePoisoning: return "تسمم بالمبيدات";
      case InspectionIssue.other: return "أخرى";
    }
  }

  void _addAction(Map<String, dynamic> action) {
    setState(() {
      _takenActions.add(action);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return AdAwareScaffold(
      screen: AdScreen.addInspection,
      appBar: CustomAppBar(title: l10n.add_inspection),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(image: AssetImage("assets/images/honey_background.png"), fit: BoxFit.cover),
        ),
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              buildTitledCard(
                title: l10n.select_hive,
                child: Row(
                  children: [
                    Expanded(
                      child: buildSelectionField(
                        displayText: _selectedHiveNumber != null ? '${l10n.hive_number} $_selectedHiveNumber' : l10n.select_hive_placeholder,
                        onTap: () async {
                          final selectedHive = await showHiveSelectionDialog(context, l10n);
                          if (selectedHive != null) {
                            _loadInitialDataForHive(selectedHive['id']!);
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
                          Text('${_inspectionDate.day}/${_inspectionDate.month}/${_inspectionDate.year}', style: const TextStyle(fontFamily: 'Cairo', color: AppTheme.darkBrown, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    )
                  ],
                ),
              ),
              const SizedBox(height: 24),
              buildTitledCard(
                title: l10n.queen_status,
                child: buildSelectionField(
                  displayText: _getQueenPresenceText(_queenStatus, l10n),
                  onTap: () => showOptionsDialog<QueenPresence>(context: context, title: l10n.queen_status, options: QueenPresence.values, currentValue: _queenStatus, onSelected: (value) => setState(() => _queenStatus = value), itemTextBuilder: (value) => _getQueenPresenceText(value, l10n)),
                ),
              ),
              const SizedBox(height: 24),
              buildTitledCard(
                  title: 'توزيع الإطارات',
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(child: _buildFrameInputField(_broodFramesController, 'حضنة', Icons.child_care)),
                          const SizedBox(width: 12),
                          Expanded(child: _buildFrameInputField(_honeyFramesController, 'عسل', Icons.opacity)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(child: _buildFrameInputField(_pollenFramesController, 'حبوب لقاح', Icons.local_florist)),
                          const SizedBox(width: 12),
                          Expanded(child: _buildFrameInputField(_emptyFramesController, 'فارغة', Icons.check_box_outline_blank)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Divider(),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(child: _buildFrameInputField(_foundationFramesController, 'شمع أساس', Icons.grid_on)),
                          const SizedBox(width: 12),
                          Expanded(child: _buildFrameInputField(_drawnFramesController, 'شمع ممطوط', Icons.auto_awesome_motion)),
                        ],
                      ),
                    ],
                  )
              ),
              const SizedBox(height: 24),
              buildTitledCard(
                title: l10n.brood_status,
                child: buildSelectionField(
                  displayText: _getBroodPatternText(_broodPattern, l10n),
                  onTap: () => showOptionsDialog<BroodPattern>(context: context, title: l10n.brood_status, options: BroodPattern.values, currentValue: _broodPattern, onSelected: (value) => setState(() => _broodPattern = value), itemTextBuilder: (value) => _getBroodPatternText(value, l10n)),
                ),
              ),
              const SizedBox(height: 24),
              buildTitledCard(
                title: l10n.overall_status,
                child: buildSelectionField(
                  displayText: _getHiveHealthText(_hiveHealth, l10n),
                  onTap: () => showOptionsDialog<HiveHealth>(context: context, title: l10n.overall_status, options: HiveHealth.values, currentValue: _hiveHealth, onSelected: (value) => setState(() => _hiveHealth = value), itemTextBuilder: (value) => _getHiveHealthText(value, l10n)),
                ),
              ),
              const SizedBox(height: 24),
              buildTitledCard(
                title: l10n.detected_issues,
                child: buildSelectionField(
                  displayText: _selectedIssues.isEmpty ? l10n.select_issues_placeholder : _selectedIssues.map((e) => _getInspectionIssueText(e, l10n)).join(', '),
                  onTap: () => showMultiSelectOptionsDialog(context: context, l10n: l10n, title: l10n.detected_issues, options: InspectionIssue.values, selectedValues: _selectedIssues, onSelected: (values) => setState(() => _selectedIssues..clear()..addAll(values)), itemTextBuilder: (value) => _getInspectionIssueText(value, l10n)),
                ),
              ),
              const SizedBox(height: 24),
              buildTitledCard(
                title: 'الإجراءات المتخذة',
                child: Column(
                  children: [
                    if (_takenActions.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        child: Text("لم يتم إضافة أي إجراءات بعد.", style: TextStyle(fontFamily: 'Cairo', color: Colors.grey.shade600), textAlign: TextAlign.center),
                      ),
                    ..._takenActions.map((action) => _buildActionChip(action, l10n)),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: ActionChip(
                        avatar: const Icon(Icons.add, size: 18),
                        label: const Text('إضافة إجراء', style: TextStyle(fontFamily: 'Cairo')),
                        onPressed: () => showAddActionDialog(context, l10n, _addAction),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              buildTitledCard(
                title: l10n.notes,
                child: TextFormField(
                  controller: _notesController,
                  maxLines: 5,
                  style: const TextStyle(fontFamily: 'Cairo', fontSize: 16),
                  decoration: InputDecoration(hintText: l10n.notes_placeholder, hintStyle: const TextStyle(fontFamily: 'Cairo'), border: InputBorder.none, filled: false),
                ),
              ),
              const SizedBox(height: 24),
              buildTitledCard(
                title: l10n.environmental_data,
                child: Column(
                  children: [
                    buildSlider(label: l10n.temperature, value: _temperature, min: 0, max: 50, divisions: 50, displayValue: '${_temperature.round()}°C', onChanged: (val) => setState(() => _temperature = val)),
                    const SizedBox(height: 16),
                    buildSlider(label: l10n.humidity, value: _humidity, min: 0, max: 100, divisions: 100, displayValue: '${_humidity.round()}%', onChanged: (val) => setState(() => _humidity = val)),
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

  Widget _buildFrameInputField(TextEditingController controller, String label, IconData icon) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      textAlign: TextAlign.center,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      decoration: InputDecoration(
        label: Center(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(label, style: const TextStyle(fontFamily: 'Cairo')),
          ),
        ),
        prefixIcon: Icon(icon, size: 20),
        contentPadding: const EdgeInsets.symmetric(vertical: 8),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.white.withAlpha(230),
      ),
      validator: (value) {
        if (value == null || int.tryParse(value) == null) {
          return 'خطأ';
        }
        return null;
      },
    );
  }

  Widget _buildActionChip(Map<String, dynamic> action, AppLocalizations l10n) {
    String label = 'إجراء غير معروف';
    switch (action['action']) {
      case 'add_feeding': label = 'أضاف تغذية ${action['amount']} (${action['type'] == 'sugar' ? 'سكري' : 'بروتين'})'; break;
      case 'add_super': label = 'أضاف عاسلة'; break;
      case 'remove_super': label = 'أزال عاسلة'; break;
      case 'add_queen_excluder': label = 'أضاف حاجز ملكي'; break;
      case 'remove_queen_excluder': label = 'أزال حاجز ملكي'; break;
      case 'add_pollen_trap': label = 'أضاف مصيدة لقاح'; break;
      case 'remove_pollen_trap': label = 'أزال مصيدة لقاح'; break;
      case 'replace_queen': label = 'استبدل الملكة'; break;
      case 'add_queen': label = 'أضاف ملكة'; break;
      case 'remove_queen': label = 'أزال الملكة'; break;
      case 'set_entrance':
        String status = 'مفتوح';
        if (action['status'] == 'partially_open') status = 'مفتوح جزئياً';
        if (action['status'] == 'closed') status = 'مغلق';
        label = 'ضبط المدخل: $status';
        break;
      default: label = action['action'].toString(); break;
    }
    return Chip(
      label: Text(label, style: const TextStyle(fontFamily: 'Cairo')),
      onDeleted: () => setState(() => _takenActions.remove(action)),
      deleteIcon: const Icon(Icons.cancel, size: 18),
    );
  }

  Widget _buildSaveButton(AppLocalizations l10n) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton.icon(
        icon: _isLoading
            ? Container(
          width: 24,
          height: 24,
          padding: const EdgeInsets.all(2.0),
          child: const CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
        )
            : const Icon(Icons.save),
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
            textTheme: const TextTheme(bodyLarge: TextStyle(fontFamily: 'Cairo'), bodyMedium: TextStyle(fontFamily: 'Cairo'), labelSmall: TextStyle(fontFamily: 'Cairo')),
            colorScheme: const ColorScheme.light(primary: AppTheme.primaryYellow, onPrimary: AppTheme.darkBrown),
          ),
          child: child!,
        );
      },
    );
    if (date != null) {
      setState(() => _inspectionDate = date);
    }
  }

  void _saveInspection() async {
    if (_selectedHiveId == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.error_select_hive, style: const TextStyle(fontFamily: 'Cairo')), backgroundColor: AppTheme.warningColor));
      return;
    }
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final userId = Provider.of<AuthProvider>(context, listen: false).user?.id;
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.error_login_required, style: const TextStyle(fontFamily: 'Cairo'))));
      setState(() => _isLoading = false);
      return;
    }

    try {
      final broodFrames = int.tryParse(_broodFramesController.text) ?? 0;
      final honeyFrames = int.tryParse(_honeyFramesController.text) ?? 0;
      final pollenFrames = int.tryParse(_pollenFramesController.text) ?? 0;
      final emptyFrames = int.tryParse(_emptyFramesController.text) ?? 0;
      final foundationFrames = int.tryParse(_foundationFramesController.text) ?? 0;
      final drawnFrames = int.tryParse(_drawnFramesController.text) ?? 0;

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
        broodFrames: broodFrames,
        honeyFrames: honeyFrames,
        pollenFrames: pollenFrames,
        emptyFrames: emptyFrames,
        issues: _selectedIssues,
        notes: _notesController.text.trim(),
        temperature: _temperature,
        humidity: _humidity,
        actions: _takenActions,
      );

      final inspectionProvider = Provider.of<InspectionProvider>(context, listen: false);
      await inspectionProvider.addInspection(newInspection);

      await _updateHiveDataAfterInspection(newInspection, foundationFrames, drawnFrames);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.inspection_saved_success, style: const TextStyle(fontFamily: 'Cairo')), backgroundColor: AppTheme.successColor));
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('خطأ: ${e.toString()}', style: const TextStyle(fontFamily: 'Cairo', fontSize: 16.0, fontWeight: FontWeight.bold)), backgroundColor: AppTheme.errorColor, duration: const Duration(seconds: 10)));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _updateHiveDataAfterInspection(InspectionModel inspection, int foundation, int drawn) async {
    final hiveProvider = Provider.of<HiveProvider>(context, listen: false);
    final hiveToUpdate = hiveProvider.getHiveById(inspection.hiveId);

    if (hiveToUpdate != null) {
      // إجمالي الإطارات يشمل الإطارات الحالية + الشمع الجديد المضاف
      final totalFrames = inspection.broodFrames + inspection.honeyFrames + inspection.pollenFrames + inspection.emptyFrames + foundation + drawn;
      bool isUpgraded = hiveToUpdate.isNucleus && totalFrames >= 6;

      final updatedHive = hiveToUpdate.copyWith(
        broodFrames: inspection.broodFrames,
        honeyFrames: inspection.honeyFrames,
        pollenFrames: inspection.pollenFrames,
        emptyFrames: inspection.emptyFrames + foundation + drawn, // نضيف الشمع الجديد للفارغ مبدئياً
        frameCount: totalFrames,
        isNucleus: isUpgraded ? false : hiveToUpdate.isNucleus,
        lastInspection: inspection.date,
      );
      await hiveProvider.updateHive(updatedHive);
    }
  }
}