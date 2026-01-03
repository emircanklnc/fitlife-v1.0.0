import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../data/models/exercise.dart';
import '../../data/repositories/exercise_repository.dart';
import '../../data/repositories/nutrition_repository.dart';
import '../../data/repositories/user_repository.dart';
import '../../data/services/daily_statistics_service.dart';

class ExerciseViewModel extends ChangeNotifier {
  final ExerciseRepository _repository;

  DailyStatisticsService? _dailyStatsService;

  List<Exercise> _exercises = [];

  bool _isLoading = false;

  String? _errorMessage;

  ExerciseViewModel(this._repository);

  void setDailyStatsService(
    NutritionRepository nutritionRepo,
    UserRepository userRepo,
  ) {
    _dailyStatsService = DailyStatisticsService(
      _repository,
      nutritionRepo,
      userRepo,
    );
    loadExercises();
  }


  List<Exercise> get exercises => _exercises;

  bool get isLoading => _isLoading;

  String? get errorMessage => _errorMessage;

  int get totalMinutes => _exercises.fold(0, (sum, ex) => sum + ex.duration);

  int get totalCalories => _exercises.fold(0, (sum, ex) => sum + ex.caloriesBurned);

  List<Exercise> get cardioExercises =>
      _exercises.where((ex) => ex.type.toLowerCase() == 'cardio').toList();

  List<Exercise> get weightExercises =>
      _exercises.where((ex) => ex.type.toLowerCase() == 'weights').toList();


  Future<void> loadExercises() async {
    _isLoading = true;
    notifyListeners();

    try {
      _exercises = await _repository.getExercisesByDate(DateTime.now());
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Egzersizler yüklenemedi: $e';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> addExercise({
    required String type,
    required String name,
    required int duration,
    required int calories,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final exercise = Exercise(
        id: const Uuid().v4(),
        date: DateTime.now(),
        type: type,
        name: name,
        duration: duration,
        caloriesBurned: calories,
      );

      final success = await _repository.addExercise(exercise);
      
      if (success) {
        await loadExercises();

        if (_dailyStatsService != null) {
          await _dailyStatsService!.saveTodayStatistics();
        }
        
        _errorMessage = null;
      }

      _isLoading = false;
      notifyListeners();
      return success;
    } catch (e) {
      _errorMessage = 'Egzersiz eklenemedi: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteExercise(String exerciseId) async {
    try {
      final exercise = _exercises.firstWhere((e) => e.id == exerciseId);
      final success = await _repository.deleteExercise(exerciseId, exercise.date);
      
      if (success) {
        await loadExercises();

        if (_dailyStatsService != null) {
          await _dailyStatsService!.saveTodayStatistics();
        }
      }
      
      return success;
    } catch (e) {
      _errorMessage = 'Egzersiz silinemedi: $e';
      notifyListeners();
      return false;
    }
  }

  void clearState() {
    _exercises = [];
    _errorMessage = null;
    _isLoading = false;
    notifyListeners();
  }

  Future<void> refresh() async {
    await loadExercises();
  }
}
