import 'package:flutter/foundation.dart';
import '../models/user_profile.dart';
import '../services/local_storage_service.dart';
import '../services/api_service.dart';
import '../services/token_service.dart';
import '../../core/constants/app_constants.dart';

class UserRepository {
  final LocalStorageService _storageService;

  UserRepository(this._storageService);

  Future<bool> login(String email, String password) async {
    try {
      final response = await ApiService.post(
        '/login.php',
        {
          'email': email,
          'password': password,
        },
        requiresAuth: false,
      );

      if (response['success'] == true && response['token'] != null) {
        final token = response['token'] as String;
        debugPrint('Login: Token alındı (${token.substring(0, 10)}...)');
        final tokenSaved = await TokenService.saveToken(token);
        
        if (!tokenSaved) {
          debugPrint('Login: Token kaydedilemedi!');
          return false;
        }
        
        debugPrint('Login: Token başarıyla kaydedildi');

        await _storageService.remove(AppConstants.userProfileKey);
        await _storageService.remove(AppConstants.exercisesKey);
        await _storageService.remove(AppConstants.foodLogsKey);
        await _storageService.remove(AppConstants.waterIntakeKey);
        await _storageService.remove(AppConstants.chatHistoryKey);
        await _storageService.remove(AppConstants.remindersKey);
        debugPrint('Login: Eski kullanıcı verileri temizlendi');

        await getUserProfile();

        await _storageService.saveData(AppConstants.isLoggedInKey, true);
        
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Login error: $e');
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
    try {
      final response = await ApiService.post(
        '/register.php',
        {
          'email': email,
          'password': password,
          'name': name,
          if (age != null) 'age': age,
          if (height != null) 'height': height,
          if (weight != null) 'weight': weight,
          if (gender != null) 'gender': gender,
        },
        requiresAuth: false,
      );

      if (response['success'] == true && response['token'] != null) {
        final token = response['token'] as String;
        debugPrint('Register: Token alındı (${token.substring(0, 10)}...)');
        final tokenSaved = await TokenService.saveToken(token);
        
        if (!tokenSaved) {
          debugPrint('Register: Token kaydedilemedi!');
          return false;
        }
        
        debugPrint('Register: Token başarıyla kaydedildi');

        await _storageService.remove(AppConstants.userProfileKey);
        await _storageService.remove(AppConstants.exercisesKey);
        await _storageService.remove(AppConstants.foodLogsKey);
        await _storageService.remove(AppConstants.waterIntakeKey);
        await _storageService.remove(AppConstants.chatHistoryKey);
        await _storageService.remove(AppConstants.remindersKey);
        debugPrint('Register: Eski kullanıcı verileri temizlendi');

        await getUserProfile();

        await _storageService.saveData(AppConstants.isLoggedInKey, true);
        
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Register error: $e');
      debugPrint('Register error type: ${e.runtimeType}');
      if (e is Exception) {
        debugPrint('Register error message: ${e.toString()}');
      }
      rethrow;
    }
  }

  Future<bool> logout() async {
    try {
      try {
        await ApiService.post('/logout.php', {}, requiresAuth: true);
        debugPrint('Logout: Backend\'de token iptal edildi');
      } catch (e) {
        debugPrint('Logout: Backend\'e istek gönderilemedi, sadece local temizlik yapılıyor: $e');
      }

      await TokenService.deleteToken();

      await _storageService.remove(AppConstants.isLoggedInKey);

      await _storageService.remove(AppConstants.userProfileKey);
      await _storageService.remove(AppConstants.exercisesKey);
      await _storageService.remove(AppConstants.foodLogsKey);
      await _storageService.remove(AppConstants.waterIntakeKey);
      await _storageService.remove(AppConstants.chatHistoryKey);
      await _storageService.remove(AppConstants.remindersKey);
      
      debugPrint('Logout: Tüm kullanıcı verileri temizlendi');
      
      return true;
    } catch (e) {
      debugPrint('Logout error: $e');
      return false;
    }
  }

  Future<bool> refreshToken() async {
    try {
      final response = await ApiService.post('/refresh_token.php', {}, requiresAuth: true);
      
      if (response['success'] == true && response['token'] != null) {
        final newToken = response['token'] as String;
        await TokenService.saveToken(newToken);
        debugPrint('Token başarıyla yenilendi');
        return true;
      }
      
      return false;
    } catch (e) {
      debugPrint('Token yenileme hatası: $e');
      return false;
    }
  }

  Future<bool> isLoggedIn() async {
    final hasToken = await TokenService.hasToken();
    if (!hasToken) {
      await _storageService.remove(AppConstants.isLoggedInKey);
      return false;
    }

    final hasLocalFlag = _storageService.getData(AppConstants.isLoggedInKey) ?? false;
    return hasLocalFlag;
  }

  Future<bool> saveUserProfile(UserProfile profile) async {
    return await _storageService.saveJson(
      AppConstants.userProfileKey,
      profile.toJson(),
    );
  }

  double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      final parsed = double.tryParse(value);
      return parsed;
    }
    if (value is num) return value.toDouble();
    return null;
  }

  int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) {
      final parsed = int.tryParse(value);
      return parsed;
    }
    if (value is num) return value.toInt();
    return null;
  }

  Future<UserProfile?> getUserProfile() async {
    try {
      final hasToken = await TokenService.hasToken();
      if (!hasToken) {
        debugPrint('Token yok, local cache\'den okunuyor');
        return _getUserProfileFromLocal();
      }

      debugPrint('Backend\'den profil çekiliyor...');
      final response = await ApiService.get('/profile.php');
      debugPrint('Backend response: ${response.toString()}');
      
      if (response['success'] == true && response['profile'] != null) {
        final profileData = response['profile'];
        debugPrint('Profil data alındı: ${profileData.toString()}');
        
        final weightHistoryData = profileData['weight_history'] as List?;
        
        try {
          final profile = UserProfile(
            id: profileData['id'].toString(),
            name: profileData['name'] ?? 'İsimsiz',
            age: _parseInt(profileData['age']),
            height: _parseDouble(profileData['height']),
            weight: _parseDouble(profileData['weight']),
            gender: profileData['gender'] as String?,
            dailyCalorieGoal: _parseInt(profileData['daily_calorie_goal']) ?? 2000,
            targetWeight: _parseDouble(profileData['target_weight']),
            weightHistory: weightHistoryData?.map((e) {
              return WeightEntry(
                date: DateTime.parse(e['date']),
                weight: _parseDouble(e['weight']) ?? 0.0,
              );
            }).toList() ?? [],
            createdAt: profileData['created_at'] != null 
                ? DateTime.parse(profileData['created_at']) 
                : DateTime.now(),
            updatedAt: profileData['updated_at'] != null 
                ? DateTime.parse(profileData['updated_at']) 
                : DateTime.now(),
          );
          
          debugPrint('Profil oluşturuldu: ${profile.name}');

          await saveUserProfile(profile);
          
          return profile;
        } catch (e) {
          debugPrint('Profil oluşturma hatası: $e');
          debugPrint('ProfileData: ${profileData.toString()}');
          return _getUserProfileFromLocal();
        }
      }

      debugPrint('Backend\'den profil alınamadı. Response: ${response.toString()}');
      debugPrint('Local cache\'den okunuyor...');
      return _getUserProfileFromLocal();
    } catch (e, stackTrace) {
      debugPrint('Profil yükleme hatası: $e');
      debugPrint('Stack trace: $stackTrace');
      final localProfile = _getUserProfileFromLocal();
      if (localProfile != null) {
        debugPrint('Local cache\'den profil bulundu: ${localProfile.name}');
      } else {
        debugPrint('Local cache\'de profil yok');
      }
      return localProfile;
    }
  }

  UserProfile? _getUserProfileFromLocal() {
    final json = _storageService.getJson(AppConstants.userProfileKey);
    if (json != null) {
      return UserProfile.fromJson(json);
    }
    return null;
  }

  Future<bool> updateUserProfile(UserProfile profile) async {
    try {
      final response = await ApiService.put(
        '/profile.php',
        {
          'name': profile.name,
          'age': profile.age,
          'height': profile.height,
          'weight': profile.weight,
          'gender': profile.gender,
          'daily_calorie_goal': profile.dailyCalorieGoal,
          'target_weight': profile.targetWeight,
        },
      );

      if (response['success'] == true) {
        await saveUserProfile(profile);
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<bool> addWeightEntry(double weight) async {
    try {
      debugPrint('📝 Kilo kaydı ekleniyor: $weight kg');

      final response = await ApiService.put(
        '/profile.php',
        {
          'weight': weight,
        },
      );

      debugPrint('📝 Backend response: ${response.toString()}');

      if (response['success'] == true) {
        final updatedProfile = await getUserProfile();
        if (updatedProfile != null) {
          debugPrint('✅ Profil başarıyla güncellendi. WeightHistory: ${updatedProfile.weightHistory.length} kayıt');
          return true;
        } else {
          debugPrint('❌ Profil güncellenemedi: updatedProfile null');
        }
      } else {
        debugPrint('❌ Backend başarısız response: ${response.toString()}');
      }
      return false;
    } catch (e, stackTrace) {
      debugPrint('❌ addWeightEntry hatası: $e');
      debugPrint('Stack trace: $stackTrace');
      return false;
    }
  }

  Future<bool> updateDailyCalorieGoal(int calorieGoal) async {
    final profile = await getUserProfile();
    if (profile == null) return false;

    final updatedProfile = profile.copyWith(
      dailyCalorieGoal: calorieGoal,
    );

    return await updateUserProfile(updatedProfile);
  }

  Future<bool> updateWaterIntake(int waterIntake) async {
    try {
      return await _storageService.saveData(
        AppConstants.waterIntakeKey,
        waterIntake,
      );
    } catch (e) {
      return false;
    }
  }

  Future<Map<String, dynamic>?> getDailyLog(DateTime date) async {
    final waterIntake = _storageService.getData(AppConstants.waterIntakeKey) ?? 0;
    
    return {
      'water_intake': waterIntake,
    };
  }
}
