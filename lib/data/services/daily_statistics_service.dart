import 'package:flutter/foundation.dart';
import '../services/api_service.dart';
import '../repositories/exercise_repository.dart';
import '../repositories/nutrition_repository.dart';
import '../repositories/user_repository.dart';

class DailyStatisticsService {
  final ExerciseRepository _exerciseRepository;
  final NutritionRepository _nutritionRepository;
  final UserRepository _userRepository;

  DailyStatisticsService(
    this._exerciseRepository,
    this._nutritionRepository,
    this._userRepository,
  );

  Future<bool> saveTodayStatistics() async {
    try {
      final today = DateTime.now();

      final caloriesIn = await _nutritionRepository.getTodayCaloriesIn();
      final caloriesOut = await _exerciseRepository.getTodayCaloriesBurned();
      final exerciseMinutes = await _exerciseRepository.getTodayExerciseMinutes();

      final dailyLog = await _userRepository.getDailyLog(today);
      final waterIntake = dailyLog?['water_intake'] as int? ?? 0;
      
      debugPrint('Daily Statistics kaydediliyor: caloriesIn=$caloriesIn, caloriesOut=$caloriesOut, waterIntake=$waterIntake, exerciseMinutes=$exerciseMinutes');

      final response = await ApiService.post(
        '/daily_statistics.php',
        {
          'date': _formatDate(today),
          'calories_in': caloriesIn,
          'calories_out': caloriesOut,
          'water_intake': waterIntake,
          'exercise_minutes': exerciseMinutes,
        },
      );
      
      if (response['success'] == true) {
        debugPrint('Daily Statistics başarıyla kaydedildi');
        return true;
      } else {
        debugPrint('Daily Statistics kayıt başarısız: ${response['error']}');
        return false;
      }
    } catch (e, stackTrace) {
      debugPrint('Daily Statistics kayıt hatası: $e');
      debugPrint('Stack trace: $stackTrace');
      return false;
    }
  }

  Future<Map<String, dynamic>?> getTodayStatistics() async {
    try {
      final today = DateTime.now();
      final formattedDate = _formatDate(today);

      final response = await ApiService.get('/daily_statistics.php');
      
      if (response['success'] == true && response['statistics'] != null) {
        final statistics = response['statistics'] as List;

        final todayStats = statistics.firstWhere(
          (stat) => stat['date'] == formattedDate,
          orElse: () => null,
        );
        
        if (todayStats != null) {
          return {
            'calories_in': todayStats['calories_in'] as int? ?? 0,
            'calories_out': todayStats['calories_out'] as int? ?? 0,
            'water_intake': todayStats['water_intake'] as int? ?? 0,
            'exercise_minutes': todayStats['exercise_minutes'] as int? ?? 0,
          };
        }
      }
      
      return null;
    } catch (e) {
      debugPrint('Bugünün istatistikleri çekilemedi: $e');
      return null;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}

