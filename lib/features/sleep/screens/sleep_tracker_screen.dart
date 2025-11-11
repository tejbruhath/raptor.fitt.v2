import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:uuid/uuid.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/services/hive_service.dart';
import '../../models/sleep_entry_model.dart';

class SleepTrackerScreen extends StatefulWidget {
  const SleepTrackerScreen({super.key});

  @override
  State<SleepTrackerScreen> createState() => _SleepTrackerScreenState();
}

class _SleepTrackerScreenState extends State<SleepTrackerScreen> {
  double _hoursSlept = 7.0;
  int _sleepQuality = 7;
  int _sorenessLevel = 5;
  int _energyLevel = 7;
  int _stressLevel = 5;
  bool _hadRestlessness = false;

  Future<void> _saveSleepEntry() async {
    final user = HiveService.getCurrentUser();
    if (user == null) return;
    
    final entry = SleepEntryModel(
      id: 'sleep_${const Uuid().v4()}',
      userId: user.id,
      sleepDate: DateTime.now(),
      hoursSlept: _hoursSlept,
      sleepQuality: _sleepQuality,
      sorenessLevel: _sorenessLevel,
      energyLevel: _energyLevel,
      stressLevel: _stressLevel,
      hadRestlessness: _hadRestlessness,
      createdAt: DateTime.now(),
    );
    
    await HiveService.saveSleepEntry(entry);
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Sleep logged! Recovery score: ${entry.recoveryScore.toInt()}'),
          backgroundColor: AppColors.success,
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tempEntry = SleepEntryModel(
      id: 'temp',
      userId: 'temp',
      sleepDate: DateTime.now(),
      hoursSlept: _hoursSlept,
      sleepQuality: _sleepQuality,
      sorenessLevel: _sorenessLevel,
      energyLevel: _energyLevel,
      stressLevel: _stressLevel,
      createdAt: DateTime.now(),
    );
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sleep Tracker'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'How was your\nsleep?',
              style: Theme.of(context).textTheme.displaySmall,
            ).animate().fadeIn(duration: 400.ms),
            
            const SizedBox(height: 32),
            
            // Recovery Score Card
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary.withOpacity(0.8),
                    AppColors.accent.withOpacity(0.8),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  const Text(
                    'Recovery Score',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    tempEntry.recoveryScore.toInt().toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 56,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    tempEntry.recoveryStatus,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 200.ms).scale(begin: const Offset(0.9, 0.9)),
            
            const SizedBox(height: 32),
            
            // Hours Slept
            _buildSliderSection(
              'Hours Slept',
              _hoursSlept,
              0,
              12,
              (v) => setState(() => _hoursSlept = v),
              suffix: 'hrs',
            ).animate().fadeIn(delay: 300.ms),
            
            const SizedBox(height: 24),
            
            // Sleep Quality
            _buildRatingSection(
              'Quality',
              _sleepQuality,
              (v) => setState(() => _sleepQuality = v),
            ).animate().fadeIn(delay: 350.ms),
            
            const SizedBox(height: 24),
            
            // Soreness Level
            _buildRatingSection(
              'Soreness Rating',
              _sorenessLevel,
              (v) => setState(() => _sorenessLevel = v),
            ).animate().fadeIn(delay: 400.ms),
            
            const SizedBox(height: 24),
            
            // Energy Level
            _buildRatingSection(
              'Energy Level',
              _energyLevel,
              (v) => setState(() => _energyLevel = v),
            ).animate().fadeIn(delay: 450.ms),
            
            const SizedBox(height: 24),
            
            // Stress Level
            _buildRatingSection(
              'Stress Level',
              _stressLevel,
              (v) => setState(() => _stressLevel = v),
            ).animate().fadeIn(delay: 500.ms),
            
            const SizedBox(height: 24),
            
            // Restlessness toggle
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Had Restlessness?',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Switch(
                    value: _hadRestlessness,
                    onChanged: (v) => setState(() => _hadRestlessness = v),
                    activeThumbColor: AppColors.primary,
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 550.ms),
            
            const SizedBox(height: 32),
            
            // Save button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _saveSleepEntry,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                ),
                child: const Text(
                  'Save',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.3, end: 0),
            
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSliderSection(
    String label,
    double value,
    double min,
    double max,
    void Function(double) onChanged, {
    String suffix = '',
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              '${value.toStringAsFixed(1)}$suffix',
              style: const TextStyle(
                color: AppColors.primary,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SliderTheme(
          data: SliderThemeData(
            activeTrackColor: AppColors.primary,
            inactiveTrackColor: AppColors.divider,
            thumbColor: AppColors.primary,
            overlayColor: AppColors.primary.withOpacity(0.2),
            trackHeight: 6,
          ),
          child: Slider(
            value: value,
            min: min,
            max: max,
            divisions: ((max - min) * 2).toInt(),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  Widget _buildRatingSection(
    String label,
    int value,
    void Function(int) onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(10, (index) {
            final rating = index + 1;
            final isSelected = rating <= value;
            return GestureDetector(
              onTap: () => onChanged(rating),
              child: Container(
                width: 30,
                height: 40,
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : AppColors.surface,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    '$rating',
                    style: TextStyle(
                      color: isSelected ? Colors.white : AppColors.textSecondary,
                      fontSize: 14,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}
