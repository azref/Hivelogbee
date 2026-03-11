import 'dart:async'; // --- تم الإصلاح ---
import 'package:flutter/material.dart';
import '../models/inspection_model.dart';
import '../services/inspection_service.dart';

class InspectionProvider extends ChangeNotifier {
  final InspectionService _inspectionService = InspectionService();
  List<InspectionModel> _inspections = [];
  List<InspectionModel> _filteredInspections = [];
  Map<String, dynamic> _stats = {};
  List<Map<String, dynamic>> _upcomingInspections = [];
  List<Map<String, dynamic>> _problemAlerts = [];
  bool _isLoading = false;
  String? _error;
  String _currentFilter = 'all';
  String _searchQuery = '';

  StreamSubscription? _inspectionsSubscription;
  StreamSubscription? _statsSubscription;
  StreamSubscription? _upcomingSubscription;
  StreamSubscription? _problemsSubscription;

  List<InspectionModel> get inspections => _filteredInspections;
  Map<String, dynamic> get stats => _stats;
  List<Map<String, dynamic>> get upcomingInspections => _upcomingInspections;
  List<Map<String, dynamic>> get problemAlerts => _problemAlerts;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get currentFilter => _currentFilter;
  String get searchQuery => _searchQuery;

  void initialize(String userId) {
    _listenToInspections(userId);
    _listenToStats(userId);
    _listenToUpcomingInspections(userId);
    _listenToProblemAlerts(userId);
  }

  void _listenToInspections(String userId) {
    _isLoading = true;
    notifyListeners();
    _inspectionsSubscription?.cancel();
    // --- تم الإصلاح: تمرير userId كمعامل مطلوب ---
    _inspectionsSubscription = _inspectionService.getInspectionsStream(userId: userId).listen(
          (inspectionsList) {
        _inspections = inspectionsList;
        _applyFilters();
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

  void _listenToStats(String userId) {
    _statsSubscription?.cancel();
    _statsSubscription = _inspectionService.getInspectionStatsStream(userId).listen(
          (stats) {
        _stats = stats;
        notifyListeners();
      },
      onError: (error) {
        print('خطأ في تحميل إحصائيات الفحوصات: $error');
      },
    );
  }

  void _listenToUpcomingInspections(String userId) {
    _upcomingSubscription?.cancel();
    _upcomingSubscription = _inspectionService.getUpcomingInspectionsStream(userId).listen(
          (upcoming) {
        _upcomingInspections = upcoming;
        notifyListeners();
      },
      onError: (error) {
        print('خطأ في تحميل الفحوصات القادمة: $error');
      },
    );
  }

  void _listenToProblemAlerts(String userId) {
    _problemsSubscription?.cancel();
    _problemsSubscription = _inspectionService.getProblemAlertsStream(userId).listen(
          (problems) {
        _problemAlerts = problems;
        notifyListeners();
      },
      onError: (error) {
        print('خطأ في تحميل تنبيهات المشاكل: $error');
      },
    );
  }

  // ... باقي الكود يبقى كما هو في الغالب ...
  void _applyFilters() {
    List<InspectionModel> tempInspections = List.from(_inspections);

    if (_searchQuery.isNotEmpty) {
      tempInspections = tempInspections.where((inspection) {
        final query = _searchQuery.toLowerCase();
        return (inspection.hiveId.toLowerCase().contains(query)) ||
            (inspection.notes?.toLowerCase().contains(query) ?? false) ||
            (inspection.inspectorName?.toLowerCase().contains(query) ?? false) ||
            inspection.issues.any((issue) => issue.name.toLowerCase().contains(query));
      }).toList();
    }

    final now = DateTime.now();
    switch (_currentFilter) {
      case 'this_week':
        final weekAgo = now.subtract(const Duration(days: 7));
        tempInspections = tempInspections
            .where((i) => i.date.isAfter(weekAgo))
            .toList();
        break;
      case 'this_month':
        final monthAgo = now.subtract(const Duration(days: 30));
        tempInspections = tempInspections
            .where((i) => i.date.isAfter(monthAgo))
            .toList();
        break;
      case 'problems':
        tempInspections = tempInspections
            .where((i) => i.issues.isNotEmpty)
            .toList();
        break;
      case 'excellent':
        tempInspections = tempInspections
            .where((i) => i.hiveHealth == HiveHealth.strong)
            .toList();
        break;
      case 'poor':
        tempInspections = tempInspections
            .where((i) => i.hiveHealth == HiveHealth.weak)
            .toList();
        break;
    }
    _filteredInspections = tempInspections;
    notifyListeners();
  }

  Future<void> addInspection(InspectionModel inspection) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      await _inspectionService.addInspection(inspection);
      _isLoading = false;
      notifyListeners();
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

  Future<Map<String, dynamic>> getInspectionAnalytics(String userId, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      return await _inspectionService.getInspectionAnalytics(
        userId,
        startDate: startDate,
        endDate: endDate,
      );
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return {};
    }
  }

  void setFilter(String filter) {
    if (_currentFilter != filter) {
      _currentFilter = filter;
      _applyFilters();
    }
  }

  void setSearchQuery(String query) {
    if (_searchQuery != query) {
      _searchQuery = query;
      _applyFilters();
    }
  }

  Future<void> refreshInspections(String userId) async {
    _listenToInspections(userId);
  }

  InspectionModel? getInspectionById(String inspectionId) {
    try {
      return _inspections.firstWhere((inspection) => inspection.id == inspectionId);
    } catch (e) {
      return null;
    }
  }

  List<InspectionModel> getInspectionsByHive(String hiveId) {
    return _inspections.where((inspection) => inspection.hiveId == hiveId).toList();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _inspectionsSubscription?.cancel();
    _statsSubscription?.cancel();
    _upcomingSubscription?.cancel();
    _problemsSubscription?.cancel();
    super.dispose();
  }
}
