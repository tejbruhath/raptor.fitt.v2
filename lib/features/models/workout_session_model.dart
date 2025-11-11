import 'package:hive/hive.dart';
import 'workout_set_model.dart';

part 'workout_session_model.g.dart';

@HiveType(typeId: 3)
class WorkoutSessionModel extends HiveObject {
  @HiveField(0)
  String id;
  
  @HiveField(1)
  String userId;
  
  @HiveField(2)
  String name;
  
  @HiveField(3)
  DateTime startTime;
  
  @HiveField(4)
  DateTime? endTime;
  
  @HiveField(5)
  List<String> exerciseIds; // IDs of exercises performed
  
  @HiveField(6)
  List<String> setIds; // IDs of all sets in this session
  
  @HiveField(7)
  String? notes;
  
  @HiveField(8)
  int? overallRating; // 1-10 how good was the workout
  
  @HiveField(9)
  bool isCompleted;
  
  @HiveField(10)
  String? focusArea; // 'push', 'pull', 'legs', 'upper', 'lower', 'full'

  WorkoutSessionModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.startTime,
    this.endTime,
    required this.exerciseIds,
    required this.setIds,
    this.notes,
    this.overallRating,
    this.isCompleted = false,
    this.focusArea,
  });

  // Calculate total duration
  Duration? get duration {
    if (endTime == null) return null;
    return endTime!.difference(startTime);
  }

  // Calculate total volume from sets
  double calculateTotalVolume(List<WorkoutSetModel> sets) {
    return sets
        .where((set) => setIds.contains(set.id) && !set.isWarmup)
        .fold(0.0, (sum, set) => sum + set.volume);
  }

  // Calculate total sets (excluding warmups)
  int calculateTotalSets(List<WorkoutSetModel> sets) {
    return sets
        .where((set) => setIds.contains(set.id) && !set.isWarmup)
        .length;
  }

  // Serialization methods for Supabase sync
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'start_time': startTime.toIso8601String(),
      'end_time': endTime?.toIso8601String(),
      'notes': notes,
      'overall_rating': overallRating,
      'is_completed': isCompleted,
      'focus_area': focusArea,
    };
  }

  factory WorkoutSessionModel.fromJson(Map<String, dynamic> json) {
    return WorkoutSessionModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      name: json['name'] as String,
      startTime: DateTime.parse(json['start_time'] as String),
      endTime: json['end_time'] != null 
          ? DateTime.parse(json['end_time'] as String)
          : null,
      exerciseIds: (json['exercise_ids'] as List?)?.cast<String>() ?? [],
      setIds: (json['set_ids'] as List?)?.cast<String>() ?? [],
      notes: json['notes'] as String?,
      overallRating: json['overall_rating'] as int?,
      isCompleted: json['is_completed'] as bool? ?? false,
      focusArea: json['focus_area'] as String?,
    );
  }

  WorkoutSessionModel copyWith({
    String? id,
    String? userId,
    String? name,
    DateTime? startTime,
    DateTime? endTime,
    List<String>? exerciseIds,
    List<String>? setIds,
    String? notes,
    int? overallRating,
    bool? isCompleted,
    String? focusArea,
  }) {
    return WorkoutSessionModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      exerciseIds: exerciseIds ?? this.exerciseIds,
      setIds: setIds ?? this.setIds,
      notes: notes ?? this.notes,
      overallRating: overallRating ?? this.overallRating,
      isCompleted: isCompleted ?? this.isCompleted,
      focusArea: focusArea ?? this.focusArea,
    );
  }
}
