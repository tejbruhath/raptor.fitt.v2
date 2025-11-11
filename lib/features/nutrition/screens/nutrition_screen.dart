import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:math' as math;
import '../../../core/theme/app_colors.dart';
import '../../../core/services/hive_service.dart';
import '../../models/nutrition_entry_model.dart';
import '../../models/user_model.dart';
import '../widgets/macro_ring.dart';
import '../widgets/food_entry_card.dart';

class NutritionScreen extends StatefulWidget {
  const NutritionScreen({super.key});

  @override
  State<NutritionScreen> createState() => _NutritionScreenState();
}

class _NutritionScreenState extends State<NutritionScreen> {
  List<NutritionEntryModel> _entries = [];
  UserModel? _user;
  double _totalCalories = 0;
  double _totalProtein = 0;
  double _totalCarbs = 0;
  double _totalFat = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    final user = HiveService.getCurrentUser();
    final allEntries = HiveService.getAllNutritionEntries();
    
    // Get today's entries
    final now = DateTime.now();
    final todayEntries = allEntries.where((e) {
      return e.consumedAt.year == now.year &&
          e.consumedAt.month == now.month &&
          e.consumedAt.day == now.day;
    }).toList();
    
    // Calculate totals
    double calories = 0;
    double protein = 0;
    double carbs = 0;
    double fat = 0;
    
    for (var entry in todayEntries) {
      calories += entry.calories;
      protein += entry.protein;
      carbs += entry.carbs;
      fat += entry.fat;
    }
    
    setState(() {
      _user = user;
      _entries = todayEntries;
      _totalCalories = calories;
      _totalProtein = protein;
      _totalCarbs = carbs;
      _totalFat = fat;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nutrition'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            onPressed: _showAddFoodDialog,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Calorie ring
            _buildCalorieRing().animate().fadeIn(duration: 500.ms).scale(begin: const Offset(0.9, 0.9)),
            
            const SizedBox(height: 32),
            
            // Macros breakdown
            _buildMacrosRow().animate().fadeIn(delay: 200.ms),
            
            const SizedBox(height: 32),
            
            // Today's meals
            Text(
              'Today\'s Meals',
              style: Theme.of(context).textTheme.headlineSmall,
            ).animate().fadeIn(delay: 300.ms),
            
            const SizedBox(height: 16),
            
            if (_entries.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: Text(
                    'No meals logged today',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 16,
                    ),
                  ),
                ),
              )
            else
              ..._entries.asMap().entries.map((entry) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: FoodEntryCard(entry: entry.value)
                      .animate()
                      .fadeIn(delay: (350 + entry.key * 50).ms),
                );
              }),
          ],
        ),
      ),
    );
  }

  Widget _buildCalorieRing() {
    final target = _user?.targetCalories ?? 2000;
    final progress = (_totalCalories / target).clamp(0, 1);
    
    return Center(
      child: SizedBox(
        width: 200,
        height: 200,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Background ring
            const SizedBox(
              width: 180,
              height: 180,
              child: CircularProgressIndicator(
                value: 1,
                strokeWidth: 16,
                backgroundColor: AppColors.divider,
                valueColor: AlwaysStoppedAnimation(AppColors.divider),
              ),
            ),
            // Progress ring
            SizedBox(
              width: 180,
              height: 180,
              child: CircularProgressIndicator(
                value: progress,
                strokeWidth: 16,
                backgroundColor: Colors.transparent,
                valueColor: const AlwaysStoppedAnimation(AppColors.primary),
              ),
            ),
            // Center text
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _totalCalories.toInt().toString(),
                  style: const TextStyle(
                    fontSize: 42,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  '/ ${target.toInt()}',
                  style: const TextStyle(
                    fontSize: 18,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Calories',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMacrosRow() {
    final targetProtein = _user?.targetProtein ?? 150;
    final targetCarbs = _user?.targetCarbs ?? 250;
    final targetFat = _user?.targetFat ?? 70;
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildMacroStat(
          'Protein',
          _totalProtein,
          targetProtein,
          AppColors.chartBlue,
        ),
        _buildMacroStat(
          'Carbs',
          _totalCarbs,
          targetCarbs,
          AppColors.chartPurple,
        ),
        _buildMacroStat(
          'Fat',
          _totalFat,
          targetFat,
          AppColors.chartYellow,
        ),
      ],
    );
  }

  Widget _buildMacroStat(String label, double current, double target, Color color) {
    final percentage = ((current / target) * 100).toInt();
    
    return Column(
      children: [
        Text(
          '${current.toInt()}g',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '$percentage%',
          style: const TextStyle(
            fontSize: 11,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  void _showAddFoodDialog() {
    showDialog(
      context: context,
      builder: (context) => const _AddFoodDialog(),
    ).then((value) {
      if (value == true) {
        _loadData();
      }
    });
  }
}

class _AddFoodDialog extends StatefulWidget {
  const _AddFoodDialog();

  @override
  State<_AddFoodDialog> createState() => _AddFoodDialogState();
}

class _AddFoodDialogState extends State<_AddFoodDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _servingController = TextEditingController();
  final _caloriesController = TextEditingController();
  final _proteinController = TextEditingController();
  final _carbsController = TextEditingController();
  final _fatController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _servingController.dispose();
    _caloriesController.dispose();
    _proteinController.dispose();
    _carbsController.dispose();
    _fatController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    
    final user = HiveService.getCurrentUser();
    if (user == null) return;
    
    final entry = NutritionEntryModel(
      id: 'ne_${DateTime.now().millisecondsSinceEpoch}',
      userId: user.id,
      foodName: _nameController.text,
      servingSize: double.parse(_servingController.text),
      calories: double.parse(_caloriesController.text),
      protein: double.parse(_proteinController.text),
      carbs: double.parse(_carbsController.text),
      fat: double.parse(_fatController.text),
      consumedAt: DateTime.now(),
      mealType: 'snack',
      isCustomFood: true,
    );
    
    await HiveService.saveNutritionEntry(entry);
    
    if (mounted) {
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.surface,
      title: const Text('Add Food'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Food Name'),
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                controller: _servingController,
                decoration: const InputDecoration(labelText: 'Serving (g)'),
                keyboardType: TextInputType.number,
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                controller: _caloriesController,
                decoration: const InputDecoration(labelText: 'Calories'),
                keyboardType: TextInputType.number,
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                controller: _proteinController,
                decoration: const InputDecoration(labelText: 'Protein (g)'),
                keyboardType: TextInputType.number,
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                controller: _carbsController,
                decoration: const InputDecoration(labelText: 'Carbs (g)'),
                keyboardType: TextInputType.number,
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                controller: _fatController,
                decoration: const InputDecoration(labelText: 'Fat (g)'),
                keyboardType: TextInputType.number,
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _save,
          child: const Text('Add'),
        ),
      ],
    );
  }
}
