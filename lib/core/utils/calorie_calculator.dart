import '../constants/app_constants.dart';

class CalorieCalculator {
  static double calculateBMR({
    required double weight,
    required double height,
    required int age,
    required String gender,
  }) {
    if (gender.toLowerCase() == 'male') {
      return (10 * weight) + (6.25 * height) - (5 * age) + 5;
    } else {
      return (10 * weight) + (6.25 * height) - (5 * age) - 161;
    }
  }

  static double calculateTDEE({
    required double bmr,
    required String activityLevel,
  }) {
    switch (activityLevel.toLowerCase()) {
      case 'sedentary':
        return bmr * 1.2;
      case 'light':
        return bmr * 1.375;
      case 'moderate':
        return bmr * 1.55;
      case 'active':
        return bmr * 1.725;
      case 'very active':
        return bmr * 1.9;
      default:
        return bmr * 1.2;
    }
  }

  static int calculateDailyGoal({
    required double tdee,
    required String goalType,
  }) {
    switch (goalType.toLowerCase()) {
      case 'lose weight':
        return (tdee - 500).round();
      case 'maintain':
        return tdee.round();
      case 'gain weight':
        return (tdee + 500).round();
      default:
        return tdee.round();
    }
  }

  static int calculateExerciseCalories({
    required String exerciseType,
    required int durationMinutes,
  }) {
    if (exerciseType.toLowerCase() == 'cardio') {
      return durationMinutes * AppConstants.cardioCaloriesPerMinute;
    } else {
      return durationMinutes * AppConstants.weightsCaloriesPerMinute;
    }
  }

  static Map<String, double> calculateMacros(int calories) {
    final proteinCalories = calories * AppConstants.proteinRatio;
    final carbsCalories = calories * AppConstants.carbsRatio;
    final fatCalories = calories * AppConstants.fatRatio;

    return {
      'protein': proteinCalories / AppConstants.proteinCaloriesPerGram,
      'carbs': carbsCalories / AppConstants.carbsCaloriesPerGram,
      'fat': fatCalories / AppConstants.fatCaloriesPerGram,
    };
  }

  static double calculateBMI({
    required double weight,
    required double height,
  }) {
    final heightInMeters = height / 100;
    return weight / (heightInMeters * heightInMeters);
  }

  static String getBMICategory(double bmi) {
    if (bmi < 18.5) {
      return 'Underweight';
    } else if (bmi < 25) {
      return 'Normal';
    } else if (bmi < 30) {
      return 'Overweight';
    } else {
      return 'Obese';
    }
  }
}
