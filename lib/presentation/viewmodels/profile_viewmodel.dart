import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../data/models/user_profile.dart';
import '../../data/repositories/user_repository.dart';
import '../../core/utils/calorie_calculator.dart';

class ProfileViewModel extends ChangeNotifier {
  final UserRepository _userRepository;

  UserProfile? _userProfile;

  bool _isLoading = false;

  String? _errorMessage;

  ProfileViewModel(this._userRepository) {
  }

  void clearProfile() {
    _userProfile = null;
    _errorMessage = null;
    _isLoading = false;
    notifyListeners();
  }


  UserProfile? get userProfile => _userProfile;

  bool get isLoading => _isLoading;

  String? get errorMessage => _errorMessage;

  double get bmi {
    if (_userProfile != null && 
        _userProfile!.weight != null && 
        _userProfile!.height != null) {
      return CalorieCalculator.calculateBMI(
        weight: _userProfile!.weight!,
        height: _userProfile!.height!,
      );
    }
    return 0;
  }

  String get bmiCategory {
    return CalorieCalculator.getBMICategory(bmi);
  }

  List<WeightEntry> get weightHistory {
    if (_userProfile?.weightHistory == null) {
      debugPrint('⚠️ weightHistory null');
      return [];
    }
    final history = List<WeightEntry>.from(_userProfile!.weightHistory);
    history.sort((a, b) => a.date.compareTo(b.date));
    debugPrint('📊 weightHistory getter çağrıldı. Uzunluk: ${history.length}');
    if (history.isNotEmpty) {
      debugPrint('📊 İlk kayıt: ${history.first.weight} kg (${history.first.date})');
      debugPrint('📊 Son kayıt: ${history.last.weight} kg (${history.last.date})');
    }
    return history;
  }

  String get totalProgress {
    final sortedHistory = weightHistory;
    if (sortedHistory.isEmpty) {
      return '0.0 kg';
    }

    if (sortedHistory.length == 1) {
      final lastWeight = sortedHistory.last.weight;
      final currentWeight = _userProfile?.weight;
      if (currentWeight != null && currentWeight != lastWeight) {
        final diff = currentWeight - lastWeight;
        final sign = diff > 0 ? '+' : '';
        return '$sign${diff.toStringAsFixed(1)} kg';
      }
      return '0.0 kg';
    }

    final secondLast = sortedHistory[sortedHistory.length - 2].weight;
    final last = sortedHistory.last.weight;
    final diff = last - secondLast;
    final sign = diff > 0 ? '+' : '';
    return '$sign${diff.toStringAsFixed(1)} kg';
  }

  double? get targetWeight {
    final sortedHistory = weightHistory;
    if (sortedHistory.isNotEmpty) {
      return sortedHistory.last.weight;
    }
    return _userProfile?.weight;
  }

  String get targetProgress {
    return totalProgress;
  }

  double get targetProgressPercentage {
    if (_userProfile?.weight == null || targetWeight == null || weightHistory.isEmpty) {
      return 0.0;
    }
    
    final current = _userProfile!.weight!;
    final target = targetWeight!;
    final startWeight = weightHistory.first.weight;

    if (target < startWeight) {
      final total = startWeight - target;
      final progress = startWeight - current;
      if (total <= 0) return 0.0;
      return (progress / total).clamp(0.0, 1.0);
    }
    else {
      final total = target - startWeight;
      final progress = current - startWeight;
      if (total <= 0) return 0.0;
      return (progress / total).clamp(0.0, 1.0);
    }
  }


