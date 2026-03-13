import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_tr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('tr')
  ];

  /// No description provided for @appName.
  ///
  /// In ar, this message translates to:
  /// **'HiveLog Bee'**
  String get appName;

  /// No description provided for @appSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'إدارة المناحل بذكاء'**
  String get appSubtitle;

  /// No description provided for @login.
  ///
  /// In ar, this message translates to:
  /// **'تسجيل الدخول'**
  String get login;

  /// No description provided for @register.
  ///
  /// In ar, this message translates to:
  /// **'إنشاء حساب جديد'**
  String get register;

  /// No description provided for @email.
  ///
  /// In ar, this message translates to:
  /// **'البريد الإلكتروني'**
  String get email;

  /// No description provided for @password.
  ///
  /// In ar, this message translates to:
  /// **'كلمة المرور'**
  String get password;

  /// No description provided for @confirm_password.
  ///
  /// In ar, this message translates to:
  /// **'تأكيد كلمة المرور'**
  String get confirm_password;

  /// No description provided for @full_name.
  ///
  /// In ar, this message translates to:
  /// **'الاسم الكامل'**
  String get full_name;

  /// No description provided for @forgot_password.
  ///
  /// In ar, this message translates to:
  /// **'نسيت كلمة المرور؟'**
  String get forgot_password;

  /// No description provided for @remember_me.
  ///
  /// In ar, this message translates to:
  /// **'تذكرني'**
  String get remember_me;

  /// No description provided for @accept_terms.
  ///
  /// In ar, this message translates to:
  /// **'أوافق على شروط الاستخدام وسياسة الخصوصية'**
  String get accept_terms;

  /// No description provided for @home.
  ///
  /// In ar, this message translates to:
  /// **'الرئيسية'**
  String get home;

  /// No description provided for @hives.
  ///
  /// In ar, this message translates to:
  /// **'الخلايا'**
  String get hives;

  /// No description provided for @inspections.
  ///
  /// In ar, this message translates to:
  /// **'الفحوصات'**
  String get inspections;

  /// No description provided for @treatments.
  ///
  /// In ar, this message translates to:
  /// **'العلاجات'**
  String get treatments;

  /// No description provided for @production.
  ///
  /// In ar, this message translates to:
  /// **'الإنتاج'**
  String get production;

  /// No description provided for @reminders.
  ///
  /// In ar, this message translates to:
  /// **'التذكيرات'**
  String get reminders;

  /// No description provided for @knowledge.
  ///
  /// In ar, this message translates to:
  /// **'المعرفة'**
  String get knowledge;

  /// No description provided for @settings.
  ///
  /// In ar, this message translates to:
  /// **'الإعدادات'**
  String get settings;

  /// No description provided for @profile.
  ///
  /// In ar, this message translates to:
  /// **'الملف الشخصي'**
  String get profile;

  /// No description provided for @statistics.
  ///
  /// In ar, this message translates to:
  /// **'الإحصائيات'**
  String get statistics;

  /// No description provided for @weather.
  ///
  /// In ar, this message translates to:
  /// **'الطقس'**
  String get weather;

  /// No description provided for @add_hive.
  ///
  /// In ar, this message translates to:
  /// **'إضافة خلية'**
  String get add_hive;

  /// No description provided for @add_inspection.
  ///
  /// In ar, this message translates to:
  /// **'إضافة فحص'**
  String get add_inspection;

  /// No description provided for @add_treatment.
  ///
  /// In ar, this message translates to:
  /// **'إضافة علاج'**
  String get add_treatment;

  /// No description provided for @hive_number.
  ///
  /// In ar, this message translates to:
  /// **'رقم الخلية'**
  String get hive_number;

  /// No description provided for @hive_status.
  ///
  /// In ar, this message translates to:
  /// **'حالة الخلية'**
  String get hive_status;

  /// No description provided for @queen_status.
  ///
  /// In ar, this message translates to:
  /// **'حالة الملكة'**
  String get queen_status;

  /// No description provided for @frame_count.
  ///
  /// In ar, this message translates to:
  /// **'عدد الإطارات'**
  String get frame_count;

  /// No description provided for @honey_frames.
  ///
  /// In ar, this message translates to:
  /// **'إطارات عسل'**
  String get honey_frames;

  /// No description provided for @brood_frames.
  ///
  /// In ar, this message translates to:
  /// **'إطارات حضنة'**
  String get brood_frames;

  /// No description provided for @save.
  ///
  /// In ar, this message translates to:
  /// **'حفظ'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In ar, this message translates to:
  /// **'إلغاء'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In ar, this message translates to:
  /// **'حذف'**
  String get delete;

  /// No description provided for @edit.
  ///
  /// In ar, this message translates to:
  /// **'تعديل'**
  String get edit;

  /// No description provided for @search.
  ///
  /// In ar, this message translates to:
  /// **'البحث'**
  String get search;

  /// No description provided for @filter.
  ///
  /// In ar, this message translates to:
  /// **'تصفية'**
  String get filter;

  /// No description provided for @sort.
  ///
  /// In ar, this message translates to:
  /// **'ترتيب'**
  String get sort;

  /// No description provided for @date.
  ///
  /// In ar, this message translates to:
  /// **'التاريخ'**
  String get date;

  /// No description provided for @notes.
  ///
  /// In ar, this message translates to:
  /// **'الملاحظات'**
  String get notes;

  /// No description provided for @location.
  ///
  /// In ar, this message translates to:
  /// **'الموقع'**
  String get location;

  /// No description provided for @temperature.
  ///
  /// In ar, this message translates to:
  /// **'درجة الحرارة'**
  String get temperature;

  /// No description provided for @humidity.
  ///
  /// In ar, this message translates to:
  /// **'الرطوبة'**
  String get humidity;

  /// No description provided for @wind_speed.
  ///
  /// In ar, this message translates to:
  /// **'سرعة الرياح'**
  String get wind_speed;

  /// No description provided for @language.
  ///
  /// In ar, this message translates to:
  /// **'اللغة'**
  String get language;

  /// No description provided for @theme.
  ///
  /// In ar, this message translates to:
  /// **'المظهر'**
  String get theme;

  /// No description provided for @notifications.
  ///
  /// In ar, this message translates to:
  /// **'الإشعارات'**
  String get notifications;

  /// No description provided for @backup.
  ///
  /// In ar, this message translates to:
  /// **'النسخ الاحتياطي'**
  String get backup;

  /// No description provided for @about.
  ///
  /// In ar, this message translates to:
  /// **'حول التطبيق'**
  String get about;

  /// No description provided for @logout.
  ///
  /// In ar, this message translates to:
  /// **'تسجيل الخروج'**
  String get logout;

  /// No description provided for @total_hives.
  ///
  /// In ar, this message translates to:
  /// **'إجمالي الخلايا'**
  String get total_hives;

  /// No description provided for @total_production.
  ///
  /// In ar, this message translates to:
  /// **'إجمالي الإنتاج'**
  String get total_production;

  /// No description provided for @active_treatments.
  ///
  /// In ar, this message translates to:
  /// **'العلاجات النشطة'**
  String get active_treatments;

  /// No description provided for @pending_inspections.
  ///
  /// In ar, this message translates to:
  /// **'الفحوصات المعلقة'**
  String get pending_inspections;

  /// No description provided for @kg.
  ///
  /// In ar, this message translates to:
  /// **'كغ'**
  String get kg;

  /// No description provided for @celsius.
  ///
  /// In ar, this message translates to:
  /// **'°م'**
  String get celsius;

  /// No description provided for @percent.
  ///
  /// In ar, this message translates to:
  /// **'%'**
  String get percent;

  /// No description provided for @kmh.
  ///
  /// In ar, this message translates to:
  /// **'كم/س'**
  String get kmh;

  /// No description provided for @light_mode.
  ///
  /// In ar, this message translates to:
  /// **'الوضع النهاري'**
  String get light_mode;

  /// No description provided for @dark_mode.
  ///
  /// In ar, this message translates to:
  /// **'الوضع الليلي'**
  String get dark_mode;

  /// No description provided for @system_mode.
  ///
  /// In ar, this message translates to:
  /// **'تتبع النظام'**
  String get system_mode;

  /// No description provided for @push_notifications.
  ///
  /// In ar, this message translates to:
  /// **'الإشعارات الفورية'**
  String get push_notifications;

  /// No description provided for @email_notifications.
  ///
  /// In ar, this message translates to:
  /// **'الإشعارات بالبريد'**
  String get email_notifications;

  /// No description provided for @weather_alerts.
  ///
  /// In ar, this message translates to:
  /// **'تنبيهات الطقس'**
  String get weather_alerts;

  /// No description provided for @auto_backup.
  ///
  /// In ar, this message translates to:
  /// **'النسخ الاحتياطي التلقائي'**
  String get auto_backup;

  /// No description provided for @offline_mode.
  ///
  /// In ar, this message translates to:
  /// **'الوضع غير المتصل'**
  String get offline_mode;

  /// No description provided for @clear_cache.
  ///
  /// In ar, this message translates to:
  /// **'مسح البيانات المؤقتة'**
  String get clear_cache;

  /// No description provided for @app_version.
  ///
  /// In ar, this message translates to:
  /// **'إصدار التطبيق'**
  String get app_version;

  /// No description provided for @contact_support.
  ///
  /// In ar, this message translates to:
  /// **'الدعم الفني'**
  String get contact_support;

  /// No description provided for @rate_app.
  ///
  /// In ar, this message translates to:
  /// **'تقييم التطبيق'**
  String get rate_app;

  /// No description provided for @share_app.
  ///
  /// In ar, this message translates to:
  /// **'مشاركة التطبيق'**
  String get share_app;

  /// No description provided for @privacy_policy.
  ///
  /// In ar, this message translates to:
  /// **'سياسة الخصوصية'**
  String get privacy_policy;

  /// No description provided for @terms_of_service.
  ///
  /// In ar, this message translates to:
  /// **'شروط الاستخدام'**
  String get terms_of_service;

  /// No description provided for @mapScreenTitle.
  ///
  /// In ar, this message translates to:
  /// **'الخريطة'**
  String get mapScreenTitle;

  /// No description provided for @reports.
  ///
  /// In ar, this message translates to:
  /// **'التقارير'**
  String get reports;

  /// No description provided for @viewDetails.
  ///
  /// In ar, this message translates to:
  /// **'عرض التفاصيل'**
  String get viewDetails;

  /// No description provided for @basic_info.
  ///
  /// In ar, this message translates to:
  /// **'المعلومات الأساسية'**
  String get basic_info;

  /// No description provided for @hive_type.
  ///
  /// In ar, this message translates to:
  /// **'نوع الخلية'**
  String get hive_type;

  /// No description provided for @full_hive.
  ///
  /// In ar, this message translates to:
  /// **'خلية كاملة'**
  String get full_hive;

  /// No description provided for @nucleus_hive.
  ///
  /// In ar, this message translates to:
  /// **'طرد (نويّة)'**
  String get nucleus_hive;

  /// No description provided for @installation_date.
  ///
  /// In ar, this message translates to:
  /// **'تاريخ التركيب'**
  String get installation_date;

  /// No description provided for @map_location.
  ///
  /// In ar, this message translates to:
  /// **'تحديد الموقع من الخريطة'**
  String get map_location;

  /// No description provided for @bee_breed.
  ///
  /// In ar, this message translates to:
  /// **'سلالة النحل'**
  String get bee_breed;

  /// No description provided for @status_active.
  ///
  /// In ar, this message translates to:
  /// **'نشطة'**
  String get status_active;

  /// No description provided for @status_weak.
  ///
  /// In ar, this message translates to:
  /// **'ضعيفة'**
  String get status_weak;

  /// No description provided for @status_sick.
  ///
  /// In ar, this message translates to:
  /// **'مريضة'**
  String get status_sick;

  /// No description provided for @status_dead.
  ///
  /// In ar, this message translates to:
  /// **'ميتة'**
  String get status_dead;

  /// No description provided for @status_swarmed.
  ///
  /// In ar, this message translates to:
  /// **'مطردة'**
  String get status_swarmed;

  /// No description provided for @queen_present.
  ///
  /// In ar, this message translates to:
  /// **'موجودة'**
  String get queen_present;

  /// No description provided for @queen_absent.
  ///
  /// In ar, this message translates to:
  /// **'غير موجودة'**
  String get queen_absent;

  /// No description provided for @queen_isNew.
  ///
  /// In ar, this message translates to:
  /// **'عذراء'**
  String get queen_isNew;

  /// No description provided for @queen_old.
  ///
  /// In ar, this message translates to:
  /// **'قديمة'**
  String get queen_old;

  /// No description provided for @queen_marked.
  ///
  /// In ar, this message translates to:
  /// **'معلمة'**
  String get queen_marked;

  /// No description provided for @queen_unmarked.
  ///
  /// In ar, this message translates to:
  /// **'غير معلمة'**
  String get queen_unmarked;

  /// No description provided for @breed_carniolan.
  ///
  /// In ar, this message translates to:
  /// **'كرنيولي'**
  String get breed_carniolan;

  /// No description provided for @breed_italian.
  ///
  /// In ar, this message translates to:
  /// **'إيطالي'**
  String get breed_italian;

  /// No description provided for @breed_caucasian.
  ///
  /// In ar, this message translates to:
  /// **'قوقازي'**
  String get breed_caucasian;

  /// No description provided for @breed_buckfast.
  ///
  /// In ar, this message translates to:
  /// **'بكفاست'**
  String get breed_buckfast;

  /// No description provided for @breed_local.
  ///
  /// In ar, this message translates to:
  /// **'محلي'**
  String get breed_local;

  /// No description provided for @breed_hybrid.
  ///
  /// In ar, this message translates to:
  /// **'هجين'**
  String get breed_hybrid;

  /// No description provided for @select_date.
  ///
  /// In ar, this message translates to:
  /// **'اختر التاريخ'**
  String get select_date;

  /// No description provided for @error_enter_number.
  ///
  /// In ar, this message translates to:
  /// **'يرجى إدخال رقم الخلية'**
  String get error_enter_number;

  /// No description provided for @error_invalid_number.
  ///
  /// In ar, this message translates to:
  /// **'يرجى إدخال رقم صحيح'**
  String get error_invalid_number;

  /// No description provided for @hive_saved_success.
  ///
  /// In ar, this message translates to:
  /// **'تم حفظ الخلية بنجاح'**
  String get hive_saved_success;

  /// No description provided for @error_login_required.
  ///
  /// In ar, this message translates to:
  /// **'خطأ: يجب تسجيل الدخول أولاً'**
  String get error_login_required;

  /// No description provided for @status_queenless.
  ///
  /// In ar, this message translates to:
  /// **'يتيمة (بدون ملكة)'**
  String get status_queenless;

  /// No description provided for @status_split.
  ///
  /// In ar, this message translates to:
  /// **'مقسومة'**
  String get status_split;

  /// No description provided for @status_merged.
  ///
  /// In ar, this message translates to:
  /// **'مضمومة'**
  String get status_merged;

  /// No description provided for @hive_frames_distribution.
  ///
  /// In ar, this message translates to:
  /// **'توزيع الإطارات'**
  String get hive_frames_distribution;

  /// No description provided for @error_invalid_value.
  ///
  /// In ar, this message translates to:
  /// **'قيمة غير صالحة'**
  String get error_invalid_value;

  /// No description provided for @select_hive.
  ///
  /// In ar, this message translates to:
  /// **'اختيار الخلية'**
  String get select_hive;

  /// No description provided for @select_hive_placeholder.
  ///
  /// In ar, this message translates to:
  /// **'اختر خلية'**
  String get select_hive_placeholder;

  /// No description provided for @inspection_date.
  ///
  /// In ar, this message translates to:
  /// **'تاريخ الفحص'**
  String get inspection_date;

  /// No description provided for @brood_status.
  ///
  /// In ar, this message translates to:
  /// **'حالة الحضنة'**
  String get brood_status;

  /// No description provided for @select_brood_status_placeholder.
  ///
  /// In ar, this message translates to:
  /// **'اختر حالة الحضنة'**
  String get select_brood_status_placeholder;

  /// No description provided for @environmental_data.
  ///
  /// In ar, this message translates to:
  /// **'البيانات البيئية'**
  String get environmental_data;

  /// No description provided for @overall_status.
  ///
  /// In ar, this message translates to:
  /// **'الحالة العامة'**
  String get overall_status;

  /// No description provided for @select_overall_status_placeholder.
  ///
  /// In ar, this message translates to:
  /// **'اختر الحالة العامة'**
  String get select_overall_status_placeholder;

  /// No description provided for @detected_issues.
  ///
  /// In ar, this message translates to:
  /// **'المشاكل المكتشفة'**
  String get detected_issues;

  /// No description provided for @select_issues_placeholder.
  ///
  /// In ar, this message translates to:
  /// **'اختر المشاكل المكتشفة'**
  String get select_issues_placeholder;

  /// No description provided for @notes_placeholder.
  ///
  /// In ar, this message translates to:
  /// **'اكتب ملاحظاتك هنا...'**
  String get notes_placeholder;

  /// No description provided for @error_select_hive.
  ///
  /// In ar, this message translates to:
  /// **'يرجى اختيار خلية أولاً'**
  String get error_select_hive;

  /// No description provided for @inspection_saved_success.
  ///
  /// In ar, this message translates to:
  /// **'تم حفظ الفحص بنجاح'**
  String get inspection_saved_success;

  /// No description provided for @error_saving_inspection.
  ///
  /// In ar, this message translates to:
  /// **'حدث خطأ أثناء حفظ الفحص'**
  String get error_saving_inspection;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en', 'es', 'fr', 'tr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
    case 'tr':
      return AppLocalizationsTr();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
