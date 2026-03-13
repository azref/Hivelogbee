import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/hive_model.dart';
import '../providers/hive_provider.dart';
import '../providers/auth_provider.dart';
import '../utils/app_theme.dart';
import '../services/ad_service.dart';
import '../widgets/custom_app_bar.dart';
import '../l10n/app_localizations.dart';

class AddHiveScreen extends StatefulWidget {
  const AddHiveScreen({super.key});

  @override
  State<AddHiveScreen> createState() => _AddHiveScreenState();
}

class _AddHiveScreenState extends State<AddHiveScreen> {
  final _formKey = GlobalKey<FormState>();
  final _numberController = TextEditingController();
  final _notesController = TextEditingController();
  final _broodFramesController = TextEditingController(text: '0');
  final _honeyFramesController = TextEditingController(text: '0');
  final _pollenFramesController = TextEditingController(text: '0');
  final _emptyFramesController = TextEditingController(text: '0');

  bool _isNucleus = false;
  HiveStatus _selectedStatus = HiveStatus.active;
  QueenStatus _selectedQueenStatus = QueenStatus.present;
  BeeBreed _selectedBreed = BeeBreed.local;
  DateTime _installationDate = DateTime.now();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    AdManager.onScreenChange(AdScreen.addHive, AdScreen.hiveList);
  }

  @override
  void dispose() {
    _numberController.dispose();
    _notesController.dispose();
    _broodFramesController.dispose();
    _honeyFramesController.dispose();
    _pollenFramesController.dispose();
    _emptyFramesController.dispose();
    super.dispose();
  }

  String _getTranslatedStatus(HiveStatus status, AppLocalizations l10n) {
    switch (status) {
      case HiveStatus.active: return l10n.status_active;
      case HiveStatus.weak: return l10n.status_weak;
      case HiveStatus.sick: return l10n.status_sick;
      case HiveStatus.dead: return l10n.status_dead;
      case HiveStatus.queenless: return l10n.status_queenless;
      case HiveStatus.split: return l10n.status_split;
      case HiveStatus.merged: return l10n.status_merged;
    }
  }

  String _getTranslatedQueenStatus(QueenStatus status, AppLocalizations l10n) {
    switch (status) {
      case QueenStatus.present: return l10n.queen_present;
      case QueenStatus.absent: return l10n.queen_absent;
      case QueenStatus.isNew: return l10n.queen_isNew;
      case QueenStatus.old: return l10n.queen_old;
      case QueenStatus.marked: return l10n.queen_marked;
      case QueenStatus.unmarked: return l10n.queen_unmarked;
    }
  }

  String _getTranslatedBreed(BeeBreed breed, AppLocalizations l10n) {
    switch (breed) {
      case BeeBreed.carniolan: return l10n.breed_carniolan;
      case BeeBreed.italian: return l10n.breed_italian;
      case BeeBreed.caucasian: return l10n.breed_caucasian;
      case BeeBreed.buckfast: return l10n.breed_buckfast;
      case BeeBreed.local: return l10n.breed_local;
      case BeeBreed.hybrid: return l10n.breed_hybrid;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return AdAwareScaffold(
      screen: AdScreen.addHive,
      appBar: CustomAppBar(
        title: l10n.add_hive,
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/honey_background.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSection(
                  title: l10n.basic_info,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _numberController,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(fontSize: 18),
                        decoration: InputDecoration(
                          labelText: l10n.hive_number,
                          labelStyle: const TextStyle(fontSize: 18),
                          prefixIcon: const Icon(Icons.tag),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          filled: true,
                          // --- إصلاح: استخدام withAlpha بدلاً من withOpacity ---
                          fillColor: Colors.white.withAlpha(230),
                        ),
                        validator: (value) => (value == null || value.trim().isEmpty) ? l10n.error_enter_number : null,
                      ),
                      const SizedBox(height: 16),
                      _buildDateField(
                        label: l10n.installation_date,
                        value: _installationDate,
                        onTap: () => _selectDate(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                _buildSection(
                  title: l10n.hive_type,
                  child: _buildDropdownField<bool>(
                    label: l10n.hive_type,
                    value: _isNucleus,
                    items: [
                      DropdownMenuItem(value: false, child: Text(l10n.full_hive, style: const TextStyle(fontSize: 18))),
                      DropdownMenuItem(value: true, child: Text(l10n.nucleus_hive, style: const TextStyle(fontSize: 18))),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _isNucleus = value!;
                      });
                    },
                  ),
                ),
                const SizedBox(height: 24),
                _buildSection(
                  title: l10n.hive_status,
                  child: _buildDropdownField<HiveStatus>(
                    label: l10n.hive_status,
                    value: _selectedStatus,
                    items: HiveStatus.values.map((status) {
                      return DropdownMenuItem(
                        value: status,
                        child: Text(_getTranslatedStatus(status, l10n), style: const TextStyle(fontSize: 18)),
                      );
                    }).toList(),
                    onChanged: (value) => setState(() => _selectedStatus = value!),
                  ),
                ),
                const SizedBox(height: 24),
                _buildSection(
                  title: l10n.queen_status,
                  child: Column(
                    children: [
                      _buildDropdownField<QueenStatus>(
                        label: l10n.queen_status,
                        value: _selectedQueenStatus,
                        items: QueenStatus.values.map((status) {
                          return DropdownMenuItem(
                            value: status,
                            child: Text(_getTranslatedQueenStatus(status, l10n), style: const TextStyle(fontSize: 18)),
                          );
                        }).toList(),
                        onChanged: (value) => setState(() => _selectedQueenStatus = value!),
                      ),
                      const SizedBox(height: 16),
                      _buildDropdownField<BeeBreed>(
                        label: l10n.bee_breed,
                        value: _selectedBreed,
                        items: BeeBreed.values.map((breed) {
                          return DropdownMenuItem(
                            value: breed,
                            child: Text(_getTranslatedBreed(breed, l10n), style: const TextStyle(fontSize: 18)),
                          );
                        }).toList(),
                        onChanged: (value) => setState(() => _selectedBreed = value!),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                _buildSection(
                    title: 'توزيع الإطارات',
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(child: _buildFrameInputField(_broodFramesController, 'حضنة', Icons.child_care)),
                            const SizedBox(width: 16),
                            Expanded(child: _buildFrameInputField(_honeyFramesController, 'عسل', Icons.opacity)),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(child: _buildFrameInputField(_pollenFramesController, 'حبوب لقاح', Icons.local_florist)),
                            const SizedBox(width: 16),
                            Expanded(child: _buildFrameInputField(_emptyFramesController, 'فارغة', Icons.check_box_outline_blank)),
                          ],
                        ),
                      ],
                    )
                ),
                const SizedBox(height: 24),
                _buildSection(
                  title: l10n.notes,
                  child: TextFormField(
                    controller: _notesController,
                    maxLines: 4,
                    style: const TextStyle(fontSize: 18),
                    decoration: InputDecoration(
                      labelText: l10n.notes,
                      labelStyle: const TextStyle(fontSize: 18),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      filled: true,
                      // --- إصلاح: استخدام withAlpha بدلاً من withOpacity ---
                      fillColor: Colors.white.withAlpha(230),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                _buildSaveButton(l10n),
                const SizedBox(height: 80),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSection({required String title, required Widget child}) {
    return Card(
      elevation: 8,
      // --- إصلاح: استخدام withAlpha بدلاً من withOpacity ---
      shadowColor: Colors.black.withAlpha(128),
      // --- إصلاح: استخدام withAlpha بدلاً من withOpacity ---
      color: Colors.white.withAlpha(217),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.darkBrown)),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }

  Widget _buildFrameInputField(TextEditingController controller, String label, IconData icon) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      textAlign: TextAlign.center,
      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      decoration: InputDecoration(
        label: Center(child: Text(label)),
        labelStyle: const TextStyle(fontSize: 16),
        prefixIcon: Icon(icon, size: 24),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        // --- إصلاح: استخدام withAlpha بدلاً من withOpacity ---
        fillColor: Colors.white.withAlpha(230),
      ),
      validator: (value) {
        if (value == null || int.tryParse(value) == null) {
          return 'قيمة غير صالحة';
        }
        return null;
      },
    );
  }

  Widget _buildDropdownField<T>({required String label, required T value, required List<DropdownMenuItem<T>> items, required ValueChanged<T?> onChanged}) {
    return DropdownButtonFormField<T>(
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(fontSize: 18),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        // --- إصلاح: استخدام withAlpha بدلاً من withOpacity ---
        fillColor: Colors.white.withAlpha(230),
      ),
      style: const TextStyle(fontSize: 18, color: Colors.black),
      initialValue: value,
      items: items,
      onChanged: onChanged,
    );
  }

  Widget _buildDateField({required String label, required DateTime value, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade500),
            borderRadius: BorderRadius.circular(12),
            // --- إصلاح: استخدام withAlpha بدلاً من withOpacity ---
            color: Colors.white.withAlpha(230)
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today, size: 24),
            const SizedBox(width: 12),
            Text("${value.day}/${value.month}/${value.year}", style: const TextStyle(fontSize: 18)),
          ],
        ),
      ),
    );
  }

  Widget _buildSaveButton(AppLocalizations l10n) {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _saveHive,
        style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryYellow,
            foregroundColor: AppTheme.darkBrown,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 8,
            // --- إصلاح: استخدام withAlpha بدلاً من withOpacity ---
            shadowColor: Colors.black.withAlpha(102)
        ),
        child: _isLoading
            ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 3, color: AppTheme.darkBrown))
            : Text(l10n.save, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
      ),
    );
  }

  Future<void> _selectDate() async {
    final date = await showDatePicker(context: context, initialDate: _installationDate, firstDate: DateTime(2020), lastDate: DateTime.now());
    if (date != null) setState(() => _installationDate = date);
  }

  Future<void> _saveHive() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final userId = Provider.of<AuthProvider>(context, listen: false).user?.id;
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.error_login_required)));
      setState(() => _isLoading = false);
      return;
    }

    try {
      final broodFrames = int.tryParse(_broodFramesController.text.trim()) ?? 0;
      final honeyFrames = int.tryParse(_honeyFramesController.text.trim()) ?? 0;
      final pollenFrames = int.tryParse(_pollenFramesController.text.trim()) ?? 0;
      final emptyFrames = int.tryParse(_emptyFramesController.text.trim()) ?? 0;
      final totalFrames = broodFrames + honeyFrames + pollenFrames + emptyFrames;

      final newHive = HiveModel(
        id: '',
        userId: userId,
        hiveNumber: _numberController.text.trim(),
        breed: _selectedBreed,
        createdDate: _installationDate,
        status: _selectedStatus,
        queenStatus: _selectedQueenStatus,
        frameCount: totalFrames,
        broodFrames: broodFrames,
        honeyFrames: honeyFrames,
        pollenFrames: pollenFrames,
        emptyFrames: emptyFrames,
        notes: _notesController.text.trim(),
        location: null,
        lastInspection: _installationDate,
        isNucleus: _isNucleus,
      );

      await Provider.of<HiveProvider>(context, listen: false).addHive(newHive);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.hive_saved_success)));
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}
