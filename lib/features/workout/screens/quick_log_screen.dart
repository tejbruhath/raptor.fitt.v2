import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/services/hive_service.dart';
import '../../../core/services/supabase_service.dart';
import '../../../core/services/sync_service.dart';
import '../../../core/services/ai_parsing_service.dart';
import '../../models/workout_set_model.dart';
import '../../models/workout_session_model.dart';
import '../../models/exercise_model.dart';

class QuickLogScreen extends StatefulWidget {
  const QuickLogScreen({super.key});

  @override
  State<QuickLogScreen> createState() => _QuickLogScreenState();
}

class _QuickLogScreenState extends State<QuickLogScreen> {
  final _inputController = TextEditingController();
  bool _isProcessing = false;
  
  String? _exerciseName;
  double? _weight;
  int? _sets;
  int? _reps;

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  Future<void> _parseInput() async {
    if (_inputController.text.isEmpty) return;
    
    setState(() => _isProcessing = true);
    
    try {
      // Check if online for Supabase AI parsing
      final connectivityResult = await Connectivity().checkConnectivity();
      final isOnline = connectivityResult != ConnectivityResult.none;
      
      List<Map<String, dynamic>>? parsedSets;
      
      if (isOnline) {
        // Use Groq AI via Supabase Edge Function
        try {
          parsedSets = await SupabaseService.parseWorkout(_inputController.text);
        } catch (e) {
          print('Supabase parsing failed, using fallback: $e');
          // Fall back to local regex parsing
          parsedSets = null;
        }
      }
      
      // Handle Supabase AI parsed results
      if (parsedSets != null && parsedSets.isNotEmpty) {
        final firstSet = parsedSets.first;
        setState(() {
          _exerciseName = firstSet['exerciseName'] as String;
          _weight = (firstSet['weight'] as num).toDouble();
          _sets = firstSet['sets'] as int;
          _reps = firstSet['reps'] as int;
        });
      } 
      // Fallback to local regex parsing if offline or Supabase failed
      else {
        final result = await AIParsingService.parseWorkoutInput(_inputController.text);
        
        if (result != null && result['type'] == 'workout') {
          final exercises = HiveService.getAllExercises();
          final exerciseNames = exercises.map((e) => e.name).toList();
          
          setState(() {
            _exerciseName = AIParsingService.matchExerciseName(
              result['exercise'],
              exerciseNames,
            );
            _weight = result['weight']?.toDouble();
            _sets = result['sets'];
            _reps = result['reps'];
          });
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to parse: $e')),
        );
      }
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  Future<void> _saveWorkout() async {
    if (_exerciseName == null || _weight == null || _sets == null || _reps == null) {
      return;
    }
    
    final user = HiveService.getCurrentUser();
    if (user == null) return;
    
    // Find or create exercise
    final exercises = HiveService.getAllExercises();
    ExerciseModel? exercise = exercises.firstWhere(
      (e) => e.name.toLowerCase() == _exerciseName!.toLowerCase(),
      orElse: () => ExerciseModel(
        id: 'ex_${const Uuid().v4()}',
        name: _exerciseName!,
        category: 'other',
        muscleGroup: 'Unknown',
        type: 'compound',
        equipment: 'barbell',
      ),
    );
    
    if (!exercises.contains(exercise)) {
      await HiveService.saveExercise(exercise);
    }
    
    // Create workout session
    final sessionId = 'ws_${const Uuid().v4()}';
    final now = DateTime.now();
    
    final setIds = <String>[];
    
    // Create sets
    for (int i = 1; i <= _sets!; i++) {
      final setId = 'set_${const Uuid().v4()}';
      final workoutSet = WorkoutSetModel(
        id: setId,
        exerciseId: exercise.id,
        setNumber: i,
        weight: _weight!,
        reps: _reps!,
        completedAt: now.add(Duration(minutes: i * 3)),
      );
      
      await HiveService.saveWorkoutSet(workoutSet);
      setIds.add(setId);
    }
    
    // Create session
    final session = WorkoutSessionModel(
      id: sessionId,
      userId: user.id,
      name: '$_exerciseName Workout',
      startTime: now,
      endTime: now.add(Duration(minutes: _sets! * 3)),
      exerciseIds: [exercise.id],
      setIds: setIds,
      isCompleted: true,
    );
    
    await HiveService.saveWorkoutSession(session);
    
    // Sync to Supabase
    await SyncService.syncWorkoutSession(session.toJson());
    for (final setId in setIds) {
      final set = HiveService.getWorkoutSet(setId);
      if (set != null) {
        await SyncService.syncWorkoutSets([set.toJson()]);
      }
    }
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Workout logged successfully! 🔥'),
          backgroundColor: AppColors.success,
        ),
      );
      
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quick Log'),
        actions: [
          IconButton(
            icon: const Icon(Icons.mic_rounded),
            onPressed: () => context.push('/voice-input?mode=workout'),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Input field
              Text(
                'Log your workout',
                style: Theme.of(context).textTheme.headlineMedium,
              ).animate().fadeIn(duration: 400.ms),
              
              const SizedBox(height: 8),
              
              Text(
                'Type: "bench 80 3 10" for Bench Press, 80kg, 3 sets, 10 reps',
                style: Theme.of(context).textTheme.bodyMedium,
              ).animate().fadeIn(delay: 100.ms),
              
              const SizedBox(height: 24),
              
              Container(
                padding: const EdgeInsets.only(left: 16, right: 8),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _inputController,
                        style: const TextStyle(
                          fontSize: 18,
                          color: AppColors.textPrimary,
                        ),
                        decoration: const InputDecoration(
                          hintText: 'e.g. bench 80 3 10',
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(vertical: 16),
                        ),
                        onSubmitted: (_) => _parseInput(),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.mic_rounded),
                      color: AppColors.primary,
                      onPressed: () async {
                        final text = await context.push<String>('/voice-input?mode=workout');
                        if (text != null && text.isNotEmpty) {
                          _inputController.text = text;
                          _parseInput();
                        }
                      },
                      tooltip: 'Voice Input',
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: 200.ms).scale(begin: const Offset(0.95, 0.95)),
              
              const SizedBox(height: 16),
              
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isProcessing ? null : _parseInput,
                  child: _isProcessing
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation(Colors.white),
                          ),
                        )
                      : const Text('Parse'),
                ),
              ).animate().fadeIn(delay: 250.ms),
              
              const SizedBox(height: 32),
              
              // Parsed output
              if (_exerciseName != null) ...[
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.primary.withOpacity(0.3),
                      width: 2,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _exerciseName!,
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildDataRow('Weight', '${_weight}kg'),
                      const SizedBox(height: 12),
                      _buildDataRow('Sets', '$_sets'),
                      const SizedBox(height: 12),
                      _buildDataRow('Reps', '$_reps'),
                    ],
                  ),
                ).animate().fadeIn(duration: 400.ms).scale(begin: const Offset(0.9, 0.9)),
                
                const SizedBox(height: 24),
                
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _saveWorkout,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.success,
                    ),
                    child: const Text(
                      'Add Workout',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.2, end: 0),
                
                const SizedBox(height: 12),
                
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: TextButton(
                    onPressed: () {
                      setState(() {
                        _exerciseName = null;
                        _weight = null;
                        _sets = null;
                        _reps = null;
                      });
                      _inputController.clear();
                    },
                    child: const Text('Clear'),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDataRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 16,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
