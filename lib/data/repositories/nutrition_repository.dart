import 'package:flutter/foundation.dart';
import '../models/food_log.dart';
import '../services/local_storage_service.dart';
import '../services/api_service.dart';
import '../../core/constants/app_constants.dart';
import 'package:intl/intl.dart';

class NutritionRepository {
  final LocalStorageService _storageService;

  NutritionRepository(this._storageService);

  Future<List<FoodLog>> getFoodLogsByDate(DateTime date) async {
    try {
      final formattedDate = DateFormat('yyyy-MM-dd').format(date);
      debugPrint('NutritionRepository: Backend\'den yemek kayıtları çekiliyor (tarih: $formattedDate)');
      final response = await ApiService.get('/food_logs.php?date=$formattedDate');
      debugPrint('NutritionRepository: Backend response: $response');
      
      if (response['success'] == true) {
        dynamic foodLogsData = response['food_logs'];

        if (foodLogsData == null) {
          debugPrint('NutritionRepository: Backend başarılı ama food_logs null, boş liste döndürülüyor');
          return [];
        }

        final foodLogsList = foodLogsData is List ? foodLogsData : [];
        debugPrint('NutritionRepository: Backend\'den ${foodLogsList.length} adet yemek kaydı alındı');
        
        if (foodLogsList.isEmpty) {
          debugPrint('NutritionRepository: Backend\'den boş liste geldi, boş liste döndürülüyor');
          await _saveFoodLogsToLocal([], date);
          return [];
        }
        
        final foodLogs = <FoodLog>[];
        for (var data in foodLogsList) {
          try {
            final id = data['id']?.toString() ?? '';
            if (id.isEmpty) {
              debugPrint('NutritionRepository: Geçersiz food log (id yok), atlanıyor: $data');
              continue;
            }
            
            final dateStr = data['date']?.toString() ?? '';
            if (dateStr.isEmpty) {
              debugPrint('NutritionRepository: Geçersiz food log (date yok), atlanıyor: $data');
              continue;
            }
            
            final foodName = data['food_name']?.toString() ?? '';
            final calories = (data['calories'] as num?)?.toInt() ?? 0;
            final protein = (data['protein'] as num?)?.toDouble() ?? 0.0;
            final carbs = (data['carbs'] as num?)?.toDouble() ?? 0.0;
            final fat = (data['fat'] as num?)?.toDouble() ?? 0.0;
            
            foodLogs.add(FoodLog(
              id: id,
              date: DateTime.parse(dateStr),
              foodName: foodName,
              calories: calories,
              protein: protein,
              carbs: carbs,
              fat: fat,
            ));
          } catch (e) {
            debugPrint('NutritionRepository: Food log parse hatası: $e, Data: $data');
            continue;
          }
        }

        await _saveFoodLogsToLocal(foodLogs, date);
        
        debugPrint('NutritionRepository: ${foodLogs.length} adet yemek kaydı döndürülüyor');
        return foodLogs;
      } else {
        debugPrint('NutritionRepository: Backend başarısız (success != true), local\'den okunuyor. Response: $response');
        return _getFoodLogsFromLocal(date);
      }
    } catch (e, stackTrace) {
      debugPrint('NutritionRepository: Backend\'den yemek kayıtları çekilemedi, local\'den okunuyor');
      debugPrint('Hata: $e');
      debugPrint('Stack trace: $stackTrace');
      return _getFoodLogsFromLocal(date);
    }
  }

  Future<bool> addFoodLog(FoodLog foodLog) async {
    try {
      final formattedDate = DateFormat('yyyy-MM-dd').format(foodLog.date);
      final response = await ApiService.post('/food_logs.php', {
        'id': foodLog.id,
        'date': formattedDate,
        'food_name': foodLog.foodName,
        'calories': foodLog.calories,
        'protein': foodLog.protein,
        'carbs': foodLog.carbs,
        'fat': foodLog.fat,
      });
      
      if (response['success'] == true) {
        final logs = _getFoodLogsFromLocal(foodLog.date);
        logs.add(foodLog);
        await _saveFoodLogsToLocal(logs, foodLog.date);
        return true;
      }
      
      return false;
    } catch (e) {
      debugPrint('Yemek kaydı eklenemedi: $e');
      return false;
    }
  }

  Future<bool> deleteFoodLog(String foodLogId, DateTime date) async {
    try {
      final formattedDate = DateFormat('yyyy-MM-dd').format(date);
      final response = await ApiService.delete('/food_logs.php?id=$foodLogId&date=$formattedDate');
      
      if (response['success'] == true) {
        final logs = _getFoodLogsFromLocal(date);
        logs.removeWhere((log) => log.id == foodLogId);
        await _saveFoodLogsToLocal(logs, date);
        return true;
      }
      
      return false;
    } catch (e) {
      debugPrint('Yemek kaydı silinemedi: $e');
      return false;
    }
  }

  Future<int> getTodayCaloriesIn() async {
    final todayLogs = await getFoodLogsByDate(DateTime.now());
    int total = 0;
    for (var log in todayLogs) {
      total += log.calories;
    }
    return total;
  }

  Future<Map<String, double>> getTodayMacros() async {
    final todayLogs = await getFoodLogsByDate(DateTime.now());
    double protein = 0, carbs = 0, fat = 0;
    for (var log in todayLogs) {
      protein += log.protein;
      carbs += log.carbs;
      fat += log.fat;
    }
    return {'protein': protein, 'carbs': carbs, 'fat': fat};
  }


  List<FoodLog> _getFoodLogsFromLocal(DateTime date) {
    final jsonList = _storageService.getJsonList(AppConstants.foodLogsKey);
    if (jsonList == null) return [];
    
    final allLogs = jsonList.map((json) => FoodLog.fromJson(json)).toList();
    return allLogs.where((log) {
      return log.date.year == date.year &&
          log.date.month == date.month &&
          log.date.day == date.day;
    }).toList();
  }

  Future<bool> _saveFoodLogsToLocal(List<FoodLog> logs, DateTime date) async {
    final jsonList = _storageService.getJsonList(AppConstants.foodLogsKey);
    List<Map<String, dynamic>> allLogs = jsonList ?? [];

    allLogs.removeWhere((json) {
      final log = FoodLog.fromJson(json);
      return log.date.year == date.year &&
          log.date.month == date.month &&
          log.date.day == date.day;
    });

    allLogs.addAll(logs.map((l) => l.toJson()));
    
    return await _storageService.saveJsonList(AppConstants.foodLogsKey, allLogs);
  }
}
