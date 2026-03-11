import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/custom_app_bar.dart';
import '../services/ad_service.dart';
import '../utils/app_theme.dart';
import '../providers/settings_provider.dart';
import '../providers/auth_provider.dart';
import 'profile_screen.dart';
import 'language_screen.dart';
import 'about_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AdAwareScaffold(
      screen: AdScreen.settings,
      appBar: const CustomAppBar(
        title: 'الإعدادات',
        showBackButton: true,
      ),
      body: Consumer2<SettingsProvider, AuthProvider>(
        builder: (context, settingsProvider, authProvider, child) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildProfileSection(context, authProvider),
              const SizedBox(height: 24),
              _buildAppearanceSection(context, settingsProvider),
              const SizedBox(height: 24),
              _buildLanguageSection(context, settingsProvider),
              const SizedBox(height: 24),
              _buildNotificationSection(context, settingsProvider),
              const SizedBox(height: 24),
              _buildDataSection(context, settingsProvider),
              const SizedBox(height: 24),
              _buildSupportSection(context),
              const SizedBox(height: 24),
              _buildAccountSection(context, authProvider),
            ],
          );
        },
      ),
    );
  }

  Widget _buildProfileSection(BuildContext context, AuthProvider authProvider) {
    final user = authProvider.user;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(
                  Icons.person,
                  color: AppTheme.primaryYellow,
                  size: 24,
                ),
                SizedBox(width: 12),
                Text(
                  'الملف الشخصي',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: CircleAvatar(
                radius: 25,
                backgroundImage: (user?.photoURL != null && user!.photoURL!.isNotEmpty)
                    ? NetworkImage(user.photoURL!)
                    : null,
                backgroundColor: AppTheme.primaryYellow.withAlpha(50),
                child: (user?.photoURL == null || user!.photoURL!.isEmpty)
                    ? const Icon(
                  Icons.person,
                  color: AppTheme.darkBrown,
                  size: 30,
                )
                    : null,
              ),
              title: Text(
                user?.displayName ?? 'المستخدم',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: Text(user?.email ?? ''),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ProfileScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppearanceSection(BuildContext context, SettingsProvider settingsProvider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(
                  Icons.palette,
                  color: AppTheme.primaryYellow,
                  size: 24,
                ),
                SizedBox(width: 12),
                Text(
                  'المظهر',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: Icon(
                settingsProvider.themeMode == ThemeMode.dark
                    ? Icons.dark_mode
                    : settingsProvider.themeMode == ThemeMode.light
                    ? Icons.light_mode
                    : Icons.brightness_auto,
                color: AppTheme.darkBrown,
              ),
              title: const Text('وضع العرض'),
              subtitle: Text(_getThemeModeText(settingsProvider.themeMode)),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () => _showThemeModeDialog(context, settingsProvider),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageSection(BuildContext context, SettingsProvider settingsProvider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(
                  Icons.language,
                  color: AppTheme.primaryYellow,
                  size: 24,
                ),
                SizedBox(width: 12),
                Text(
                  'اللغة',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(
                Icons.translate,
                color: AppTheme.darkBrown,
              ),
              title: const Text('لغة التطبيق'),
              subtitle: Text(_getLanguageText(settingsProvider.language)),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const LanguageScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationSection(BuildContext context, SettingsProvider settingsProvider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(
                  Icons.notifications,
                  color: AppTheme.primaryYellow,
                  size: 24,
                ),
                SizedBox(width: 12),
                Text(
                  'الإشعارات',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              secondary: const Icon(
                Icons.push_pin,
                color: AppTheme.darkBrown,
              ),
              title: const Text('الإشعارات الفورية'),
              subtitle: const Text('تلقي إشعارات فورية للتذكيرات المهمة'),
              value: settingsProvider.pushNotificationsEnabled,
              activeTrackColor: AppTheme.primaryYellow,
              onChanged: (value) {
                settingsProvider.setPushNotifications(value);
              },
            ),
            SwitchListTile(
              secondary: const Icon(
                Icons.email,
                color: AppTheme.darkBrown,
              ),
              title: const Text('الإشعارات بالبريد'),
              subtitle: const Text('تلقي تذكيرات عبر البريد الإلكتروني'),
              value: settingsProvider.emailNotificationsEnabled,
              activeTrackColor: AppTheme.primaryYellow,
              onChanged: (value) {
                settingsProvider.setEmailNotifications(value);
              },
            ),
            SwitchListTile(
              secondary: const Icon(
                Icons.cloud,
                color: AppTheme.darkBrown,
              ),
              title: const Text('تنبيهات الطقس'),
              subtitle: const Text('تلقي تنبيهات حالة الطقس'),
              value: settingsProvider.weatherAlertsEnabled,
              activeTrackColor: AppTheme.primaryYellow,
              onChanged: (value) {
                settingsProvider.setWeatherAlerts(value);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDataSection(BuildContext context, SettingsProvider settingsProvider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(
                  Icons.storage,
                  color: AppTheme.primaryYellow,
                  size: 24,
                ),
                SizedBox(width: 12),
                Text(
                  'البيانات والتخزين',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              secondary: const Icon(
                Icons.cloud_sync,
                color: AppTheme.darkBrown,
              ),
              title: const Text('النسخ الاحتياطي التلقائي'),
              subtitle: const Text('حفظ البيانات تلقائياً في السحابة'),
              value: settingsProvider.autoBackupEnabled,
              activeTrackColor: AppTheme.primaryYellow,
              onChanged: (value) {
                settingsProvider.setAutoBackup(value);
              },
            ),
            SwitchListTile(
              secondary: const Icon(
                Icons.offline_bolt,
                color: AppTheme.darkBrown,
              ),
              title: const Text('الوضع غير المتصل'),
              subtitle: const Text('العمل بدون اتصال بالإنترنت'),
              value: settingsProvider.offlineModeEnabled,
              activeTrackColor: AppTheme.primaryYellow,
              onChanged: (value) {
                settingsProvider.setOfflineMode(value);
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.cleaning_services,
                color: AppTheme.darkBrown,
              ),
              title: const Text('مسح البيانات المؤقتة'),
              subtitle: const Text('تحرير مساحة التخزين'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () => _showClearCacheDialog(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSupportSection(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(
                  Icons.help,
                  color: AppTheme.primaryYellow,
                  size: 24,
                ),
                SizedBox(width: 12),
                Text(
                  'المساعدة والدعم',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(
                Icons.info,
                color: AppTheme.darkBrown,
              ),
              title: const Text('حول التطبيق'),
              subtitle: const Text('معلومات التطبيق والإصدار'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AboutScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.feedback,
                color: AppTheme.darkBrown,
              ),
              title: const Text('إرسال ملاحظات'),
              subtitle: const Text('شاركنا رأيك واقتراحاتك'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () => _sendFeedback(context),
            ),
            ListTile(
              leading: const Icon(
                Icons.star_rate,
                color: AppTheme.darkBrown,
              ),
              title: const Text('تقييم التطبيق'),
              subtitle: const Text('قيم التطبيق في متجر Google Play'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () => _rateApp(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountSection(BuildContext context, AuthProvider authProvider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(
                  Icons.account_circle,
                  color: AppTheme.primaryYellow,
                  size: 24,
                ),
                SizedBox(width: 12),
                Text(
                  'الحساب',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(
                Icons.logout,
                color: AppTheme.errorColor,
              ),
              title: const Text(
                'تسجيل الخروج',
                style: TextStyle(
                  color: AppTheme.errorColor,
                ),
              ),
              subtitle: const Text('الخروج من الحساب الحالي'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () => _showLogoutDialog(context, authProvider),
            ),
          ],
        ),
      ),
    );
  }

  String _getThemeModeText(ThemeMode themeMode) {
    switch (themeMode) {
      case ThemeMode.light:
        return 'الوضع النهاري';
      case ThemeMode.dark:
        return 'الوضع الليلي';
      case ThemeMode.system:
        return 'تتبع النظام';
    }
  }

  String _getLanguageText(String language) {
    switch (language) {
      case 'ar':
        return 'العربية';
      case 'en':
        return 'English';
      case 'fr':
        return 'Français';
      default:
        return 'العربية';
    }
  }

  void _showThemeModeDialog(BuildContext context, SettingsProvider settingsProvider) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('اختر وضع العرض'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioListTile<ThemeMode>(
                title: const Text('الوضع النهاري'),
                value: ThemeMode.light,
                groupValue: settingsProvider.themeMode,
                onChanged: (ThemeMode? value) {
                  if (value != null) {
                    settingsProvider.setThemeMode(value);
                    Navigator.pop(context);
                  }
                },
                activeColor: AppTheme.primaryYellow,
              ),
              RadioListTile<ThemeMode>(
                title: const Text('الوضع الليلي'),
                value: ThemeMode.dark,
                groupValue: settingsProvider.themeMode,
                onChanged: (ThemeMode? value) {
                  if (value != null) {
                    settingsProvider.setThemeMode(value);
                    Navigator.pop(context);
                  }
                },
                activeColor: AppTheme.primaryYellow,
              ),
              RadioListTile<ThemeMode>(
                title: const Text('تتبع النظام'),
                value: ThemeMode.system,
                groupValue: settingsProvider.themeMode,
                onChanged: (ThemeMode? value) {
                  if (value != null) {
                    settingsProvider.setThemeMode(value);
                    Navigator.pop(context);
                  }
                },
                activeColor: AppTheme.primaryYellow,
              ),
            ],
          ),
        );
      },
    );
  }

  void _showClearCacheDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('مسح البيانات المؤقتة'),
        content: const Text('هل تريد مسح البيانات المؤقتة؟ سيؤدي هذا إلى تحرير مساحة التخزين.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('تم مسح البيانات المؤقتة بنجاح'),
                  backgroundColor: AppTheme.successColor,
                ),
              );
            },
            child: const Text('مسح'),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, AuthProvider authProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تسجيل الخروج'),
        content: const Text('هل تريد تسجيل الخروج من حسابك؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await authProvider.signOut();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
            ),
            child: const Text('تسجيل الخروج'),
          ),
        ],
      ),
    );
  }

  void _sendFeedback(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('سيتم فتح تطبيق البريد الإلكتروني'),
        backgroundColor: AppTheme.primaryYellow,
      ),
    );
  }

  void _rateApp(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('سيتم فتح متجر Google Play'),
        backgroundColor: AppTheme.primaryYellow,
      ),
    );
  }
}