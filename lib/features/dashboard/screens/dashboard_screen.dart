import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/services/hive_service.dart';
import '../../../core/services/supabase_service.dart';
import '../widgets/quick_log_card.dart';
import '../widgets/stat_card.dart';
import '../widgets/ai_insight_card.dart';
import '../widgets/recent_workout_card.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;
  String _aiInsight = 'Loading insight...';
  bool _loadingInsight = true;

  @override
  void initState() {
    super.initState();
    _loadAIInsight();
  }

  Future<void> _loadAIInsight() async {
    try {
      final insight = await SupabaseService.generateInsight(type: 'daily');
      if (mounted) {
        setState(() {
          _aiInsight = insight;
          _loadingInsight = false;
        });
      }
    } catch (e) {
      print('Error loading AI insight: $e');
      if (mounted) {
        setState(() {
          _aiInsight = 'Stay consistent and trust the process! 💪';
          _loadingInsight = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: _currentIndex == 0 
            ? _buildDashboard()
            : _buildPlaceholder(),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildDashboard() {
    final user = HiveService.getCurrentUser();
    
    return CustomScrollView(
      slivers: [
        // Header
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Dashboard',
                  style: Theme.of(context).textTheme.displayMedium,
                ).animate().fadeIn(duration: 400.ms),
                IconButton(
                  icon: const Icon(Icons.settings_outlined, size: 28),
                  onPressed: () => context.push('/profile'),
                ).animate().fadeIn(delay: 100.ms),
              ],
            ),
          ),
        ),
        
        // Quick Log Card (Large, Center)
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: const QuickLogCard()
                .animate()
                .fadeIn(delay: 200.ms, duration: 500.ms)
                .scale(begin: const Offset(0.95, 0.95)),
          ),
        ),
        
        const SliverToBoxAdapter(child: SizedBox(height: 24)),
        
        // Stats Row
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                Expanded(
                  child: StatCard(
                    label: 'Workout',
                    value: 'Bench Press',
                    subtitle: 'Pauier',
                    onTap: () => context.push('/workout-session'),
                  ).animate().fadeIn(delay: 300.ms, duration: 400.ms),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: StatCard(
                    label: 'Nutrition',
                    value: '2000/3001',
                    progress: 0.66,
                    onTap: () => context.push('/nutrition'),
                  ).animate().fadeIn(delay: 350.ms, duration: 400.ms),
                ),
              ],
            ),
          ),
        ),
        
        const SliverToBoxAdapter(child: SizedBox(height: 16)),
        
        // AI Insight Card
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: AIInsightCard(insight: _aiInsight)
                .animate()
                .fadeIn(delay: 400.ms, duration: 400.ms),
          ),
        ),
        
        const SliverToBoxAdapter(child: SizedBox(height: 24)),
        
        // Recent Workouts
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              'Recent Activity',
              style: Theme.of(context).textTheme.headlineSmall,
            ).animate().fadeIn(delay: 450.ms),
          ),
        ),
        
        const SliverToBoxAdapter(child: SizedBox(height: 12)),
        
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: RecentWorkoutCard(
                    exerciseName: 'Bench Press',
                    weight: '80 kg',
                    sets: '3×10',
                    date: 'Apr ${30 - index}',
                  ).animate().fadeIn(delay: (500 + index * 50).ms),
                );
              },
              childCount: 3,
            ),
          ),
        ),
        
        const SliverToBoxAdapter(child: SizedBox(height: 100)),
      ],
    );
  }

  Widget _buildPlaceholder() {
    return Center(
      child: Text(
        'Coming Soon',
        style: Theme.of(context).textTheme.headlineMedium,
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(
          top: BorderSide(color: AppColors.divider, width: 1),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(Icons.home_rounded, 'Home', 0),
              _buildNavItem(Icons.fitness_center_rounded, 'Workout', 1),
              _buildNavItem(Icons.restaurant_rounded, 'Nutrition', 2),
              _buildNavItem(Icons.bar_chart_rounded, 'Insights', 3),
              _buildNavItem(Icons.person_rounded, 'Profile', 4),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final isActive = _currentIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() => _currentIndex = index);
        if (index == 1) context.push('/workout-session');
        if (index == 2) context.push('/nutrition');
        if (index == 3) context.push('/insights');
        if (index == 4) context.push('/profile');
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primary.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isActive ? AppColors.primary : AppColors.textSecondary,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isActive ? AppColors.primary : AppColors.textSecondary,
                fontSize: 11,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
