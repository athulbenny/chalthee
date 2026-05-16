import 'package:chalthee/storage/device_mapper.dart';
import 'package:chalthee/storage/firebase_connect.dart';

class ExerciseStorage {
  final Map<DateTime, Map<String, dynamic>> _exercises = {};

  Map<DateTime, Map<String, dynamic>> get exercises => _exercises;

  /// ---------------- GET EXERCISE ----------------
  Future<Map<String, dynamic>> getExercise(DateTime date) async {
    final normalized = DateTime(date.year, date.month, date.day);
    if (_exercises.containsKey(normalized)) {
      return _exercises[normalized]!;
    }

    // Fetch from Firebase if not in local cache
    final uuid = await DeviceMapper().getUuid();
    final dateString = normalized.toIso8601String().split('T')[0];
    final data = await DbConnect().fetchExerciseForADate(uuid!, dateString);
    _exercises[normalized] = data;
    return data;
  }

  /// ---------------- SAVE EXERCISE ----------------
  Future<void> saveExercise(DateTime date, Map<String, dynamic> exerciseMap) async {
    final normalized = DateTime(date.year, date.month, date.day);
    _exercises[normalized] = exerciseMap;
    await _saveToFirebase(normalized, exerciseMap);
  }

  /// ---------------- DELETE EXERCISE ----------------
  Future<void> deleteExercise(DateTime date) async {
    final normalized = DateTime(date.year, date.month, date.day);
    if (!_exercises.containsKey(normalized)) return;
    _exercises.remove(normalized);
    await _saveToFirebase(normalized, {}); // Saving an empty map to clear/delete
  }

  /// ---------------- SAVE TO FIREBASE ----------------
  Future<void> _saveToFirebase(DateTime date, Map<String, dynamic> exerciseMap) async {
    final uuid = await DeviceMapper().getUuid();
    final dateString = date.toIso8601String().split('T')[0];
    await DbConnect().addExerciseForADate(uuid!, dateString, exerciseMap);
  }
}