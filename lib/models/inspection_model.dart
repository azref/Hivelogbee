// Enums to ensure data consistency
enum HiveHealth { strong, average, weak }
enum QueenPresence { present, absent, newQueen, unseen }
enum BroodPattern { good, spotty, poor, none }
enum Temperament { calm, nervous, aggressive }
enum InspectionIssue {
  varroa,
  smallHiveBeetle,
  waxMoth,
  americanFoulbrood,
  europeanFoulbrood,
  chalkbrood,
  sacbrood,
  nosema,
  queenIssues,
  robbing,
  pesticidePoisoning,
  other,
  foulbrood,
  queenless,
  swarming,
}

class InspectionModel {
  final String id;
  final String userId;
  final String hiveId;
  final DateTime date;
  final String? inspectorName;
  final HiveHealth hiveHealth;
  final Temperament temperament;
  final QueenPresence queenPresence;
  final bool queenCellsSeen;
  final bool eggsSeen;
  final BroodPattern broodPattern;
  final int broodFrames;
  final int honeyFrames;
  final List<InspectionIssue> issues;
  final String? notes;
  final double? temperature;
  final double? humidity;
  final Map<String, dynamic>? customFields;
  // --- 1. تم تغيير اسم الحقل ---
  final List<Map<String, dynamic>> actions;

  InspectionModel({
    required this.id,
    required this.userId,
    required this.hiveId,
    required this.date,
    this.inspectorName,
    required this.hiveHealth,
    required this.temperament,
    required this.queenPresence,
    required this.queenCellsSeen,
    required this.eggsSeen,
    required this.broodPattern,
    required this.broodFrames,
    required this.honeyFrames,
    this.issues = const [],
    this.notes,
    this.temperature,
    this.humidity,
    this.customFields,
    // --- 2. تم تغيير اسم الحقل ---
    this.actions = const [],
  });

  // تحويل النموذج إلى Map للتوافق مع Supabase
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'hive_id': hiveId,
      'date': date.toIso8601String(),
      'inspector_name': inspectorName,
      'hive_health': hiveHealth.name,
      'temperament': temperament.name,
      'queen_presence': queenPresence.name,
      'queen_cells_seen': queenCellsSeen,
      'eggs_seen': eggsSeen,
      'brood_pattern': broodPattern.name,
      'brood_frames': broodFrames,
      'honey_frames': honeyFrames,
      'issues': issues.map((e) => e.name).toList(),
      'notes': notes,
      'temperature': temperature,
      'humidity': humidity,
      'custom_fields': customFields,
      // --- 3. تم تغيير المفتاح ---
      'actions': actions,
    };
  }

  // إنشاء نموذج من Map قادم من Supabase
  factory InspectionModel.fromMap(Map<String, dynamic> map) {
    return InspectionModel(
      id: map['id'] ?? '',
      userId: map['user_id'] ?? '',
      hiveId: map['hive_id'] ?? '',
      date: DateTime.parse(map['date']),
      inspectorName: map['inspector_name'],
      hiveHealth: HiveHealth.values.firstWhere(
            (e) => e.name == map['hive_health'],
        orElse: () => HiveHealth.average,
      ),
      temperament: Temperament.values.firstWhere(
            (e) => e.name == map['temperament'],
        orElse: () => Temperament.calm,
      ),
      queenPresence: QueenPresence.values.firstWhere(
            (e) => e.name == map['queen_presence'],
        orElse: () => QueenPresence.unseen,
      ),
      queenCellsSeen: map['queen_cells_seen'] ?? false,
      eggsSeen: map['eggs_seen'] ?? false,
      broodPattern: BroodPattern.values.firstWhere(
            (e) => e.name == map['brood_pattern'],
        orElse: () => BroodPattern.good,
      ),
      broodFrames: map['brood_frames'] ?? 0,
      honeyFrames: map['honey_frames'] ?? 0,
      issues: (map['issues'] as List<dynamic>? ?? [])
          .map((issue) => InspectionIssue.values.firstWhere(
            (e) => e.name == issue,
        orElse: () => InspectionIssue.other,
      ))
          .toList(),
      notes: map['notes'],
      temperature: map['temperature']?.toDouble(),
      humidity: map['humidity']?.toDouble(),
      customFields: map['custom_fields'] != null ? Map<String, dynamic>.from(map['custom_fields']) : null,
      // --- 4. تم تغيير المفتاح ---
      actions: List<Map<String, dynamic>>.from(map['actions'] ?? []),
    );
  }

  // دالة بديلة، للتوافق مع الاصطلاح الجديد
  factory InspectionModel.fromSupabase(Map<String, dynamic> data) {
    return InspectionModel.fromMap(data);
  }

  InspectionModel copyWith({
    String? id,
    String? userId,
    String? hiveId,
    DateTime? date,
    String? inspectorName,
    HiveHealth? hiveHealth,
    Temperament? temperament,
    QueenPresence? queenPresence,
    bool? queenCellsSeen,
    bool? eggsSeen,
    BroodPattern? broodPattern,
    int? broodFrames,
    int? honeyFrames,
    List<InspectionIssue>? issues,
    String? notes,
    double? temperature,
    double? humidity,
    Map<String, dynamic>? customFields,
    // --- 5. تم تغيير اسم الحقل ---
    List<Map<String, dynamic>>? actions,
  }) {
    return InspectionModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      hiveId: hiveId ?? this.hiveId,
      date: date ?? this.date,
      inspectorName: inspectorName ?? this.inspectorName,
      hiveHealth: hiveHealth ?? this.hiveHealth,
      temperament: temperament ?? this.temperament,
      queenPresence: queenPresence ?? this.queenPresence,
      queenCellsSeen: queenCellsSeen ?? this.queenCellsSeen,
      eggsSeen: eggsSeen ?? this.eggsSeen,
      broodPattern: broodPattern ?? this.broodPattern,
      broodFrames: broodFrames ?? this.broodFrames,
      honeyFrames: honeyFrames ?? this.honeyFrames,
      issues: issues ?? this.issues,
      notes: notes ?? this.notes,
      temperature: temperature ?? this.temperature,
      humidity: humidity ?? this.humidity,
      customFields: customFields ?? this.customFields,
      actions: actions ?? this.actions,
    );
  }
}
