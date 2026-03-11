import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/inspection_model.dart';

class InspectionService {
  final SupabaseClient _client = Supabase.instance.client;

  // دالة للحصول على استعلام أساسي لتقليل التكرار

  // تم تحديث الدالة لتتوافق مع Supabase Realtime
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

  // هذه الدالة يمكن استبدالها بـ "Database View" أو "RPC Function" في Supabase لأداء أفضل
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

  Future<String> addInspection(InspectionModel inspection) async {
    try {
      // استخدام دالة RPC لتنفيذ العمليتين معًا (transaction)
      final response = await _client.rpc('add_inspection_and_update_hive', params: {
        'p_inspection_data': inspection.toMap(),
        'p_hive_id': inspection.hiveId,
        'p_inspection_date': inspection.date.toIso8601String(),
      });
      return response as String;
    } catch (e) {
      throw Exception('فشل في إضافة الفحص: $e');
    }
  }

  Future<void> updateInspection(InspectionModel inspection) async {
    try {
      // استخدام دالة RPC لتنفيذ العمليتين معًا (transaction)
      await _client.rpc('update_inspection_and_hive', params: {
        'p_inspection_data': inspection.toMap(),
        'p_inspection_id': inspection.id,
        'p_hive_id': inspection.hiveId,
        'p_inspection_date': inspection.date.toIso8601String(),
      });
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

  // هذه الدوال المعقدة يجب تحويلها إلى "Database Views" أو "RPC Functions" في Supabase
  Stream<List<Map<String, dynamic>>> getUpcomingInspectionsStream(String userId) {
    // استدعاء دالة RPC التي تقوم بحساب الفحوصات القادمة
    return _client
        .rpc('get_upcoming_inspections', params: {'p_user_id': userId})
        .asStream()
        .map((response) => List<Map<String, dynamic>>.from(response as List));
  }

  Stream<List<Map<String, dynamic>>> getProblemAlertsStream(String userId) {
    // استدعاء دالة RPC التي تقوم بحساب تنبيهات المشاكل
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
      // استدعاء دالة RPC التي تقوم بحساب التحليلات
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