import '../../features/models/workout_session_model.dart';
import '../../features/models/workout_set_model.dart';
import '../../features/models/sleep_entry_model.dart';
import '../../features/models/exercise_model.dart';

class AnalyticsService {
  // Calculate Strength Index (0-100 based on total volume and consistency)
  static double calculateStrengthIndex({
    required List<WorkoutSessionModel> sessions,
    required List<WorkoutSetModel> sets,
  }) {
    if (sessions.isEmpty) return 0;
    
    // Get last 30 days
    final now = DateTime.now();
    final recentSessions = sessions.where((s) => 
      s.startTime.isAfter(now.subtract(const Duration(days: 30)))
    ).toList();
    
    if (recentSessions.isEmpty) return 0;
    
    // Total volume in last 30 days
    double totalVolume = 0;
    for (var session in recentSessions) {
      final sessionSets = sets.where((s) => session.setIds.contains(s.id));
      totalVolume += sessionSets.fold(0.0, (sum, s) => sum + s.volume);
    }
    
    // Normalize to 0-100 scale (assuming 50,000 kg is excellent monthly volume)
    double volumeScore = (totalVolume / 50000) * 50;
    volumeScore = volumeScore.clamp(0, 50);
    
    // Consistency score (sessions per week)
    double avgSessionsPerWeek = recentSessions.length / 4.0;
    double consistencyScore = (avgSessionsPerWeek / 5) * 50; // 5 sessions/week = perfect
    consistencyScore = consistencyScore.clamp(0, 50);
    
    return (volumeScore + consistencyScore).clamp(0, 100);
  }

  // Calculate 2-Week Growth Potential (based on recent progress)
  static double calculate2WeekGrowthPotential({
    required List<WorkoutSetModel> sets,
    required String exerciseId,
  }) {
    final now = DateTime.now();
    final twoWeeksAgo = now.subtract(const Duration(days: 14));
    final fourWeeksAgo = now.subtract(const Duration(days: 28));
    
    final recent = sets.where((s) => 
      s.exerciseId == exerciseId && s.completedAt.isAfter(twoWeeksAgo)
    );
    
    final previous = sets.where((s) => 
      s.exerciseId == exerciseId && 
      s.completedAt.isAfter(fourWeeksAgo) &&
      s.completedAt.isBefore(twoWeeksAgo)
    );
    
    if (recent.isEmpty || previous.isEmpty) return 0;
    
    double recentMax = recent.map((s) => s.estimated1RM).reduce((a, b) => a > b ? a : b);
    double previousMax = previous.map((s) => s.estimated1RM).reduce((a, b) => a > b ? a : b);
    
    // Growth rate as percentage
    double growthRate = ((recentMax - previousMax) / previousMax) * 100;
    
    // Project 2 weeks forward
    return growthRate.clamp(-10, 10); // Cap at ±10%
  }

  // Estimate Personal Records (PRs) for each exercise
  static Map<String, double> estimatePRs({
    required List<WorkoutSetModel> sets,
    required List<ExerciseModel> exercises,
  }) {
    Map<String, double> prs = {};
    
    for (var exercise in exercises) {
      final exerciseSets = sets.where((s) => s.exerciseId == exercise.id);
      if (exerciseSets.isEmpty) continue;
      
      double maxEstimated1RM = exerciseSets
        .map((s) => s.estimated1RM)
        .reduce((a, b) => a > b ? a : b);
      
      prs[exercise.name] = maxEstimated1RM;
    }
    
    return prs;
  }

  // Analyze Recovery-Output Pattern
  static String analyzeRecoveryPattern({
    required List<SleepEntryModel> sleepEntries,
    required List<WorkoutSessionModel> sessions,
    required List<WorkoutSetModel> sets,
  }) {
    if (sleepEntries.isEmpty || sessions.isEmpty) return 'Insufficient data';
    
    // Calculate average recovery score
    double avgRecovery = sleepEntries
      .map((e) => e.recoveryScore)
      .reduce((a, b) => a + b) / sleepEntries.length;
    
    // Calculate average volume per session
    double avgVolume = 0;
    for (var session in sessions) {
      final sessionSets = sets.where((s) => session.setIds.contains(s.id));
      avgVolume += sessionSets.fold(0.0, (sum, s) => sum + s.volume);
    }
    avgVolume /= sessions.length;
    
    // Determine pattern
    if (avgRecovery >= 75 && avgVolume > 5000) {
      return 'High Recovery, High Output';
    } else if (avgRecovery >= 75 && avgVolume <= 5000) {
      return 'High Recovery, Moderate Output';
    } else if (avgRecovery < 75 && avgVolume > 5000) {
      return 'Low Recovery, High Output (Risk)';
    } else {
      return 'Low Recovery, Low Output';
    }
  }

