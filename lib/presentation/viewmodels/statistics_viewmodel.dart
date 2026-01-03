import 'package:flutter/material.dart';
import '../../data/repositories/exercise_repository.dart';
import '../../data/repositories/nutrition_repository.dart';
import '../../data/repositories/user_repository.dart';
import '../../data/services/api_service.dart';
import '../../core/utils/date_helpers.dart';

class DailyStatistics {
  final DateTime date;
  final int caloriesIn;
  final int caloriesOut;
  final int waterIntake;

  DailyStatistics({
    required this.date,
    required this.caloriesIn,
    required this.caloriesOut,
    required this.waterIntake,
  });
}

class StatisticsViewModel extends ChangeNotifier {
  final ExerciseRepository _exerciseRepository;
  final NutritionRepository _nutritionRepository;
  final UserRepository _userRepository;

  List<DailyStatistics> _dailyStatistics = [];

  bool _isLoading = false;

  String? _errorMessage;

  StatisticsViewModel(
    this._exerciseRepository,
    this._nutritionRepository,
    this._userRepository,
  ) {
    loadStatistics();
  }


  List<DailyStatistics> get dailyStatistics => _dailyStatistics;

  bool get isLoading => _isLoading;

  String? get errorMessage => _errorMessage;


  Future<void> loadStatistics() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await ApiService.get('/daily_statistics.php');
      
      if (response['success'] == true) {
        final statisticsData = response['statistics'] as List;
        
        _dailyStatistics = statisticsData.map((data) {
          return DailyStatistics(
            date: DateTime.parse(data['date']),
            caloriesIn: data['calories_in'] as int? ?? 0,
            caloriesOut: data['calories_out'] as int? ?? 0,
            waterIntake: data['water_intake'] as int? ?? 0,
          );
        }).toList();
        
        _errorMessage = null;
      } else {
        await _loadStatisticsFromLocal();
      }
    } catch (e) {
      debugPrint('Backend API hatası, local verilerden yükleniyor: $e');
      await _loadStatisticsFromLocal();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> _loadStatisticsFromLocal() async {
    try {
      _dailyStatistics = [];

      final now = DateTime.now();
      for (int i = 6; i >= 0; i--) {
        final date = DateTime(now.year, now.month, now.day - i);

        final foodLogs = await _nutritionRepository.getFoodLogsByDate(date);
        int caloriesIn = 0;
        for (var log in foodLogs) {
          caloriesIn += log.calories;
        }

        final exercises = await _exerciseRepository.getExercisesByDate(date);
        int caloriesOut = 0;
        for (var exercise in exercises) {
          caloriesOut += exercise.caloriesBurned;
        }

        final dailyLog = await _userRepository.getDailyLog(DateTime.now());
        final waterIntake = dailyLog?['water_intake'] as int? ?? 0;

        _dailyStatistics.add(
          DailyStatistics(
            date: date,
            caloriesIn: caloriesIn,
            caloriesOut: caloriesOut,
            waterIntake: waterIntake,
          ),
        );
      }

      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'İstatistikler yüklenemedi: $e';
      debugPrint('Local istatistikler yüklenemedi: $e');
    }
  }

  Future<void> refresh() async {
    await loadStatistics();
  }
}

