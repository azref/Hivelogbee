// تم حذف 'package:cloud_firestore/cloud_firestore.dart'

enum UserRole {
  beekeeper,
  admin,
  moderator,
  user,
}

enum SubscriptionType {
  free,
  pro,
  premium,
}

enum ExperienceLevel {
  beginner,
  intermediate,
  advanced,
  expert,
}

class UserModel {
  final String id;
  final String email;
  final String displayName;
  final String? photoURL;
  final String? phoneNumber;
  final UserRole role;
  final SubscriptionType subscriptionType;
  final DateTime? subscriptionExpiry;
  final ExperienceLevel experienceLevel;
  final int yearsOfExperience;
  final String? location;
  final double? latitude;
  final double? longitude;
  final String? country;
  final String? region;
  final String preferredLanguage;
  final Map<String, bool> notificationSettings;
  final Map<String, dynamic> appSettings;
  final DateTime createdAt;
  final DateTime lastLoginAt;
  final bool isActive;
  final bool isEmailVerified;
  final bool isPhoneVerified;
  final int totalHives;
  final int totalNuclei;
  final double totalProduction;
  final Map<String, dynamic>? customFields;

  UserModel({
    required this.id,
    required this.email,
    required this.displayName,
    this.photoURL,
    this.phoneNumber,
    required this.role,
    required this.subscriptionType,
    this.subscriptionExpiry,
    required this.experienceLevel,
    required this.yearsOfExperience,
    this.location,
    this.latitude,
    this.longitude,
    this.country,
    this.region,
    required this.preferredLanguage,
    required this.notificationSettings,
    required this.appSettings,
    required this.createdAt,
    required this.lastLoginAt,
    required this.isActive,
    required this.isEmailVerified,
    required this.isPhoneVerified,
    required this.totalHives,
    required this.totalNuclei,
    required this.totalProduction,
    this.customFields,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'display_name': displayName,
      'photo_url': photoURL,
      'phone_number': phoneNumber,
      'role': role.name,
      'subscription_type': subscriptionType.name,
      'subscription_expiry': subscriptionExpiry?.toIso8601String(),
      'experience_level': experienceLevel.name,
      'years_of_experience': yearsOfExperience,
      'location': location,
      'latitude': latitude,
      'longitude': longitude,
      'country': country,
      'region': region,
      'preferred_language': preferredLanguage,
      'notification_settings': notificationSettings,
      'app_settings': appSettings,
      'created_at': createdAt.toIso8601String(),
      'last_login_at': lastLoginAt.toIso8601String(),
      'is_active': isActive,
      'is_email_verified': isEmailVerified,
      'is_phone_verified': isPhoneVerified,
      'total_hives': totalHives,
      'total_nuclei': totalNuclei,
      'total_production': totalProduction,
      'custom_fields': customFields,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] ?? '',
      email: map['email'] ?? '',
      displayName: map['display_name'] ?? '',
      photoURL: map['photo_url'],
      phoneNumber: map['phone_number'],
      role: UserRole.values.firstWhere(
            (e) => e.name == map['role'],
        orElse: () => UserRole.user,
      ),
      subscriptionType: SubscriptionType.values.firstWhere(
            (e) => e.name == map['subscription_type'],
        orElse: () => SubscriptionType.free,
      ),
      subscriptionExpiry: map['subscription_expiry'] != null
          ? DateTime.parse(map['subscription_expiry'])
          : null,
      experienceLevel: ExperienceLevel.values.firstWhere(
            (e) => e.name == map['experience_level'],
        orElse: () => ExperienceLevel.beginner,
      ),
      yearsOfExperience: map['years_of_experience'] ?? 0,
      location: map['location'],
      latitude: map['latitude']?.toDouble(),
      longitude: map['longitude']?.toDouble(),
      country: map['country'],
      region: map['region'],
      preferredLanguage: map['preferred_language'] ?? 'ar',
      notificationSettings: Map<String, bool>.from(map['notification_settings'] ?? defaultNotificationSettings),
      appSettings: Map<String, dynamic>.from(map['app_settings'] ?? defaultAppSettings),
      createdAt: DateTime.parse(map['created_at']),
      lastLoginAt: DateTime.parse(map['last_login_at']),
      isActive: map['is_active'] ?? true,
      isEmailVerified: map['is_email_verified'] ?? false,
      isPhoneVerified: map['is_phone_verified'] ?? false,
      totalHives: map['total_hives'] ?? 0,
      totalNuclei: map['total_nuclei'] ?? 0,
      totalProduction: map['total_production']?.toDouble() ?? 0.0,
      customFields: map['custom_fields'],
    );
  }

  factory UserModel.fromSupabase(Map<String, dynamic> data) {
    return UserModel.fromMap(data);
  }

  static Map<String, bool> get defaultNotificationSettings => {
    'inspectionReminders': true,
    'treatmentReminders': true,
    'feedingReminders': true,
    'weatherAlerts': true,
    'diseaseAlerts': true,
    'splittingReminders': true,
    'harvestReminders': true,
    'generalNotifications': true,
    'marketingEmails': false,
    'pushNotifications': true,
    'emailNotifications': true,
    'smsNotifications': false,
  };

  static Map<String, dynamic> get defaultAppSettings => {
    'theme': 'system',
    'language': 'ar',
    'temperatureUnit': 'celsius',
    'weightUnit': 'kg',
    'dateFormat': 'dd/MM/yyyy',
    'timeFormat': '24h',
    'autoBackup': true,
    'offlineMode': true,
    'highQualityImages': true,
    'dataCompression': true,
    'analyticsEnabled': true,
    'crashReportingEnabled': true,
  };

  UserModel copyWith({
    String? id,
    String? email,
    String? displayName,
    String? photoURL,
    String? phoneNumber,
    UserRole? role,
    SubscriptionType? subscriptionType,
    DateTime? subscriptionExpiry,
    ExperienceLevel? experienceLevel,
    int? yearsOfExperience,
    String? location,
    double? latitude,
    double? longitude,
    String? country,
    String? region,
    String? preferredLanguage,
    Map<String, bool>? notificationSettings,
    Map<String, dynamic>? appSettings,
    DateTime? createdAt,
    DateTime? lastLoginAt,
    bool? isActive,
    bool? isEmailVerified,
    bool? isPhoneVerified,
    int? totalHives,
    int? totalNuclei,
    double? totalProduction,
    Map<String, dynamic>? customFields,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoURL: photoURL ?? this.photoURL,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      role: role ?? this.role,
      subscriptionType: subscriptionType ?? this.subscriptionType,
      subscriptionExpiry: subscriptionExpiry ?? this.subscriptionExpiry,
      experienceLevel: experienceLevel ?? this.experienceLevel,
      yearsOfExperience: yearsOfExperience ?? this.yearsOfExperience,
      location: location ?? this.location,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      country: country ?? this.country,
      region: region ?? this.region,
      preferredLanguage: preferredLanguage ?? this.preferredLanguage,
      notificationSettings: notificationSettings ?? this.notificationSettings,
      appSettings: appSettings ?? this.appSettings,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      isActive: isActive ?? this.isActive,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      isPhoneVerified: isPhoneVerified ?? this.isPhoneVerified,
      totalHives: totalHives ?? this.totalHives,
      totalNuclei: totalNuclei ?? this.totalNuclei,
      totalProduction: totalProduction ?? this.totalProduction,
      customFields: customFields ?? this.customFields,
    );
  }
}

