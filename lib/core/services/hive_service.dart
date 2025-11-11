import 'package:hive_flutter/hive_flutter.dart';
import '../../features/models/user_model.dart';
import '../../features/models/exercise_model.dart';
import '../../features/models/workout_set_model.dart';
import '../../features/models/workout_session_model.dart';
import '../../features/models/nutrition_entry_model.dart';
import '../../features/models/sleep_entry_model.dart';

class HiveService {
  static const String userBox = 'users';
  static const String exerciseBox = 'exercises';
  static const String workoutSetBox = 'workout_sets';
  static const String workoutSessionBox = 'workout_sessions';
  static const String nutritionBox = 'nutrition_entries';
  static const String sleepBox = 'sleep_entries';
  static const String settingsBox = 'settings';

  static Future<void> init() async {
    // Register adapters
    Hive.registerAdapter(UserModelAdapter());
    Hive.registerAdapter(ExerciseModelAdapter());
    Hive.registerAdapter(WorkoutSetModelAdapter());
    Hive.registerAdapter(WorkoutSessionModelAdapter());
    Hive.registerAdapter(NutritionEntryModelAdapter());
    Hive.registerAdapter(SleepEntryModelAdapter());

    // Open boxes
    await Hive.openBox<UserModel>(userBox);
    await Hive.openBox<ExerciseModel>(exerciseBox);
    await Hive.openBox<WorkoutSetModel>(workoutSetBox);
    await Hive.openBox<WorkoutSessionModel>(workoutSessionBox);
    await Hive.openBox<NutritionEntryModel>(nutritionBox);
    await Hive.openBox<SleepEntryModel>(sleepBox);
    await Hive.openBox(settingsBox);
    
    // Seed default exercises if empty
    await _seedDefaultExercises();
  }

  static Future<void> _seedDefaultExercises() async {
    final box = Hive.box<ExerciseModel>(exerciseBox);
    if (box.isEmpty) {
      final defaultExercises = [
        // Chest
        ExerciseModel(
          id: 'ex_bench_press',
          name: 'Bench Press',
          category: 'chest',
          muscleGroup: 'Pectorals',
          type: 'compound',
          equipment: 'barbell',
          description: 'Flat barbell bench press',
        ),
        ExerciseModel(
          id: 'ex_incline_bench',
          name: 'Incline Bench Press',
          category: 'chest',
          muscleGroup: 'Upper Pectorals',
          type: 'compound',
          equipment: 'barbell',
        ),
        ExerciseModel(
          id: 'ex_dumbbell_press',
          name: 'Dumbbell Press',
          category: 'chest',
          muscleGroup: 'Pectorals',
          type: 'compound',
          equipment: 'dumbbell',
        ),
        ExerciseModel(
          id: 'ex_chest_fly',
          name: 'Chest Fly',
          category: 'chest',
          muscleGroup: 'Pectorals',
          type: 'isolation',
          equipment: 'dumbbell',
        ),
        
        // Back
        ExerciseModel(
          id: 'ex_deadlift',
          name: 'Deadlift',
          category: 'back',
          muscleGroup: 'Erector Spinae',
          type: 'compound',
          equipment: 'barbell',
        ),
        ExerciseModel(
          id: 'ex_pullup',
          name: 'Pull-up',
          category: 'back',
          muscleGroup: 'Lats',
          type: 'compound',
          equipment: 'bodyweight',
        ),
        ExerciseModel(
          id: 'ex_barbell_row',
          name: 'Barbell Row',
          category: 'back',
          muscleGroup: 'Lats',
          type: 'compound',
          equipment: 'barbell',
        ),
        ExerciseModel(
          id: 'ex_lat_pulldown',
          name: 'Lat Pulldown',
          category: 'back',
          muscleGroup: 'Lats',
          type: 'compound',
          equipment: 'cable',
        ),
        
        // Legs
        ExerciseModel(
          id: 'ex_squat',
          name: 'Squat',
          category: 'legs',
          muscleGroup: 'Quadriceps',
          type: 'compound',
          equipment: 'barbell',
        ),
        ExerciseModel(
          id: 'ex_leg_press',
          name: 'Leg Press',
          category: 'legs',
          muscleGroup: 'Quadriceps',
          type: 'compound',
          equipment: 'machine',
        ),
        ExerciseModel(
          id: 'ex_leg_curl',
          name: 'Leg Curl',
          category: 'legs',
          muscleGroup: 'Hamstrings',
          type: 'isolation',
          equipment: 'machine',
        ),
        ExerciseModel(
          id: 'ex_leg_extension',
          name: 'Leg Extension',
          category: 'legs',
          muscleGroup: 'Quadriceps',
          type: 'isolation',
          equipment: 'machine',
        ),
        
        // Shoulders
        ExerciseModel(
          id: 'ex_overhead_press',
          name: 'Overhead Press',
          category: 'shoulders',
          muscleGroup: 'Deltoids',
          type: 'compound',
          equipment: 'barbell',
        ),
        ExerciseModel(
          id: 'ex_lateral_raise',
          name: 'Lateral Raise',
          category: 'shoulders',
          muscleGroup: 'Lateral Deltoid',
          type: 'isolation',
          equipment: 'dumbbell',
        ),
        ExerciseModel(
          id: 'ex_front_raise',
          name: 'Front Raise',
          category: 'shoulders',
          muscleGroup: 'Anterior Deltoid',
          type: 'isolation',
          equipment: 'dumbbell',
        ),
        
        // Arms
        ExerciseModel(
          id: 'ex_barbell_curl',
          name: 'Barbell Curl',
          category: 'arms',
          muscleGroup: 'Biceps',
          type: 'isolation',
          equipment: 'barbell',
        ),
        ExerciseModel(
          id: 'ex_tricep_extension',
          name: 'Tricep Extension',
          category: 'arms',
          muscleGroup: 'Triceps',
          type: 'isolation',
          equipment: 'dumbbell',
        ),
        ExerciseModel(
          id: 'ex_hammer_curl',
          name: 'Hammer Curl',
          category: 'arms',
          muscleGroup: 'Biceps',
          type: 'isolation',
          equipment: 'dumbbell',
        ),
      ];

      for (var exercise in defaultExercises) {
        await box.put(exercise.id, exercise);
      }
    }
  }

