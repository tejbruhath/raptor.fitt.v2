import 'package:hive/hive.dart';

part 'nutrition_entry_model.g.dart';

@HiveType(typeId: 4)
class NutritionEntryModel extends HiveObject {
  @HiveField(0)
  String id;
  
  @HiveField(1)
  String userId;
  
  @HiveField(2)
  String foodName;
  
  @HiveField(3)
  double servingSize; // in grams
  
  @HiveField(4)
  double calories;
  
  @HiveField(5)
  double protein;
  
  @HiveField(6)
  double carbs;
  
  @HiveField(7)
  double fat;
  
  @HiveField(8)
  double? fiber;
  
  @HiveField(9)
  double? sugar;
  
  @HiveField(10)
  DateTime consumedAt;
  
  @HiveField(11)
  String mealType; // 'breakfast', 'lunch', 'dinner', 'snack'
  
  @HiveField(12)
  bool isCustomFood;
  
  @HiveField(13)
  String? notes;

  NutritionEntryModel({
    required this.id,
    required this.userId,
    required this.foodName,
    required this.servingSize,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    this.fiber,
    this.sugar,
    required this.consumedAt,
    required this.mealType,
    this.isCustomFood = false,
    this.notes,
  });

  // Scale macros based on serving size
  NutritionEntryModel scaleToServing(double newServingSize) {
    double scaleFactor = newServingSize / servingSize;
    return copyWith(
      servingSize: newServingSize,
      calories: calories * scaleFactor,
      protein: protein * scaleFactor,
      carbs: carbs * scaleFactor,
      fat: fat * scaleFactor,
      fiber: fiber != null ? fiber! * scaleFactor : null,
      sugar: sugar != null ? sugar! * scaleFactor : null,
    );
  }

  // Serialization methods for Supabase sync
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'food_name': foodName,
      'serving_size': servingSize,
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
      'fiber': fiber,
      'sugar': sugar,
      'consumed_at': consumedAt.toIso8601String(),
      'meal_type': mealType,
      'is_custom_food': isCustomFood,
      'notes': notes,
    };
  }

  factory NutritionEntryModel.fromJson(Map<String, dynamic> json) {
    return NutritionEntryModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      foodName: json['food_name'] as String,
      servingSize: (json['serving_size'] as num).toDouble(),
      calories: (json['calories'] as num).toDouble(),
      protein: (json['protein'] as num).toDouble(),
      carbs: (json['carbs'] as num).toDouble(),
      fat: (json['fat'] as num).toDouble(),
      fiber: json['fiber'] != null ? (json['fiber'] as num).toDouble() : null,
      sugar: json['sugar'] != null ? (json['sugar'] as num).toDouble() : null,
      consumedAt: DateTime.parse(json['consumed_at'] as String),
      mealType: json['meal_type'] as String,
      isCustomFood: json['is_custom_food'] as bool? ?? false,
      notes: json['notes'] as String?,
    );
  }

  NutritionEntryModel copyWith({
    String? id,
    String? userId,
    String? foodName,
    double? servingSize,
    double? calories,
    double? protein,
    double? carbs,
    double? fat,
    double? fiber,
    double? sugar,
    DateTime? consumedAt,
    String? mealType,
    bool? isCustomFood,
    String? notes,
  }) {
    return NutritionEntryModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      foodName: foodName ?? this.foodName,
      servingSize: servingSize ?? this.servingSize,
      calories: calories ?? this.calories,
      protein: protein ?? this.protein,
      carbs: carbs ?? this.carbs,
      fat: fat ?? this.fat,
      fiber: fiber ?? this.fiber,
      sugar: sugar ?? this.sugar,
      consumedAt: consumedAt ?? this.consumedAt,
      mealType: mealType ?? this.mealType,
      isCustomFood: isCustomFood ?? this.isCustomFood,
      notes: notes ?? this.notes,
    );
  }
}
