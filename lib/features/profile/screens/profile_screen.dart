import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/services/hive_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    final user = HiveService.getCurrentUser();
    
    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('No user data')),
      );
    }
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_rounded),
            onPressed: () => context.push('/settings'),
            tooltip: 'Settings',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Profile header
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.white.withOpacity(0.2),
                    child: Text(
                      user.name[0].toUpperCase(),
                      style: const TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    user.name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildStatBadge('${user.currentStreak}', 'Day Streak'),
                      const SizedBox(width: 16),
                      _buildStatBadge(user.experienceLevel, 'Level'),
                    ],
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 400.ms).scale(begin: const Offset(0.95, 0.95)),
            
            const SizedBox(height: 24),
            
            // Achievements section
            _buildSectionTitle('Achievements').animate().fadeIn(delay: 200.ms),
            const SizedBox(height: 12),
            _buildAchievementCard(
              'Current Streak',
              '${user.currentStreak} days',
            ).animate().fadeIn(delay: 250.ms),
            const SizedBox(height: 12),
            _buildAchievementCard(
              'Longest Streak',
              '${user.longestStreak} days',
            ).animate().fadeIn(delay: 300.ms),
            
            const SizedBox(height: 24),
            
            // Preparation Progress section
            _buildSectionTitle('Preparation Progress').animate().fadeIn(delay: 350.ms),
            const SizedBox(height: 12),
            _buildProgressCard(
              'Current Weight',
              '${user.weight.toStringAsFixed(1)} kg',
            ).animate().fadeIn(delay: 400.ms),
            const SizedBox(height: 12),
            _buildProgressCard(
              'Goal',
              user.fitnessGoal.toUpperCase(),
            ).animate().fadeIn(delay: 450.ms),
            
            const SizedBox(height: 24),
            
            // Body Measurements
            _buildSectionTitle('Body Measurements').animate().fadeIn(delay: 500.ms),
            const SizedBox(height: 12),
            _buildMeasurementCard(
              'Height',
              '${user.height.toInt()} cm',
            ).animate().fadeIn(delay: 550.ms),
            const SizedBox(height: 12),
            _buildMeasurementCard(
              'Weight',
              '${user.weight.toStringAsFixed(1)} kg',
            ).animate().fadeIn(delay: 600.ms),
            
            const SizedBox(height: 32),
            
            // Settings button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton.icon(
                onPressed: () {
                  // Settings
                },
                icon: const Icon(Icons.settings_outlined),
                label: const Text('Settings'),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.divider),
                ),
              ),
            ).animate().fadeIn(delay: 650.ms),
            
            const SizedBox(height: 12),
            
            // Logout button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: TextButton.icon(
                onPressed: () async {
                  await HiveService.clearAllData();
                  if (context.mounted) {
                    context.go('/onboarding');
                  }
                },
                icon: const Icon(Icons.logout_rounded, color: AppColors.error),
                label: const Text(
                  'Logout',
                  style: TextStyle(color: AppColors.error),
                ),
              ),
            ).animate().fadeIn(delay: 700.ms),
            
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildStatBadge(String value, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: Theme.of(context).textTheme.headlineSmall,
      ),
    );
  }

  Widget _buildAchievementCard(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(
                Icons.emoji_events_rounded,
                color: AppColors.primary,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                label,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.primary,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressCard(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMeasurementCard(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16,
            ),
          ),
          Row(
            children: [
              Text(
                value,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textSecondary,
                size: 20,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
