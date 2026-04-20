import 'dart:convert';
import 'package:chalthee/constants/constant_values.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class DeviceMapper {
  static final String _key = ConstantValues.uniqueDeviceIdCache;
  bool isSynced = true;

  Future<String?> getUuid() async {
    final prefs = await SharedPreferences.getInstance();
    String? jsonString = prefs.getString(_key);
    if (jsonString == null) {
      await createSession();
    }
    jsonString = prefs.getString(_key);
    final data = jsonDecode(jsonString!);
    String? uuid = data['uuid'];
    return uuid;
  }

  Future<bool?> isSyncedStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_key);
    if (jsonString == null) return true;
    final data = jsonDecode(jsonString);
    isSynced = data['isSynced'] == 1;
    return isSynced;
  }

  Future<void> createSession() async {
    String? uuid = const Uuid().v4().replaceAll("-", "").toUpperCase();
    print("new user-device-id generated : ${uuid.substring(20)}");
    isSynced = false;
    await _save(uuid);
  }

  Future<void> changeSyncStatus(bool syncStatus) async {
    String? uuid = await getUuid();
    isSynced = syncStatus;
    await _save(uuid);
  }

  Future<void> _save(String? uuid) async {
    final prefs = await SharedPreferences.getInstance();
    final data = {"uuid": uuid, "isSynced": isSynced ? 1 : 0};
    await prefs.setString(_key, jsonEncode(data));
  }

  Future<void> saveFromFirebase(String uniqueId) async {
    final prefs = await SharedPreferences.getInstance();
    print("user-device-id loaded from firebase : ${uniqueId.substring(20)}");
    final data = {
      "uuid": uniqueId,
      "isSynced": 1, // true
    };
    await prefs.setString(_key, jsonEncode(data));
  }

  Future<void> clear() async {
    isSynced = true;
    await _save(null);
  }
}
