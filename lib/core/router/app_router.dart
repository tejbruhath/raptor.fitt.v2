import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/signup_screen.dart';
import '../../features/onboarding/screens/onboarding_screen.dart';
import '../../features/dashboard/screens/dashboard_screen.dart';
import '../../features/workout/screens/workout_session_screen.dart';
import '../../features/workout/screens/quick_log_screen.dart';
import '../../features/workout/screens/exercise_list_screen.dart';
import '../../features/nutrition/screens/nutrition_screen.dart';
import '../../features/sleep/screens/sleep_tracker_screen.dart';
import '../../features/insights/screens/insights_screen.dart';
import '../../features/profile/screens/profile_screen.dart';
import '../../features/voice/screens/voice_input_screen.dart';
import '../../features/settings/screens/settings_screen.dart';
import '../services/hive_service.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/login',
    redirect: (context, state) {
      final isAuthenticated = Supabase.instance.client.auth.currentUser != null;
      final isLoggingIn = state.matchedLocation == '/login';
      final isSigningUp = state.matchedLocation == '/signup';
      final isOnboarding = state.matchedLocation == '/onboarding';

      // If not authenticated and not on auth screens, redirect to login
      if (!isAuthenticated && !isLoggingIn && !isSigningUp && !isOnboarding) {
        return '/login';
      }

      // If authenticated but no user profile in Hive, go to onboarding
      if (isAuthenticated && !isOnboarding) {
        final hasUserProfile = HiveService.getCurrentUser() != null;
        if (!hasUserProfile && state.matchedLocation != '/onboarding') {
          return '/onboarding';
        }
      }

      // If authenticated and has profile, don't let them access auth screens
      if (isAuthenticated && (isLoggingIn || isSigningUp)) {
        return '/dashboard';
      }

      return null; // No redirect needed
    },
    routes: [
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/signup',
        name: 'signup',
        builder: (context, state) => const SignupScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        name: 'onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/dashboard',
        name: 'dashboard',
        builder: (context, state) => const DashboardScreen(),
      ),
      GoRoute(
        path: '/quick-log',
        name: 'quick-log',
        builder: (context, state) => const QuickLogScreen(),
      ),
      GoRoute(
        path: '/workout-session',
        name: 'workout-session',
        builder: (context, state) => const WorkoutSessionScreen(),
      ),
      GoRoute(
        path: '/exercises',
        name: 'exercises',
        builder: (context, state) => const ExerciseListScreen(),
      ),
      GoRoute(
        path: '/nutrition',
        name: 'nutrition',
        builder: (context, state) => const NutritionScreen(),
      ),
      GoRoute(
        path: '/sleep',
        name: 'sleep',
        builder: (context, state) => const SleepTrackerScreen(),
      ),
      GoRoute(
        path: '/insights',
        name: 'insights',
        builder: (context, state) => const InsightsScreen(),
      ),
      GoRoute(
        path: '/profile',
        name: 'profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: '/voice-input',
        name: 'voice-input',
        builder: (context, state) {
          final mode = state.uri.queryParameters['mode'] ?? 'workout';
          return VoiceInputScreen(mode: mode);
        },
      ),
      GoRoute(
        path: '/settings',
        name: 'settings',
        builder: (context, state) => const SettingsScreen(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Page not found: ${state.uri}'),
      ),
    ),
  );
});
