import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'data/services/local_storage_service.dart';
import 'data/repositories/user_repository.dart';
import 'data/repositories/exercise_repository.dart';
import 'data/repositories/nutrition_repository.dart';
import 'data/repositories/chatbot_repository.dart';
import 'data/repositories/reminder_repository.dart';
import 'presentation/viewmodels/auth_viewmodel.dart';
import 'presentation/viewmodels/profile_viewmodel.dart';
import 'presentation/viewmodels/dashboard_viewmodel.dart';
import 'presentation/viewmodels/exercise_viewmodel.dart';
import 'presentation/viewmodels/nutrition_viewmodel.dart';
import 'presentation/viewmodels/chatbot_viewmodel.dart';
import 'presentation/viewmodels/reminder_viewmodel.dart';
import 'presentation/viewmodels/statistics_viewmodel.dart';
import 'core/theme/app_theme.dart';
import 'app.dart';
import 'presentation/screens/splash/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initializeDateFormatting('tr', null);

  final storageService = await LocalStorageService.getInstance();

  final userRepository = UserRepository(storageService);
  final exerciseRepository = ExerciseRepository(storageService);
  final nutritionRepository = NutritionRepository(storageService);
  final chatbotRepository = ChatbotRepository(storageService);
  final reminderRepository = ReminderRepository(storageService);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthViewModel(userRepository),
        ),

        ChangeNotifierProvider(
          create: (_) => ProfileViewModel(userRepository),
        ),

        ChangeNotifierProvider(
          create: (_) => DashboardViewModel(
            userRepository,
            exerciseRepository,
            nutritionRepository,
          ),
        ),

        ChangeNotifierProvider(
          create: (_) {
            final viewModel = ExerciseViewModel(exerciseRepository);
            viewModel.setDailyStatsService(nutritionRepository, userRepository);
            return viewModel;
          },
        ),

        ChangeNotifierProvider(
          create: (_) {
            final viewModel = NutritionViewModel(nutritionRepository, userRepository);
            viewModel.setDailyStatsService(exerciseRepository);
            return viewModel;
          },
        ),

        ChangeNotifierProvider(
          create: (_) => ChatbotViewModel(chatbotRepository, userRepository),
        ),

        ChangeNotifierProvider(
          create: (_) => ReminderViewModel(reminderRepository),
        ),

        ChangeNotifierProvider(
          create: (_) => StatisticsViewModel(
            exerciseRepository,
            nutritionRepository,
            userRepository,
          ),
        ),
      ],
      child: const FitLifeApp(),
    ),
  );
}

class FitLifeApp extends StatefulWidget {
  const FitLifeApp({Key? key}) : super(key: key);

  @override
  State<FitLifeApp> createState() => _FitLifeAppState();
}

class _FitLifeAppState extends State<FitLifeApp> {
  bool _showSplash = true;

  void _onSplashComplete() {
    setState(() {
      _showSplash = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FitLife',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: _showSplash
          ? SplashScreen(onAnimationComplete: _onSplashComplete)
          : const App(),
    );
  }
}
