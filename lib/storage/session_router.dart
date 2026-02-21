import 'dart:convert';
import 'package:chalthee/storage/device_mapper.dart';
import 'package:chalthee/storage/firebase_connect.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SessionManager {

  static const String sessionKey = "session";

  /// Get full cache
  static Future<Map<String, dynamic>> getSession() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(sessionKey);
    if (data == null) {
      return {
        "login": 0,
        "users": []
      };
    }
    print(data);
    return jsonDecode(data);
  }

  /// Save session
  static Future<void> saveSession(Map<String, dynamic> session) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(sessionKey, jsonEncode(session));
  }

  /// Check login status
  static Future<bool> isLoggedIn() async {
    final session = await getSession();
    return session["login"] == 1;
  }

  /// Get current logged user
  static Future<Map<String, dynamic>?> getCurrentUser() async {
    final session = await getSession();
    final users = session["users"] as List;
    for (var user in users) {
      if (user["isloggedin"] == 1) {
        return user;
      }
    }
    return null;
  }

  /// Login user

  static Future<void> loginUser(String name, String mail) async {
    final prefs = await SharedPreferences.getInstance();
    Map<String, dynamic> session;
    Map<String, dynamic>? userData;
    bool found = false;
    final sessionString = prefs.getString(sessionKey);
    if(sessionString == null){
      await DbConnect().getProductsByMail(mail);
    } else {
      List users = jsonDecode(sessionString)["users"];
      for (var user in users) {
        if (user["usermail"] == mail) {
          found = true;
        }
      }
      if(!found){
        userData = await DbConnect().getProductsByMail(mail);
      }
    }

    final sessionData = prefs.getString(sessionKey);
    if (sessionData == null) {
      session = {
        "login": 0,
        "users": []
      };
      await DeviceMapper().getUuid();
    } else {
      session = jsonDecode(sessionData);
    }
    List users = session["users"];
    found = false;
    for (var user in users) {
      if (user["usermail"] == mail) {
        user["isloggedin"] = 1;
        found = true;
      } else {
        user["isloggedin"] = 0;
      }
    }
    if(!found && userData == null) {
        users.add({
          "username": name,
          "usermail": mail,
          "isloggedin": 1,
          "weightMap": {}
        });
    }
    session["login"] = 1;
    await prefs.setString(sessionKey, jsonEncode(session));
  }

  /// Logout current user
  static Future<void> logout() async {
    final session = await getSession();
    List users = session["users"];
    for (var user in users) {
      user["isloggedin"] = 0;
    }
    session["login"] = 0;
    DeviceMapper().changeSyncStatus(false);
    //DbConnect().addProduct(session);
    await saveSession(session);
  }

  static Future<Map<String, dynamic>> getCurrentWeightMap() async {
    final prefs = await SharedPreferences.getInstance();
    final sessionString = prefs.getString(sessionKey);
    if (sessionString == null) return {};
    final session = jsonDecode(sessionString);
    final users = session["users"];
    for (var user in users) {
      if (user["isloggedin"] == 1) {
        return Map<String, dynamic>.from(
          user["weightMap"] ?? {},
        );
      }
    }
    return {};
  }


  static Future<void> saveWeightMap(
      Map<String, dynamic> weightMap) async {
    final prefs = await SharedPreferences.getInstance();
    final sessionString = prefs.getString(sessionKey);
    if (sessionString == null) return;
    final session = jsonDecode(sessionString);
    final users = session["users"];
    for (var user in users) {
      if (user["isloggedin"] == 1) {
        user["weightMap"] = weightMap;
      }
    }
    DeviceMapper().changeSyncStatus(false);
    await prefs.setString(sessionKey, jsonEncode(session));
  }

static Future<void> removeUsers(String mailId) async{
  final prefs = await SharedPreferences.getInstance();
  final sessionString = prefs.getString(sessionKey);
  if (sessionString == null) return;
  final session = jsonDecode(sessionString);
  List users = session["users"];
  users = users.where((user){
    final email = user["usermail"];
    if(email == mailId) return false;
    return true;
  }).toList();
}

  static Future<void> removeUsersWithoutWeightMap() async {
    final prefs = await SharedPreferences.getInstance();
    final sessionString = prefs.getString(sessionKey);
    if (sessionString == null) return;
    final session = jsonDecode(sessionString);
    List users = session["users"];
    /// keep only users that have weightMap and not empty
    users = users.where((user) {
      if (!user.containsKey("weightMap")) return false;
      final weightMap = user["weightMap"];
      if (weightMap == null) return false;
      if (weightMap is Map && weightMap.isEmpty) return false;
      return true;
    }).toList();
    session["users"] = users;
    /// also fix login flag if no users exist
    final hasLoggedInUser =
    users.any((user) => user["isloggedin"] == 1);
    session["login"] = hasLoggedInUser ? 1 : 0;
    await prefs.setString(
      sessionKey,
      jsonEncode(session),
    );
  }

}