  Future<void> loadUserProfile() async {
    _isLoading = true;
    notifyListeners();

    try {
      debugPrint('ProfileViewModel: Profil yükleniyor...');
      _userProfile = await _userRepository.getUserProfile();
      
      if (_userProfile != null) {
        debugPrint('ProfileViewModel: Profil başarıyla yüklendi: ${_userProfile!.name}');
        _errorMessage = null;
      } else {
        debugPrint('ProfileViewModel: Profil null, hata mesajı ayarlanıyor...');
        _errorMessage = 'Profil bulunamadı. Lütfen tekrar giriş yapın.';
      }
    } catch (e) {
      final errorStr = e.toString();
      debugPrint('Profil yükleme hatası: $e');

      if (errorStr.contains('token') || errorStr.contains('Token')) {
        debugPrint('Token hatası tespit edildi, local cache\'den okunuyor...');
        try {
          _userProfile = await _userRepository.getUserProfile();
          if (_userProfile == null) {
            _errorMessage = 'Profil yüklenemedi. Lütfen tekrar giriş yapın.';
          }
        } catch (e2) {
          _userProfile = null;
          _errorMessage = 'Profil yüklenemedi. Lütfen tekrar giriş yapın.';
        }
      } else {
        _userProfile = null;
        _errorMessage = 'Profil yüklenemedi: $e';
      }
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> updateProfile({
    String? name,
    int? age,
    double? height,
    double? weight,
    String? gender,
    double? targetWeight,
  }) async {
    if (_userProfile == null) return false;

    _isLoading = true;
    notifyListeners();

    try {
      List<WeightEntry>? updatedHistory;
      if (weight != null && weight != _userProfile!.weight) {
        updatedHistory = [
          ..._userProfile!.weightHistory,
          WeightEntry(date: DateTime.now(), weight: weight),
        ];
      }

      final updatedProfile = _userProfile!.copyWith(
        name: name,
        age: age,
        height: height,
        weight: weight,
        gender: gender,
        targetWeight: targetWeight,
        weightHistory: updatedHistory,
      );

      final success = await _userRepository.updateUserProfile(updatedProfile);
      
      if (success) {
        _userProfile = await _userRepository.getUserProfile();
        _errorMessage = null;
      }

      _isLoading = false;
      notifyListeners();
      return success;
    } catch (e) {
      _errorMessage = 'Profil güncellenemedi: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> addWeightEntry(double weight) async {
    if (_userProfile == null) return false;
    
    _isLoading = true;
    notifyListeners();
    
    try {
      final success = await _userRepository.addWeightEntry(weight);
      
      if (success) {
        final updatedProfile = await _userRepository.getUserProfile();
        if (updatedProfile != null) {
          _userProfile = updatedProfile;
          _errorMessage = null;
          debugPrint('✅ Kilo kaydı eklendi. Yeni profil: ${updatedProfile.weight} kg');
          debugPrint('✅ WeightHistory uzunluğu: ${updatedProfile.weightHistory.length}');
          if (updatedProfile.weightHistory.isNotEmpty) {
            debugPrint('✅ Son kilo kaydı: ${updatedProfile.weightHistory.last.weight} kg');
          }
          _isLoading = false;
          notifyListeners();
          return true;
        } else {
          debugPrint('❌ Profil güncellenemedi: updatedProfile null');
        }
      } else {
        debugPrint('❌ Backend\'e kilo kaydı eklenemedi');
      }
      
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e, stackTrace) {
      debugPrint('❌ Kilo kaydı ekleme hatası: $e');
      debugPrint('Stack trace: $stackTrace');

      String errorMsg = 'Kilo kaydı eklenemedi';
      if (e.toString().contains('Sunucuya bağlanılamadı')) {
        errorMsg = 'Sunucuya bağlanılamadı. İnternet bağlantınızı kontrol edin.';
      } else if (e.toString().contains('token') || e.toString().contains('Token')) {
        errorMsg = 'Oturum süreniz dolmuş. Lütfen tekrar giriş yapın.';
      } else if (e.toString().contains('timeout') || e.toString().contains('zaman aşımı')) {
        errorMsg = 'İstek zaman aşımına uğradı. Lütfen tekrar deneyin.';
      } else {
        errorMsg = 'Kilo kaydı eklenirken bir hata oluştu: ${e.toString()}';
      }
      
      _errorMessage = errorMsg;
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateDailyCalorieGoal(int calorieGoal) async {
    if (_userProfile == null) return false;

    _isLoading = true;
    notifyListeners();

    try {
      final updatedProfile = _userProfile!.copyWith(
        dailyCalorieGoal: calorieGoal,
      );

      final success = await _userRepository.updateUserProfile(updatedProfile);
      
      if (success) {
        _userProfile = await _userRepository.getUserProfile();
        _errorMessage = null;
      }

      _isLoading = false;
      notifyListeners();
      return success;
    } catch (e) {
      _errorMessage = 'Kalori hedefi güncellenemedi: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
