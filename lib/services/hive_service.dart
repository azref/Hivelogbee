import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/hive_model.dart';

class HiveService {
  final SupabaseClient _client = Supabase.instance.client;

  Stream<List<HiveModel>> getHivesStream(String userId) {
    final stream = _client
        .from('hives')
        .stream(primaryKey: ['id']);

    return stream.transform(StreamTransformer.fromHandlers(
      handleData: (List<Map<String, dynamic>> data, EventSink<List<HiveModel>> sink) {
        try {
          final filtered = data.where((map) => map['user_id'] == userId).toList();

          // --- ✅ الإصلاح: تحويل التاريخ إلى DateTime قبل الفرز ---
          final sorted = filtered..sort((a, b) {
            final dateA = DateTime.tryParse(a['created_date'] ?? '') ?? DateTime(1970);
            final dateB = DateTime.tryParse(b['created_date'] ?? '') ?? DateTime(1970);
            return dateB.compareTo(dateA);
          });

          sink.add(sorted.map((map) => HiveModel.fromMap(map)).toList());
        } catch (e) {
          // في حالة حدوث أي خطأ أثناء التحويل أو الفرز، أرسل قائمة فارغة
          print('Error in HiveService StreamTransformer: $e');
          sink.add([]);
        }
      },
    ));
  }


  Stream<HiveModel?> getHiveStream(String userId, String hiveId) {
    final stream = _client
        .from('hives')
        .stream(primaryKey: ['id']);

    return stream.transform(StreamTransformer.fromHandlers(
      handleData: (List<Map<String, dynamic>> data, EventSink<HiveModel?> sink) {
        final hiveMap = data.firstWhere(
              (map) => map['user_id'] == userId && map['id'] == hiveId,
          orElse: () => <String, dynamic>{},
        );
        sink.add(hiveMap.isNotEmpty ? HiveModel.fromMap(hiveMap) : null);
      },
    ));
  }

  Stream<List<HiveModel>> getNucleiStream(String userId, String parentHiveId) {
    final stream = _client
        .from('hives')
        .stream(primaryKey: ['id']);

    return stream.transform(StreamTransformer.fromHandlers(
      handleData: (List<Map<String, dynamic>> data, EventSink<List<HiveModel>> sink) {
        final filtered = data.where((map) =>
        map['user_id'] == userId &&
            map['parent_hive_id'] == parentHiveId &&
            map['is_nucleus'] == true
        ).toList();
        final sorted = filtered..sort((a, b) =>
            (b['created_date'] as String).compareTo(a['created_date'] as String)
        );
        sink.add(sorted.map((map) => HiveModel.fromMap(map)).toList());
      },
    ));
  }

  Stream<Map<String, dynamic>> getHiveStatsStream(String userId) {
    final stream = _client
        .from('hives')
        .stream(primaryKey: ['id']);

    return stream.transform(StreamTransformer.fromHandlers(
      handleData: (List<Map<String, dynamic>> data, EventSink<Map<String, dynamic>> sink) {
        final filtered = data.where((map) => map['user_id'] == userId);

        int totalHives = 0;
        int activeHives = 0;
        int nuclei = 0;
        int problemHives = 0;
        int readyForDivision = 0;
        int readyForUpgrade = 0;

        for (var map in filtered) {
          final hive = HiveModel.fromMap(map);
          totalHives++;
          if (hive.status == HiveStatus.active) activeHives++;
          if (hive.isNucleus) {
            nuclei++;
            if (hive.frameCount >= 5) readyForUpgrade++;
          } else {
            if (hive.frameCount >= 8 && hive.status == HiveStatus.active) {
              readyForDivision++;
            }
          }
          if (hive.tags.contains('problem')) problemHives++;
        }

        sink.add({
          'totalHives': totalHives,
          'activeHives': activeHives,
          'nuclei': nuclei,
          'problemHives': problemHives,
          'readyForDivision': readyForDivision,
          'readyForUpgrade': readyForUpgrade,
        });
      },
    ));
  }

  // --- باقي الدوال (add, update, delete, etc.) تبقى كما هي ---

  Future<String> addHive(HiveModel hive) async {
    try {
      final response = await _client.from('hives').insert(hive.toMap()).select().single();
      return response['id'];
    } catch (e) {
      print('!!!!!!!!!! SUPABASE ERROR (addHive): $e !!!!!!!!!!');
      throw Exception('فشل في إضافة الخلية: $e');
    }
  }

  Future<void> updateHive(HiveModel hive) async {
    try {
      await _client.from('hives').update(hive.toMap()).eq('id', hive.id);
    } catch (e) {
      throw Exception('فشل في تحديث الخلية: $e');
    }
  }

  Future<void> updateHiveField(String hiveId, String field, dynamic value) async {
    try {
      await _client.from('hives').update({field: value}).eq('id', hiveId);
    } catch (e) {
      throw Exception('فشل في تحديث حقل الخلية: $e');
    }
  }

  Future<void> deleteHive(String hiveId) async {
    try {
      await _client.from('hives').delete().eq('id', hiveId);
    } catch (e) {
      throw Exception('فشل في حذف الخلية: $e');
    }
  }

  Future<void> divideHive(String parentHiveId, HiveModel nucleus) async {
    try {
      await _client.rpc('divide_hive', params: {
        'p_parent_hive_id': parentHiveId,
        'p_nucleus_data': nucleus.copyWith(parentHiveId: parentHiveId, isNucleus: true).toMap(),
      });
    } catch (e) {
      throw Exception('فشل في تقسيم الخلية: $e');
    }
  }

  Future<void> upgradeNucleus(String nucleusId) async {
    try {
      await _client.from('hives').update({
        'is_nucleus': false,
        'parent_hive_id': null,
        'custom_fields': {'upgradedAt': DateTime.now().toIso8601String()}
      }).eq('id', nucleusId);
    } catch (e) {
      throw Exception('فشل في ترقية الطرد: $e');
    }
  }

  Future<List<HiveModel>> getHivesForDivision(String userId) async {
    try {
      final response = await _client
          .from('hives')
          .select()
          .eq('user_id', userId)
          .eq('is_nucleus', false)
          .eq('status', HiveStatus.active.name)
          .gte('frame_count', 8);

      return response.map((map) => HiveModel.fromMap(map)).toList();
    } catch (e) {
      throw Exception('فشل في جلب الخلايا الجاهزة للتقسيم: $e');
    }
  }
}