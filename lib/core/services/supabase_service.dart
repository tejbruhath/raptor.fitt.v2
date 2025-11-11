import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:convert';

class SupabaseService {
  static final SupabaseClient _client = Supabase.instance.client;

  // Parse workout using Groq AI (via Edge Function)
  static Future<List<Map<String, dynamic>>> parseWorkout(String input) async {
    try {
      final response = await _client.functions.invoke(
        'parse-workout',
        body: {
          'input': input,
          'userId': _client.auth.currentUser?.id,
        },
      );

      final data = json.decode(response.data);
      if (data['success'] == true) {
        return List<Map<String, dynamic>>.from(data['parsed'] ?? []);
      }

      throw Exception('Failed to parse workout');
    } catch (e) {
      print('Error parsing workout: $e');
      rethrow;
    }
  }

  // Generate AI insight
  static Future<String> generateInsight({
    required String type, // 'daily', 'recovery', 'deload', 'pr_celebration'
    Map<String, dynamic>? context,
  }) async {
    try {
      final response = await _client.functions.invoke(
        'generate-insight',
        body: {
          'userId': _client.auth.currentUser?.id,
          'type': type,
          'context': context,
        },
      );

      final data = json.decode(response.data);
      return data['insight'] ?? 'Keep pushing! 💪';
    } catch (e) {
      print('Error generating insight: $e');
      return 'Stay consistent and trust the process! 💪';
    }
  }

  // Sync local changes to cloud
  static Future<Map<String, dynamic>> syncData(
    List<Map<String, dynamic>> changes,
  ) async {
    try {
      final response = await _client.functions.invoke(
        'sync-data',
        body: {
          'userId': _client.auth.currentUser?.id,
          'changes': changes,
        },
      );

      return json.decode(response.data);
    } catch (e) {
      print('Error syncing data: $e');
      rethrow;
    }
  }

  // CRUD Operations for each table
  
  // Workout Sessions
  static Future<List<Map<String, dynamic>>> getWorkoutSessions({
    int? limit,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      var query = _client
          .from('workout_sessions')
          .select('*, workout_sets(*, exercises(*))')
          .eq('user_id', _client.auth.currentUser!.id)
          .order('start_time', ascending: false);

      if (limit != null) {
        query = query.limit(limit);
      }

      if (startDate != null) {
        query = query.gte('start_time', startDate.toIso8601String());
      }

      if (endDate != null) {
        query = query.lte('start_time', endDate.toIso8601String());
      }

      final response = await query;
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error fetching workout sessions: $e');
      return [];
    }
  }

  static Future<Map<String, dynamic>?> createWorkoutSession(
    Map<String, dynamic> session,
  ) async {
    try {
      final response = await _client
          .from('workout_sessions')
          .insert({
            ...session,
            'user_id': _client.auth.currentUser!.id,
          })
          .select()
          .single();

      return response;
    } catch (e) {
      print('Error creating workout session: $e');
      return null;
    }
  }

  // Workout Sets
  static Future<List<Map<String, dynamic>>?> createWorkoutSets(
    List<Map<String, dynamic>> sets,
  ) async {
    try {
      final setsWithUser = sets.map((set) => {
        ...set,
        'user_id': _client.auth.currentUser!.id,
      }).toList();

      final response = await _client
          .from('workout_sets')
          .insert(setsWithUser)
          .select();

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error creating workout sets: $e');
      return null;
    }
  }

  // Nutrition Entries
  static Future<List<Map<String, dynamic>>> getNutritionEntries({
    DateTime? date,
  }) async {
    try {
      var query = _client
          .from('nutrition_entries')
          .select()
          .eq('user_id', _client.auth.currentUser!.id)
          .order('consumed_at', ascending: false);

      if (date != null) {
        final startOfDay = DateTime(date.year, date.month, date.day);
        final endOfDay = startOfDay.add(const Duration(days: 1));
        query = query
            .gte('consumed_at', startOfDay.toIso8601String())
            .lt('consumed_at', endOfDay.toIso8601String());
      }

      final response = await query;
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error fetching nutrition entries: $e');
      return [];
    }
  }

  static Future<Map<String, dynamic>?> createNutritionEntry(
    Map<String, dynamic> entry,
  ) async {
    try {
      final response = await _client
          .from('nutrition_entries')
          .insert({
            ...entry,
            'user_id': _client.auth.currentUser!.id,
          })
          .select()
          .single();

      return response;
    } catch (e) {
      print('Error creating nutrition entry: $e');
      return null;
    }
  }

  // Sleep Entries
  static Future<List<Map<String, dynamic>>> getSleepEntries({
    int? limit,
  }) async {
    try {
      var query = _client
          .from('sleep_entries')
          .select()
          .eq('user_id', _client.auth.currentUser!.id)
          .order('sleep_date', ascending: false);

      if (limit != null) {
        query = query.limit(limit);
      }

      final response = await query;
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error fetching sleep entries: $e');
      return [];
    }
  }

  static Future<Map<String, dynamic>?> createSleepEntry(
    Map<String, dynamic> entry,
  ) async {
    try {
      final response = await _client
          .from('sleep_entries')
          .insert({
            ...entry,
            'user_id': _client.auth.currentUser!.id,
          })
          .select()
          .single();

      return response;
    } catch (e) {
      print('Error creating sleep entry: $e');
      return null;
    }
  }

