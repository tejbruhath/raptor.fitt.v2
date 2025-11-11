import 'package:hive/hive.dart';

part 'sleep_entry_model.g.dart';

@HiveType(typeId: 5)
class SleepEntryModel extends HiveObject {
  @HiveField(0)
  String id;
  
  @HiveField(1)
  String userId;
  
  @HiveField(2)
  DateTime sleepDate;
  
  @HiveField(3)
  double hoursSlept;
  
  @HiveField(4)
  int sleepQuality; // 1-10 scale
  
  @HiveField(5)
  int sorenessLevel; // 1-10 scale
  
  @HiveField(6)
  int energyLevel; // 1-10 scale
  
  @HiveField(7)
  int stressLevel; // 1-10 scale
  
  @HiveField(8)
  bool hadRestlessness;
  
  @HiveField(9)
  String? notes;
  
  @HiveField(10)
  DateTime createdAt;

  SleepEntryModel({
    required this.id,
    required this.userId,
    required this.sleepDate,
    required this.hoursSlept,
    required this.sleepQuality,
    required this.sorenessLevel,
    required this.energyLevel,
    required this.stressLevel,
    this.hadRestlessness = false,
    this.notes,
    required this.createdAt,
  });

  // Calculate recovery score (0-100)
  double get recoveryScore {
    double sleepScore = (hoursSlept / 8) * 25; // 25 points max
    double qualityScore = (sleepQuality / 10) * 25; // 25 points max
    double sorenessScore = ((10 - sorenessLevel) / 10) * 25; // 25 points max (inverse)
    double energyScore = (energyLevel / 10) * 25; // 25 points max
    
    double total = sleepScore + qualityScore + sorenessScore + energyScore;
    return total.clamp(0, 100);
  }

  // Determine recovery status
  String get recoveryStatus {
    double score = recoveryScore;
    if (score >= 80) return 'Excellent';
    if (score >= 60) return 'Good';
    if (score >= 40) return 'Moderate';
    if (score >= 20) return 'Poor';
    return 'Very Poor';
  }

  // Check if user needs rest
  bool get needsRest {
    return recoveryScore < 50 || sorenessLevel >= 7 || hoursSlept < 6;
  }

  // Serialization methods for Supabase sync
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'sleep_date': sleepDate.toIso8601String(),
      'hours_slept': hoursSlept,
      'sleep_quality': sleepQuality,
      'soreness_level': sorenessLevel,
      'energy_level': energyLevel,
      'stress_level': stressLevel,
      'had_restlessness': hadRestlessness,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory SleepEntryModel.fromJson(Map<String, dynamic> json) {
    return SleepEntryModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      sleepDate: DateTime.parse(json['sleep_date'] as String),
      hoursSlept: (json['hours_slept'] as num).toDouble(),
      sleepQuality: json['sleep_quality'] as int,
      sorenessLevel: json['soreness_level'] as int,
      energyLevel: json['energy_level'] as int,
      stressLevel: json['stress_level'] as int,
      hadRestlessness: json['had_restlessness'] as bool? ?? false,
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  SleepEntryModel copyWith({
    String? id,
    String? userId,
    DateTime? sleepDate,
    double? hoursSlept,
    int? sleepQuality,
    int? sorenessLevel,
    int? energyLevel,
    int? stressLevel,
    bool? hadRestlessness,
    String? notes,
    DateTime? createdAt,
  }) {
    return SleepEntryModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      sleepDate: sleepDate ?? this.sleepDate,
      hoursSlept: hoursSlept ?? this.hoursSlept,
      sleepQuality: sleepQuality ?? this.sleepQuality,
      sorenessLevel: sorenessLevel ?? this.sorenessLevel,
      energyLevel: energyLevel ?? this.energyLevel,
      stressLevel: stressLevel ?? this.stressLevel,
      hadRestlessness: hadRestlessness ?? this.hadRestlessness,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
