import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/hive_provider.dart';
import '../utils/app_theme.dart';
import '../l10n/app_localizations.dart';

// =================================================================
// 1. دوال بناء أجزاء الواجهة (UI Builders)
// =================================================================

Widget buildTitledCard({required String title, required Widget child}) {
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

Widget buildSelectionField({required String displayText, required VoidCallback onTap}) {
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

Widget buildSlider({
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

// =================================================================
// 2. دوال عرض النوافذ المنبثقة (Dialogs)
// =================================================================

Future<Map<String, String>?> showHiveSelectionDialog(BuildContext context, AppLocalizations l10n) async {
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
                Navigator.pop(context, {'id': hive.id, 'number': hive.hiveNumber});
              },
            );
          },
        ),
      ),
    ),
  );
}

void showOptionsDialog<T>({
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

void showMultiSelectOptionsDialog<T>({
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

// =================================================================
// 3. دوال عرض نوافذ الإجراءات المتخذة (Action Dialogs)
// =================================================================

void showConfirmationDialog({
  required BuildContext context,
  required String title,
  required VoidCallback onConfirm,
}) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title, style: const TextStyle(fontFamily: 'Cairo')),
      content: const Text('هل أنت متأكد من إضافة هذا الإجراء؟', style: TextStyle(fontFamily: 'Cairo')),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء', style: TextStyle(fontFamily: 'Cairo'))),
        ElevatedButton(onPressed: () {
          onConfirm();
          Navigator.pop(context);
        }, child: const Text('تأكيد', style: TextStyle(fontFamily: 'Cairo'))),
      ],
    ),
  );
}

void showAddActionDialog(BuildContext context, AppLocalizations l10n, ValueChanged<Map<String, dynamic>> onActionAdded) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('إضافة إجراء', style: TextStyle(fontFamily: 'Cairo')),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(title: const Text('إضافة إطارات', style: TextStyle(fontFamily: 'Cairo')), onTap: () { Navigator.pop(context); showAddFramesDialog(context, l10n, onActionAdded); }),
            ListTile(title: const Text('إضافة تغذية', style: TextStyle(fontFamily: 'Cairo')), onTap: () { Navigator.pop(context); showAddFeedingDialog(context, l10n, onActionAdded); }),
            ListTile(title: const Text('إضافة عاسلة', style: TextStyle(fontFamily: 'Cairo')), onTap: () { Navigator.pop(context); showConfirmationDialog(context: context, title: 'إضافة عاسلة', onConfirm: () => onActionAdded({'action': 'add_super'})); }),
            ListTile(title: const Text('إزالة عاسلة', style: TextStyle(fontFamily: 'Cairo')), onTap: () { Navigator.pop(context); showConfirmationDialog(context: context, title: 'إزالة عاسلة', onConfirm: () => onActionAdded({'action': 'remove_super'})); }),
            ListTile(title: const Text('إضافة حاجز ملكي', style: TextStyle(fontFamily: 'Cairo')), onTap: () { Navigator.pop(context); showConfirmationDialog(context: context, title: 'إضافة حاجز ملكي', onConfirm: () => onActionAdded({'action': 'add_queen_excluder'})); }),
            ListTile(title: const Text('إزالة حاجز ملكي', style: TextStyle(fontFamily: 'Cairo')), onTap: () { Navigator.pop(context); showConfirmationDialog(context: context, title: 'إزالة حاجز ملكي', onConfirm: () => onActionAdded({'action': 'remove_queen_excluder'})); }),
            ListTile(title: const Text('إضافة مصيدة لقاح', style: TextStyle(fontFamily: 'Cairo')), onTap: () { Navigator.pop(context); showConfirmationDialog(context: context, title: 'إضافة مصيدة لقاح', onConfirm: () => onActionAdded({'action': 'add_pollen_trap'})); }),
            ListTile(title: const Text('إزالة مصيدة لقاح', style: TextStyle(fontFamily: 'Cairo')), onTap: () { Navigator.pop(context); showConfirmationDialog(context: context, title: 'إزالة مصيدة لقاح', onConfirm: () => onActionAdded({'action': 'remove_pollen_trap'})); }),
            ListTile(title: const Text('استبدال الملكة', style: TextStyle(fontFamily: 'Cairo')), onTap: () { Navigator.pop(context); showConfirmationDialog(context: context, title: 'استبدال الملكة', onConfirm: () => onActionAdded({'action': 'replace_queen'})); }),
            ListTile(title: const Text('ضبط المدخل', style: TextStyle(fontFamily: 'Cairo')), onTap: () { Navigator.pop(context); showSetEntranceDialog(context, l10n, onActionAdded); }),
          ],
        ),
      ),
    ),
  );
}