  // Exercises
  static Future<List<Map<String, dynamic>>> getExercises() async {
    try {
      final response = await _client
          .from('exercises')
          .select()
          .order('name', ascending: true);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error fetching exercises: $e');
      return [];
    }
  }

  // User Profile
  static Future<Map<String, dynamic>?> getUserProfile() async {
    try {
      final response = await _client
          .from('users')
          .select()
          .eq('id', _client.auth.currentUser!.id)
          .single();

      return response;
    } catch (e) {
      print('Error fetching user profile: $e');
      return null;
    }
  }

  static Future<Map<String, dynamic>?> updateUserProfile(
    Map<String, dynamic> updates,
  ) async {
    try {
      final response = await _client
          .from('users')
          .update(updates)
          .eq('id', _client.auth.currentUser!.id)
          .select()
          .single();

      return response;
    } catch (e) {
      print('Error updating user profile: $e');
      return null;
    }
  }

  static Future<Map<String, dynamic>?> createUserProfile(
    Map<String, dynamic> profile,
  ) async {
    try {
      final response = await _client
          .from('users')
          .insert({
            ...profile,
            'id': _client.auth.currentUser!.id,
          })
          .select()
          .single();

      return response;
    } catch (e) {
      print('Error creating user profile: $e');
      return null;
    }
  }

  // Crews
  static Future<List<Map<String, dynamic>>> getUserCrews() async {
    try {
      final response = await _client
          .from('crew_members')
          .select('crews(*)')
          .eq('user_id', _client.auth.currentUser!.id);

      return List<Map<String, dynamic>>.from(
        response.map((item) => item['crews']),
      );
    } catch (e) {
      print('Error fetching user crews: $e');
      return [];
    }
  }

  static Future<Map<String, dynamic>?> createCrew(
    String name,
  ) async {
    try {
      final response = await _client
          .from('crews')
          .insert({
            'name': name,
            'creator_id': _client.auth.currentUser!.id,
            'invite_code': _generateInviteCode(),
          })
          .select()
          .single();

      // Add creator as member
      await _client.from('crew_members').insert({
        'crew_id': response['id'],
        'user_id': _client.auth.currentUser!.id,
      });

      return response;
    } catch (e) {
      print('Error creating crew: $e');
      return null;
    }
  }

  static String _generateInviteCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = DateTime.now().millisecondsSinceEpoch.toString();
    return random.substring(random.length - 6);
  }

  static Future<Map<String, dynamic>?> joinCrew(String inviteCode) async {
    try {
      // Find crew by invite code
      final crewResponse = await _client
          .from('crews')
          .select()
          .eq('invite_code', inviteCode)
          .single();

      // Add current user as member
      final memberResponse = await _client
          .from('crew_members')
          .insert({
            'crew_id': crewResponse['id'],
            'user_id': _client.auth.currentUser!.id,
          })
          .select()
          .single();

      return memberResponse;
    } catch (e) {
      print('Error joining crew: $e');
      return null;
    }
  }

  static Future<bool> leaveCrew(String crewId) async {
    try {
      await _client
          .from('crew_members')
          .delete()
          .eq('crew_id', crewId)
          .eq('user_id', _client.auth.currentUser!.id);

      return true;
    } catch (e) {
      print('Error leaving crew: $e');
      return false;
    }
  }

  static Future<Map<String, dynamic>?> createChallenge({
    required String crewId,
    required String name,
    required String type, // 'volume', 'consistency', 'pr'
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final response = await _client
          .from('crew_challenges')
          .insert({
            'crew_id': crewId,
            'name': name,
            'type': type,
            'start_date': startDate.toIso8601String(),
            'end_date': endDate.toIso8601String(),
            'is_active': true,
          })
          .select()
          .single();

      return response;
    } catch (e) {
      print('Error creating challenge: $e');
      return null;
    }
  }

  static Future<bool> updateChallengeScore({
    required String challengeId,
    required double score,
  }) async {
    try {
      await _client
          .from('crew_challenge_scores')
          .upsert({
            'challenge_id': challengeId,
            'user_id': _client.auth.currentUser!.id,
            'score': score,
            'updated_at': DateTime.now().toIso8601String(),
          });

      return true;
    } catch (e) {
      print('Error updating challenge score: $e');
      return false;
    }
  }

  static Future<List<Map<String, dynamic>>> getChallengeLeaderboard(
    String challengeId,
  ) async {
    try {
      final response = await _client
          .from('crew_challenge_scores')
          .select('*, users(name)')
          .eq('challenge_id', challengeId)
          .order('score', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error fetching leaderboard: $e');
      return [];
    }
  }

  // Real-time subscriptions
  static RealtimeChannel subscribeToWorkouts(
    Function(Map<String, dynamic>) onInsert,
  ) {
    return _client
        .channel('workout_sessions')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'workout_sessions',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'user_id',
            value: _client.auth.currentUser!.id,
          ),
          callback: (payload) => onInsert(payload.newRecord),
        )
        .subscribe();
  }
}
