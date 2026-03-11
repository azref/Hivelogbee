// تم حذف 'package:cloud_firestore/cloud_firestore.dart'

enum TreatmentType {
  varroa,
  nosema,
  foulbrood,
  chalkbrood,
  dysentery,
  feeding,
  vitamin,
  antibiotic,
  organic,
  other,
}

enum TreatmentMethod {
  strips,
  fumigation,
  spray,
  powder,
  syrup,
  tablet,
  injection,
  other,
}

enum TreatmentStatus {
  planned,
  inProgress,
  completed,
  cancelled,
}

class TreatmentModel {
  final String id;
  final String userId;
  final String hiveId;
  final String hiveNumber;
  final TreatmentType treatmentType;
  final String treatmentName;
  final TreatmentMethod method;
  final String dosage;
  final DateTime startDate;
  final DateTime? endDate;
  final int durationDays;
  final int durationWeeks;
  final TreatmentStatus status;
  final String reason;
  final String notes;
  final double cost;
  final String supplier;
  final List<String> photos;
  final DateTime? nextTreatmentDate;
  final bool isRecurring;
  final int recurringIntervalDays;
  final Map<String, dynamic>? sideEffects;
  final double effectiveness;
  final Map<String, dynamic>? customFields;

  TreatmentModel({
    required this.id,
    required this.userId,
    required this.hiveId,
    this.hiveNumber = '',
    required this.treatmentType,
    required this.treatmentName,
    required this.method,
    required this.dosage,
    required this.startDate,
    this.endDate,
    required this.durationDays,
    this.durationWeeks = 0,
    required this.status,
    required this.reason,
    required this.notes,
    required this.cost,
    required this.supplier,
    required this.photos,
    this.nextTreatmentDate,
    this.isRecurring = false,
    this.recurringIntervalDays = 0,
    this.sideEffects,
    this.effectiveness = 0.0,
    this.customFields,
  });

  String get type => treatmentType.name;

  // تحويل النموذج إلى Map للتوافق مع Supabase
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'hive_id': hiveId,
      'hive_number': hiveNumber,
      'treatment_type': treatmentType.name,
      'treatment_name': treatmentName,
      'method': method.name,
      'dosage': dosage,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate?.toIso8601String(),
      'duration_days': durationDays,
      'duration_weeks': durationWeeks,
      'status': status.name,
      'reason': reason,
      'notes': notes,
      'cost': cost,
      'supplier': supplier,
      'photos': photos,
      'next_treatment_date': nextTreatmentDate?.toIso8601String(),
      'is_recurring': isRecurring,
      'recurring_interval_days': recurringIntervalDays,
      'side_effects': sideEffects,
      'effectiveness': effectiveness,
      'custom_fields': customFields,
      // 'created_at' تتم إدارته تلقائيًا بواسطة Supabase
    };
  }

  // إنشاء نموذج من Map قادم من Supabase
  factory TreatmentModel.fromMap(Map<String, dynamic> map) {
    return TreatmentModel(
      id: map['id'] ?? '',
      userId: map['user_id'] ?? '',
      hiveId: map['hive_id'] ?? '',
      hiveNumber: map['hive_number'] ?? '',
      treatmentType: TreatmentType.values.firstWhere(
            (e) => e.name == map['treatment_type'],
        orElse: () => TreatmentType.other,
      ),
      treatmentName: map['treatment_name'] ?? '',
      method: TreatmentMethod.values.firstWhere(
            (e) => e.name == map['method'],
        orElse: () => TreatmentMethod.other,
      ),
      dosage: map['dosage'] ?? '',
      startDate: DateTime.parse(map['start_date']),
      endDate: map['end_date'] != null
          ? DateTime.parse(map['end_date'])
          : null,
      durationDays: map['duration_days'] ?? 0,
      durationWeeks: map['duration_weeks'] ?? 0,
      status: TreatmentStatus.values.firstWhere(
            (e) => e.name == map['status'],
        orElse: () => TreatmentStatus.planned,
      ),
      reason: map['reason'] ?? '',
      notes: map['notes'] ?? '',
      cost: map['cost']?.toDouble() ?? 0.0,
      supplier: map['supplier'] ?? '',
      photos: List<String>.from(map['photos'] ?? []),
      nextTreatmentDate: map['next_treatment_date'] != null
          ? DateTime.parse(map['next_treatment_date'])
          : null,
      isRecurring: map['is_recurring'] ?? false,
      recurringIntervalDays: map['recurring_interval_days'] ?? 0,
      sideEffects: map['side_effects'] != null ? Map<String, dynamic>.from(map['side_effects']) : null,
      effectiveness: map['effectiveness']?.toDouble() ?? 0.0,
      customFields: map['custom_fields'] != null ? Map<String, dynamic>.from(map['custom_fields']) : null,
    );
  }

  // دالة بديلة، للتوافق مع الاصطلاح الجديد
  factory TreatmentModel.fromSupabase(Map<String, dynamic> data) {
    return TreatmentModel.fromMap(data);
  }

  TreatmentModel copyWith({
    String? id,
    String? userId,
    String? hiveId,
    String? hiveNumber,
    TreatmentType? treatmentType,
    String? treatmentName,
    TreatmentMethod? method,
    String? dosage,
    DateTime? startDate,
    DateTime? endDate,
    int? durationDays,
    int? durationWeeks,
    TreatmentStatus? status,
    String? reason,
    String? notes,
    double? cost,
    String? supplier,
    List<String>? photos,
    DateTime? nextTreatmentDate,
    bool? isRecurring,
    int? recurringIntervalDays,
    Map<String, dynamic>? sideEffects,
    double? effectiveness,
    Map<String, dynamic>? customFields,
  }) {
    return TreatmentModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      hiveId: hiveId ?? this.hiveId,
      hiveNumber: hiveNumber ?? this.hiveNumber,
      treatmentType: treatmentType ?? this.treatmentType,
      treatmentName: treatmentName ?? this.treatmentName,
      method: method ?? this.method,
      dosage: dosage ?? this.dosage,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      durationDays: durationDays ?? this.durationDays,
      durationWeeks: durationWeeks ?? this.durationWeeks,
      status: status ?? this.status,
      reason: reason ?? this.reason,
      notes: notes ?? this.notes,
      cost: cost ?? this.cost,
      supplier: supplier ?? this.supplier,
      photos: photos ?? this.photos,
      nextTreatmentDate: nextTreatmentDate ?? this.nextTreatmentDate,
      isRecurring: isRecurring ?? this.isRecurring,
      recurringIntervalDays: recurringIntervalDays ?? this.recurringIntervalDays,
      sideEffects: sideEffects ?? this.sideEffects,
      effectiveness: effectiveness ?? this.effectiveness,
      customFields: customFields ?? this.customFields,
    );
  }
}