void showAddFramesDialog(BuildContext context, AppLocalizations l10n, ValueChanged<Map<String, dynamic>> onActionAdded) {
  String type = 'foundation';
  int count = 1;
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('إضافة إطارات', style: TextStyle(fontFamily: 'Cairo')),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DropdownButtonFormField<String>(
            initialValue: type,
            items: const [
              DropdownMenuItem(value: 'foundation', child: Text('شمع أساس', style: TextStyle(fontFamily: 'Cairo'))),
              DropdownMenuItem(value: 'drawn', child: Text('شمع ممطوط', style: TextStyle(fontFamily: 'Cairo'))),
            ],
            onChanged: (val) => type = val!,
          ),
          TextFormField(
            initialValue: '1',
            decoration: const InputDecoration(labelText: 'العدد', labelStyle: TextStyle(fontFamily: 'Cairo')),
            keyboardType: TextInputType.number,
            onChanged: (val) => count = int.tryParse(val) ?? 1,
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.cancel, style: const TextStyle(fontFamily: 'Cairo'))),
        ElevatedButton(onPressed: () {
          onActionAdded({'action': 'add_frames', 'type': type, 'count': count});
          Navigator.pop(context);
        }, child: Text(l10n.save, style: const TextStyle(fontFamily: 'Cairo'))),
      ],
    ),
  );
}

void showAddFeedingDialog(BuildContext context, AppLocalizations l10n, ValueChanged<Map<String, dynamic>> onActionAdded) {
  String type = 'sugar';
  String amount = '1L';
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('إضافة تغذية', style: TextStyle(fontFamily: 'Cairo')),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DropdownButtonFormField<String>(
            initialValue: type,
            items: const [
              DropdownMenuItem(value: 'sugar', child: Text('محلول سكري', style: TextStyle(fontFamily: 'Cairo'))),
              DropdownMenuItem(value: 'pollen_patty', child: Text('عجينة بروتينية', style: TextStyle(fontFamily: 'Cairo'))),
            ],
            onChanged: (val) => type = val!,
          ),
          TextFormField(
            initialValue: '1L',
            decoration: const InputDecoration(labelText: 'الكمية', labelStyle: TextStyle(fontFamily: 'Cairo')),
            onChanged: (val) => amount = val,
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.cancel, style: const TextStyle(fontFamily: 'Cairo'))),
        ElevatedButton(onPressed: () {
          onActionAdded({'action': 'add_feeding', 'type': type, 'amount': amount});
          Navigator.pop(context);
        }, child: Text(l10n.save, style: const TextStyle(fontFamily: 'Cairo'))),
      ],
    ),
  );
}

void showSetEntranceDialog(BuildContext context, AppLocalizations l10n, ValueChanged<Map<String, dynamic>> onActionAdded) {
  String status = 'open';
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('ضبط المدخل', style: TextStyle(fontFamily: 'Cairo')),
      content: DropdownButtonFormField<String>(
        initialValue: status,
        items: const [
          DropdownMenuItem(value: 'open', child: Text('مفتوح', style: TextStyle(fontFamily: 'Cairo'))),
          DropdownMenuItem(value: 'partially_open', child: Text('مفتوح جزئياً', style: TextStyle(fontFamily: 'Cairo'))),
          DropdownMenuItem(value: 'closed', child: Text('مغلق', style: TextStyle(fontFamily: 'Cairo'))),
        ],
        onChanged: (val) => status = val!,
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.cancel, style: const TextStyle(fontFamily: 'Cairo'))),
        ElevatedButton(onPressed: () {
          onActionAdded({'action': 'set_entrance', 'status': status});
          Navigator.pop(context);
        }, child: Text(l10n.save, style: const TextStyle(fontFamily: 'Cairo'))),
      ],
    ),
  );
}
