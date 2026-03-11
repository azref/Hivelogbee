import 'dart:async';
import 'package:flutter/material.dart';
import '../models/production_model.dart';
import '../services/production_service.dart'; // سيتم استبداله بـ SupabaseProductionService

class ProductionProvider extends ChangeNotifier {
  final ProductionService _productionService = ProductionService(); // سيتم استبداله
  List<ProductionModel> _productions = [];
  List<ProductionModel> _filteredProductions = [];
  Map<String, dynamic> _stats = {};
  Map<String, dynamic> _yearlyComparison = {};
  List<Map<String, dynamic>> _topBuyers = [];
  bool _isLoading = false;
  String? _error;
  String _currentFilter = 'all';
  String _searchQuery = '';
  int _selectedYear = DateTime.now().year;

  // تم الاستغناء عن Pagination الخاصة بـ Firestore
  // DocumentSnapshot? _lastDocument;
  // bool _hasMoreData = true;

  StreamSubscription? _productionsSubscription;
  StreamSubscription? _statsSubscription;
  StreamSubscription? _buyersSubscription;

  List<ProductionModel> get productions => _filteredProductions;
  Map<String, dynamic> get stats => _stats;
  Map<String, dynamic> get yearlyComparison => _yearlyComparison;
  List<Map<String, dynamic>> get topBuyers => _topBuyers;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get currentFilter => _currentFilter;
  String get searchQuery => _searchQuery;
  int get selectedYear => _selectedYear;

  void initialize(String userId) {
    _listenToProductions(userId);
    _listenToStats(userId);
    _listenToTopBuyers(userId);
  }

  void _listenToProductions(String userId) {
    _isLoading = true;
    notifyListeners();
    _productionsSubscription?.cancel();
    _productionsSubscription = _productionService.getProductionsStream(
      userId: userId,
      year: _selectedYear,
    ).listen(
          (productionsList) {
        _productions = productionsList;
        _applyFilters();
        _isLoading = false;
        _error = null;
        notifyListeners();
      },
      onError: (error) {
        _error = 'خطأ في تحميل الإنتاج: $error';
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  void _listenToStats(String userId) {
    _statsSubscription?.cancel();
    _statsSubscription = _productionService.getProductionStatsStream(
      userId: userId,
      year: _selectedYear,
    ).listen(
          (stats) {
        _stats = stats;
        notifyListeners();
      },
      onError: (error) {
        print('خطأ في تحميل إحصائيات الإنتاج: $error');
      },
    );
  }

  void _listenToTopBuyers(String userId) {
    _buyersSubscription?.cancel();
    _buyersSubscription = _productionService.getTopBuyersStream(userId).listen(
          (buyers) {
        _topBuyers = buyers;
        notifyListeners();
      },
      onError: (error) {
        print('خطأ في تحميل أفضل المشترين: $error');
      },
    );
  }

  void _applyFilters() {
    List<ProductionModel> tempProductions = List.from(_productions);

    if (_searchQuery.isNotEmpty) {
      tempProductions = tempProductions.where((production) {
        final query = _searchQuery.toLowerCase();
        return (production.hiveId.toLowerCase().contains(query)) ||
            (production.notes?.toLowerCase().contains(query) ?? false) ||
            (production.buyer?.toLowerCase().contains(query) ?? false) ||
            production.productType.name.toLowerCase().contains(query);
      }).toList();
    }

    switch (_currentFilter) {
      case 'honey':
        tempProductions = tempProductions.where((p) => p.productType == ProductType.honey).toList();
        break;
      // ... باقي حالات الفلترة تبقى كما هي
      case 'sold':
        tempProductions = tempProductions.where((p) => p.isSold).toList();
        break;
      case 'unsold':
        tempProductions = tempProductions.where((p) => !p.isSold).toList();
        break;
    }
    _filteredProductions = tempProductions;
    notifyListeners(); // تمت الإضافة لضمان تحديث الواجهة
  }

  Future<void> addProduction(ProductionModel production) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      await _productionService.addProduction(production);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> updateProduction(ProductionModel production) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      await _productionService.updateProduction(production);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> deleteProduction(String productionId) async { // تم تعديل المعاملات
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      await _productionService.deleteProduction(productionId); // تم تعديل المعاملات
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  // الدوال التي تعتمد على استدعاءات RPC أو views في Supabase
  Future<void> loadYearlyComparison(String userId, int year1, int year2) async {
    try {
      _yearlyComparison = await _productionService.compareYears(userId, year1, year2);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>> getMonthlyAnalytics(String userId, int year) async {
    try {
      return await _productionService.getMonthlyAnalytics(userId, year);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return {};
    }
  }

  Future<List<Map<String, dynamic>>> getBuyerAnalytics(String userId) async {
    try {
      return await _productionService.getBuyerAnalytics(userId);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return [];
    }
  }

  void setFilter(String filter) { // تم إزالة userId
    if (_currentFilter != filter) {
      _currentFilter = filter;
      _applyFilters();
    }
  }

  void setSearchQuery(String query) { // تم إزالة userId
    if (_searchQuery != query) {
      _searchQuery = query;
      _applyFilters();
    }
  }

  void setSelectedYear(int year, String userId) {
    if (_selectedYear != year) {
      _selectedYear = year;
      // إعادة تحميل البيانات للسنة الجديدة
      _listenToProductions(userId);
      _listenToStats(userId);
    }
  }

  Future<void> refreshProductions(String userId) async {
    _listenToProductions(userId);
  }

  // الدوال المساعدة تبقى كما هي وتعمل على قائمة _productions
  ProductionModel? getProductionById(String productionId) {
    try {
      return _productions.firstWhere((production) => production.id == productionId);
    } catch (e) {
      return null;
    }
  }

  // ... باقي الدوال المساعدة تبقى كما هي ...

  void clearError() {
    _error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _productionsSubscription?.cancel();
    _statsSubscription?.cancel();
    _buyersSubscription?.cancel();
    super.dispose();
  }
}
