import 'package:shared_preferences/shared_preferences.dart';

class AppSessionService {
  static const String _appStartTimeKey = 'app_start_time';
  static const String _messageShownForCurrentSessionKey = 'message_shown_for_current_session';
  static const int _sessionTimeoutHours = 1; // Consider new session after 1 hour of inactivity

  Future<bool> shouldShowMotivationalMessage() async {
    final prefs = await SharedPreferences.getInstance();
    final messageShown = prefs.getBool(_messageShownForCurrentSessionKey) ?? false;

    // Check if we're in a new app session
    final isNewSession = await _isNewAppSession();

    // Reset message shown flag for new session
    if (isNewSession) {
      await prefs.setBool(_messageShownForCurrentSessionKey, false);
      return true;
    }

    // Same session, check if message already shown
    return !messageShown;
  }

  Future<bool> _isNewAppSession() async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();

    // Get last app start time
    final lastStartTimeString = prefs.getString(_appStartTimeKey);

    if (lastStartTimeString == null) {
      // First time ever
      await prefs.setString(_appStartTimeKey, now.toIso8601String());
      return true;
    }

    try {
      final lastStartTime = DateTime.parse(lastStartTimeString);
      final timeSinceLastStart = now.difference(lastStartTime);

      // If more than sessionTimeoutHours have passed, consider it a new session
      if (timeSinceLastStart.inHours >= _sessionTimeoutHours) {
        await prefs.setString(_appStartTimeKey, now.toIso8601String());
        return true;
      }

      return false;
    } catch (e) {
      // On error, treat as new session
      await prefs.setString(_appStartTimeKey, now.toIso8601String());
      return true;
    }
  }

  Future<void> markMessageAsShown() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_messageShownForCurrentSessionKey, true);
  }

  Future<void> resetSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_appStartTimeKey);
    await prefs.remove(_messageShownForCurrentSessionKey);
  }
}