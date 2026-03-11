import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/treatment_model.dart';

class TreatmentService {
  final SupabaseClient _client = Supabase.instance.client;


  // تم تحديث الدالة لتتوافق مع Supabase Realtime
  Stream<List<TreatmentModel>> getTreatmentsStream({
    required String userId,
    String? hiveId,
    String? filter,
  }) {
    final stream = _client
        .from('treatments')
        .stream(primaryKey: ['id']);

    return stream.transform(StreamTransformer.fromHandlers(
      handleData: (List<Map<String, dynamic>> data, EventSink<List<TreatmentModel>> sink) {
        var filtered = data.where((map) => map['user_id'] == userId);

        if (hiveId != null) {
          filtered = filtered.where((map) => map['hive_id'] == hiveId);
        }

        if (filter != null && filter != 'all') {
          // الفلترة حسب الحالة
          if (TreatmentStatus.values.any((e) => e.name == filter)) {
            filtered = filtered.where((map) => map['status'] == filter);
          }
          // الفلترة حسب النوع
          else if (TreatmentType.values.any((e) => e.name == filter)) {
            filtered = filtered.where((map) => map['treatment_type'] == filter);
          }
        }

        final sorted = filtered.toList()..sort((a, b) =>
            (b['start_date'] as String).compareTo(a['start_date'] as String)
        );

        sink.add(sorted.map((map) => TreatmentModel.fromMap(map)).toList());
      },
    ));
  }

  Stream<TreatmentModel?> getTreatmentStream(String userId, String treatmentId) {
    final stream = _client
        .from('treatments')
        .stream(primaryKey: ['id']);

    return stream.transform(StreamTransformer.fromHandlers(
      handleData: (List<Map<String, dynamic>> data, EventSink<TreatmentModel?> sink) {
        final treatmentMap = data.firstWhere(
              (map) => map['user_id'] == userId && map['id'] == treatmentId,
          orElse: () => <String, dynamic>{},
        );
        sink.add(treatmentMap.isNotEmpty ? TreatmentModel.fromMap(treatmentMap) : null);
      },
    ));
  }

  Stream<List<TreatmentModel>> getHiveTreatmentsStream(String userId, String hiveId) {
    final stream = _client
        .from('treatments')
        .stream(primaryKey: ['id']);

    return stream.transform(StreamTransformer.fromHandlers(
      handleData: (List<Map<String, dynamic>> data, EventSink<List<TreatmentModel>> sink) {
        var filtered = data.where((map) =>
        map['user_id'] == userId &&
            map['hive_id'] == hiveId
        );

        final sorted = filtered.toList()..sort((a, b) =>
            (b['start_date'] as String).compareTo(a['start_date'] as String)
        );

        // أخذ آخر 10 فقط
        final limited = sorted.take(10).toList();

        sink.add(limited.map((map) => TreatmentModel.fromMap(map)).toList());
      },
    ));
  }

  Stream<List<TreatmentModel>> getActiveTreatmentsStream(String userId) {
    final stream = _client
        .from('treatments')
        .stream(primaryKey: ['id']);

    return stream.transform(StreamTransformer.fromHandlers(
      handleData: (List<Map<String, dynamic>> data, EventSink<List<TreatmentModel>> sink) {
        var filtered = data.where((map) =>
        map['user_id'] == userId &&
            map['status'] == TreatmentStatus.inProgress.name
        );

        final sorted = filtered.toList()..sort((a, b) =>
            (b['end_date'] as String).compareTo(a['end_date'] as String)
        );

        sink.add(sorted.map((map) => TreatmentModel.fromMap(map)).toList());
      },
    ));
  }

  // الدوال التحليلية والمعقدة يتم استبدالها بدوال RPC
  Stream<Map<String, dynamic>> getTreatmentStatsStream(String userId) {
    return _client
        .rpc('get_treatment_stats', params: {'p_user_id': userId})
        .asStream()
        .map((response) => response as Map<String, dynamic>);
  }

  Stream<List<Map<String, dynamic>>> getOverdueTreatmentsStream(String userId) {
    return _client
        .rpc('get_overdue_treatments', params: {'p_user_id': userId})
        .asStream()
        .map((response) => List<Map<String, dynamic>>.from(response as List));
  }

  Stream<List<Map<String, dynamic>>> getUpcomingTreatmentsStream(String userId) {
    return _client
        .rpc('get_upcoming_treatments', params: {'p_user_id': userId})
        .asStream()
        .map((response) => List<Map<String, dynamic>>.from(response as List));
  }

  Future<Map<String, dynamic>> getTreatmentAnalytics(String userId, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final response = await _client.rpc('get_treatment_analytics', params: {
        'p_user_id': userId,
        'p_start_date': startDate?.toIso8601String(),
        'p_end_date': endDate?.toIso8601String(),
      });
      return response as Map<String, dynamic>;
    } catch (e) {
      throw Exception('فشل في جلب تحليلات العلاجات: $e');
    }
  }

  // دوال إضافة وتعديل وحذف
  Future<String> addTreatment(TreatmentModel treatment) async {
    try {
      // دالة RPC لإضافة العلاج وإنشاء التذكيرات المرتبطة به في عملية واحدة
      final response = await _client.rpc('add_treatment_with_reminders', params: {
        'p_treatment_data': treatment.toMap(),
      });
      return response as String;
    } catch (e) {
      throw Exception('فشل في إضافة العلاج: $e');
    }
  }

  Future<void> updateTreatment(TreatmentModel treatment) async {
    try {
      await _client.from('treatments').update(treatment.toMap()).eq('id', treatment.id);
    } catch (e) {
      throw Exception('فشل في تحديث العلاج: $e');
    }
  }

  Future<void> deleteTreatment(String treatmentId) async {
    try {
      // يفترض أن ON DELETE CASCADE مهيأة لحذف التذكيرات المرتبطة
      await _client.from('treatments').delete().eq('id', treatmentId);
    } catch (e) {
      throw Exception('فشل في حذف العلاج: $e');
    }
  }

  Future<void> completeTreatment(String treatmentId, {
    String? notes,
    double? effectiveness,
  }) async {
    try {
      await _client.rpc('complete_treatment', params: {
        'p_treatment_id': treatmentId,
        'p_notes': notes,
        'p_effectiveness': effectiveness,
      });
    } catch (e) {
      throw Exception('فشل في إكمال العلاج: $e');
    }
  }

  Future<List<TreatmentModel>> searchTreatments(String userId, String query) async {
    try {
      // البحث النصي الكامل (Full-Text Search) هو الأفضل هنا
      final response = await _client
          .from('treatments')
          .select()
          .eq('user_id', userId)
          .textSearch('fts', query); // يفترض وجود عمود 'fts' للبحث النصي
      return response.map((map) => TreatmentModel.fromMap(map)).toList();
    } catch (e) {
      throw Exception('فشل في البحث: $e');
    }
  }
}