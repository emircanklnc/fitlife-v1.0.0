import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/profile_viewmodel.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../widgets/weight_chart.dart';
import '../../widgets/custom_text_field.dart';
import '../statistics/statistics_screen.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/validators.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Consumer<ProfileViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final profile = viewModel.userProfile;
          if (profile == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.person_outline_rounded,
                    size: 64,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    AppStrings.noProfileData,
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  if (viewModel.errorMessage != null) ...[
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Text(
                        viewModel.errorMessage!,
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.error,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () {
                          viewModel.loadUserProfile();
                        },
                        icon: const Icon(Icons.refresh_rounded),
                        label: const Text('Yeniden Dene'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                        ),
                      ),
                      if (viewModel.errorMessage != null &&
                          (viewModel.errorMessage!.contains('token') ||
                           viewModel.errorMessage!.contains('Token') ||
                           viewModel.errorMessage!.contains('giriş'))) ...[
                        const SizedBox(width: 12),
                        ElevatedButton.icon(
                          onPressed: () async {
                            final authViewModel = context.read<AuthViewModel>();
                            await authViewModel.logout();
                          },
                          icon: const Icon(Icons.login_rounded),
                          label: const Text('Tekrar Giriş Yap'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.error,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            );
          }

          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.primary.withOpacity(0.1),
                  AppColors.background,
                ],
              ),
            ),
            child: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppStrings.profile,
                      style: AppTextStyles.h2.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'İlerlemenizi takip edin',
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 24),

                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: AppColors.cardBackground,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.03),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 64,
                                height: 64,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      AppColors.primary,
                                      AppColors.secondary,
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Center(
                                  child: Icon(
                                    Icons.person_rounded,
                                    color: Colors.white,
                                    size: 32,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      profile.name,
                                      style: AppTextStyles.h3.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Premium Üye',
                                      style: AppTextStyles.caption.copyWith(
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                decoration: BoxDecoration(
                                  color: AppColors.background,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: IconButton(
                                  icon: Icon(
                                    Icons.edit_rounded,
                                    color: AppColors.textSecondary,
                                  ),
                                  onPressed: () => _showEditProfileDialog(context),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),

                          GridView.count(
                            crossAxisCount: 2,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            mainAxisSpacing: 16,
                            crossAxisSpacing: 9,
                            childAspectRatio: 1.3,
                            children: [
                              _buildStatCard(
                                context,
                                icon: Icons.calendar_today_rounded,
                                label: 'Yaş',
                                value: '${profile.age}',
                                gradientColors: [
                                  AppColors.primary.withOpacity(0.1),
                                  Colors.transparent,
                                ],
                                iconColor: AppColors.primary,
                              ),
                              _buildStatCard(
                                context,
                                icon: Icons.straighten_rounded,
                                label: 'Boy',
                                value: profile.height != null 
                                    ? '${profile.height!.toInt()} cm' 
                                    : 'Boş',
                                gradientColors: [
                                  AppColors.secondary.withOpacity(0.1),
                                  Colors.transparent,
                                ],
                                iconColor: AppColors.secondary,
                              ),
                              _buildStatCard(
                                context,
                                icon: Icons.monitor_weight_rounded,
                                label: 'Kilo',
                                value: profile.weight != null 
                                    ? '${profile.weight!.toInt()} kg' 
                                    : 'Boş',
                                gradientColors: [
                                  AppColors.primary.withOpacity(0.1),
                                  Colors.transparent,
                                ],
                                iconColor: AppColors.primary,
                              ),
                              _buildStatCard(
                                context,
                                icon: Icons.person_outline_rounded,
                                label: 'Cinsiyet',
                                value: profile.gender == 'Male' ? AppStrings.male : AppStrings.female,
                                gradientColors: [
                                  AppColors.secondary.withOpacity(0.1),
                                  Colors.transparent,
                                ],
                                iconColor: AppColors.secondary,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: AppColors.cardBackground,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.03),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppStrings.weightProgress,
                            style: AppTextStyles.bodyBold.copyWith(
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Son 6 ay',
                            style: AppTextStyles.small.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 24),
                          SizedBox(
                            height: 250,
                            child: WeightChart(
                              weightHistory: viewModel.weightHistory,
                              targetWeight: viewModel.targetWeight,
                            ),
                          ),
                          const SizedBox(height: 24),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                                colors: [
                                  AppColors.primary.withOpacity(0.1),
                                  AppColors.secondary.withOpacity(0.1),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Toplam İlerleme',
                                      style: AppTextStyles.small.copyWith(
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      viewModel.totalProgress,
                                      style: AppTextStyles.h2.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      'Hedef',
                                      style: AppTextStyles.small.copyWith(
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      viewModel.targetWeight != null
                                          ? '${viewModel.targetWeight!.toInt()} kg'
                                          : 'Belirlenmedi',
                                      style: AppTextStyles.h2.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.secondary,
                                      ),
                                    ),
                                    if (viewModel.targetWeight != null && profile.weight != null) ...[
                                      const SizedBox(height: 4),
                                      Text(
                                        viewModel.targetProgress,
                                        style: AppTextStyles.small.copyWith(
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),

                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const StatisticsScreen(),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.bar_chart_rounded),
                              label: const Text(AppStrings.statistics),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),

                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: () => _showLogoutDialog(context),
                              icon: const Icon(Icons.logout_rounded),
                              label: const Text('Çıkış Yap'),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                side: BorderSide(
                                  color: AppColors.error.withOpacity(0.5),
                                  width: 1.5,
                                ),
                                foregroundColor: AppColors.error,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddWeightDialog(context),
        icon: const Icon(Icons.add_rounded),
        label: const Text(AppStrings.addWeight),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required List<Color> gradientColors,
    required Color iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradientColors,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 16,
                color: iconColor,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: AppTextStyles.small.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          Text(
            value,
            style: AppTextStyles.h2.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  String _getBMICategory(String category) {
    switch (category.toLowerCase()) {
      case 'underweight':
        return AppStrings.underweight;
      case 'normal':
        return AppStrings.normal;
      case 'overweight':
        return AppStrings.overweight;
      case 'obese':
        return AppStrings.obese;
      default:
        return category;
    }
  }

  void _showEditProfileDialog(BuildContext context) {
    final viewModel = context.read<ProfileViewModel>();
    final profile = viewModel.userProfile;
    if (profile == null) return;

    final nameController = TextEditingController(text: profile.name);
    final ageController = TextEditingController(text: profile.age.toString());
    final heightController = TextEditingController(text: profile.height.toString());
    final targetWeightController = TextEditingController(
      text: profile.targetWeight != null ? profile.targetWeight!.toStringAsFixed(1) : '',
    );
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        insetPadding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
        title: const Text(
          AppStrings.editProfile,
          style: TextStyle(fontSize: 18),
        ),
        titlePadding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
        contentPadding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
        actionsPadding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        content: SizedBox(
          width: double.minPositive,
          child: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CustomTextField(
                    label: AppStrings.name,
                    controller: nameController,
                    validator: Validators.validateName,
                  ),
                  const SizedBox(height: 12),
                  CustomTextField(
                    label: AppStrings.age,
                    controller: ageController,
                    keyboardType: TextInputType.number,
                    validator: Validators.validateAge,
                  ),
                  const SizedBox(height: 12),
                  CustomTextField(
                    label: '${AppStrings.height} (${AppStrings.cm})',
                    controller: heightController,
                    keyboardType: TextInputType.number,
                    validator: Validators.validateHeight,
                  ),
                  const SizedBox(height: 12),
                  CustomTextField(
                    label: 'Hedef Kilo (${AppStrings.kg})',
                    controller: targetWeightController,
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return null;
                      }
                      return Validators.validateWeight(value);
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            child: const Text(AppStrings.cancel),
          ),
          TextButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                await viewModel.updateProfile(
                  name: nameController.text,
                  age: int.parse(ageController.text),
                  height: double.parse(heightController.text),
                  targetWeight: targetWeightController.text.isNotEmpty
                      ? double.parse(targetWeightController.text)
                      : null,
                );
                if (context.mounted) Navigator.pop(context);
              }
            },
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            child: const Text(AppStrings.save),
          ),
        ],
      ),
    );
  }

  void _showAddWeightDialog(BuildContext context) {
    final viewModel = context.read<ProfileViewModel>();
    final weightController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        insetPadding: const EdgeInsets.symmetric(horizontal: 40, vertical: 304),
        title: const Text(
          AppStrings.addWeightEntry,
          style: TextStyle(fontSize: 18),
        ),
        titlePadding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
        contentPadding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
        actionsPadding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        content: SizedBox(
          width: double.minPositive,
          child: Form(
            key: formKey,
            child: CustomTextField(
              label: '${AppStrings.weight} (${AppStrings.kg})',
              controller: weightController,
              keyboardType: TextInputType.number,
              validator: Validators.validateWeight,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            child: const Text(AppStrings.cancel),
          ),
          TextButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                final weight = double.parse(weightController.text);
                final success = await viewModel.addWeightEntry(weight);
                
                if (context.mounted) {
                  Navigator.pop(context);

                  if (success) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('$weight kg başarıyla eklendi'),
                        duration: const Duration(seconds: 2),
                        backgroundColor: AppColors.secondary,
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Kilo eklenirken bir hata oluştu'),
                        duration: const Duration(seconds: 2),
                        backgroundColor: AppColors.error,
                      ),
                    );
                  }
                }
              }
            },
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            child: const Text(AppStrings.add),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        insetPadding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
        titlePadding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
        contentPadding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
        actionsPadding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        title: Row(
          children: [
            Icon(
              Icons.logout_rounded,
              color: AppColors.error,
              size: 22,
            ),
            const SizedBox(width: 10),
            const Text(
              'Çıkış Yap',
              style: TextStyle(fontSize: 18),
            ),
          ],
        ),
        content: SizedBox(
          width: double.minPositive,
          child: const Text(
            'Çıkış yapmak istediğinize emin misiniz?',
            style: TextStyle(fontSize: 14),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            child: Text(
              'İptal',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              final authViewModel = context.read<AuthViewModel>();
              
              if (context.mounted) {
                Navigator.pop(context);
              }

              await authViewModel.logout();

            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Çıkış Yap',
              style: TextStyle(color: Colors.white, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}
