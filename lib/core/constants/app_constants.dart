
class AppConstants {
  static const String appName = 'FitLife';
  static const String appVersion = '1.0.0';

  static const String userProfileKey = 'user_profile';
  static const String isLoggedInKey = 'is_logged_in';
  static const String exercisesKey = 'exercises';
  static const String foodLogsKey = 'food_logs';
  static const String waterIntakeKey = 'water_intake';
  static const String chatHistoryKey = 'chat_history';
  static const String remindersKey = 'reminders';

  static const int defaultCaloriesGoal = 2000;
  static const int defaultWaterGoal = 8;
  static const int defaultExerciseGoal = 60;

  static const int cardioCaloriesPerMinute = 10;
  static const int weightsCaloriesPerMinute = 6;

  static const double proteinRatio = 0.25;
  static const double carbsRatio = 0.50;
  static const double fatRatio = 0.25;

  static const int proteinCaloriesPerGram = 4;
  static const int carbsCaloriesPerGram = 4;
  static const int fatCaloriesPerGram = 9;

  static const String backendBaseUrl = 'https://proje.cloud/api/api';

  static const String tokenKey = 'auth_token';
  static const String tokenSavedAtKey = 'token_saved_at';

  static const String geminiApiKey = '';

  static const String geminiModelName = 'gemini-2.5-flash';

  static const double defaultPadding = 16.0;
  static const double largePadding = 24.0;
  static const double xlPadding = 32.0;
  static const double defaultBorderRadius = 16.0;
  static const double largeBorderRadius = 24.0;
}
