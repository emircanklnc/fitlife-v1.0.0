import 'package:flutter/material.dart';
import '../../data/repositories/exercise_repository.dart';
import '../../data/repositories/nutrition_repository.dart';
import '../../data/repositories/user_repository.dart';
import '../../data/services/daily_statistics_service.dart';
import '../../core/constants/app_constants.dart';

class DashboardViewModel extends ChangeNotifier {
  final UserRepository _userRepository;
  final ExerciseRepository _exerciseRepository;
  final NutritionRepository _nutritionRepository;

  late final DailyStatisticsService _dailyStatsService;

  DashboardViewModel(
    this._userRepository,
    this._exerciseRepository,
    this._nutritionRepository,
  ) {
    _dailyStatsService = DailyStatisticsService(
      _exerciseRepository,
      _nutritionRepository,
      _userRepository,
    );
    loadDashboardData();
  }


  int _caloriesIn = 0;

  int _caloriesOut = 0;

  int _waterIntake = 0;

  int _exerciseMinutes = 0;

  String _userName = 'Kullanıcı';

  final int _caloriesGoal = AppConstants.defaultCaloriesGoal;
  final int _waterGoal = AppConstants.defaultWaterGoal;
  final int _exerciseGoal = AppConstants.defaultExerciseGoal;


  int get caloriesIn => _caloriesIn;
  int get caloriesOut => _caloriesOut;
  int get waterIntake => _waterIntake;
  int get exerciseMinutes => _exerciseMinutes;
  String get userName => _userName;

  int get caloriesGoal => _caloriesGoal;
  int get waterGoal => _waterGoal;
  int get exerciseGoal => _exerciseGoal;

  int get netCalories => _caloriesIn - _caloriesOut;

  int get remainingCalories => _caloriesGoal - _caloriesIn + _caloriesOut;


  double get caloriesInPercentage =>
      (_caloriesIn / _caloriesGoal).clamp(0.0, 1.0);

  double get caloriesOutPercentage =>
      (_caloriesOut / _caloriesGoal).clamp(0.0, 1.0);

  @Deprecated('Use caloriesInPercentage instead')
  double get caloriesPercentage => caloriesInPercentage;

  double get waterPercentage =>
      (_waterIntake / _waterGoal).clamp(0.0, 1.0);

  double get exercisePercentage =>
      (_exerciseMinutes / _exerciseGoal).clamp(0.0, 1.0);


  Future<void> loadDashboardData() async {
    try {
      final today = DateTime.now();
      final formattedDate = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
      
      try {
        final response = await _dailyStatsService.getTodayStatistics();
        if (response != null) {
          _caloriesIn = response['calories_in'] as int? ?? 0;
          _caloriesOut = response['calories_out'] as int? ?? 0;
          _waterIntake = response['water_intake'] as int? ?? 0;
          _exerciseMinutes = response['exercise_minutes'] as int? ?? 0;
        } else {
          _caloriesIn = await _nutritionRepository.getTodayCaloriesIn();
          _caloriesOut = await _exerciseRepository.getTodayCaloriesBurned();
          _exerciseMinutes = await _exerciseRepository.getTodayExerciseMinutes();
          
          final dailyLog = await _userRepository.getDailyLog(today);
          _waterIntake = dailyLog?['water_intake'] as int? ?? 0;
        }
      } catch (e) {
        debugPrint('Backend\'den daily statistics çekilemedi, repository\'lerden toplanıyor: $e');
        _caloriesIn = await _nutritionRepository.getTodayCaloriesIn();
        _caloriesOut = await _exerciseRepository.getTodayCaloriesBurned();
        _exerciseMinutes = await _exerciseRepository.getTodayExerciseMinutes();
        
        final dailyLog = await _userRepository.getDailyLog(today);
        _waterIntake = dailyLog?['water_intake'] as int? ?? 0;
      }

      final userProfile = await _userRepository.getUserProfile();
      if (userProfile != null) {
        _userName = userProfile.name;
      }

      notifyListeners();

      await _dailyStatsService.saveTodayStatistics();
    } catch (e) {
      debugPrint('Dashboard verileri yüklenemedi: $e');
    }
  }

  void updateWaterIntake(int glasses) {
    _waterIntake = glasses;
    notifyListeners();
  }

  Future<void> incrementWater() async {
    if (_waterIntake < _waterGoal) {
      _waterIntake++;

      await _userRepository.updateWaterIntake(_waterIntake);

      await _dailyStatsService.saveTodayStatistics();
      
      notifyListeners();
    }
  }

  Future<void> decrementWater() async {
    if (_waterIntake > 0) {
      _waterIntake--;

      await _userRepository.updateWaterIntake(_waterIntake);

      await _dailyStatsService.saveTodayStatistics();
      
      notifyListeners();
    }
  }

  void clearState() {
    _caloriesIn = 0;
    _caloriesOut = 0;
    _waterIntake = 0;
    _exerciseMinutes = 0;
    _userName = 'Kullanıcı';
    notifyListeners();
  }

  Future<void> refresh() async {
    await loadDashboardData();
  }
}
