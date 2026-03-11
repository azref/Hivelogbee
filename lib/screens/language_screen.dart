import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/custom_app_bar.dart';
import '../services/ad_service.dart';
import '../utils/app_theme.dart';
import '../providers/settings_provider.dart';

class LanguageScreen extends StatelessWidget {
  const LanguageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AdAwareScaffold(
      screen: AdScreen.settings,
      appBar: const CustomAppBar(
        title: 'اختيار اللغة',
        showBackButton: true,
      ),
      body: Consumer<SettingsProvider>(
        builder: (context, settingsProvider, child) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.language,
                              color: AppTheme.primaryYellow,
                              size: 24,
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              'اللغات المتاحة',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'اختر اللغة المفضلة لعرض التطبيق',
                          style: TextStyle(
                            color: AppTheme.darkBrown.withValues(alpha: 0.7), // --- تم التعديل هنا ---
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: Card(
                    child: ListView.separated(
                      padding: const EdgeInsets.all(8),
                      itemCount: settingsProvider.supportedLanguages.length,
                      separatorBuilder: (context, index) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final language = settingsProvider.supportedLanguages[index];
                        final isSelected = settingsProvider.language == language['code'];

                        return _buildLanguageItem(
                          context,
                          settingsProvider,
                          language,
                          isSelected,
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                _buildLanguageInfo(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildLanguageItem(
      BuildContext context,
      SettingsProvider settingsProvider,
      Map<String, String> language,
      bool isSelected,
      ) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: isSelected ? AppTheme.lightYellow : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: isSelected
            ? Border.all(color: AppTheme.primaryYellow, width: 2)
            : null,
      ),
      child: ListTile(
        leading: Container(
          width: 50,
          height: 35,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6),
            color: AppTheme.primaryYellow.withValues(alpha: 0.1), // --- تم التعديل هنا ---
            border: Border.all(
              color: AppTheme.primaryYellow.withValues(alpha: 0.3), // --- تم التعديل هنا ---
            ),
          ),
          child: Center(
            child: Text(
              _getLanguageFlag(language['code']!),
              style: const TextStyle(fontSize: 20),
            ),
          ),
        ),
        title: Text(
          language['nativeName']!,
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected ? AppTheme.darkBrown : null,
          ),
        ),
        subtitle: Text(
          language['name']!,
          style: TextStyle(
            color: AppTheme.darkBrown.withValues(alpha: 0.6), // --- تم التعديل هنا ---
            fontSize: 12,
          ),
        ),
        trailing: isSelected
            ? Icon(
          Icons.check_circle,
          color: AppTheme.primaryYellow,
          size: 24,
        )
            : Icon(
          Icons.radio_button_unchecked,
          color: AppTheme.darkBrown.withValues(alpha: 0.3), // --- تم التعديل هنا ---
          size: 24,
        ),
        onTap: () => _selectLanguage(context, settingsProvider, language['code']!),
      ),
    );
  }

  Widget _buildLanguageInfo() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: AppTheme.primaryYellow,
                  size: 20,
                ),
                const SizedBox(width: 8),
                const Text(
                  'معلومات اللغة',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildInfoItem(
              Icons.star,
              'اللغة الأساسية',
              'العربية الفصحى هي اللغة الأساسية للتطبيق',
            ),
            const SizedBox(height: 8),
            _buildInfoItem(
              Icons.translate,
              'الترجمة',
              'جميع النصوص والواجهات متوفرة باللغات المدعومة',
            ),
            const SizedBox(height: 8),
            _buildInfoItem(
              Icons.restart_alt,
              'إعادة التشغيل',
              'قد تحتاج لإعادة تشغيل التطبيق لتطبيق التغييرات',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String title, String description) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 16,
          color: AppTheme.darkBrown.withValues(alpha: 0.6), // --- تم التعديل هنا ---
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                description,
                style: TextStyle(
                  fontSize: 12,
                  color: AppTheme.darkBrown.withValues(alpha: 0.6), // --- تم التعديل هنا ---
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _getLanguageFlag(String languageCode) {
    switch (languageCode) {
      case 'ar':
        return '🇸🇦';
      case 'en':
        return '🇺🇸';
      case 'fr':
        return '🇫🇷';
      case 'es':
        return '🇪🇸';
      case 'de':
        return '🇩🇪';
      case 'ru':
        return '🇷🇺';
      case 'zh':
        return '🇨🇳';
      default:
        return '🌐';
    }
  }

  void _selectLanguage(BuildContext context, SettingsProvider settingsProvider, String languageCode) {
    if (settingsProvider.language == languageCode) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تغيير اللغة'),
        content: Text(
          'هل تريد تغيير لغة التطبيق إلى ${settingsProvider.getLanguageName(languageCode)}؟\n\nقد تحتاج لإعادة تشغيل التطبيق لتطبيق التغييرات.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await settingsProvider.setLanguage(languageCode);

              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'تم تغيير اللغة إلى ${settingsProvider.getLanguageName(languageCode)}',
                    ),
                    backgroundColor: AppTheme.successColor,
                    action: SnackBarAction(
                      label: 'إعادة التشغيل',
                      textColor: Colors.white,
                      onPressed: () {
                        // TODO: Restart app
                      },
                    ),
                  ),
                );
              }
            },
            child: const Text('تأكيد'),
          ),
        ],
      ),
    );
  }
}