extension TreatmentModelExtensions on TreatmentModel {
  String get treatmentTypeDisplayName {
    switch (treatmentType) {
      case TreatmentType.varroa:
        return 'فاروا';
      case TreatmentType.nosema:
        return 'نوزيما';
      case TreatmentType.foulbrood:
        return 'تعفن الحضنة';
      case TreatmentType.chalkbrood:
        return 'الحضنة الطباشيرية';
      case TreatmentType.dysentery:
        return 'الإسهال';
      case TreatmentType.feeding:
        return 'تغذية';
      case TreatmentType.vitamin:
        return 'فيتامينات';
      case TreatmentType.antibiotic:
        return 'مضاد حيوي';
      case TreatmentType.organic:
        return 'عضوي';
      case TreatmentType.other:
        return 'أخرى';
    }
  }

  String get methodDisplayName {
    switch (method) {
      case TreatmentMethod.strips:
        return 'شرائط';
      case TreatmentMethod.fumigation:
        return 'تبخير';
      case TreatmentMethod.spray:
        return 'رش';
      case TreatmentMethod.powder:
        return 'مسحوق';
      case TreatmentMethod.syrup:
        return 'شراب';
      case TreatmentMethod.tablet:
        return 'أقراص';
      case TreatmentMethod.injection:
        return 'حقن';
      case TreatmentMethod.other:
        return 'أخرى';
    }
  }

  String get statusDisplayName {
    switch (status) {
      case TreatmentStatus.planned:
        return 'مخطط';
      case TreatmentStatus.inProgress:
        return 'جاري';
      case TreatmentStatus.completed:
        return 'مكتمل';
      case TreatmentStatus.cancelled:
        return 'ملغي';
    }
  }

  bool get isActive => status == TreatmentStatus.inProgress;

  bool get isOverdue {
    if (endDate == null) return false;
    return DateTime.now().isAfter(endDate!) && status != TreatmentStatus.completed;
  }

  int get daysRemaining {
    if (endDate == null) return 0;
    final difference = endDate!.difference(DateTime.now()).inDays;
    return difference > 0 ? difference : 0;
  }

  double get progressPercentage {
    if (status == TreatmentStatus.completed) return 100.0;
    if (status == TreatmentStatus.cancelled) return 0.0;

    final totalDays = endDate?.difference(startDate).inDays ?? durationDays;
    final elapsedDays = DateTime.now().difference(startDate).inDays;

    if (totalDays <= 0) return 0.0;
    final progress = (elapsedDays / totalDays) * 100;
    return progress.clamp(0.0, 100.0);
  }

  String get effectivenessDisplayName {
    if (effectiveness >= 90) return 'ممتاز';
    if (effectiveness >= 70) return 'جيد';
    if (effectiveness >= 50) return 'متوسط';
    if (effectiveness >= 30) return 'ضعيف';
    return 'غير فعال';
  }
}
