import 'dart:async';
import 'package:flutter/material.dart';
import '../models/treatment_model.dart';
import '../services/treatment_service.dart';

class TreatmentProvider extends ChangeNotifier {
  final TreatmentService _treatmentService = TreatmentService();

  // القائمة الرئيسية التي تحتوي على كل العلاجات
  List<TreatmentModel> _allTreatments = [];

  bool _isLoading = false;
  String? _error;
  StreamSubscription? _treatmentsSubscription;
  String? _currentUserId; // لتخزين userId

  // Getters
  bool get isLoading => _isLoading;
  String? get error => _error;

  // --- 1. دالة جلب البيانات الرئيسية ---
  // يتم استدعاؤها مرة واحدة عند تهيئة التطبيق أو عند السحب للتحديث
  Future<void> fetchTreatments(String userId) async {
    // إذا كان المستمع يعمل بالفعل لنفس المستخدم، لا تفعل شيئًا
    if (_currentUserId == userId && _treatmentsSubscription != null) {
      return;
    }

    _currentUserId = userId;
    _isLoading = true;
    notifyListeners();

    _treatmentsSubscription?.cancel();
    _treatmentsSubscription = _treatmentService.getTreatmentsStream(userId: userId).listen(
          (treatmentsList) {
        _allTreatments = treatmentsList;
        _isLoading = false;
        _error = null;
        notifyListeners();
      },
      onError: (error) {
        _error = 'خطأ في تحميل العلاجات: $error';
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  // --- 2. دالة الفلترة الجديدة والمهمة ---
  // هذه الدالة لا تغير حالة الـ Provider، بل تقوم فقط بإرجاع قائمة مفلترة
  List<TreatmentModel> getFilteredTreatments(String filter) {
    if (filter == 'all') {
      return _allTreatments;
    }

    // الفلترة بناءً على الحالة (status)
    if (filter == 'active' || filter == 'completed') {
      final status = filter == 'active' ? TreatmentStatus.inProgress : TreatmentStatus.completed;
      return _allTreatments.where((t) => t.status == status).toList();
    }

    // الفلترة للحالات المتأخرة
    if (filter == 'overdue') {
      return _allTreatments.where((t) => t.isOverdue).toList();
    }

    // يمكنك إضافة فلاتر أخرى هنا إذا لزم الأمر
    // ...

    // إذا لم يتطابق الفلتر، أرجع القائمة الكاملة كإجراء وقائي
    return _allTreatments;
  }

  // --- دوال الإضافة والتحديث والحذف (تبقى كما هي تقريبًا) ---
  Future<void> addTreatment(TreatmentModel treatment) async {
    try {
      await _treatmentService.addTreatment(treatment);
      // لا حاجة لـ notifyListeners() هنا لأن الـ stream سيقوم بالتحديث تلقائيًا
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> updateTreatment(TreatmentModel treatment) async {
    try {
      await _treatmentService.updateTreatment(treatment);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> deleteTreatment(String treatmentId) async {
    try {
      await _treatmentService.deleteTreatment(treatmentId);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  // ... يمكنك إضافة باقي الدوال المساعدة مثل getTreatmentById إذا احتجتها

  @override
  void dispose() {
    _treatmentsSubscription?.cancel();
    super.dispose();
  }
}
