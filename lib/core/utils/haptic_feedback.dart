import 'dart:async';

import 'package:flutter/services.dart';

/// iOS-style haptic feedback utilities
///
/// Use these methods to provide tactile feedback for user interactions,
/// making the app feel more native and responsive on iOS devices.
class HapticFeedbackHelper {
  /// Light impact haptic - for subtle selections and toggles
  ///
  /// Use for: checkbox toggles, segmented control changes, list item selections
  static Future<void> lightImpact() async {
    await HapticFeedback.lightImpact();
  }

  /// Medium impact haptic - for moderate actions
  ///
  /// Use for: button taps, successful form submissions, refreshing data
  static Future<void> mediumImpact() async {
    await HapticFeedback.mediumImpact();
  }

  /// Heavy impact haptic - for significant actions
  ///
  /// Use for: confirming important actions, completing major tasks
  static Future<void> heavyImpact() async {
    await HapticFeedback.heavyImpact();
  }

  /// Selection click haptic - for scrolling through options
  ///
  /// Use for: picker wheel changes, scrolling through discrete items
  static Future<void> selectionClick() async {
    await HapticFeedback.selectionClick();
  }

  /// Vibrate - general purpose vibration
  ///
  /// Note: Consider using more specific haptic types above for better UX
  static Future<void> vibrate() async {
    await HapticFeedback.vibrate();
  }

  /// Success haptic - indicates successful completion
  ///
  /// Combination of medium impact for iOS-like success feel
  static Future<void> success() async {
    await HapticFeedback.mediumImpact();
  }

  /// Error haptic - indicates an error or failed action
  ///
  /// Uses heavy impact to grab attention
  static Future<void> error() async {
    await HapticFeedback.heavyImpact();
  }

  /// Warning haptic - indicates caution needed
  ///
  /// Medium impact for warning scenarios
  static Future<void> warning() async {
    await HapticFeedback.mediumImpact();
  }
}

typedef AsyncVoidCallback = Future<void> Function();

/// Extension on synchronous callbacks to easily add haptic feedback
extension HapticFeedbackExtension on VoidCallback {
  /// Wraps a callback with light haptic feedback
  AsyncVoidCallback withLightHaptic() {
    return () async {
      await HapticFeedbackHelper.lightImpact();
      this();
    };
  }

  /// Wraps a callback with medium haptic feedback
  AsyncVoidCallback withMediumHaptic() {
    return () async {
      await HapticFeedbackHelper.mediumImpact();
      this();
    };
  }

  /// Wraps a callback with heavy haptic feedback
  AsyncVoidCallback withHeavyHaptic() {
    return () async {
      await HapticFeedbackHelper.heavyImpact();
      this();
    };
  }
}

/// Extension for already async callbacks so they can be wrapped without losing awaiting behaviour
extension AsyncHapticFeedbackExtension on AsyncVoidCallback {
  /// Wraps an async callback with light haptic feedback
  AsyncVoidCallback withLightHaptic() {
    return () async {
      await HapticFeedbackHelper.lightImpact();
      await this();
    };
  }

  /// Wraps an async callback with medium haptic feedback
  AsyncVoidCallback withMediumHaptic() {
    return () async {
      await HapticFeedbackHelper.mediumImpact();
      await this();
    };
  }

  /// Wraps an async callback with heavy haptic feedback
  AsyncVoidCallback withHeavyHaptic() {
    return () async {
      await HapticFeedbackHelper.heavyImpact();
      await this();
    };
  }
}

/// Usage Examples:
/// 
/// ```dart
/// // Simple usage
/// ElevatedButton(
///   onPressed: () async {
///     await HapticFeedbackHelper.mediumImpact();
///     // Your action
///   },
///   child: Text('Tap Me'),
/// )
/// 
/// // With extension
/// ElevatedButton(
///   onPressed: (() {
///     // Your action
///   }).withMediumHaptic(),
///   child: Text('Tap Me'),
/// )
/// 
/// // Success feedback
/// try {
///   await saveTransaction();
///   await HapticFeedbackHelper.success();
/// } catch (e) {
///   await HapticFeedbackHelper.error();
/// }
/// ```
