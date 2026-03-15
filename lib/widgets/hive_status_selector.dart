import 'package:flutter/material.dart';
import '../models/hive_model.dart';
import '../l10n/app_localizations.dart';
import '../utils/app_theme.dart';

// هذا الويدجت مسؤول عن عرض واختيار حالة الخلية أو الطرد
class HiveStatusSelector extends StatelessWidget {
  final HiveType selectedType;
  final HiveStatus hiveStatus;
  final NucleusStatus? nucleusStatus;
  final Function(dynamic) onChanged; // دالة لإعادة القيمة المختارة

  const HiveStatusSelector({
    super.key,
    required this.selectedType,
    required this.hiveStatus,
    required this.nucleusStatus,
    required this.onChanged,
  });

  // دوال مساعدة للترجمة
  String _getTranslatedHiveStatus(HiveStatus status, AppLocalizations l10n) {
    switch (status) {
      case HiveStatus.active: return 'نشطة';
      case HiveStatus.weak: return 'ضعيفة';
      case HiveStatus.queenless: return 'بدون ملكة';
      case HiveStatus.sick: return 'مريضة';
    // --- تم حذف حالة 'ميتة' ---
      case HiveStatus.split: return 'مقسمة';
      case HiveStatus.merged: return 'مضمومة';
    // تمت إضافة default للسلامة، على الرغم من أنه لا يجب الوصول إليه
      default: return '';
    }
  }

  String _getTranslatedNucleusStatus(NucleusStatus status, AppLocalizations l10n) {
    switch (status) {
      case NucleusStatus.mating: return 'قيد التلقيح';
      case NucleusStatus.mated: return 'ملقحة';
      case NucleusStatus.failed: return 'فاشلة';
      case NucleusStatus.laying: return 'تضع البيض';
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final bool isNucleus = selectedType == HiveType.nucleus;

    // بناء الواجهة بناءً على نوع الخلية (خلية كاملة أو طرد)
    return _buildSection(
      // تغيير عنوان القسم ديناميكيًا
      title: isNucleus ? 'حالة الطرد' : 'حالة الخلية',
      child: isNucleus
          ? _buildDropdownField<NucleusStatus>(
        l10n: l10n,
        label: 'حالة الملكة',
        value: nucleusStatus ?? NucleusStatus.mating,
        items: NucleusStatus.values.map((status) {
          return DropdownMenuItem(
            value: status,
            child: Text(_getTranslatedNucleusStatus(status, l10n), style: const TextStyle(fontSize: 18)),
          );
        }).toList(),
        onChanged: (value) {
          if (value != null) {
            onChanged(value);
          }
        },
      )
          : _buildDropdownField<HiveStatus>(
        l10n: l10n,
        label: 'حالة الخلية',
        value: hiveStatus,
        // --- تم تعديل هذا الجزء لتصفية القائمة ---
        items: HiveStatus.values
            .where((status) => status != HiveStatus.dead) // <-- السطر المضاف للتصفية
            .map((status) {
          return DropdownMenuItem(
            value: status,
            child: Text(_getTranslatedHiveStatus(status, l10n), style: const TextStyle(fontSize: 18)),
          );
        }).toList(),
        onChanged: (value) {
          if (value != null) {
            onChanged(value);
          }
        },
      ),
    );
  }

  // ويدجت بناء القسم (Card)
  Widget _buildSection({required String title, required Widget child}) {
    return Card(
      elevation: 8,
      shadowColor: Colors.black.withAlpha(128),
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

  // ويدجت بناء القائمة المنسدلة
  Widget _buildDropdownField<T>({
    required AppLocalizations l10n,
    required String label,
    required T value,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
  }) {
    return DropdownButtonFormField<T>(
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(fontSize: 18),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.white.withAlpha(230),
      ),
      style: const TextStyle(fontSize: 18, color: Colors.black),
      initialValue: value,
      items: items,
      onChanged: onChanged,
    );
  }
}