  // User methods
  static Future<void> saveUser(UserModel user) async {
    final box = Hive.box<UserModel>(userBox);
    await box.put('current_user', user);
  }

  static UserModel? getCurrentUser() {
    final box = Hive.box<UserModel>(userBox);
    return box.get('current_user');
  }

  // Exercise methods
  static List<ExerciseModel> getAllExercises() {
    final box = Hive.box<ExerciseModel>(exerciseBox);
    return box.values.toList();
  }

  static ExerciseModel? getExercise(String id) {
    final box = Hive.box<ExerciseModel>(exerciseBox);
    return box.get(id);
  }

  static Future<void> saveExercise(ExerciseModel exercise) async {
    final box = Hive.box<ExerciseModel>(exerciseBox);
    await box.put(exercise.id, exercise);
  }

  // Workout methods
  static Future<void> saveWorkoutSession(WorkoutSessionModel session) async {
    final box = Hive.box<WorkoutSessionModel>(workoutSessionBox);
    await box.put(session.id, session);
  }

  static List<WorkoutSessionModel> getAllWorkoutSessions() {
    final box = Hive.box<WorkoutSessionModel>(workoutSessionBox);
    return box.values.toList();
  }

  static Future<void> saveWorkoutSet(WorkoutSetModel set) async {
    final box = Hive.box<WorkoutSetModel>(workoutSetBox);
    await box.put(set.id, set);
  }

  static List<WorkoutSetModel> getAllWorkoutSets() {
    final box = Hive.box<WorkoutSetModel>(workoutSetBox);
    return box.values.toList();
  }

  // Nutrition methods
  static Future<void> saveNutritionEntry(NutritionEntryModel entry) async {
    final box = Hive.box<NutritionEntryModel>(nutritionBox);
    await box.put(entry.id, entry);
  }

  static List<NutritionEntryModel> getAllNutritionEntries() {
    final box = Hive.box<NutritionEntryModel>(nutritionBox);
    return box.values.toList();
  }

  // Sleep methods
  static Future<void> saveSleepEntry(SleepEntryModel entry) async {
    final box = Hive.box<SleepEntryModel>(sleepBox);
    await box.put(entry.id, entry);
  }

  static List<SleepEntryModel> getAllSleepEntries() {
    final box = Hive.box<SleepEntryModel>(sleepBox);
    return box.values.toList();
  }

  // Clear all data
  static Future<void> clearAllData() async {
    await Hive.box<UserModel>(userBox).clear();
    await Hive.box<ExerciseModel>(exerciseBox).clear();
    await Hive.box<WorkoutSetModel>(workoutSetBox).clear();
    await Hive.box<WorkoutSessionModel>(workoutSessionBox).clear();
    await Hive.box<NutritionEntryModel>(nutritionBox).clear();
    await Hive.box<SleepEntryModel>(sleepBox).clear();
    await _seedDefaultExercises();
  }
}
