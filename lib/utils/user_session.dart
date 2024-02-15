import 'package:shared_preferences/shared_preferences.dart';

class UserSession {
  static Future<void> storeUserId({required String userId}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userId', userId);
  }

  static Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('userId');
  }
}
