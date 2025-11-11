import 'package:flutter/services.dart';
import 'package:vibration/vibration.dart';

class HapticFeedbackUtil {
  // Light tap
  static Future<void> light() async {
    await HapticFeedback.lightImpact();
  }

  // Medium tap
  static Future<void> medium() async {
    await HapticFeedback.mediumImpact();
  }

  // Heavy tap
  static Future<void> heavy() async {
    await HapticFeedback.heavyImpact();
  }

  // Selection changed
  static Future<void> selection() async {
    await HapticFeedback.selectionClick();
  }

  // Success vibration pattern
  static Future<void> success() async {
    if (await Vibration.hasVibrator() ?? false) {
      await Vibration.vibrate(duration: 100);
      await Future.delayed(const Duration(milliseconds: 50));
      await Vibration.vibrate(duration: 100);
    }
  }

  // Error vibration pattern
  static Future<void> error() async {
    if (await Vibration.hasVibrator() ?? false) {
      await Vibration.vibrate(duration: 300);
    }
  }

  // Custom pattern
  static Future<void> custom({
    required List<int> pattern,
  }) async {
    if (await Vibration.hasVibrator() ?? false) {
      await Vibration.vibrate(pattern: pattern);
    }
  }

  // Celebration pattern (for PRs)
  static Future<void> celebration() async {
    if (await Vibration.hasVibrator() ?? false) {
      await Vibration.vibrate(pattern: [0, 100, 50, 100, 50, 200]);
    }
  }
}
