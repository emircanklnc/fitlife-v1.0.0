import 'package:flutter/material.dart';
import '../../data/repositories/user_repository.dart';
import '../../data/services/token_service.dart';

class AuthViewModel extends ChangeNotifier {
  final UserRepository _userRepository;

  AuthViewModel(this._userRepository) {
    _checkLoginStatus();
  }

  bool _isLoading = false;

  String? _errorMessage;


  bool get isLoading => _isLoading;

  String? get errorMessage => _errorMessage;

  bool _isLoggedInCached = false;
  bool get isLoggedIn => _isLoggedInCached;

  Future<void> _checkLoginStatus() async {
    final hasToken = await TokenService.hasToken();
    
    if (hasToken) {
      final isExpired = await TokenService.isTokenExpired();
      
      if (isExpired) {
        debugPrint('Token 7 günden eski, yenileniyor...');
        final refreshed = await _userRepository.refreshToken();
        
        if (!refreshed) {
          debugPrint('Token yenilenemedi, kullanıcı çıkış yapılıyor');
          await _userRepository.logout();
          _isLoggedInCached = false;
          notifyListeners();
          return;
        }
      }
    }
    
    _isLoggedInCached = await _userRepository.isLoggedIn();
    notifyListeners();
  }


  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final success = await _userRepository.login(email, password);

      if (success) {
        await _checkLoginStatus();
      }

      _isLoading = false;
      notifyListeners();
      
      return success;
    } catch (e) {
      _errorMessage = 'Giriş başarısız: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      final success = await _userRepository.logout();

      if (success) {
        await _checkLoginStatus();
      }
      
      _isLoading = false;
      notifyListeners();
      return success;
    } catch (e) {
      _errorMessage = 'Çıkış başarısız: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register(
    String email,
    String password,
    String name, {
    int? age,
    double? height,
    double? weight,
    String? gender,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final success = await _userRepository.register(
        email,
        password,
        name,
        age: age,
        height: height,
        weight: weight,
        gender: gender,
      );

      if (success) {
        await _checkLoginStatus();
      }

      _isLoading = false;
      notifyListeners();
      
      return success;
    } catch (e) {
      String errorMsg = 'Kayıt başarısız';
      if (e.toString().contains('Email already exists')) {
        errorMsg = 'Bu e-posta adresi zaten kayıtlı';
      } else if (e.toString().contains('Invalid email format')) {
        errorMsg = 'Geçersiz e-posta formatı';
      } else if (e.toString().contains('Password must be at least')) {
        errorMsg = 'Şifre en az 6 karakter olmalıdır';
      } else if (e.toString().contains('Database connection failed')) {
        errorMsg = 'Veritabanı bağlantı hatası. Lütfen daha sonra tekrar deneyin.';
      } else if (e.toString().contains('API Error')) {
        errorMsg = 'Sunucuya bağlanılamadı. İnternet bağlantınızı kontrol edin.';
      } else {
        errorMsg = 'Kayıt başarısız: ${e.toString()}';
      }
      
      _errorMessage = errorMsg;
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
