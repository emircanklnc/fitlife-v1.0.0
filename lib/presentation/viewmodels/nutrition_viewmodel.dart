import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../data/models/food_log.dart';
import '../../data/repositories/nutrition_repository.dart';
import '../../data/repositories/user_repository.dart';
import '../../data/repositories/exercise_repository.dart';
import '../../data/services/daily_statistics_service.dart';
import '../../core/constants/app_constants.dart';

class NutritionViewModel extends ChangeNotifier {
  final NutritionRepository _repository;

  final UserRepository _userRepository;

  DailyStatisticsService? _dailyStatsService;

  List<FoodLog> _foodLogs = [];

  bool _isLoading = false;

  String? _errorMessage;

  int _dailyGoal = AppConstants.defaultCaloriesGoal;

  NutritionViewModel(this._repository, this._userRepository) {
    loadFoodLogs();
    _loadDailyGoal();
  }

  void setDailyStatsService(ExerciseRepository exerciseRepo) {
    _dailyStatsService = DailyStatisticsService(
      exerciseRepo,
      _repository,
      _userRepository,
    );
  }


  List<FoodLog> get foodLogs => _foodLogs;

  bool get isLoading => _isLoading;

  String? get errorMessage => _errorMessage;

  int get dailyGoal => _dailyGoal;

  Future<void> loadDailyGoal() async {
    try {
      final profile = await _userRepository.getUserProfile();
      if (profile != null) {
        _dailyGoal = profile.dailyCalorieGoal;
        notifyListeners();
      }
    } catch (e) {
      _dailyGoal = AppConstants.defaultCaloriesGoal;
      notifyListeners();
    }
  }

  Future<void> _loadDailyGoal() async {
    await loadDailyGoal();
  }


  int get totalCalories => _foodLogs.fold(0, (sum, log) => sum + log.calories);

  double get totalProtein => _foodLogs.fold(0.0, (sum, log) => sum + log.protein);

  double get totalCarbs => _foodLogs.fold(0.0, (sum, log) => sum + log.carbs);

  double get totalFat => _foodLogs.fold(0.0, (sum, log) => sum + log.fat);


  double get caloriesPercentage => (totalCalories / dailyGoal).clamp(0.0, 1.0);

  int get remainingCalories => dailyGoal - totalCalories;

  double get proteinPercentage {
    final total = totalProtein + totalCarbs + totalFat;
    return total > 0 ? (totalProtein / total) : 0;
  }

  double get carbsPercentage {
    final total = totalProtein + totalCarbs + totalFat;
    return total > 0 ? (totalCarbs / total) : 0;
  }

  double get fatPercentage {
    final total = totalProtein + totalCarbs + totalFat;
    return total > 0 ? (totalFat / total) : 0;
  }


  Future<void> loadFoodLogs() async {
    _isLoading = true;
    notifyListeners();

    try {
      _foodLogs = await _repository.getFoodLogsByDate(DateTime.now());

      await _loadDailyGoal();
      
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Yemek kayıtları yüklenemedi: $e';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> addFoodLog({
    required String foodName,
    required int calories,
    required double protein,
    required double carbs,
    required double fat,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final foodLog = FoodLog(
        id: const Uuid().v4(),
        date: DateTime.now(),
        foodName: foodName,
        calories: calories,
        protein: protein,
        carbs: carbs,
        fat: fat,
      );

      final success = await _repository.addFoodLog(foodLog);
      
      if (success) {
        await loadFoodLogs();

        if (_dailyStatsService != null) {
          await _dailyStatsService!.saveTodayStatistics();
        }
        
        _errorMessage = null;
      }

      _isLoading = false;
      notifyListeners();
      return success;
    } catch (e) {
      _errorMessage = 'Yemek eklenemedi: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteFoodLog(String foodLogId) async {
    try {
      final foodLog = _foodLogs.firstWhere((f) => f.id == foodLogId);
      final success = await _repository.deleteFoodLog(foodLogId, foodLog.date);
      
      if (success) {
        await loadFoodLogs();

        if (_dailyStatsService != null) {
          await _dailyStatsService!.saveTodayStatistics();
        }
      }
      
      return success;
    } catch (e) {
      _errorMessage = 'Yemek silinemedi: $e';
      notifyListeners();
      return false;
    }
  }

  void clearState() {
    _foodLogs = [];
    _errorMessage = null;
    _isLoading = false;
    notifyListeners();
  }

  Future<void> refresh() async {
    await loadFoodLogs();
  }
}
