import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:hive/hive.dart';
import 'supabase_service.dart';

class SyncService {
  static final _connectivity = Connectivity();
  static bool _isSyncing = false;
  static Timer? _syncTimer;

  // Start background sync (every 5 minutes when online)
  static void startBackgroundSync() {
    _syncTimer?.cancel();
    _syncTimer = Timer.periodic(const Duration(minutes: 5), (_) {
      syncAll();
    });

    // Also sync when connectivity changes
    _connectivity.onConnectivityChanged.listen((result) {
      if (result != ConnectivityResult.none) {
        syncAll();
      }
    });
  }

  static void stopBackgroundSync() {
    _syncTimer?.cancel();
  }

  // Sync all pending changes
  static Future<bool> syncAll() async {
    if (_isSyncing) return false;

    try {
      _isSyncing = true;

      // Check connectivity
      final connectivityResult = await _connectivity.checkConnectivity();
      if (connectivityResult == ConnectivityResult.none) {
        return false;
      }

      final syncQueue = await Hive.openBox('sync_queue');
      if (syncQueue.isEmpty) {
        return true;
      }

      final changes = <Map<String, dynamic>>[];

      // Collect all pending changes
      for (var key in syncQueue.keys) {
        final item = syncQueue.get(key);
        if (item != null) {
          changes.add(Map<String, dynamic>.from(item));
        }
      }

      if (changes.isEmpty) {
        return true;
      }

      // Send to Supabase
      final result = await SupabaseService.syncData(changes);

      if (result['success'] == true) {
        // Clear synced items
        final syncedCount = result['syncedCount'] ?? 0;
        if (syncedCount > 0) {
          await syncQueue.clear();
          print('Synced $syncedCount items to cloud');
        }
      }

      return true;
    } catch (e) {
      print('Sync error: $e');
      return false;
    } finally {
      _isSyncing = false;
    }
  }

  // Queue a change for sync
  static Future<void> queueChange({
    required String table,
    required String operation,
    required Map<String, dynamic> data,
    String? localId,
  }) async {
    try {
      final syncQueue = await Hive.openBox('sync_queue');

      final change = {
        'table': table,
        'operation': operation,
        'data': data,
        'localId': localId ?? data['id'],
        'timestamp': DateTime.now().toIso8601String(),
      };

      await syncQueue.add(change);

      // Try to sync immediately if online
      final connectivityResult = await _connectivity.checkConnectivity();
      if (connectivityResult != ConnectivityResult.none) {
        syncAll();
      }
    } catch (e) {
      print('Error queueing change: $e');
    }
  }

  // Sync workout session
  static Future<void> syncWorkoutSession(Map<String, dynamic> session) async {
    await queueChange(
      table: 'workout_sessions',
      operation: 'insert',
      data: session,
    );
  }

  // Sync workout sets
  static Future<void> syncWorkoutSets(List<Map<String, dynamic>> sets) async {
    for (final set in sets) {
      await queueChange(
        table: 'workout_sets',
        operation: 'insert',
        data: set,
      );
    }
  }

  // Sync nutrition entry
  static Future<void> syncNutritionEntry(Map<String, dynamic> entry) async {
    await queueChange(
      table: 'nutrition_entries',
      operation: 'insert',
      data: entry,
    );
  }

  // Sync sleep entry
  static Future<void> syncSleepEntry(Map<String, dynamic> entry) async {
    await queueChange(
      table: 'sleep_entries',
      operation: 'insert',
      data: entry,
    );
  }

  // Resolve conflict by comparing timestamps (last-write-wins)
  static Map<String, dynamic> _resolveConflict(
    Map<String, dynamic> localData,
    Map<String, dynamic> remoteData,
  ) {
    // Get timestamps
    final localUpdated = localData['updated_at'] != null
        ? DateTime.parse(localData['updated_at'] as String)
        : DateTime.now();
    final remoteUpdated = remoteData['updated_at'] != null
        ? DateTime.parse(remoteData['updated_at'] as String)
        : DateTime.now();

    // Keep the most recent one (last-write-wins)
    return remoteUpdated.isAfter(localUpdated) ? remoteData : localData;
  }

  // Download latest data from cloud
  static Future<void> downloadCloudData() async {
    try {
      // Check connectivity
      final connectivityResult = await _connectivity.checkConnectivity();
      if (connectivityResult == ConnectivityResult.none) {
        return;
      }

      // Download user profile
      final profile = await SupabaseService.getUserProfile();
      if (profile != null) {
        final usersBox = await Hive.openBox('users');
        final localProfile = usersBox.get('current_user');
        
        // Resolve conflict if local data exists
        if (localProfile != null) {
          final resolved = _resolveConflict(localProfile, profile);
          await usersBox.put('current_user', resolved);
        } else {
          await usersBox.put('current_user', profile);
        }
      }

      // Download recent workouts
      final workouts = await SupabaseService.getWorkoutSessions(limit: 50);
      final sessionsBox = await Hive.openBox('workout_sessions');
      for (final workout in workouts) {
        await sessionsBox.put(workout['id'], workout);
      }

      // Download exercises
      final exercises = await SupabaseService.getExercises();
      final exercisesBox = await Hive.openBox('exercises');
      for (final exercise in exercises) {
        await exercisesBox.put(exercise['id'], exercise);
      }

      // Download recent nutrition
      final nutrition = await SupabaseService.getNutritionEntries();
      final nutritionBox = await Hive.openBox('nutrition_entries');
      for (final entry in nutrition) {
        await nutritionBox.put(entry['id'], entry);
      }

      // Download recent sleep
      final sleep = await SupabaseService.getSleepEntries(limit: 30);
      final sleepBox = await Hive.openBox('sleep_entries');
      for (final entry in sleep) {
        await sleepBox.put(entry['id'], entry);
      }

      print('Downloaded cloud data successfully');
    } catch (e) {
      print('Error downloading cloud data: $e');
    }
  }

  // Get sync status
  static Future<Map<String, dynamic>> getSyncStatus() async {
    final syncQueue = await Hive.openBox('sync_queue');
    final connectivityResult = await _connectivity.checkConnectivity();

    return {
      'pendingChanges': syncQueue.length,
      'isOnline': connectivityResult != ConnectivityResult.none,
      'isSyncing': _isSyncing,
      'lastSync': syncQueue.isEmpty
          ? 'All synced'
          : '${syncQueue.length} items pending',
    };
  }
}
