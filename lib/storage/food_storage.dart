import 'package:chalthee/storage/device_mapper.dart';
import 'package:chalthee/storage/firebase_connect.dart';

class FoodStorage {
  final Map<DateTime, Map<String, dynamic>> _foods = {};

  Map<DateTime, Map<String, dynamic>> get foods => _foods;

  /// ---------------- GET FOOD ----------------
  Future<Map<String, dynamic>> getFood(DateTime date) async {
    final normalized = DateTime(date.year, date.month, date.day);
    if (_foods.containsKey(normalized)) {
      return _foods[normalized]!;
    }

    // Fetch from Firebase if not in local cache
    final uuid = await DeviceMapper().getUuid();
    final dateString = normalized.toIso8601String().split('T')[0];
    final data = await DbConnect().fetchFoodForADate(uuid!, dateString);
    _foods[normalized] = data;
    return data;
  }

  /// ---------------- SAVE FOOD ----------------
  Future<void> saveFood(DateTime date, Map<String, dynamic> foodMap) async {
    final normalized = DateTime(date.year, date.month, date.day);
    _foods[normalized] = foodMap;
    await _saveToFirebase(normalized, foodMap);
  }

  /// ---------------- DELETE FOOD ----------------
  Future<void> deleteFood(DateTime date) async {
    final normalized = DateTime(date.year, date.month, date.day);
    if (!_foods.containsKey(normalized)) return;
    _foods.remove(normalized);
    await _saveToFirebase(normalized, {}); // Saving an empty map to clear/delete
  }

  /// ---------------- SAVE TO FIREBASE ----------------
  Future<void> _saveToFirebase(DateTime date, Map<String, dynamic> foodMap) async {
    final uuid = await DeviceMapper().getUuid();
    final dateString = date.toIso8601String().split('T')[0];
    await DbConnect().addFoodForADate(uuid!, dateString, foodMap);
  }
}
