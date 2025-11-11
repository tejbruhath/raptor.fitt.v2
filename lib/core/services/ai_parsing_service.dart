import 'dart:convert';
import 'package:dart_openai/dart_openai.dart';

class AIParsingService {
  static const String systemPrompt = '''
You are a fitness logging assistant. Parse user input into structured workout or nutrition data.

For workout input (e.g., "bench 80 3 10"):
- Extract: exercise name, weight (kg), sets, reps
- Return JSON: {"type": "workout", "exercise": "bench press", "weight": 80, "sets": 3, "reps": 10}

For nutrition input (e.g., "chicken 100"):
- Extract: food name, serving size (g)
- Return JSON: {"type": "nutrition", "food": "chicken breast", "serving": 100}

If unclear, ask for clarification.
Always return valid JSON.
''';

  // Initialize OpenAI (call this in main with API key)
  static void init(String apiKey) {
    OpenAI.apiKey = apiKey;
  }

  // Parse workout input
  static Future<Map<String, dynamic>?> parseWorkoutInput(String input) async {
    try {
      final response = await OpenAI.instance.chat.create(
        model: 'gpt-4o-mini',
        messages: [
          OpenAIChatCompletionChoiceMessageModel(
            role: OpenAIChatMessageRole.system,
            content: [OpenAIChatCompletionChoiceMessageContentItemModel.text(systemPrompt)],
          ),
          OpenAIChatCompletionChoiceMessageModel(
            role: OpenAIChatMessageRole.user,
            content: [OpenAIChatCompletionChoiceMessageContentItemModel.text(input)],
          ),
        ],
        temperature: 0.3,
        maxTokens: 200,
      );

      final content = response.choices.first.message.content?.first.text;
      if (content != null) {
        return jsonDecode(content);
      }
      return null;
    } catch (e) {
      print('AI Parsing Error: $e');
      return _fallbackParse(input);
    }
  }

  // Fallback parsing using regex (if AI fails)
  static Map<String, dynamic>? _fallbackParse(String input) {
    // Pattern: "exercise weight sets reps" (e.g., "bench 80 3 10")
    final workoutPattern = RegExp(
      r'(\w+(?:\s+\w+)?)\s+(\d+(?:\.\d+)?)\s+(\d+)\s+(\d+)',
      caseSensitive: false,
    );
    
    final match = workoutPattern.firstMatch(input.toLowerCase());
    if (match != null) {
      return {
        'type': 'workout',
        'exercise': match.group(1),
        'weight': double.parse(match.group(2)!),
        'sets': int.parse(match.group(3)!),
        'reps': int.parse(match.group(4)!),
      };
    }

    // Pattern: "food serving" (e.g., "chicken 100")
    final nutritionPattern = RegExp(
      r'(\w+(?:\s+\w+)?)\s+(\d+(?:\.\d+)?)',
      caseSensitive: false,
    );
    
    final nutritionMatch = nutritionPattern.firstMatch(input.toLowerCase());
    if (nutritionMatch != null) {
      return {
        'type': 'nutrition',
        'food': nutritionMatch.group(1),
        'serving': double.parse(nutritionMatch.group(2)!),
      };
    }

    return null;
  }

  // Parse nutrition input
  static Future<Map<String, dynamic>?> parseNutritionInput(String input) async {
    return parseWorkoutInput(input); // Uses same parsing logic
  }

  // Match exercise name to database
  static String matchExerciseName(String input, List<String> exerciseNames) {
    input = input.toLowerCase().trim();
    
    // Exact match
    for (var name in exerciseNames) {
      if (name.toLowerCase() == input) return name;
    }
    
    // Partial match
    for (var name in exerciseNames) {
      if (name.toLowerCase().contains(input) || input.contains(name.toLowerCase())) {
        return name;
      }
    }
    
    // Common aliases
    final aliases = {
      'bench': 'Bench Press',
      'squat': 'Squat',
      'dead': 'Deadlift',
      'deadlift': 'Deadlift',
      'ohp': 'Overhead Press',
      'press': 'Overhead Press',
      'pullup': 'Pull-up',
      'chinup': 'Pull-up',
      'row': 'Barbell Row',
      'curl': 'Barbell Curl',
      'tricep': 'Tricep Extension',
    };
    
    for (var key in aliases.keys) {
      if (input.contains(key)) {
        return aliases[key]!;
      }
    }
    
    // Default to first match or return input capitalized
    return _capitalize(input);
  }

  static String _capitalize(String text) {
    return text.split(' ').map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }

  // Generate AI insights/summary
  static Future<String> generateWorkoutSummary({
    required Map<String, dynamic> workoutData,
  }) async {
    try {
      final prompt = '''
Generate a brief, motivational workout summary based on:
- Total volume: ${workoutData['totalVolume']} kg
- Exercises: ${workoutData['exercises']}
- Duration: ${workoutData['duration']} minutes
- Previous session comparison: ${workoutData['comparison']}

Keep it under 50 words, energetic tone.
''';

      final response = await OpenAI.instance.chat.create(
        model: 'gpt-4o-mini',
        messages: [
          OpenAIChatCompletionChoiceMessageModel(
            role: OpenAIChatMessageRole.user,
            content: [OpenAIChatCompletionChoiceMessageContentItemModel.text(prompt)],
          ),
        ],
        temperature: 0.7,
        maxTokens: 100,
      );

      return response.choices.first.message.content?.first.text ?? 
          'Great workout! Keep pushing 🔥';
    } catch (e) {
      print('AI Summary Error: $e');
      return 'Solid session! Keep the momentum going 💪';
    }
  }

  // Generate recovery advice
  static Future<String> generateRecoveryAdvice({
    required double recoveryScore,
    required double sleepHours,
    required int sorenessLevel,
  }) async {
    try {
      final prompt = '''
Based on:
- Recovery score: $recoveryScore/100
- Sleep: $sleepHours hours
- Soreness: $sorenessLevel/10

Give 1-2 sentence recovery advice. Be supportive and actionable.
''';

      final response = await OpenAI.instance.chat.create(
        model: 'gpt-4o-mini',
        messages: [
          OpenAIChatCompletionChoiceMessageModel(
            role: OpenAIChatMessageRole.user,
            content: [OpenAIChatCompletionChoiceMessageContentItemModel.text(prompt)],
          ),
        ],
        temperature: 0.7,
        maxTokens: 80,
      );

      return response.choices.first.message.content?.first.text ?? 
          'Listen to your body today.';
    } catch (e) {
      if (recoveryScore < 50) {
        return 'Recovery is low. Consider light activity or rest today.';
      } else {
        return 'Recovery looks good! You\'re ready to train hard.';
      }
    }
  }
}
