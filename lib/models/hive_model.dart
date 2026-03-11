// تم حذف 'package:cloud_firestore/cloud_firestore.dart'

enum HiveStatus {
  active,      // نشطة
  weak,        // ضعيفة
  queenless,   // بدون ملكة
  sick,        // مريضة
  dead,        // ميتة
  split,       // مقسمة
  merged,      // مدمجة
}

enum QueenStatus {
  present,     // موجودة
  absent,      // غائبة
  isNew,       // جديدة (تم التغيير من new)
  old,         // قديمة
  marked,      // معلمة
  unmarked,    // غير معلمة
}

enum BeeBreed {
  carniolan,   // كارنيولي
  italian,     // إيطالي
  caucasian,   // قوقازي
  buckfast,    // باكفاست
  local,       // محلي
  hybrid,      // هجين
}

class HiveModel {
  final String id;
  final String userId;
  final String hiveNumber;
  final BeeBreed breed;
  final DateTime createdDate;
  final HiveStatus status;
  final QueenStatus queenStatus;
  final int frameCount;
  final int broodFrames;
  final int honeyFrames;
  final String? notes;
  final String? location;
  final double? latitude;
  final double? longitude;
  final DateTime lastInspection;
  final DateTime? nextInspection;
  final bool isNucleus; // هل هي طرد أم خلية كاملة
  final String? parentHiveId; // معرف الخلية الأم في حالة التقسيم
  final List<String> tags; // علامات مخصصة
  final Map<String, dynamic>? customFields; // حقول مخصصة إضافية

  HiveModel({
    required this.id,
    required this.userId,
    required this.hiveNumber,
    required this.breed,
    required this.createdDate,
    required this.status,
    required this.queenStatus,
    required this.frameCount,
    required this.broodFrames,
    required this.honeyFrames,
    this.notes,
    this.location,
    this.latitude,
    this.longitude,
    required this.lastInspection,
    this.nextInspection,
    this.isNucleus = false,
    this.parentHiveId,
    this.tags = const [],
    this.customFields,
  });

  // Added getters for backward compatibility
  String get number => hiveNumber;
  String get type => isNucleus ? 'nucleus' : 'hive';
  DateTime get lastInspectionDate => lastInspection;

