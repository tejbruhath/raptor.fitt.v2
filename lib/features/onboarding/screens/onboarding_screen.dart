import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/services/hive_service.dart';
import '../../../core/services/supabase_service.dart';
import '../../models/user_model.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  final _bodyFatController = TextEditingController();
  
  String _sex = 'Male';
  String _fitnessGoal = 'bulk';
  String _experienceLevel = 'intermediate';

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _bodyFatController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      // Get authenticated user ID from Supabase
      final authUser = Supabase.instance.client.auth.currentUser;
      if (authUser == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please sign in first'),
              backgroundColor: AppColors.error,
            ),
          );
        }
        return;
      }

      final user = UserModel(
        id: authUser.id, // Use Supabase user ID
        name: _nameController.text,
        age: int.parse(_ageController.text),
        sex: _sex,
        height: double.parse(_heightController.text),
        weight: double.parse(_weightController.text),
        bodyFatPercentage: _bodyFatController.text.isEmpty 
            ? null 
            : double.parse(_bodyFatController.text),
        fitnessGoal: _fitnessGoal,
        experienceLevel: _experienceLevel,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Calculate TDEE and macros
      final macros = user.calculateMacros();
      final updatedUser = user.copyWith(
        tdee: user.calculateTDEE(),
        targetCalories: macros['calories'],
        targetProtein: macros['protein'],
        targetCarbs: macros['carbs'],
        targetFat: macros['fat'],
      );

      // Save to Hive first (offline-first)
      await HiveService.saveUser(updatedUser);

      // Save to Supabase
      try {
        await SupabaseService.createUserProfile(updatedUser.toJson());
      } catch (e) {
        print('Failed to sync user profile to Supabase: $e');
        // Don't block user - will sync later
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile created successfully! 🎉'),
            backgroundColor: AppColors.success,
          ),
        );
        context.go('/dashboard');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                Text(
                  'Let\'s Get Started',
                  style: Theme.of(context).textTheme.displayLarge,
                ).animate().fadeIn(duration: 600.ms).slideX(begin: -0.2, end: 0),
                
                const SizedBox(height: 40),
                
                // Name field
                _buildTextField(
                  controller: _nameController,
                  label: 'Name',
                  validator: (v) => v!.isEmpty ? 'Required' : null,
                ).animate().fadeIn(delay: 100.ms, duration: 400.ms),
                
                const SizedBox(height: 16),
                
                // Age field
                _buildTextField(
                  controller: _ageController,
                  label: 'Age',
                  keyboardType: TextInputType.number,
                  validator: (v) => v!.isEmpty ? 'Required' : null,
                ).animate().fadeIn(delay: 150.ms, duration: 400.ms),
                
                const SizedBox(height: 16),
                
                // Sex selector
                _buildSexSelector().animate().fadeIn(delay: 200.ms, duration: 400.ms),
                
                const SizedBox(height: 16),
                
                // Height field
                _buildTextField(
                  controller: _heightController,
                  label: 'Height (cm)',
                  keyboardType: TextInputType.number,
                  validator: (v) => v!.isEmpty ? 'Required' : null,
                ).animate().fadeIn(delay: 250.ms, duration: 400.ms),
                
                const SizedBox(height: 16),
                
                // Weight field
                _buildTextField(
                  controller: _weightController,
                  label: 'Weight (kg)',
                  keyboardType: TextInputType.number,
                  validator: (v) => v!.isEmpty ? 'Required' : null,
                ).animate().fadeIn(delay: 300.ms, duration: 400.ms),
                
                const SizedBox(height: 16),
                
                // Body fat field (optional)
                _buildTextField(
                  controller: _bodyFatController,
                  label: 'Estimated BF%',
                  keyboardType: TextInputType.number,
                ).animate().fadeIn(delay: 350.ms, duration: 400.ms),
                
                const SizedBox(height: 24),
                
                // Fitness goal
                _buildDropdown(
                  label: 'Fitness Goal',
                  value: _fitnessGoal,
                  items: const [
                    DropdownMenuItem(value: 'bulk', child: Text('Bulk')),
                    DropdownMenuItem(value: 'cut', child: Text('Cut')),
                    DropdownMenuItem(value: 'recomp', child: Text('Recomp')),
                    DropdownMenuItem(value: 'maintain', child: Text('Maintain')),
                  ],
                  onChanged: (v) => setState(() => _fitnessGoal = v!),
                ).animate().fadeIn(delay: 400.ms, duration: 400.ms),
                
                const SizedBox(height: 16),
                
                // Experience level
                _buildDropdown(
                  label: 'Experience Level',
                  value: _experienceLevel,
                  items: const [
                    DropdownMenuItem(value: 'beginner', child: Text('Beginner')),
                    DropdownMenuItem(value: 'intermediate', child: Text('Intermediate')),
                    DropdownMenuItem(value: 'advanced', child: Text('Advanced')),
                  ],
                  onChanged: (v) => setState(() => _experienceLevel = v!),
                ).animate().fadeIn(delay: 450.ms, duration: 400.ms),
                
                const SizedBox(height: 40),
                
                // Continue button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      'Continue',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ).animate().fadeIn(delay: 500.ms, duration: 400.ms).scale(begin: const Offset(0.9, 0.9)),
                
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      style: const TextStyle(fontSize: 16, color: AppColors.textPrimary),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: AppColors.textSecondary),
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      ),
    );
  }

  Widget _buildSexSelector() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildSexOption('Male'),
          ),
          Expanded(
            child: _buildSexOption('Female'),
          ),
        ],
      ),
    );
  }

  Widget _buildSexOption(String value) {
    final isSelected = _sex == value;
    return GestureDetector(
      onTap: () => setState(() => _sex = value),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            value,
            style: TextStyle(
              color: isSelected ? Colors.white : AppColors.textSecondary,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required String value,
    required List<DropdownMenuItem<String>> items,
    required void Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              items: items,
              onChanged: onChanged,
              dropdownColor: AppColors.surface,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
