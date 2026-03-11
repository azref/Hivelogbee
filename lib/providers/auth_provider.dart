import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;

  UserModel? _user;
  bool _isLoading = true;
  String? _errorMessage;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _supabase.auth.currentUser != null;

  AuthProvider() {
    print("--- AuthProvider Initialized ---");
    _supabase.auth.onAuthStateChange.listen((data) {
      print("--- onAuthStateChange triggered ---");
      _onAuthStateChanged(data.session?.user);
    });
  }

  Future<void> _onAuthStateChanged(User? supabaseUser) async {
    _setLoading(true);
    if (supabaseUser == null) {
      _user = null;
      print("User is null. Data cleared.");
    } else {
      print("User found: ${supabaseUser.email}. Loading profile...");
      try {
        final data = await _supabase.from('profiles').select().eq('id', supabaseUser.id).maybeSingle();

        if (data != null) {
          _user = UserModel.fromMap(data);
          print("Profile loaded successfully for: ${_user!.displayName}");
        } else {
          print("Profile not found. Waiting for trigger...");
          await Future.delayed(const Duration(milliseconds: 1500));
          final retryData = await _supabase.from('profiles').select().eq('id', supabaseUser.id).maybeSingle();
          if (retryData != null) {
            _user = UserModel.fromMap(retryData);
            print("Profile loaded on second attempt for: ${_user!.displayName}");
          } else {
            print("CRITICAL: Profile still not found. Check Supabase trigger.");
            _setError("فشل في تحميل الملف الشخصي. الرجاء المحاولة مرة أخرى.");
          }
        }
      } catch (e) {
        print("Error in _onAuthStateChanged: $e");
        _setError("حدث خطأ أثناء تحميل بيانات المستخدم.");
      }
    }
    _setLoading(false);
  }

  Future<bool> createUserWithEmailAndPassword(String email, String password, String displayName) async {
    print("--- Attempting to create user: $email ---");
    try {
      _setLoading(true);
      _clearError();
      await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {'display_name': displayName, 'photo_url': null},
      );
      print("--- Supabase signUp call successful for: $email ---");
      _setLoading(false); // <--- هذا السطر المضاف
      return true;
    } on AuthException catch (e) {
      print("--- AuthException on signUp: ${e.message} ---");
      _setError(e.message);
      _setLoading(false);
      return false;
    } catch (e) {
      print("--- Generic Exception on signUp: $e ---");
      _setError('حدث خطأ غير متوقع');
      _setLoading(false);
      return false;
    }
  }

  Future<bool> signInWithEmailAndPassword(String email, String password) async {
    try {
      _setLoading(true);
      _clearError();
      await _supabase.auth.signInWithPassword(email: email, password: password);
      return true;
    } on AuthException catch (e) {
      _setError(e.message);
      _setLoading(false);
      return false;
    } catch (e) {
      _setError('حدث خطأ غير متوقع');
      _setLoading(false);
      return false;
    }
  }

  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

  Future<bool> resetPassword(String email) async {
    try {
      _setLoading(true);
      _clearError();
      await _supabase.auth.resetPasswordForEmail(email);
      _setLoading(false);
      return true;
    } on AuthException catch (e) {
      _setError(e.message);
      _setLoading(false);
      return false;
    } catch (e) {
      _setError('حدث خطأ غير متوقع');
      _setLoading(false);
      return false;
    }
  }

  Future<bool> updateUserProfile(Map<String, dynamic> updates) async {
    if (_user == null) return false;
    try {
      _setLoading(true);
      _clearError();
      await _supabase.from('profiles').update(updates).eq('id', _user!.id);
      // onAuthStateChange سيقوم بتحديث البيانات تلقائياً إذا تم تغييرها في قاعدة البيانات
      // أو يمكننا تحديثها يدويًا هنا لسرعة الاستجابة في الواجهة
      await _onAuthStateChanged(_supabase.auth.currentUser);
      _setLoading(false);
      return true;
    } catch (e) {
      _setError('حدث خطأ أثناء تحديث الملف الشخصي');
      _setLoading(false);
      return false;
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
