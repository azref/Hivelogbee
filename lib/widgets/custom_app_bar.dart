import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../utils/app_theme.dart';
import '../screens/settings_screen.dart'; // تم إضافة الاستيراد

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showBackButton;
  final VoidCallback? onBackButtonPressed;
  final List<Widget>? additionalActions;
  final String? shareText;
  final String? shareSubject;
  final VoidCallback? onNotificationPressed; // معامل جديد لزر الجرس

  const CustomAppBar({
    super.key,
    required this.title,
    this.showBackButton = false,
    this.onBackButtonPressed,
    this.additionalActions,
    this.shareText,
    this.shareSubject,
    this.onNotificationPressed, // معامل جديد
  });

  @override
  Widget build(BuildContext context) {
    // --- تم التعديل: استخدام الأصفر كلون للشريط والبني للأيقونات ---
    const Color appBarColor = AppTheme.primaryYellow;
    const Color iconAndTextColor = AppTheme.darkBrown;
    // ---------------------------------------------

    return AppBar(
      backgroundColor: appBarColor,
      elevation: 1.0,
      centerTitle: true,

      leading: showBackButton
          ? IconButton(
        icon: const Icon(Icons.arrow_back_ios_new, color: iconAndTextColor),
        onPressed: onBackButtonPressed ?? () => Navigator.of(context).pop(),
      )
          : null,
      automaticallyImplyLeading: false,

      title: Text(
        title,
        style: const TextStyle(
          color: iconAndTextColor,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),

      actions: _buildActions(context),
    );
  }

  List<Widget> _buildActions(BuildContext context) {
    final allActions = <Widget>[];

    // 1. الجرس الثابت مع وظيفته
    allActions.add(
      IconButton(
        icon: const Icon(Icons.notifications_none_outlined, color: AppTheme.darkBrown),
        onPressed: onNotificationPressed ?? () {
          // وظيفة افتراضية إذا لم يتم تمرير معامل
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('لا توجد إشعارات جديدة'),
              backgroundColor: AppTheme.primaryYellow,
            ),
          );
        },
      ),
    );

    // 2. الأيقونات الإضافية من الشاشة الحاضنة
    if (additionalActions != null) {
      allActions.addAll(additionalActions!);
    }

    // 3. أيقونة المشاركة
    allActions.add(
      IconButton(
        icon: const Icon(Icons.share_outlined, color: AppTheme.darkBrown),
        onPressed: () => _shareApp(context),
      ),
    );

    // 4. أيقونة الإعدادات (تم تعديلها لتعمل)
    allActions.add(
      IconButton(
        icon: const Icon(Icons.settings_outlined, color: AppTheme.darkBrown),
        onPressed: () => _openSettings(context),
      ),
    );

    allActions.add(const SizedBox(width: 8));

    return allActions;
  }

  void _shareApp(BuildContext context) {
    final defaultText = shareText ?? 'تحقق من هذا التطبيق الرائع!';
    final defaultSubject = shareSubject ?? 'HiveLog Bee';
    Share.share(defaultText, subject: defaultSubject);
  }

  // --- تم تعديل هذه الدالة لتعمل فعلياً ---
  void _openSettings(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const SettingsScreen(),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}