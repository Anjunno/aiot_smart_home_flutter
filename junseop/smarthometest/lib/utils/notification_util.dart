import 'package:shared_preferences/shared_preferences.dart';

Future<bool> isNotificationEnabled() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getBool('notifications_enabled') ?? true;
}

