import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/inspection_model.dart';
import '../services/inspection_service.dart';
import 'hive_provider.dart';
// --- 1. استيراد خدمة الخلايا ---
import '../services/hive_service.dart';

class InspectionProvider extends ChangeNotifier {
  final InspectionService _inspectionService = InspectionService();
  // --- 2. إضافة خدمة الخلايا ---
  final HiveService _hiveService = HiveService();
  final BuildContext context;

  InspectionProvider(this.context);

  List<InspectionModel> _inspections = [];
  bool _isLoading = false;
  String? _error;
  String _searchQuery = '';
  StreamSubscription? _inspectionsSubscription;
  String? _currentUserId;

  List<InspectionModel> get inspections => _inspections;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get searchQuery => _searchQuery;

  void initialize(String userId) {
    if (_currentUserId != userId) {
      _currentUserId = userId;
      fetchInspections();
    }
  }

  Future<void> fetchInspections() async {
    if (_currentUserId == null) return;
    _isLoading = true;
    notifyListeners();

    _inspectionsSubscription?.cancel();
    _inspectionsSubscription = _inspectionService.getInspectionsStream(userId: _currentUserId!).listen(
          (inspectionsList) {
        _inspections = inspectionsList;
        _isLoading = false;
        _error = null;
        notifyListeners();
      },
      onError: (error) {
        _error = 'خطأ في تحميل الفحوصات: $error';
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  // --- *** 3. تعديل دالة addInspection بالكامل لتطبيق الخطة الجديدة *** ---
  Future<void> addInspection(InspectionModel inspection) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // الخطوة 1: إضافة الفحص وتحديث الخلية في الخادم عبر RPC
      await _inspectionService.addInspection(inspection);
      print('--- InspectionProvider: نجحت عملية RPC في الخادم. ---');

      // الخطوة 2: جلب النسخة المحدثة من الخلية من الخادم
      final updatedHive = await _hiveService.getHiveById(inspection.hiveId);
      if (updatedHive == null) {
        throw Exception('لم يتم العثور على الخلية بعد تحديثها.');
      }
      print('--- InspectionProvider: تم جلب الخلية المحدثة من الخادم. عدد الإطارات: ${updatedHive.frameCount} ---');

      // الخطوة 3: إجبار HiveProvider على تحديث حالته بالخلية الجديدة
      final hiveProvider = Provider.of<HiveProvider>(context, listen: false);
      hiveProvider.forceUpdateHiveState(updatedHive);

      // الـ stream الخاص بالفحوصات سيقوم بتحديث قائمة الفحوصات تلقائياً
      _isLoading = false;
      // لا حاجة لـ notifyListeners() هنا لأن forceUpdateHiveState تقوم بذلك

    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> updateInspection(InspectionModel inspection) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      await _inspectionService.updateInspection(inspection);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> deleteInspection(String inspectionId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      await _inspectionService.deleteInspection(inspectionId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  void setSearchQuery(String query) {
    if (_searchQuery != query) {
      _searchQuery = query;
      // سنحتاج إلى تطبيق الفلترة هنا إذا أردنا البحث
      notifyListeners();
    }
  }

  Future<void> refreshInspections() async {
    if (_currentUserId != null) {
      await fetchInspections();
    }
  }

  @override
  void dispose() {
    _inspectionsSubscription?.cancel();
    super.dispose();
  }
}
