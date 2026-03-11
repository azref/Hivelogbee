import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/production_model.dart';

class ProductionService {
  final SupabaseClient _client = Supabase.instance.client;

  // تم تحديث الدالة لتتوافق مع Supabase Realtime
  Stream<List<ProductionModel>> getProductionsStream({
    required String userId,
    required int year,
  }) {
    final startOfYear = DateTime(year, 1, 1).toIso8601String();
    final endOfYear = DateTime(year, 12, 31, 23, 59, 59).toIso8601String();

    final stream = _client
        .from('productions')
        .stream(primaryKey: ['id']);

    return stream.transform(StreamTransformer.fromHandlers(
      handleData: (List<Map<String, dynamic>> data, EventSink<List<ProductionModel>> sink) {
        // تصفية البيانات حسب userId والنطاق الزمني
        var filtered = data.where((map) =>
        map['user_id'] == userId &&
            map['date'] >= startOfYear &&
            map['date'] <= endOfYear
        );

        // ترتيب البيانات تنازلياً حسب التاريخ
        final sorted = filtered.toList()..sort((a, b) =>
            (b['date'] as String).compareTo(a['date'] as String)
        );

        sink.add(sorted.map((map) => ProductionModel.fromMap(map)).toList());
      },
    ));
  }

  // هذه الدوال المعقدة يجب تحويلها إلى "Database Views" أو "RPC Functions" في Supabase
  Stream<Map<String, dynamic>> getProductionStatsStream({
    required String userId,
    required int year,
  }) {
    // استدعاء دالة RPC التي تقوم بحساب الإحصائيات بشكل دوري أو عند الطلب
    // هذا يقلل من الحسابات على العميل
    return _client
        .rpc('get_production_stats', params: {'p_user_id': userId, 'p_year': year})
        .asStream()
        .map((response) => response as Map<String, dynamic>);
  }

  Stream<List<Map<String, dynamic>>> getTopBuyersStream(String userId) {
    // استدعاء دالة RPC التي تقوم بتجميع بيانات أفضل المشترين
    return _client
        .rpc('get_top_buyers', params: {'p_user_id': userId})
        .asStream()
        .map((response) => List<Map<String, dynamic>>.from(response as List));
  }

  Future<String> addProduction(ProductionModel production) async {
    try {
      final response = await _client.from('productions').insert(production.toMap()).select().single();
      return response['id'];
    } catch (e) {
      throw Exception('فشل في إضافة الإنتاج: $e');
    }
  }

  Future<void> updateProduction(ProductionModel production) async {
    try {
      await _client.from('productions').update(production.toMap()).eq('id', production.id);
    } catch (e) {
      throw Exception('فشل في تحديث الإنتاج: $e');
    }
  }

  Future<void> deleteProduction(String productionId) async {
    try {
      await _client.from('productions').delete().eq('id', productionId);
    } catch (e) {
      throw Exception('فشل في حذف الإنتاج: $e');
    }
  }

  // الدوال التحليلية يتم استبدالها بدوال RPC لأداء أفضل
  Future<Map<String, dynamic>> compareYears(String userId, int year1, int year2) async {
    try {
      final response = await _client.rpc('compare_production_years', params: {
        'p_user_id': userId,
        'p_year1': year1,
        'p_year2': year2,
      });
      return response as Map<String, dynamic>;
    } catch (e) {
      throw Exception('فشل في مقارنة السنوات: $e');
    }
  }

  Future<Map<String, dynamic>> getMonthlyAnalytics(String userId, int year) async {
    try {
      final response = await _client.rpc('get_monthly_production_analytics', params: {
        'p_user_id': userId,
        'p_year': year,
      });
      return response as Map<String, dynamic>;
    } catch (e) {
      throw Exception('فشل في جلب التحليلات الشهرية: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getBuyerAnalytics(String userId) async {
    try {
      final response = await _client.rpc('get_buyer_analytics', params: {'p_user_id': userId});
      return List<Map<String, dynamic>>.from(response as List);
    } catch (e) {
      throw Exception('فشل في جلب تحليلات المشترين: $e');
    }
  }
}