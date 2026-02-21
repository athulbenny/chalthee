import 'package:chalthee/storage/session_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WeightStorage {
  late SharedPreferences _prefs;
  late SessionManager _sessionManager;

  final Map<DateTime, double> _weights = {};
  Map<DateTime, double> get weights => _weights;

  /// ---------------- INIT ----------------
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    /// Load from current logged-in user's weightMap
    final map = await SessionManager.getCurrentWeightMap();
    _weights.clear();
    map.forEach((key, value) {
      _weights[DateTime.parse(key)] =
          (value as num).toDouble();
    });
    print(_weights);
  }

  /// ---------------- SAVE ----------------
  Future<void> saveWeight(
      DateTime date,
      double weight,
      ) async {
    final normalized =
    DateTime(date.year, date.month, date.day);
    _weights[normalized] = weight;
    await _saveToSession();
  }

  /// ---------------- DELETE ----------------
  Future<void> deleteWeight(DateTime date) async {
    final normalized =
    DateTime(date.year, date.month, date.day);
    _weights.remove(normalized);
    await _saveToSession();
  }

  /// ---------------- GET PREVIOUS DAY ----------------
  double? getPreviousDayWeight(DateTime day) {
    final prevDay = DateTime(
      day.year,
      day.month,
      day.day,
    ).subtract(const Duration(days: 1));
    return _weights[prevDay];
  }

  /// ---------------- SAVE TO SESSION ----------------
  Future<void> _saveToSession() async {
    final mapToSave = _weights.map(
          (k, v) => MapEntry(
        k.toIso8601String().split('T')[0],
        v,
      ),
    );
    await SessionManager.saveWeightMap(mapToSave);
  }

}
