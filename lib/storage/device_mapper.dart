import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class DeviceMapper {
  static const String _key = "device_mapper";
  //late SharedPreferences prefs;
  // String? uuid;
  bool isSynced = true;
  bool fbStatus = true;
  // static final DeviceMapper _instance =
  // DeviceMapper._internal();
  // factory DeviceMapper() => _instance;
  // DeviceMapper._internal();

  // Future<void> init() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   final jsonString = prefs.getString(_key);
  //   if (jsonString == null) return ;
  //   final data = jsonDecode(jsonString);
  //   uuid = data['uuid'];
  //   isSynced = data['isSynced'] == 1;
  // }

  Future<String?> getUuid() async {
    final prefs = await SharedPreferences.getInstance();
    String? jsonString = prefs.getString(_key);
    print(jsonString);
    if (jsonString == null) {
      await createSession();
    }
    jsonString = prefs.getString(_key);
    final data = jsonDecode(jsonString!);
    String? uuid = data['uuid'];
    return uuid;
  }

  Future<bool?> isSyncedStatus() async{
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_key);
    if (jsonString == null) return true;
    final data = jsonDecode(jsonString);
    isSynced = data['isSynced'] == 1;
    return isSynced;
  }

  Future<bool?> getFbStatus() async{
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_key);
    if (jsonString == null) return true;
    final data = jsonDecode(jsonString);
    fbStatus = data['fbStatus'] == 1;
    return fbStatus;
  }

  Future<void> createSession() async {
    String? uuid = const Uuid().v4().replaceAll("-", "").toUpperCase();
    print("uuid = $uuid");
    isSynced = false;
    fbStatus = true;
    await _save(uuid);
  }

  Future<void> changeSyncStatus(bool syncStatus) async {
    String? uuid = await getUuid();
    isSynced = syncStatus;
    await _save(uuid);
  }

  Future<void> changeFbStatus(bool fbSyncStatus) async {
    String? uuid = await getUuid();
    fbStatus = fbSyncStatus;
    await _save(uuid);
  }

  Future<void> _save(String? uuid) async {
    final prefs = await SharedPreferences.getInstance();
    final data = {
      "uuid": uuid,
      "isSynced": isSynced ? 1 : 0,
      "fbStatus": fbStatus ? 1 : 0
    };
    await prefs.setString(_key, jsonEncode(data));
  }

  Future<void> saveFromFirebase(String uniqueId ) async {
    final prefs = await SharedPreferences.getInstance();
    print("uniqueid from firebase $uniqueId");
    final data = {
      "uuid": uniqueId,
      "isSynced": 1, // true
      "fbStatus": 1 //true
    };
    await prefs.setString(_key, jsonEncode(data));
  }

  Future<void> clear() async {
    isSynced = true;
    fbStatus = true;
    await _save(null);
  }

 }
