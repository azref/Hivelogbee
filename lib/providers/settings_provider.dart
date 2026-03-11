import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider extends ChangeNotifier {
  static const String _themeModeKey = 'theme_mode';
  static const String _languageKey = 'language';
  static const String _pushNotificationsKey = 'push_notifications';
  static const String _emailNotificationsKey = 'email_notifications';
  static const String _weatherAlertsKey = 'weather_alerts';
  static const String _autoBackupKey = 'auto_backup';
  static const String _offlineModeKey = 'offline_mode';

  ThemeMode _themeMode = ThemeMode.system;
  String _language = 'ar';
  bool _pushNotificationsEnabled = true;
  bool _emailNotificationsEnabled = true;
  bool _weatherAlertsEnabled = true;
  bool _autoBackupEnabled = true;
  bool _offlineModeEnabled = true;

  ThemeMode get themeMode => _themeMode;
  String get language => _language;

  // --- تمت إضافة هذا الـ Getter ---
  Locale get locale => Locale(_language);
  // ---------------------------------

  bool get pushNotificationsEnabled => _pushNotificationsEnabled;
  bool get emailNotificationsEnabled => _emailNotificationsEnabled;
  bool get weatherAlertsEnabled => _weatherAlertsEnabled;
  bool get autoBackupEnabled => _autoBackupEnabled;
  bool get offlineModeEnabled => _offlineModeEnabled;

  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();

    final themeModeIndex = prefs.getInt(_themeModeKey) ?? ThemeMode.system.index;
    _themeMode = ThemeMode.values[themeModeIndex];

    _language = prefs.getString(_languageKey) ?? 'ar';
    _pushNotificationsEnabled = prefs.getBool(_pushNotificationsKey) ?? true;
    _emailNotificationsEnabled = prefs.getBool(_emailNotificationsKey) ?? true;
    _weatherAlertsEnabled = prefs.getBool(_weatherAlertsKey) ?? true;
    _autoBackupEnabled = prefs.getBool(_autoBackupKey) ?? true;
    _offlineModeEnabled = prefs.getBool(_offlineModeKey) ?? true;

    notifyListeners();
  }

  Future<void> setLanguage(String language) async {
    _language = language;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageKey, language);
  }

  // ... باقي الدوال تبقى كما هي ...

  Future<void> setThemeMode(ThemeMode themeMode) async {
    _themeMode = themeMode;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_themeModeKey, themeMode.index);
  }

  Future<void> setPushNotifications(bool enabled) async {
    _pushNotificationsEnabled = enabled;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_pushNotificationsKey, enabled);
  }

  Future<void> setEmailNotifications(bool enabled) async {
    _emailNotificationsEnabled = enabled;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_emailNotificationsKey, enabled);
  }

  Future<void> setWeatherAlerts(bool enabled) async {
    _weatherAlertsEnabled = enabled;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_weatherAlertsKey, enabled);
  }

  Future<void> setAutoBackup(bool enabled) async {
    _autoBackupEnabled = enabled;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_autoBackupKey, enabled);
  }

  Future<void> setOfflineMode(bool enabled) async {
    _offlineModeEnabled = enabled;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_offlineModeKey, enabled);
  }

  Map<String, dynamic> getAllSettings() {
    return {
      'themeMode': _themeMode.name,
      'language': _language,
      'pushNotifications': _pushNotificationsEnabled,
      'emailNotifications': _emailNotificationsEnabled,
      'weatherAlerts': _weatherAlertsEnabled,
      'autoBackup': _autoBackupEnabled,
      'offlineMode': _offlineModeEnabled,
    };
  }

  Future<void> resetToDefaults() async {
    _themeMode = ThemeMode.system;
    _language = 'ar';
    _pushNotificationsEnabled = true;
    _emailNotificationsEnabled = true;
    _weatherAlertsEnabled = true;
    _autoBackupEnabled = true;
    _offlineModeEnabled = true;

    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  String getLanguageName(String languageCode) {
    switch (languageCode) {
      case 'ar':
        return 'العربية';
      case 'en':
        return 'English';
      case 'fr':
        return 'Français';
      case 'es':
        return 'Español';
      case 'de':
        return 'Deutsch';
      case 'ru':
        return 'Русский';
      case 'zh':
        return '中文';
      default:
        return 'العربية';
    }
  }

  List<Map<String, String>> get supportedLanguages => [
    {'code': 'ar', 'name': 'Arabic', 'nativeName': 'العربية', 'flag': '🇸🇦'},
    {'code': 'en', 'name': 'English', 'nativeName': 'English', 'flag': '🇺🇸'},
    {'code': 'fr', 'name': 'French', 'nativeName': 'Français', 'flag': '🇫🇷'},
    {'code': 'es', 'name': 'Spanish', 'nativeName': 'Español', 'flag': '🇪🇸'},
    {'code': 'de', 'name': 'German', 'nativeName': 'Deutsch', 'flag': '🇩🇪'},
    {'code': 'ru', 'name': 'Russian', 'nativeName': 'Русский', 'flag': '🇷🇺'},
    {'code': 'zh', 'name': 'Chinese', 'nativeName': '中文', 'flag': '🇨🇳'},
  ];

  bool get isRTL => _language == 'ar';

  TextDirection get textDirection => isRTL ? TextDirection.rtl : TextDirection.ltr;
}
