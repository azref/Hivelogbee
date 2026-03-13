import 'dart:async';
import 'package:flutter/material.dart';
import '../models/hive_model.dart';
import '../services/hive_service.dart';

class HiveProvider extends ChangeNotifier {
  final HiveService _hiveService = HiveService();

  List<HiveModel> _allHives = [];
  bool _isLoading = false;
  String? _error;
  String _searchQuery = '';
  StreamSubscription? _hivesSubscription;
  String? _currentUserId;

  bool get isLoading => _isLoading;
  String? get error => _error;
  String get searchQuery => _searchQuery;
  List<HiveModel> get hives => _allHives;

  void initialize(String userId) {
    if (_currentUserId != userId) {
      _currentUserId = userId;
      fetchHives();
    }
  }

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

  List<HiveModel> getFilteredHives(String filter) {
    List<HiveModel> tempHives = List.from(_allHives);

    if (_searchQuery.isNotEmpty) {
      tempHives = tempHives.where((hive) {
        final query = _searchQuery.toLowerCase();
        return (hive.hiveNumber.toLowerCase().contains(query)) ||
            (hive.location?.toLowerCase().contains(query) ?? false) ||
            (hive.notes?.toLowerCase().contains(query) ?? false);
      }).toList();
    }

    switch (filter) {
      case 'all':
        return tempHives;
      case 'active':
        return tempHives.where((h) => h.status == HiveStatus.active).toList();
      case 'nuclei':
        return tempHives.where((h) => h.isNucleus).toList();
      case 'issues':
      // return tempHives.where((h) => h.tags.contains('problem')).toList();
        return tempHives;
      default:
        return tempHives;
    }
  }

  void setSearchQuery(String query) {
    if (_searchQuery != query) {
      _searchQuery = query;
      notifyListeners();
    }
  }

  HiveModel? getHiveById(String hiveId) {
    try {
      return _allHives.firstWhere((hive) => hive.id == hiveId);
    } catch (e) {
      return null;
    }
  }

  Future<void> addHive(HiveModel hive) async {
    try {
      await _hiveService.addHive(hive);
    } catch (e) {
      _error = 'فشل في إضافة الخلية: $e';
      notifyListeners();
      rethrow;
    }
  }

  Future<void> updateHive(HiveModel hive) async {
    try {
      await _hiveService.updateHive(hive);
    } catch (e) {
      _error = 'فشل في تحديث الخلية: $e';
      notifyListeners();
      rethrow;
    }
  }

  // --- *** 1. الدالة الجديدة والقوية للتحديث الفوري *** ---
  /// تقوم بتحديث حالة خلية واحدة في الذاكرة وإجبار الواجهة على إعادة الرسم.
  /// تُستخدم للتحديث المتفائل بعد نجاح عملية في الخادم.
  void forceUpdateHiveState(HiveModel updatedHive) {
    // البحث عن فهرس الخلية القديمة في القائمة
    final index = _allHives.indexWhere((hive) => hive.id == updatedHive.id);

    // إذا تم العثور على الخلية، قم باستبدالها
    if (index != -1) {
      _allHives[index] = updatedHive;
      print('--- HiveProvider: تم تحديث الخلية ${updatedHive.hiveNumber} في الحالة المحلية. ---');
      // إعلام جميع المستمعين بالتغيير
      notifyListeners();
    }
  }

  Future<void> deleteHive(String hiveId) async {
    try {
      await _hiveService.deleteHive(hiveId);
    } catch (e) {
      _error = 'فشل في حذف الخلية: $e';
      notifyListeners();
      rethrow;
    }
  }

  @override
  void dispose() {
    _hivesSubscription?.cancel();
    super.dispose();
  }
}
