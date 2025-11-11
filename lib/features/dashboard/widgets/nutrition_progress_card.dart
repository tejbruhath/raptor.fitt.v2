import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class NutritionProgressCard extends StatelessWidget {
  final double currentCalories;
  final double targetCalories;

  const NutritionProgressCard({
    super.key,
    required this.currentCalories,
    required this.targetCalories,
  });

  @override
  Widget build(BuildContext context) {
    final progress = currentCalories / targetCalories;
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Nutrition',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                currentCalories.toInt().toString(),
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 6, left: 4),
                child: Text(
                  '/ ${targetCalories.toInt()}',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress.clamp(0, 1),
              backgroundColor: AppColors.divider,
              valueColor: const AlwaysStoppedAnimation(AppColors.accent),
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }
}
