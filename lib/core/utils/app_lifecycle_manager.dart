import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Tracks app lifecycle to detect fresh app starts
class AppLifecycleManager with WidgetsBindingObserver {
  static final AppLifecycleManager _instance = AppLifecycleManager._internal();
  factory AppLifecycleManager() => _instance;
  AppLifecycleManager._internal();

  bool _isAppInForeground = true;
  bool _wasAppKilled = false;

  void initialize() {
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
      // App came to foreground
        _isAppInForeground = true;
        break;
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
      // App went to background
        _isAppInForeground = false;
        break;
      case AppLifecycleState.detached:
      // App was killed
        _wasAppKilled = true;
        _isAppInForeground = false;
        break;
      case AppLifecycleState.hidden:
        // TODO: Handle this case.
        throw UnimplementedError();
    }
  }

  /// Returns true if this is the first time the app is opening since it was killed
  bool get isFreshAppStart {
    // If app was killed and now it's in foreground, it's a fresh start
    if (_wasAppKilled && _isAppInForeground) {
      _wasAppKilled = false; // Reset for next time
      return true;
    }
    return false;
  }

  /// Manually mark app as killed (for testing)
  void markAppAsKilled() {
    _wasAppKilled = true;
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
  }
}