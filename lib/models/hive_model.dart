// تم حذف 'package:cloud_firestore/cloud_firestore.dart'

enum HiveType {
  fullHive,
  nucleus,
}

enum HiveStatus {
  active,
  weak,
  queenless,
  sick,
  dead,
  split,
  merged,
}

enum NucleusStatus {
  mating,
  mated,
  failed,
  laying,
}

enum QueenStatus {
  present,
  absent,
  isNew,
  old,
  marked,
  unmarked,
}

enum BeeBreed {
  carniolan,
  italian,
  caucasian,
  buckfast,
  local,
  hybrid,
}

class HiveModel {
  final String id;
  final String userId;
  final String hiveNumber;
  final BeeBreed breed;
  final DateTime createdDate;
  final HiveType type;
  final HiveStatus status;
  final NucleusStatus? nucleusStatus;
  final QueenStatus queenStatus;
  final int frameCount;
  final int broodFrames;
  final int honeyFrames;
  final int pollenFrames;
  final int emptyFrames;
  final String? notes;
  final String? location;
  final double? latitude;
  final double? longitude;
  final DateTime lastInspection;
  final DateTime? nextInspection;
  final String? parentHiveId;
  final List<String> tags;
  final Map<String, dynamic>? customFields;

  HiveModel({
    required this.id,
    required this.userId,
    required this.hiveNumber,
    required this.breed,
    required this.createdDate,
    required this.type,
    required this.status,
    this.nucleusStatus,
    required this.queenStatus,
    required this.frameCount,
    required this.broodFrames,
    required this.honeyFrames,
    required this.pollenFrames,
    required this.emptyFrames,
    this.notes,
    this.location,
    this.latitude,
    this.longitude,
    required this.lastInspection,
    this.nextInspection,
    this.parentHiveId,
    this.tags = const [],
    this.customFields,
  });

  String get number => hiveNumber;
  DateTime get lastInspectionDate => lastInspection;
  bool get isNucleus => type == HiveType.nucleus;

  Map<String, dynamic> toMap() {
    final map = {
      'user_id': userId,
      'hive_number': hiveNumber,
      'breed': breed.name,
      'created_date': createdDate.toIso8601String(),
      'type': type.name,
      'status': status.name,
      'nucleus_status': nucleusStatus?.name,
      'queen_status': queenStatus.name,
      'frame_count': frameCount,
      'brood_frames': broodFrames,
      'honey_frames': honeyFrames,
      'pollen_frames': pollenFrames,
      'empty_frames': emptyFrames,
      'notes': notes,
      'location': location,
      'latitude': latitude,
      'longitude': longitude,
      'last_inspection': lastInspection.toIso8601String(),
      'next_inspection': nextInspection?.toIso8601String(),
      'parent_hive_id': parentHiveId,
      'tags': tags,
      'custom_fields': customFields,
      'is_nucleus': type == HiveType.nucleus,
    };

    if (id.isNotEmpty) {
      map['id'] = id;
    }

    return map;
  }

  factory HiveModel.fromMap(Map<String, dynamic> map) {
    String queenStatusString = map['queen_status'] ?? 'present';
    if (queenStatusString == 'new') {
      queenStatusString = 'isNew';
    }

    HiveType type;
    if (map['type'] != null) {
      type = HiveType.values.firstWhere((e) => e.name == map['type'], orElse: () => HiveType.fullHive);
    } else {
      type = (map['is_nucleus'] ?? false) ? HiveType.nucleus : HiveType.fullHive;
    }

    // --- تم التصحيح هنا ---
    NucleusStatus? nucleusStatus;
    if (map['nucleus_status'] != null) {
      for (var status in NucleusStatus.values) {
        if (status.name == map['nucleus_status']) {
          nucleusStatus = status;
          break;
        }
      }
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
      type: type,
      status: HiveStatus.values.firstWhere(
            (e) => e.name == map['status'],
        orElse: () => HiveStatus.active,
      ),
      nucleusStatus: nucleusStatus, // <-- استخدام القيمة المصححة
      queenStatus: QueenStatus.values.firstWhere(
            (e) => e.name == queenStatusString,
        orElse: () => QueenStatus.present,
      ),
      frameCount: map['frame_count'] ?? 0,
      broodFrames: map['brood_frames'] ?? 0,
      honeyFrames: map['honey_frames'] ?? 0,
      pollenFrames: map['pollen_frames'] ?? 0,
      emptyFrames: map['empty_frames'] ?? 0,
      notes: map['notes'],
      location: map['location'],
      latitude: map['latitude']?.toDouble(),
      longitude: map['longitude']?.toDouble(),
      lastInspection: DateTime.parse(map['last_inspection']),
      nextInspection: map['next_inspection'] != null
          ? DateTime.parse(map['next_inspection'])
          : null,
      parentHiveId: map['parent_hive_id'],
      tags: List<String>.from(map['tags'] ?? []),
      customFields: map['custom_fields'] != null ? Map<String, dynamic>.from(map['custom_fields']) : null,
    );
  }

