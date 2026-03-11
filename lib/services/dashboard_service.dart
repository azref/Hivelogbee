import 'package:supabase_flutter/supabase_flutter.dart';

// تم تعديل هذا النموذج ليتطابق مع ناتج دالة SQL الجديدة
class DashboardStats {
  final int totalHives;
  final double totalProduction;
  final int activeTreatments;
  final int pendingInspections;
  final int upcomingReminders; // <-- تم إضافة هذا الحقل
  final List<dynamic> recentActivity;

  DashboardStats({
    required this.totalHives,
    required this.totalProduction,
    required this.activeTreatments,
    required this.pendingInspections,
    required this.upcomingReminders, // <-- تم إضافة هذا الحقل
    required this.recentActivity,
  });

  // تم تعديل هذه الدالة لتستقبل الحقل الجديد
  factory DashboardStats.fromMap(Map<String, dynamic> map) {
    return DashboardStats(
      totalHives: (map['total_hives'] as num?)?.toInt() ?? 0,
      totalProduction: (map['total_production'] as num?)?.toDouble() ?? 0.0,
      activeTreatments: (map['active_treatments'] as num?)?.toInt() ?? 0,
      pendingInspections: (map['pending_inspections'] as num?)?.toInt() ?? 0,
      upcomingReminders: (map['upcoming_reminders'] as num?)?.toInt() ?? 0, // <-- تم إضافة هذا الحقل
      recentActivity: (map['recent_activity'] as List<dynamic>?) ?? [],
    );
  }
}


class DashboardService {
  final SupabaseClient _client = Supabase.instance.client;

  /// يجلب بيانات لوحة التحكم المجمعة من دالة RPC في Supabase.
  Future<DashboardStats> getDashboardStats() async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) {
        throw 'المستخدم غير مسجل دخوله.';
      }

      final data = await _client.rpc(
        'get_dashboard_stats',
        params: {'p_user_id': userId},
      );

      if (data == null) {
        throw 'لم يتم استلام بيانات من الخادم.';
      }

      return DashboardStats.fromMap(data);

    } on PostgrestException catch (e) {
      print('PostgrestException في getDashboardStats: ${e.message}');
      throw 'فشل في جلب بيانات لوحة التحكم: ${e.message}';
    } catch (e) {
      print('Exception في getDashboardStats: $e');
      throw 'حدث خطأ غير متوقع. يرجى التحقق من اتصالك بالإنترنت.';
    }
  }
}
