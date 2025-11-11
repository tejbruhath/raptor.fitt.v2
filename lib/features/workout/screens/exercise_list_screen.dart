import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/services/hive_service.dart';
import '../../models/exercise_model.dart';

class ExerciseListScreen extends StatefulWidget {
  const ExerciseListScreen({super.key});

  @override
  State<ExerciseListScreen> createState() => _ExerciseListScreenState();
}

class _ExerciseListScreenState extends State<ExerciseListScreen> {
  List<ExerciseModel> _exercises = [];
  List<ExerciseModel> _filteredExercises = [];
  String _selectedCategory = 'all';
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadExercises();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadExercises() {
    final exercises = HiveService.getAllExercises();
    setState(() {
      _exercises = exercises;
      _filteredExercises = exercises;
    });
  }

  void _filterExercises() {
    var filtered = _exercises;
    
    // Filter by category
    if (_selectedCategory != 'all') {
      filtered = filtered.where((e) => e.category == _selectedCategory).toList();
    }
    
    // Filter by search
    if (_searchController.text.isNotEmpty) {
      filtered = filtered
          .where((e) => e.name
              .toLowerCase()
              .contains(_searchController.text.toLowerCase()))
          .toList();
    }
    
    setState(() => _filteredExercises = filtered);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Exercises'),
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              onChanged: (_) => _filterExercises(),
              decoration: InputDecoration(
                hintText: 'Search exercises...',
                prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary),
                filled: true,
                fillColor: AppColors.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          
          // Category tabs
          SizedBox(
            height: 50,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _buildCategoryChip('All', 'all'),
                _buildCategoryChip('Chest', 'chest'),
                _buildCategoryChip('Back', 'back'),
                _buildCategoryChip('Legs', 'legs'),
                _buildCategoryChip('Shoulders', 'shoulders'),
                _buildCategoryChip('Arms', 'arms'),
              ],
            ),
          ),
          
          const SizedBox(height: 8),
          
          // Exercise list
          Expanded(
            child: _filteredExercises.isEmpty
                ? const Center(
                    child: Text(
                      'No exercises found',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _filteredExercises.length,
                    itemBuilder: (context, index) {
                      final exercise = _filteredExercises[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _ExerciseCard(exercise: exercise)
                            .animate()
                            .fadeIn(delay: (index * 30).ms),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(String label, String value) {
    final isSelected = _selectedCategory == value;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) {
          setState(() => _selectedCategory = value);
          _filterExercises();
        },
        backgroundColor: AppColors.surface,
        selectedColor: AppColors.primary,
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : AppColors.textSecondary,
        ),
      ),
    );
  }
}

class _ExerciseCard extends StatelessWidget {
  final ExerciseModel exercise;

  const _ExerciseCard({required this.exercise});

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'chest':
        return Icons.fitness_center;
      case 'back':
        return Icons.accessibility_new;
      case 'legs':
        return Icons.directions_run;
      case 'shoulders':
        return Icons.airline_seat_recline_extra;
      case 'arms':
        return Icons.sports_martial_arts;
      default:
        return Icons.fitness_center;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              _getCategoryIcon(exercise.category),
              color: AppColors.primary,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  exercise.name,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${exercise.muscleGroup} • ${exercise.equipment}',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          if (exercise.isFavorite)
            const Icon(
              Icons.favorite,
              color: AppColors.error,
              size: 20,
            ),
        ],
      ),
    );
  }
}
