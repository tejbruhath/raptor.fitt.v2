import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/services/hive_service.dart';
import '../../models/workout_session_model.dart';
import '../../models/workout_set_model.dart';

class WorkoutSessionScreen extends StatefulWidget {
  const WorkoutSessionScreen({super.key});

  @override
  State<WorkoutSessionScreen> createState() => _WorkoutSessionScreenState();
}

class _WorkoutSessionScreenState extends State<WorkoutSessionScreen> {
  List<WorkoutSessionModel> _sessions = [];
  Map<String, List<WorkoutSetModel>> _sessionSets = {};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    final sessions = HiveService.getAllWorkoutSessions();
    final allSets = HiveService.getAllWorkoutSets();
    
    // Sort sessions by date (most recent first)
    sessions.sort((a, b) => b.startTime.compareTo(a.startTime));
    
    // Group sets by session
    final setsMap = <String, List<WorkoutSetModel>>{};
    for (var session in sessions) {
      setsMap[session.id] = allSets
          .where((set) => session.setIds.contains(set.id))
          .toList();
    }
    
    setState(() {
      _sessions = sessions;
      _sessionSets = setsMap;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Workouts'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            onPressed: () => context.push('/quick-log'),
          ),
        ],
      ),
      body: _sessions.isEmpty
          ? _buildEmptyState()
          : _buildWorkoutList(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.fitness_center_rounded,
            size: 80,
            color: AppColors.textSecondary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No workouts yet',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Start your first workout!',
            style: TextStyle(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () => context.push('/quick-log'),
            icon: const Icon(Icons.add_rounded),
            label: const Text('Log Workout'),
          ),
        ],
      ),
    );
  }

  Widget _buildWorkoutList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _sessions.length,
      itemBuilder: (context, index) {
        final session = _sessions[index];
        final sets = _sessionSets[session.id] ?? [];
        final exercises = HiveService.getAllExercises();
        
        // Get exercise names
        final exerciseNames = session.exerciseIds
            .map((id) => exercises.firstWhere(
                  (e) => e.id == id,
                  orElse: () => exercises.first,
                ).name)
            .join(', ');
        
        // Calculate total volume
        final totalVolume = sets.fold(0.0, (sum, set) => sum + set.volume);
        
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _WorkoutCard(
            session: session,
            exerciseNames: exerciseNames,
            totalSets: sets.length,
            totalVolume: totalVolume,
          ).animate().fadeIn(delay: (index * 50).ms),
        );
      },
    );
  }
}

class _WorkoutCard extends StatelessWidget {
  final WorkoutSessionModel session;
  final String exerciseNames;
  final int totalSets;
  final double totalVolume;

  const _WorkoutCard({
    required this.session,
    required this.exerciseNames,
    required this.totalSets,
    required this.totalVolume,
  });

  String _formatDate(DateTime date) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 
                    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[date.month - 1]} ${date.day}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Today',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
              ),
              Icon(
                Icons.trending_up_rounded,
                color: AppColors.success,
                size: 20,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            exerciseNames,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildStat('${totalVolume.toInt()} kg', 'Volume'),
              const SizedBox(width: 24),
              _buildStat('$totalSets sets', 'Total'),
            ],
          ),
          if (session.duration != null) ...[
            const SizedBox(height: 8),
            Text(
              'Duration: ${session.duration!.inMinutes} min',
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStat(String value, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}
