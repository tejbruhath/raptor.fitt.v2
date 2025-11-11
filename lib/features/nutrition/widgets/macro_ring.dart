import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class MacroRing extends StatelessWidget {
  final double value;
  final double target;
  final String label;
  final Color color;

  const MacroRing({
    super.key,
    required this.value,
    required this.target,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final progress = (value / target).clamp(0, 1);
    
    return Column(
      children: [
        SizedBox(
          width: 80,
          height: 80,
          child: Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 70,
                height: 70,
                child: CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 8,
                  backgroundColor: AppColors.divider,
                  valueColor: AlwaysStoppedAnimation(color),
                ),
              ),
              Text(
                '${value.toInt()}g',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
