import 'package:hive/hive.dart';

part 'workout_set_model.g.dart';

@HiveType(typeId: 2)
class WorkoutSetModel extends HiveObject {
  @HiveField(0)
  String id;
  
  @HiveField(1)
  String exerciseId;
  
  @HiveField(2)
  int setNumber;
  
  @HiveField(3)
  double weight; // in kg
  
  @HiveField(4)
  int reps;
  
  @HiveField(5)
  int? rpe; // Rate of Perceived Exertion (1-10)
  
  @HiveField(6)
  bool isWarmup;
  
  @HiveField(7)
  bool isFailure;
  
  @HiveField(8)
  int? restTime; // in seconds
  
  @HiveField(9)
  String? notes;
  
  @HiveField(10)
  DateTime completedAt;

  WorkoutSetModel({
    required this.id,
    required this.exerciseId,
    required this.setNumber,
    required this.weight,
    required this.reps,
    this.rpe,
    this.isWarmup = false,
    this.isFailure = false,
    this.restTime,
    this.notes,
    required this.completedAt,
  });

  // Calculate volume (weight × reps)
  double get volume => weight * reps;

  // Calculate estimated 1RM using Epley formula
  double get estimated1RM {
    if (reps == 1) return weight;
    return weight * (1 + reps / 30);
  }

  // Serialization methods for Supabase sync
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'exercise_id': exerciseId,
      'set_number': setNumber,
      'weight': weight,
      'reps': reps,
      'rpe': rpe,
      'is_warmup': isWarmup,
      'is_failure': isFailure,
      'rest_time': restTime,
      'notes': notes,
      'completed_at': completedAt.toIso8601String(),
    };
  }

  factory WorkoutSetModel.fromJson(Map<String, dynamic> json) {
    return WorkoutSetModel(
      id: json['id'] as String,
      exerciseId: json['exercise_id'] as String,
      setNumber: json['set_number'] as int,
      weight: (json['weight'] as num).toDouble(),
      reps: json['reps'] as int,
      rpe: json['rpe'] as int?,
      isWarmup: json['is_warmup'] as bool? ?? false,
      isFailure: json['is_failure'] as bool? ?? false,
      restTime: json['rest_time'] as int?,
      notes: json['notes'] as String?,
      completedAt: DateTime.parse(json['completed_at'] as String),
    );
  }

  WorkoutSetModel copyWith({
    String? id,
    String? exerciseId,
    int? setNumber,
    double? weight,
    int? reps,
    int? rpe,
    bool? isWarmup,
    bool? isFailure,
    int? restTime,
    String? notes,
    DateTime? completedAt,
  }) {
    return WorkoutSetModel(
      id: id ?? this.id,
      exerciseId: exerciseId ?? this.exerciseId,
      setNumber: setNumber ?? this.setNumber,
      weight: weight ?? this.weight,
      reps: reps ?? this.reps,
      rpe: rpe ?? this.rpe,
      isWarmup: isWarmup ?? this.isWarmup,
      isFailure: isFailure ?? this.isFailure,
      restTime: restTime ?? this.restTime,
      notes: notes ?? this.notes,
      completedAt: completedAt ?? this.completedAt,
    );
  }
}
