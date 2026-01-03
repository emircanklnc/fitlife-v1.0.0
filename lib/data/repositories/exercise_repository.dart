import 'package:flutter/foundation.dart';
import '../models/exercise.dart';
import '../services/local_storage_service.dart';
import '../services/api_service.dart';
import '../../core/constants/app_constants.dart';
import 'package:intl/intl.dart';

class ExerciseRepository {
  final LocalStorageService _storageService;

  ExerciseRepository(this._storageService);

  Future<List<Exercise>> getExercisesByDate(DateTime date) async {
    try {
      final formattedDate = DateFormat('yyyy-MM-dd').format(date);
      final response = await ApiService.get('/exercises.php?date=$formattedDate');
      
      if (response['success'] == true && response['exercises'] != null) {
        final exercisesData = response['exercises'] as List;
        final exercises = exercisesData.map((data) {
          return Exercise(
            id: data['id'] as String,
            date: DateTime.parse(data['date'] as String),
            type: data['type'] as String,
            name: data['name'] as String,
            duration: data['duration'] as int,
            caloriesBurned: data['calories_burned'] as int,
          );
        }).toList();

        await _saveExercisesToLocal(exercises, date);
        
        return exercises;
      }

      return _getExercisesFromLocal(date);
    } catch (e) {
      debugPrint('Backend\'den egzersiz çekilemedi, local\'den okunuyor: $e');
      return _getExercisesFromLocal(date);
    }
  }

  Future<bool> addExercise(Exercise exercise) async {
    try {
      final formattedDate = DateFormat('yyyy-MM-dd').format(exercise.date);
      final response = await ApiService.post('/exercises.php', {
        'id': exercise.id,
        'date': formattedDate,
        'type': exercise.type,
        'name': exercise.name,
        'duration': exercise.duration,
        'calories_burned': exercise.caloriesBurned,
      });
      
      if (response['success'] == true) {
        final exercises = _getExercisesFromLocal(exercise.date);
        exercises.add(exercise);
        await _saveExercisesToLocal(exercises, exercise.date);
        return true;
      }
      
      return false;
    } catch (e) {
      debugPrint('Egzersiz eklenemedi: $e');
      return false;
    }
  }

  Future<bool> deleteExercise(String exerciseId, DateTime date) async {
    try {
      final formattedDate = DateFormat('yyyy-MM-dd').format(date);
      final response = await ApiService.delete('/exercises.php?id=$exerciseId&date=$formattedDate');
      
      if (response['success'] == true) {
        final exercises = _getExercisesFromLocal(date);
        exercises.removeWhere((e) => e.id == exerciseId);
        await _saveExercisesToLocal(exercises, date);
        return true;
      }
      
      return false;
    } catch (e) {
      debugPrint('Egzersiz silinemedi: $e');
      return false;
    }
  }

  Future<int> getTodayCaloriesBurned() async {
    final todayExercises = await getExercisesByDate(DateTime.now());
    int total = 0;
    for (var exercise in todayExercises) {
      total += exercise.caloriesBurned;
    }
    return total;
  }

  Future<int> getTodayExerciseMinutes() async {
    final todayExercises = await getExercisesByDate(DateTime.now());
    int total = 0;
    for (var exercise in todayExercises) {
      total += exercise.duration;
    }
    return total;
  }


  List<Exercise> _getExercisesFromLocal(DateTime date) {
    final jsonList = _storageService.getJsonList(AppConstants.exercisesKey);
    if (jsonList == null) return [];
    
    final allExercises = jsonList.map((json) => Exercise.fromJson(json)).toList();
    return allExercises.where((exercise) {
      return exercise.date.year == date.year &&
          exercise.date.month == date.month &&
          exercise.date.day == date.day;
    }).toList();
  }

  Future<bool> _saveExercisesToLocal(List<Exercise> exercises, DateTime date) async {
    final jsonList = _storageService.getJsonList(AppConstants.exercisesKey);
    List<Map<String, dynamic>> allExercises = jsonList ?? [];

    allExercises.removeWhere((json) {
      final exercise = Exercise.fromJson(json);
      return exercise.date.year == date.year &&
          exercise.date.month == date.month &&
          exercise.date.day == date.day;
    });

    allExercises.addAll(exercises.map((e) => e.toJson()));
    
    return await _storageService.saveJsonList(AppConstants.exercisesKey, allExercises);
  }
}
