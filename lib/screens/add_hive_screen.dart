import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/hive_model.dart';
import '../providers/hive_provider.dart';
import '../providers/auth_provider.dart';
import '../utils/app_theme.dart';
import '../services/ad_service.dart';
import '../widgets/custom_app_bar.dart';
import '../l10n/app_localizations.dart'; // --- تم تصحيح المسار ---

class AddHiveScreen extends StatefulWidget {
  const AddHiveScreen({super.key});

  @override
  State<AddHiveScreen> createState() => _AddHiveScreenState();
}

class _AddHiveScreenState extends State<AddHiveScreen> {
  final _formKey = GlobalKey<FormState>();
  final _numberController = TextEditingController();
  final _locationController = TextEditingController();
  final _notesController = TextEditingController();
  final _framesController = TextEditingController(text: '10');

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
    _locationController.dispose();
    _notesController.dispose();
    _framesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // --- تم تصحيح طريقة الاستدعاء ---
    final l10n = AppLocalizations.of(context)!;

    return AdAwareScaffold(
      screen: AdScreen.addHive,
      appBar: CustomAppBar(
        title: l10n.add_hive, // --- تم تصحيح المفتاح ---
        additionalActions: [
          TextButton(
            onPressed: _isLoading ? null : _saveHive,
            child: Text(
              l10n.save, // --- تم تصحيح المفتاح ---
              style: TextStyle(
                color: _isLoading ? Colors.grey : AppTheme.primaryYellow,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: Container(
        decoration: AppTheme.gradientDecoration,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildBasicInfoSection(l10n),
                const SizedBox(height: 24),
                _buildTypeAndStatusSection(l10n),
                const SizedBox(height: 24),
                _buildQueenInfoSection(l10n),
                const SizedBox(height: 24),
                _buildFramesSection(l10n),
                const SizedBox(height: 24),
                _buildLocationSection(l10n),
                const SizedBox(height: 24),
                _buildNotesSection(l10n),
                const SizedBox(height: 32),
                _buildSaveButton(l10n),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBasicInfoSection(AppLocalizations l10n) {
    return _buildSection(
      title: 'المعلومات الأساسية',
      child: Column(
        children: [
          TextFormField(
            controller: _numberController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: l10n.hive_number, // --- تم تصحيح المفتاح ---
              prefixIcon: const Icon(Icons.tag),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Colors.white,
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'يرجى إدخال رقم الخلية';
              }
              final number = int.tryParse(value);
              if (number == null || number <= 0) {
                return 'يرجى إدخال رقم صحيح';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          _buildDateField(
            label: 'تاريخ التركيب',
            value: _installationDate,
            onTap: () => _selectDate(),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeAndStatusSection(AppLocalizations l10n) {
    return _buildSection(
      title: 'النوع والحالة',
      child: Column(
        children: [
          _buildDropdownField<bool>(
            label: 'نوع الخلية',
            value: _isNucleus,
            items: [
              DropdownMenuItem(value: false, child: Text('خلية كاملة')),
              DropdownMenuItem(value: true, child: Text('طرد')),
            ],
            onChanged: (value) {
              setState(() {
                _isNucleus = value!;
                if (value) {
                  _framesController.text = '5';
                } else {
                  _framesController.text = '10';
                }
              });
            },
          ),
          const SizedBox(height: 16),
          _buildDropdownField<HiveStatus>(
            label: l10n.hive_status, // --- تم تصحيح المفتاح ---
            value: _selectedStatus,
            items: HiveStatus.values.map((status) {
              return DropdownMenuItem(
                value: status,
                child: Text(status.name),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedStatus = value!;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildQueenInfoSection(AppLocalizations l10n) {
    return _buildSection(
      title: 'معلومات الملكة',
      child: Column(
        children: [
          _buildDropdownField<QueenStatus>(
            label: l10n.queen_status, // --- تم تصحيح المفتاح ---
            value: _selectedQueenStatus,
            items: QueenStatus.values.map((status) {
              return DropdownMenuItem(
                value: status,
                child: Text(status.name),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedQueenStatus = value!;
              });
            },
          ),
          const SizedBox(height: 16),
          _buildDropdownField<BeeBreed>(
            label: 'سلالة النحل',
            value: _selectedBreed,
            items: BeeBreed.values.map((breed) {
              return DropdownMenuItem(
                value: breed,
                child: Text(breed.name),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedBreed = value!;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFramesSection(AppLocalizations l10n) {
    return _buildSection(
      title: 'الإطارات',
      child: TextFormField(
        controller: _framesController,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          labelText: l10n.frame_count, // --- تم تصحيح المفتاح ---
          prefixIcon: const Icon(Icons.layers),
          suffixText: 'إطار',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          filled: true,
          fillColor: Colors.white,
        ),
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return 'يرجى إدخال عدد الإطارات';
          }
          final frames = int.tryParse(value);
          if (frames == null || frames <= 0) {
            return 'يرجى إدخال عدد صحيح';
          }
          if (frames > 20) {
            return 'عدد الإطارات كبير جداً';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildLocationSection(AppLocalizations l10n) {
    return _buildSection(
      title: l10n.location, // --- تم تصحيح المفتاح ---
      child: Column(
        children: [
          TextFormField(
            controller: _locationController,
            decoration: InputDecoration(
              labelText: 'موقع الخلية',
              prefixIcon: const Icon(Icons.location_on),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            height: 50,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(12),
              color: Colors.white,
            ),
            child: InkWell(
              onTap: _selectLocationFromMap,
              borderRadius: BorderRadius.circular(12),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.map, color: AppTheme.primaryYellow),
                  SizedBox(width: 8),
                  Text(
                    'تحديد الموقع من الخريطة',
                    style: TextStyle(
                      color: AppTheme.primaryYellow,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotesSection(AppLocalizations l10n) {
    return _buildSection(
      title: l10n.notes, // --- تم تصحيح المفتاح ---
      child: TextFormField(
        controller: _notesController,
        maxLines: 4,
        decoration: InputDecoration(
          labelText: 'ملاحظات إضافية',
          prefixIcon: const Icon(Icons.note),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          filled: true,
          fillColor: Colors.white,
          alignLabelWithHint: true,
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((255 * 0.05).round()),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.darkBrown,
            ),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildDropdownField<T>({
    required String label,
    required T value,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
  }) {
    return DropdownButtonFormField<T>(
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
      initialValue: value,
      items: items,
      onChanged: onChanged,
    );
  }

  Widget _buildDateField({
    required String label,
    required DateTime value,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(12),
          color: Colors.white,
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${value.day}/${value.month}/${value.year}',
                    style: const TextStyle(
                      fontSize: 16,
                      color: AppTheme.darkBrown,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSaveButton(AppLocalizations l10n) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _saveHive,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primaryYellow,
          foregroundColor: AppTheme.darkBrown,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 3,
        ),
        child: _isLoading
            ? const SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(AppTheme.darkBrown),
          ),
        )
            : Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.save),
            const SizedBox(width: 8),
            Text(
              l10n.save, // --- تم تصحيح المفتاح ---
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _installationDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
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
        _installationDate = date;
      });
    }
  }

  void _selectLocationFromMap() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('سيتم فتح الخريطة لتحديد الموقع'),
        backgroundColor: AppTheme.primaryYellow,
      ),
    );
  }

  Future<void> _saveHive() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userId = authProvider.user?.id;

    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('خطأ: المستخدم غير مسجل الدخول'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
      setState(() => _isLoading = false);
      return;
    }

    try {
      final newHive = HiveModel(
        id: '',
        userId: userId,
        hiveNumber: _numberController.text.trim(),
        breed: _selectedBreed,
        createdDate: _installationDate,
        status: _selectedStatus,
        queenStatus: _selectedQueenStatus,
        frameCount: int.tryParse(_framesController.text.trim()) ?? 10,
        broodFrames: 0,
        honeyFrames: 0,
        notes: _notesController.text.trim(),
        location: _locationController.text.trim(),
        lastInspection: _installationDate,
        isNucleus: _isNucleus,
      );

      await Provider.of<HiveProvider>(context, listen: false).addHive(newHive);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم حفظ الخلية بنجاح'),
            backgroundColor: AppTheme.successColor,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('حدث خطأ أثناء حفظ الخلية: ${e.toString()}'),
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
  }
}
