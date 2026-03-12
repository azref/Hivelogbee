import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../utils/app_theme.dart';
import '../screens/settings_screen.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showBackButton;
  final VoidCallback? onBackButtonPressed;
  final List<Widget>? additionalActions;
  final String? shareText;
  final String? shareSubject;
  final VoidCallback? onNotificationPressed;
  final bool centerTitle;

  const CustomAppBar({
    super.key,
    required this.title,
    this.showBackButton = false,
    this.onBackButtonPressed,
    this.additionalActions,
    this.shareText,
    this.shareSubject,
    this.onNotificationPressed,
    this.centerTitle = true,
  });

  @override
  Widget build(BuildContext context) {
    const Color appBarColor = AppTheme.primaryYellow;
    const Color iconAndTextColor = AppTheme.darkBrown;

    return AppBar(
      backgroundColor: appBarColor,
      elevation: 1.0,
      centerTitle: centerTitle,

      // --- الجرس في الـ leading (الجهة اليسرى في العربية) ---
      leading: showBackButton
          ? IconButton(
        icon: const Icon(Icons.arrow_back_ios_new, color: iconAndTextColor),
        onPressed: onBackButtonPressed ?? () => Navigator.of(context).pop(),
      )
          : IconButton(
        icon: const Icon(Icons.notifications_none_outlined, color: iconAndTextColor),
        onPressed: onNotificationPressed ?? () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('لا توجد إشعارات جديدة'),
              backgroundColor: AppTheme.primaryYellow,
            ),
          );
        },
      ),
      automaticallyImplyLeading: false,

      // --- العنوان في المنتصف ---
      title: Text(
        title,
        style: const TextStyle(
          color: iconAndTextColor,
          fontSize: 15,
          fontWeight: FontWeight.bold,
        ),
      ),

      // --- باقي الأيقونات في الـ actions (الجهة اليمنى) ---
      actions: _buildActions(context),
    );
  }

  List<Widget> _buildActions(BuildContext context) {
    final allActions = <Widget>[];

    // 1. الأيقونات الإضافية من الشاشة الحاضنة (الثلاث نقاط)
    if (additionalActions != null) {
      allActions.addAll(additionalActions!);
    }

    // 2. أيقونة المشاركة
    allActions.add(
      IconButton(
        icon: const Icon(Icons.share_outlined, color: AppTheme.darkBrown),
        onPressed: () => _shareApp(context),
      ),
    );

    // 3. أيقونة الإعدادات
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