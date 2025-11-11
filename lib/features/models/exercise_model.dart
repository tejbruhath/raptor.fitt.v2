import 'package:hive/hive.dart';

part 'exercise_model.g.dart';

@HiveType(typeId: 1)
class ExerciseModel extends HiveObject {
  @HiveField(0)
  String id;
  
  @HiveField(1)
  String name;
  
  @HiveField(2)
  String category; // 'chest', 'back', 'legs', 'shoulders', 'arms', 'core'
  
  @HiveField(3)
  String muscleGroup; // specific muscle
  
  @HiveField(4)
  String type; // 'compound', 'isolation', 'cardio'
  
  @HiveField(5)
  String equipment; // 'barbell', 'dumbbell', 'machine', 'bodyweight', 'cable'
  
  @HiveField(6)
  String? description;
  
  @HiveField(7)
  bool isFavorite;
  
  @HiveField(8)
  int timesPerformed;
  
  @HiveField(9)
  DateTime? lastPerformed;
  
  @HiveField(10)
  double? personalBest; // max weight lifted
  
  @HiveField(11)
  DateTime? personalBestDate;

  ExerciseModel({
    required this.id,
    required this.name,
    required this.category,
    required this.muscleGroup,
    required this.type,
    required this.equipment,
    this.description,
    this.isFavorite = false,
    this.timesPerformed = 0,
    this.lastPerformed,
    this.personalBest,
    this.personalBestDate,
  });

  // Serialization methods for Supabase sync
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'muscle_group': muscleGroup,
      'type': type,
      'equipment': equipment,
      'description': description,
      'is_favorite': isFavorite,
      'times_performed': timesPerformed,
      'last_performed': lastPerformed?.toIso8601String(),
      'personal_best': personalBest,
      'personal_best_date': personalBestDate?.toIso8601String(),
    };
  }

  factory ExerciseModel.fromJson(Map<String, dynamic> json) {
    return ExerciseModel(
      id: json['id'] as String,
      name: json['name'] as String,
      category: json['category'] as String,
      muscleGroup: json['muscle_group'] as String,
      type: json['type'] as String,
      equipment: json['equipment'] as String,
      description: json['description'] as String?,
      isFavorite: json['is_favorite'] as bool? ?? false,
      timesPerformed: json['times_performed'] as int? ?? 0,
      lastPerformed: json['last_performed'] != null
          ? DateTime.parse(json['last_performed'] as String)
          : null,
      personalBest: json['personal_best'] != null
          ? (json['personal_best'] as num).toDouble()
          : null,
      personalBestDate: json['personal_best_date'] != null
          ? DateTime.parse(json['personal_best_date'] as String)
          : null,
    );
  }

  ExerciseModel copyWith({
    String? id,
    String? name,
    String? category,
    String? muscleGroup,
    String? type,
    String? equipment,
    String? description,
    bool? isFavorite,
    int? timesPerformed,
    DateTime? lastPerformed,
    double? personalBest,
    DateTime? personalBestDate,
  }) {
    return ExerciseModel(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      muscleGroup: muscleGroup ?? this.muscleGroup,
      type: type ?? this.type,
      equipment: equipment ?? this.equipment,
      description: description ?? this.description,
      isFavorite: isFavorite ?? this.isFavorite,
      timesPerformed: timesPerformed ?? this.timesPerformed,
      lastPerformed: lastPerformed ?? this.lastPerformed,
      personalBest: personalBest ?? this.personalBest,
      personalBestDate: personalBestDate ?? this.personalBestDate,
    );
  }
}
