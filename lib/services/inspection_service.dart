import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/inspection_model.dart';

class InspectionService {
  final SupabaseClient _client = Supabase.instance.client;

  Stream<List<InspectionModel>> getInspectionsStream({
    required String userId,
    String? hiveId,
  }) {
    final stream = _client
        .from('inspections')
        .stream(primaryKey: ['id']);

    return stream.transform(StreamTransformer.fromHandlers(
      handleData: (List<Map<String, dynamic>> data, EventSink<List<InspectionModel>> sink) {
        var filtered = data.where((map) => map['user_id'] == userId);

        if (hiveId != null) {
          filtered = filtered.where((map) => map['hive_id'] == hiveId);
        }

        final sorted = filtered.toList()
          ..sort((a, b) => (b['date'] as String).compareTo(a['date'] as String));

        sink.add(sorted.map((map) => InspectionModel.fromMap(map)).toList());
      },
    ));
  }

  Stream<InspectionModel?> getInspectionStream(String userId, String inspectionId) {
    final stream = _client
        .from('inspections')
        .stream(primaryKey: ['id']);

    return stream.transform(StreamTransformer.fromHandlers(
      handleData: (List<Map<String, dynamic>> data, EventSink<InspectionModel?> sink) {
        final inspectionMap = data.firstWhere(
              (map) => map['user_id'] == userId && map['id'] == inspectionId,
          orElse: () => <String, dynamic>{},
        );
        sink.add(inspectionMap.isNotEmpty ? InspectionModel.fromMap(inspectionMap) : null);
      },
    ));
  }

  Stream<Map<String, dynamic>> getInspectionStatsStream(String userId) {
    final stream = _client
        .from('inspections')
        .stream(primaryKey: ['id']);

    return stream.transform(StreamTransformer.fromHandlers(
      handleData: (List<Map<String, dynamic>> data, EventSink<Map<String, dynamic>> sink) {
        final filtered = data.where((map) => map['user_id'] == userId);
        int totalInspections = 0;
        int thisWeekInspections = 0;
        int thisMonthInspections = 0;
        int problemInspections = 0;
        int excellentInspections = 0;
        final now = DateTime.now();
        final weekAgo = now.subtract(const Duration(days: 7));
        final monthAgo = now.subtract(const Duration(days: 30));

        for (var map in filtered) {
          totalInspections++;
          final inspection = InspectionModel.fromMap(map);
          final inspectionDate = inspection.date;
          if (inspectionDate.isAfter(weekAgo)) thisWeekInspections++;
          if (inspectionDate.isAfter(monthAgo)) thisMonthInspections++;
          if (inspection.issues.isNotEmpty) problemInspections++;
          if (inspection.hiveHealth == HiveHealth.strong) excellentInspections++;
        }

        sink.add({
          'totalInspections': totalInspections,
          'thisWeekInspections': thisWeekInspections,
          'thisMonthInspections': thisMonthInspections,
          'problemInspections': problemInspections,
          'excellentInspections': excellentInspections,
        });
      },
    ));
  }

  // --- *** 1. تبسيط دالة addInspection بالكامل *** ---
  Future<void> addInspection(InspectionModel inspection) async {
    try {
      // عملية INSERT بسيطة ومباشرة
      await _client.from('inspections').insert(inspection.toMap());
    } catch (e) {
      if (e is PostgrestException) {
        throw Exception('فشل في إضافة الفحص: ${e.message}');
      }
      throw Exception('فشل في إضافة الفحص: $e');
    }
  }

  Future<void> updateInspection(InspectionModel inspection) async {
    try {
      // عملية UPDATE بسيطة ومباشرة
      await _client.from('inspections').update(inspection.toMap()).eq('id', inspection.id);
    } catch (e) {
      throw Exception('فشل في تحديث الفحص: $e');
    }
  }

  Future<void> deleteInspection(String inspectionId) async {
    try {
      await _client.from('inspections').delete().eq('id', inspectionId);
    } catch (e) {
      throw Exception('فشل في حذف الفحص: $e');
    }
  }

  Stream<List<Map<String, dynamic>>> getUpcomingInspectionsStream(String userId) {
    return _client
        .rpc('get_upcoming_inspections', params: {'p_user_id': userId})
        .asStream()
        .map((response) => List<Map<String, dynamic>>.from(response as List));
  }

  Stream<List<Map<String, dynamic>>> getProblemAlertsStream(String userId) {
    return _client
        .rpc('get_problem_alerts', params: {'p_user_id': userId})
        .asStream()
        .map((response) => List<Map<String, dynamic>>.from(response as List));
  }

  Future<Map<String, dynamic>> getInspectionAnalytics(String userId, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final response = await _client.rpc('get_inspection_analytics', params: {
        'p_user_id': userId,
        'p_start_date': startDate?.toIso8601String(),
        'p_end_date': endDate?.toIso8601String(),
      });
      return response as Map<String, dynamic>;
    } catch (e) {
      throw Exception('فشل في جلب تحليلات الفحوصات: $e');
    }
  }
}
