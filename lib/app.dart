import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'presentation/viewmodels/auth_viewmodel.dart';
import 'presentation/viewmodels/profile_viewmodel.dart';
import 'presentation/viewmodels/dashboard_viewmodel.dart';
import 'presentation/viewmodels/exercise_viewmodel.dart';
import 'presentation/viewmodels/nutrition_viewmodel.dart';
import 'presentation/viewmodels/reminder_viewmodel.dart';
import 'presentation/viewmodels/chatbot_viewmodel.dart';
import 'presentation/screens/auth/login_screen.dart';
import 'presentation/screens/dashboard/dashboard_screen.dart';
import 'presentation/screens/profile/profile_screen.dart';
import 'presentation/screens/exercise/exercise_screen.dart';
import 'presentation/screens/nutrition/nutrition_screen.dart';
import 'presentation/screens/chatbot/chatbot_screen.dart';
import 'core/theme/app_colors.dart';
import 'core/theme/app_text_styles.dart';
import 'core/constants/app_strings.dart';

class App extends StatefulWidget {
  const App({Key? key}) : super(key: key);

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> with SingleTickerProviderStateMixin {
  int _currentIndex = 0;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onTabTapped(int index) {
    if (_currentIndex != index) {
      setState(() {
        _currentIndex = index;
      });

      _animationController.reset();
      _animationController.forward();
    }
  }

  void setCurrentIndex(int index) {
    _onTabTapped(index);
  }

  final List<Widget> _screens = [
    const DashboardScreen(),
    const ExerciseScreen(),
    const NutritionScreen(),
    const ChatbotScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final authViewModel = context.watch<AuthViewModel>();
    final isLoggedIn = authViewModel.isLoggedIn;

    if (!isLoggedIn) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        try {
          final profileViewModel = context.read<ProfileViewModel>();
          profileViewModel.clearProfile();

          final chatbotViewModel = context.read<ChatbotViewModel>();
          chatbotViewModel.clearHistory();

          final reminderViewModel = context.read<ReminderViewModel>();
          reminderViewModel.clearState();
        } catch (e) {
        }
      });
      return const LoginScreen();
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        final profileViewModel = context.read<ProfileViewModel>();
        if (profileViewModel.userProfile == null && !profileViewModel.isLoading) {
          profileViewModel.loadUserProfile();
        }

        final dashboardViewModel = context.read<DashboardViewModel>();
        dashboardViewModel.clearState();
        dashboardViewModel.refresh();

        final exerciseViewModel = context.read<ExerciseViewModel>();
        exerciseViewModel.clearState();
        exerciseViewModel.refresh();

        final nutritionViewModel = context.read<NutritionViewModel>();
        nutritionViewModel.clearState();
        nutritionViewModel.refresh();

        final chatbotViewModel = context.read<ChatbotViewModel>();
        chatbotViewModel.clearHistory();

        final reminderViewModel = context.read<ReminderViewModel>();
        reminderViewModel.clearState();
      } catch (e) {
        debugPrint('ViewModel refresh hatası: $e');
      }
    });

    return Scaffold(
      backgroundColor: AppColors.background,

      body: FadeTransition(
        opacity: _fadeAnimation,
        child: IndexedStack(
          index: _currentIndex,
          children: _screens,
        ),
      ),

      bottomNavigationBar: _buildModernBottomNav(),
    );
  }

  Widget _buildModernBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                index: 0,
                icon: Icons.home_rounded,
                label: AppStrings.dashboard,
              ),
              _buildNavItem(
                index: 1,
                icon: Icons.fitness_center_rounded,
                label: AppStrings.exercise,
              ),
              _buildNavItem(
                index: 2,
                icon: Icons.restaurant_rounded,
                label: AppStrings.nutrition,
              ),
              _buildNavItem(
                index: 3,
                icon: Icons.chat_bubble_rounded,
                label: AppStrings.chat,
              ),
              _buildNavItem(
                index: 4,
                icon: Icons.person_rounded,
                label: AppStrings.profile,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required String label,
  }) {
    final isSelected = _currentIndex == index;
    
    return Expanded(
      child: InkWell(
        onTap: () => _onTabTapped(index),
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primary.withOpacity(0.1)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  size: 26,
                  color: isSelected ? AppColors.primary : AppColors.grey400,
                ),
              ),
              const SizedBox(height: 4),

              Text(
                label,
                style: AppTextStyles.small.copyWith(
                  color: isSelected ? AppColors.primary : AppColors.grey400,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