  // تحويل النموذج إلى Map للتوافق مع Supabase (باستخدام ISO 8601 strings للتواريخ)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId, // تم التغيير للتوافق مع اصطلاحات Supabase (snake_case)
      'hive_number': hiveNumber,
      'breed': breed.name,
      'created_date': createdDate.toIso8601String(),
      'status': status.name,
      'queen_status': queenStatus.name,
      'frame_count': frameCount,
      'brood_frames': broodFrames,
      'honey_frames': honeyFrames,
      'notes': notes,
      'location': location,
      'latitude': latitude,
      'longitude': longitude,
      'last_inspection': lastInspection.toIso8601String(),
      'next_inspection': nextInspection?.toIso8601String(),
      'is_nucleus': isNucleus,
      'parent_hive_id': parentHiveId,
      'tags': tags,
      'custom_fields': customFields,
      // 'updated_at' تتم إدارته تلقائيًا بواسطة Supabase عادةً
    };
  }

  // إنشاء نموذج من Map قادم من Supabase
  factory HiveModel.fromMap(Map<String, dynamic> map) {
    String queenStatusString = map['queen_status'] ?? 'present';
    if (queenStatusString == 'new') {
      queenStatusString = 'isNew';
    }

    return HiveModel(
      id: map['id'] ?? '',
      userId: map['user_id'] ?? '',
      hiveNumber: map['hive_number'] ?? '',
      breed: BeeBreed.values.firstWhere(
            (e) => e.name == map['breed'],
        orElse: () => BeeBreed.local,
      ),
      createdDate: DateTime.parse(map['created_date']),
      status: HiveStatus.values.firstWhere(
            (e) => e.name == map['status'],
        orElse: () => HiveStatus.active,
      ),
      queenStatus: QueenStatus.values.firstWhere(
            (e) => e.name == queenStatusString,
        orElse: () => QueenStatus.present,
      ),
      frameCount: map['frame_count'] ?? 0,
      broodFrames: map['brood_frames'] ?? 0,
      honeyFrames: map['honey_frames'] ?? 0,
      notes: map['notes'],
      location: map['location'],
      latitude: map['latitude']?.toDouble(),
      longitude: map['longitude']?.toDouble(),
      lastInspection: DateTime.parse(map['last_inspection']),
      nextInspection: map['next_inspection'] != null
          ? DateTime.parse(map['next_inspection'])
          : null,
      isNucleus: map['is_nucleus'] ?? false,
      parentHiveId: map['parent_hive_id'],
      tags: List<String>.from(map['tags'] ?? []),
      customFields: map['custom_fields'] != null ? Map<String, dynamic>.from(map['custom_fields']) : null,
    );
  }

  // دالة بديلة لـ fromFirestore، للتوافق مع الاصطلاح الجديد
  factory HiveModel.fromSupabase(Map<String, dynamic> data) {
    return HiveModel.fromMap(data);
  }

  // Create a copy with updated fields
  HiveModel copyWith({
    String? id,
    String? userId,
    String? hiveNumber,
    BeeBreed? breed,
    DateTime? createdDate,
    HiveStatus? status,
    QueenStatus? queenStatus,
    int? frameCount,
    int? broodFrames,
    int? honeyFrames,
    String? notes,
    String? location,
    double? latitude,
    double? longitude,
    DateTime? lastInspection,
    DateTime? nextInspection,
    bool? isNucleus,
    String? parentHiveId,
    List<String>? tags,
    Map<String, dynamic>? customFields,
  }) {
    return HiveModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      hiveNumber: hiveNumber ?? this.hiveNumber,
      breed: breed ?? this.breed,
      createdDate: createdDate ?? this.createdDate,
      status: status ?? this.status,
      queenStatus: queenStatus ?? this.queenStatus,
      frameCount: frameCount ?? this.frameCount,
      broodFrames: broodFrames ?? this.broodFrames,
      honeyFrames: honeyFrames ?? this.honeyFrames,
      notes: notes ?? this.notes,
      location: location ?? this.location,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      lastInspection: lastInspection ?? this.lastInspection,
      nextInspection: nextInspection ?? this.nextInspection,
      isNucleus: isNucleus ?? this.isNucleus,
      parentHiveId: parentHiveId ?? this.parentHiveId,
      tags: tags ?? this.tags,
      customFields: customFields ?? this.customFields,
    );
  }

  @override
  String toString() {
    return 'HiveModel(id: $id, hiveNumber: $hiveNumber, status: $status, frameCount: $frameCount)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is HiveModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

// Helper functions for UI display
extension HiveModelExtensions on HiveModel {
  String get statusDisplayName {
    switch (status) {
      case HiveStatus.active:
        return 'نشطة';
      case HiveStatus.weak:
        return 'ضعيفة';
      case HiveStatus.queenless:
        return 'بدون ملكة';
      case HiveStatus.sick:
        return 'مريضة';
      case HiveStatus.dead:
        return 'ميتة';
      case HiveStatus.split:
        return 'مقسمة';
      case HiveStatus.merged:
        return 'مدمجة';
    }
  }

  String get queenStatusDisplayName {
    switch (queenStatus) {
      case QueenStatus.present:
        return 'موجودة';
      case QueenStatus.absent:
        return 'غائبة';
      case QueenStatus.isNew: // تم التغيير هنا أيضاً
        return 'جديدة';
      case QueenStatus.old:
        return 'قديمة';
      case QueenStatus.marked:
        return 'معلمة';
      case QueenStatus.unmarked:
        return 'غير معلمة';
    }
  }

  String get breedDisplayName {
    switch (breed) {
      case BeeBreed.carniolan:
        return 'كارنيولي';
      case BeeBreed.italian:
        return 'إيطالي';
      case BeeBreed.caucasian:
        return 'قوقازي';
      case BeeBreed.buckfast:
        return 'باكفاست';
      case BeeBreed.local:
        return 'محلي';
      case BeeBreed.hybrid:
        return 'هجين';
    }
  }

  String get typeDisplayName {
    return isNucleus ? 'طرد' : 'خلية';
  }
}
