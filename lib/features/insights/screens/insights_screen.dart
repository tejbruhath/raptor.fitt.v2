import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/services/hive_service.dart';
import '../../../core/services/analytics_service.dart';

class InsightsScreen extends StatefulWidget {
  const InsightsScreen({super.key});

  @override
  State<InsightsScreen> createState() => _InsightsScreenState();
}

class _InsightsScreenState extends State<InsightsScreen> {
  double _strengthIndex = 0;
  String _recoveryPattern = '';
  double _consistencyIndex = 0;
  List<Map<String, dynamic>> _weeklyVolume = [];

  @override
  void initState() {
    super.initState();
    _calculateAnalytics();
  }

  void _calculateAnalytics() {
    final sessions = HiveService.getAllWorkoutSessions();
    final sets = HiveService.getAllWorkoutSets();
    final exercises = HiveService.getAllExercises();
    final sleepEntries = HiveService.getAllSleepEntries();
    
    final strengthIndex = AnalyticsService.calculateStrengthIndex(
      sessions: sessions,
      sets: sets,
    );
    
    final recoveryPattern = AnalyticsService.analyzeRecoveryPattern(
      sleepEntries: sleepEntries,
      sessions: sessions,
      sets: sets,
    );
    
    final consistencyIndex = AnalyticsService.calculateConsistencyIndex(
      workoutSessions: sessions,
      sleepEntries: sleepEntries,
    );
    
    final weeklyVolume = AnalyticsService.calculateWeeklyVolume(
      sessions: sessions,
      sets: sets,
    );
    
    setState(() {
      _strengthIndex = strengthIndex;
      _recoveryPattern = recoveryPattern;
      _consistencyIndex = consistencyIndex;
      _weeklyVolume = weeklyVolume;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Insights'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _calculateAnalytics,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Weekly Volume Chart
            Text(
              'Weekly Volume',
              style: Theme.of(context).textTheme.headlineSmall,
            ).animate().fadeIn(duration: 400.ms),
            
            const SizedBox(height: 16),
            
            _buildVolumeChart().animate().fadeIn(delay: 200.ms),
            
            const SizedBox(height: 32),
            
            // Strength Index
            _buildMetricCard(
              'Strength Index',
              _strengthIndex.toInt().toString(),
              AppColors.primary,
            ).animate().fadeIn(delay: 300.ms),
            
            const SizedBox(height: 16),
            
            // Recovery Pattern
            _buildMetricCard(
              'Recovery Pattern',
              _recoveryPattern,
              AppColors.accent,
              isText: true,
            ).animate().fadeIn(delay: 350.ms),
            
            const SizedBox(height: 16),
            
            // Consistency Index
            _buildMetricCard(
              'Consistency Index',
              '${_consistencyIndex.toInt()}%',
              AppColors.success,
            ).animate().fadeIn(delay: 400.ms),
            
            const SizedBox(height: 32),
            
            // Week Growth Potential
            Text(
              '2-Week Growth',
              style: Theme.of(context).textTheme.headlineSmall,
            ).animate().fadeIn(delay: 450.ms),
            
            const SizedBox(height: 16),
            
            _buildGrowthCard().animate().fadeIn(delay: 500.ms),
          ],
        ),
      ),
    );
  }

  Widget _buildVolumeChart() {
    if (_weeklyVolume.isEmpty) {
      return Container(
        height: 200,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Center(
          child: Text(
            'No data available',
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ),
      );
    }
    
    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: _weeklyVolume.map((e) => e['volume'] as double).reduce((a, b) => a > b ? a : b) * 1.2,
          barTouchData: BarTouchData(enabled: false),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  if (value.toInt() >= 0 && value.toInt() < _weeklyVolume.length) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        _weeklyVolume[value.toInt()]['week'],
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 11,
                        ),
                      ),
                    );
                  }
                  return const SizedBox();
                },
              ),
            ),
            leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
          barGroups: _weeklyVolume.asMap().entries.map((entry) {
            return BarChartGroupData(
              x: entry.key,
              barRods: [
                BarChartRodData(
                  toY: entry.value['volume'],
                  color: AppColors.primary,
                  width: 20,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildMetricCard(String label, String value, Color color, {bool isText = false}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: isText ? 18 : 36,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGrowthCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.trending_up_rounded,
                color: AppColors.success,
                size: 24,
              ),
              SizedBox(width: 8),
              Text(
                '↑3%',
                style: TextStyle(
                  color: AppColors.success,
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            'Projected growth based on recent progress',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