  // Calculate Muscle Strength Tiers (categorize exercises by performance)
  static Map<String, List<String>> calculateMuscleStrengthTiers({
    required List<WorkoutSetModel> sets,
    required List<ExerciseModel> exercises,
  }) {
    Map<String, List<String>> tiers = {
      'Strong': [],
      'Developing': [],
      'Weak': [],
    };
    
    final prs = estimatePRs(sets: sets, exercises: exercises);
    
    // Define strength standards (example for 80kg person)
    final standards = {
      'Bench Press': {'strong': 100, 'developing': 70},
      'Squat': {'strong': 140, 'developing': 100},
      'Deadlift': {'strong': 160, 'developing': 120},
      'Overhead Press': {'strong': 60, 'developing': 40},
    };
    
    for (var exercise in exercises) {
      if (!prs.containsKey(exercise.name)) continue;
      
      double pr = prs[exercise.name]!;
      var standard = standards[exercise.name];
      
      if (standard != null) {
        if (pr >= standard['strong']!) {
          tiers['Strong']!.add(exercise.name);
        } else if (pr >= standard['developing']!) {
          tiers['Developing']!.add(exercise.name);
        } else {
          tiers['Weak']!.add(exercise.name);
        }
      }
    }
    
    return tiers;
  }

  // Calculate Weekly Volume
  static List<Map<String, dynamic>> calculateWeeklyVolume({
    required List<WorkoutSessionModel> sessions,
    required List<WorkoutSetModel> sets,
  }) {
    List<Map<String, dynamic>> weeklyData = [];
    
    // Get last 8 weeks
    final now = DateTime.now();
    for (int i = 7; i >= 0; i--) {
      final weekStart = now.subtract(Duration(days: (i * 7) + now.weekday - 1));
      final weekEnd = weekStart.add(const Duration(days: 7));
      
      final weekSessions = sessions.where((s) => 
        s.startTime.isAfter(weekStart) && s.startTime.isBefore(weekEnd)
      );
      
      double weekVolume = 0;
      for (var session in weekSessions) {
        final sessionSets = sets.where((s) => session.setIds.contains(s.id));
        weekVolume += sessionSets.fold(0.0, (sum, s) => sum + s.volume);
      }
      
      weeklyData.add({
        'week': 'W${8 - i}',
        'volume': weekVolume,
        'sessions': weekSessions.length,
      });
    }
    
    return weeklyData;
  }

  // Calculate Consistency Index (0-100)
  static double calculateConsistencyIndex({
    required List<WorkoutSessionModel> workoutSessions,
    required List<SleepEntryModel> sleepEntries,
    int days = 30,
  }) {
    final now = DateTime.now();
    final startDate = now.subtract(Duration(days: days));
    
    // Workout consistency
    final recentWorkouts = workoutSessions.where((s) => 
      s.startTime.isAfter(startDate)
    ).length;
    double workoutScore = (recentWorkouts / (days / 2)) * 50; // Expect workout every 2 days
    workoutScore = workoutScore.clamp(0, 50);
    
    // Sleep tracking consistency
    final recentSleep = sleepEntries.where((e) => 
      e.sleepDate.isAfter(startDate)
    ).length;
    double sleepScore = (recentSleep / days) * 50; // Expect daily tracking
    sleepScore = sleepScore.clamp(0, 50);
    
    return (workoutScore + sleepScore).clamp(0, 100);
  }

  // Recommend deload week (based on fatigue signals)
  static bool shouldDeload({
    required List<SleepEntryModel> sleepEntries,
    required List<WorkoutSessionModel> sessions,
    required List<WorkoutSetModel> sets,
  }) {
    final now = DateTime.now();
    final lastWeek = now.subtract(const Duration(days: 7));
    
    // Check recent sleep quality
    final recentSleep = sleepEntries.where((e) => 
      e.sleepDate.isAfter(lastWeek)
    );
    
    if (recentSleep.isEmpty) return false;
    
    double avgRecovery = recentSleep
      .map((e) => e.recoveryScore)
      .reduce((a, b) => a + b) / recentSleep.length;
    
    // Check volume trend (last 4 weeks)
    final weeklyVolumes = calculateWeeklyVolume(sessions: sessions, sets: sets);
    if (weeklyVolumes.length >= 4) {
      final lastFourWeeks = weeklyVolumes.sublist(weeklyVolumes.length - 4);
      final isIncreasing = lastFourWeeks[0]['volume'] < lastFourWeeks[3]['volume'];
      
      // Recommend deload if recovery is low and volume has been increasing
      if (avgRecovery < 60 && isIncreasing) {
        return true;
      }
    }
    
    return false;
  }

  // Generate focus areas (weak muscle groups to prioritize)
  static List<String> generateFocusAreas({
    required List<WorkoutSetModel> sets,
    required List<ExerciseModel> exercises,
  }) {
    final tiers = calculateMuscleStrengthTiers(sets: sets, exercises: exercises);
    
    // Return weak areas as focus
    return tiers['Weak']!;
  }
}
