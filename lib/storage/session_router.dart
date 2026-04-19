import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:chalthee/storage/device_mapper.dart';
import 'package:chalthee/storage/firebase_connect.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SessionManager {

  /// Check login status
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('loginStatus') ?? false;
  }

  static Future<String?> getUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('userEmail');
  }

  static Future<String?> getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('userName');
  }

  /// Get current logged user (stubbed structure for compatibility)
  static Future<Map<String, dynamic>?> getCurrentUser() async {
    final email = await getUserEmail();
    final name = await getUserName();
    if (email != null) {
      return {
        "usermail": email,
        "username": name ?? "User",
        "isloggedin": 1
      };
    }
    return null;
  }

  /// Login user
  static Future<bool> loginUser(String name, String mail) async {
    final prefs = await SharedPreferences.getInstance();
    // Check if user exists in Firebase.
    final existingUserMap = await DbConnect().getProductsByMail(mail);
    if (existingUserMap == null) {
       // Create new user record aligned to this unique device UUID because they aren't in Firebase
       await DbConnect().createNewUserRecord(name, mail);
    }
    await prefs.setBool('loginStatus', true);
    await prefs.setString('userEmail', mail);
    await prefs.setString('userName', name);
    return true;
  }

  /// Logout current user
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('loginStatus');
    await prefs.remove('userEmail');
    await prefs.remove('userName');
    cleanLocalPreferences(prefs);
    DeviceMapper().changeSyncStatus(false);
  }

  static Future<void> cleanLocalPreferences(SharedPreferences prefs) async{
    await prefs.remove("syncHealth");
    await prefs.remove("height");
    await prefs.remove("isKg");
    await prefs.remove("goalWeight");
    await prefs.remove('alarmTime');
    await AndroidAlarmManager.cancel(1);
  }

  static Future<double> getLocalPreferencesHeight() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getDouble("height") ?? 0.0;
  }

  static Future<double> getLocalPreferencesWeight() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getDouble("goalWeight") ?? 0.0;
  }

}
