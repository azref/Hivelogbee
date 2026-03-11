import 'dart:async';
import 'package:flutter/material.dart';
import '../models/hive_model.dart';
import '../services/hive_service.dart';

/// HiveProvider: مسؤول فقط عن جلب قائمة الخلايا الكاملة،
/// وتوفير دوال لفلترتها والبحث فيها.
class HiveProvider extends ChangeNotifier {
  final HiveService _hiveService = HiveService();

  // القائمة الرئيسية التي تحتوي على كل الخلايا
  List<HiveModel> _allHives = [];

  bool _isLoading = false;
  String? _error;
  String _searchQuery = '';
  StreamSubscription? _hivesSubscription;
  String? _currentUserId;

  // --- Getters ---
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get searchQuery => _searchQuery;
  // Getter للوصول إلى القائمة الكاملة من الخارج (إذا لزم الأمر)
  List<HiveModel> get hives => _allHives;

  /// تهيئة الـ Provider وتحديد المستخدم لبدء جلب البيانات.
  void initialize(String userId) {
    if (_currentUserId != userId) {
      _currentUserId = userId;
      fetchHives();
    }
  }

  /// الدالة الرئيسية لجلب وتحديث قائمة الخلايا عبر stream.
  Future<void> fetchHives() async {
    if (_currentUserId == null) return;

    _isLoading = true;
    notifyListeners();

    _hivesSubscription?.cancel();
    _hivesSubscription = _hiveService.getHivesStream(_currentUserId!).listen(
          (hivesList) {
        _allHives = hivesList;
        _isLoading = false;
        _error = null;
        notifyListeners();
      },
      onError: (error) {
        _error = 'خطأ في تحميل الخلايا: $error';
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  /// دالة الفلترة التي تستخدمها الواجهة لعرض البيانات.
  /// لا تغير حالة الـ Provider، بل تُرجع قائمة مفلترة.
  List<HiveModel> getFilteredHives(String filter) {
    List<HiveModel> tempHives = List.from(_allHives);

    // 1. تطبيق فلتر البحث
    if (_searchQuery.isNotEmpty) {
      tempHives = tempHives.where((hive) {
        final query = _searchQuery.toLowerCase();
        return (hive.hiveNumber.toLowerCase().contains(query)) ||
            (hive.location?.toLowerCase().contains(query) ?? false) ||
            (hive.notes?.toLowerCase().contains(query) ?? false);
      }).toList();
    }

    // 2. تطبيق فلتر التبويب
    switch (filter) {
      case 'all':
        return tempHives;
      case 'active':
        return tempHives.where((h) => h.status == HiveStatus.active).toList();
      case 'nuclei':
        return tempHives.where((h) => h.isNucleus).toList();
      case 'issues':
        return tempHives.where((h) => h.tags.contains('problem')).toList();
      default:
        return tempHives;
    }
  }

  /// تحديث قيمة البحث من الواجهة.
  void setSearchQuery(String query) {
    if (_searchQuery != query) {
      _searchQuery = query;
      notifyListeners();
    }
  }

  /// دالة مساعدة لإيجاد خلية بواسطة الـ ID الخاص بها.
  /// هذه الدالة ضرورية لشاشات التفاصيل.
  HiveModel? getHiveById(String hiveId) {
    try {
      return _allHives.firstWhere((hive) => hive.id == hiveId);
    } catch (e) {
      return null;
    }
  }

  // --- دوال الإضافة والتحديث والحذف (لا تغيير) ---
  Future<void> addHive(HiveModel hive) async { /* ... */ }
  Future<void> updateHive(HiveModel hive) async { /* ... */ }
  Future<void> deleteHive(String hiveId) async { /* ... */ }

  @override
  void dispose() {
    _hivesSubscription?.cancel();
    super.dispose();
  }
}