extension UserModelExtensions on UserModel {
  String get roleDisplayName {
    switch (role) {
      case UserRole.beekeeper:
        return 'نحال';
      case UserRole.admin:
        return 'مدير';
      case UserRole.moderator:
        return 'مشرف';
      case UserRole.user:
        return 'مستخدم';
    }
  }

  String get subscriptionDisplayName {
    switch (subscriptionType) {
      case SubscriptionType.free:
        return 'مجاني';
      case SubscriptionType.pro:
        return 'احترافي';
      case SubscriptionType.premium:
        return 'مميز';
    }
  }

  String get experienceLevelDisplayName {
    switch (experienceLevel) {
      case ExperienceLevel.beginner:
        return 'مبتدئ';
      case ExperienceLevel.intermediate:
        return 'متوسط';
      case ExperienceLevel.advanced:
        return 'متقدم';
      case ExperienceLevel.expert:
        return 'خبير';
    }
  }

  bool get isPremiumUser => subscriptionType != SubscriptionType.free;

  bool get isSubscriptionActive {
    if (subscriptionType == SubscriptionType.free) return true;
    if (subscriptionExpiry == null) return false;
    return DateTime.now().isBefore(subscriptionExpiry!);
  }

  bool get canAddMoreHives {
    if (isPremiumUser && isSubscriptionActive) return true;
    return totalHives < 30;
  }

  int get remainingFreeHives {
    if (isPremiumUser && isSubscriptionActive) return -1;
    return (30 - totalHives).clamp(0, 30);
  }

  bool get needsSubscriptionUpgrade => totalHives >= 30 && !isPremiumUser;

  String get membershipStatus {
    if (subscriptionType == SubscriptionType.free) {
      return 'عضوية مجانية ($totalHives/30 خلية)';
    }
    if (!isSubscriptionActive) {
      return 'اشتراك منتهي الصلاحية';
    }
    return '$subscriptionDisplayName - نشط';
  }

  double get averageProductionPerHive {
    if (totalHives == 0) return 0.0;
    return totalProduction / totalHives;
  }

  String get experienceDescription {
    if (yearsOfExperience == 0) return 'جديد في تربية النحل';
    if (yearsOfExperience == 1) return 'سنة واحدة من الخبرة';
    if (yearsOfExperience < 5) return '$yearsOfExperience سنوات من الخبرة';
    if (yearsOfExperience < 10) return 'نحال متمرس ($yearsOfExperience سنوات)';
    return 'نحال خبير ($yearsOfExperience سنة من الخبرة)';
  }

  bool get hasLocationData => latitude != null && longitude != null;

  String get fullLocation {
    final parts = <String>[];
    if (location != null) parts.add(location!);
    if (region != null) parts.add(region!);
    if (country != null) parts.add(country!);
    return parts.join(', ');
  }
}
