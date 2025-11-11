import 'package:hive/hive.dart';

part 'user_model.g.dart';

@HiveType(typeId: 0)
class UserModel extends HiveObject {
  @HiveField(0)
  String id;
  
  @HiveField(1)
  String name;
  
  @HiveField(2)
  int age;
  
  @HiveField(3)
  String sex; // 'Male', 'Female', 'Other'
  
  @HiveField(4)
  double height; // in cm
  
  @HiveField(5)
  double weight; // in kg
  
  @HiveField(6)
  String fitnessGoal; // 'bulk', 'cut', 'recomp', 'maintain'
  
  @HiveField(7)
  double? bodyFatPercentage;
  
  @HiveField(8)
  String experienceLevel; // 'beginner', 'intermediate', 'advanced'
  
  @HiveField(9)
  double? tdee; // Total Daily Energy Expenditure
  
  @HiveField(10)
  double? targetCalories;
  
  @HiveField(11)
  double? targetProtein;
  
  @HiveField(12)
  double? targetCarbs;
  
  @HiveField(13)
  double? targetFat;
  
  @HiveField(14)
  DateTime createdAt;
  
  @HiveField(15)
  DateTime updatedAt;
  
  @HiveField(16)
  String? profileImageUrl;
  
  @HiveField(17)
  int currentStreak;
  
  @HiveField(18)
  int longestStreak;

  UserModel({
    required this.id,
    required this.name,
    required this.age,
    required this.sex,
    required this.height,
    required this.weight,
    required this.fitnessGoal,
    this.bodyFatPercentage,
    required this.experienceLevel,
    this.tdee,
    this.targetCalories,
    this.targetProtein,
    this.targetCarbs,
    this.targetFat,
    required this.createdAt,
    required this.updatedAt,
    this.profileImageUrl,
    this.currentStreak = 0,
    this.longestStreak = 0,
  });

  // Calculate TDEE using Mifflin-St Jeor Equation
  double calculateTDEE({double activityMultiplier = 1.55}) {
    double bmr;
    if (sex.toLowerCase() == 'male') {
      bmr = (10 * weight) + (6.25 * height) - (5 * age) + 5;
    } else {
      bmr = (10 * weight) + (6.25 * height) - (5 * age) - 161;
    }
    return bmr * activityMultiplier;
  }

  // Adjust macros based on goal
  Map<String, double> calculateMacros() {
    double calories = tdee ?? calculateTDEE();
    
    switch (fitnessGoal.toLowerCase()) {
      case 'bulk':
        calories += 300; // Surplus
        break;
      case 'cut':
        calories -= 500; // Deficit
        break;
      case 'recomp':
        // Maintain
        break;
      default:
        break;
    }
    
    // Protein: 2g per kg body weight
    double protein = weight * 2;
    
    // Fat: 25% of calories
    double fatCalories = calories * 0.25;
    double fat = fatCalories / 9; // 9 calories per gram of fat
    
    // Carbs: remaining calories
    double remainingCalories = calories - (protein * 4) - (fat * 9);
    double carbs = remainingCalories / 4; // 4 calories per gram of carbs
    
    return {
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
    };
  }

  // Serialization methods for Supabase sync
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'age': age,
      'sex': sex,
      'height': height,
      'weight': weight,
      'fitness_goal': fitnessGoal,
      'body_fat_percentage': bodyFatPercentage,
      'experience_level': experienceLevel,
      'tdee': tdee,
      'target_calories': targetCalories,
      'target_protein': targetProtein,
      'target_carbs': targetCarbs,
      'target_fat': targetFat,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'profile_image_url': profileImageUrl,
      'current_streak': currentStreak,
      'longest_streak': longestStreak,
    };
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      name: json['name'] as String,
      age: json['age'] as int,
      sex: json['sex'] as String,
      height: (json['height'] as num).toDouble(),
      weight: (json['weight'] as num).toDouble(),
      fitnessGoal: json['fitness_goal'] as String,
      bodyFatPercentage: json['body_fat_percentage'] != null 
          ? (json['body_fat_percentage'] as num).toDouble()
          : null,
      experienceLevel: json['experience_level'] as String,
      tdee: json['tdee'] != null ? (json['tdee'] as num).toDouble() : null,
      targetCalories: json['target_calories'] != null 
          ? (json['target_calories'] as num).toDouble()
          : null,
      targetProtein: json['target_protein'] != null 
          ? (json['target_protein'] as num).toDouble()
          : null,
      targetCarbs: json['target_carbs'] != null 
          ? (json['target_carbs'] as num).toDouble()
          : null,
      targetFat: json['target_fat'] != null 
          ? (json['target_fat'] as num).toDouble()
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      profileImageUrl: json['profile_image_url'] as String?,
      currentStreak: json['current_streak'] as int? ?? 0,
      longestStreak: json['longest_streak'] as int? ?? 0,
    );
  }

  UserModel copyWith({
    String? id,
    String? name,
    int? age,
    String? sex,
    double? height,
    double? weight,
    String? fitnessGoal,
    double? bodyFatPercentage,
    String? experienceLevel,
    double? tdee,
    double? targetCalories,
    double? targetProtein,
    double? targetCarbs,
    double? targetFat,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? profileImageUrl,
    int? currentStreak,
    int? longestStreak,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      age: age ?? this.age,
      sex: sex ?? this.sex,
      height: height ?? this.height,
      weight: weight ?? this.weight,
      fitnessGoal: fitnessGoal ?? this.fitnessGoal,
      bodyFatPercentage: bodyFatPercentage ?? this.bodyFatPercentage,
      experienceLevel: experienceLevel ?? this.experienceLevel,
      tdee: tdee ?? this.tdee,
      targetCalories: targetCalories ?? this.targetCalories,
      targetProtein: targetProtein ?? this.targetProtein,
      targetCarbs: targetCarbs ?? this.targetCarbs,
      targetFat: targetFat ?? this.targetFat,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
    );
  }
}