  factory HiveModel.fromSupabase(Map<String, dynamic> data) {
    return HiveModel.fromMap(data);
  }

  HiveModel copyWith({
    String? id,
    String? userId,
    String? hiveNumber,
    BeeBreed? breed,
    DateTime? createdDate,
    HiveType? type,
    HiveStatus? status,
    NucleusStatus? nucleusStatus,
    QueenStatus? queenStatus,
    int? frameCount,
    int? broodFrames,
    int? honeyFrames,
    int? pollenFrames,
    int? emptyFrames,
    String? notes,
    String? location,
    double? latitude,
    double? longitude,
    DateTime? lastInspection,
    DateTime? nextInspection,
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
      type: type ?? this.type,
      status: status ?? this.status,
      nucleusStatus: nucleusStatus ?? this.nucleusStatus,
      queenStatus: queenStatus ?? this.queenStatus,
      frameCount: frameCount ?? this.frameCount,
      broodFrames: broodFrames ?? this.broodFrames,
      honeyFrames: honeyFrames ?? this.honeyFrames,
      pollenFrames: pollenFrames ?? this.pollenFrames,
      emptyFrames: emptyFrames ?? this.emptyFrames,
      notes: notes ?? this.notes,
      location: location ?? this.location,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      lastInspection: lastInspection ?? this.lastInspection,
      nextInspection: nextInspection ?? this.nextInspection,
      parentHiveId: parentHiveId ?? this.parentHiveId,
      tags: tags ?? this.tags,
      customFields: customFields ?? this.customFields,
    );
  }

  @override
  String toString() {
    return 'HiveModel(id: $id, hiveNumber: $hiveNumber, type: $type, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is HiveModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

extension HiveModelExtensions on HiveModel {
  String get statusDisplayName {
    if (type == HiveType.nucleus && nucleusStatus != null) {
      return nucleusStatusDisplayName;
    }
    switch (status) {
      case HiveStatus.active: return 'نشطة';
      case HiveStatus.weak: return 'ضعيفة';
      case HiveStatus.queenless: return 'بدون ملكة';
      case HiveStatus.sick: return 'مريضة';
      case HiveStatus.dead: return 'ميتة';
      case HiveStatus.split: return 'مقسمة';
      case HiveStatus.merged: return 'مدمجة';
    }
  }

  String get nucleusStatusDisplayName {
    switch (nucleusStatus) {
      case NucleusStatus.mating: return 'قيد التلقيح';
      case NucleusStatus.mated: return 'ملقحة';
      case NucleusStatus.failed: return 'فاشلة';
      case NucleusStatus.laying: return 'تضع البيض';
      default: return 'غير محدد';
    }
  }

  String get queenStatusDisplayName {
    switch (queenStatus) {
      case QueenStatus.present: return 'موجودة';
      case QueenStatus.absent: return 'غائبة';
      case QueenStatus.isNew: return 'جديدة';
      case QueenStatus.old: return 'قديمة';
      case QueenStatus.marked: return 'معلمة';
      case QueenStatus.unmarked: return 'غير معلمة';
    }
  }

  String get breedDisplayName {
    switch (breed) {
      case BeeBreed.carniolan: return 'كارنيولي';
      case BeeBreed.italian: return 'إيطالي';
      case BeeBreed.caucasian: return 'قوقازي';
      case BeeBreed.buckfast: return 'باكفاست';
      case BeeBreed.local: return 'محلي';
      case BeeBreed.hybrid: return 'هجين';
    }
  }

  String get typeDisplayName {
    switch (type) {
      case HiveType.fullHive: return 'خلية';
      case HiveType.nucleus: return 'طرد';
    }
  }
}
