import 'package:chalthee/storage/firebase_connect.dart';

class WeightStorage {

  final Map<DateTime, double> _weights = {};
  Map<DateTime, double> get weights => _weights;

  /// ---------------- INIT ----------------
  Future<bool> init() async {
    /// Load directly from Firebase
    final map = await DbConnect().fetchWeightMap();
    _weights.clear();
    if(map != null) {
      map.forEach((key, value) {
        _weights[DateTime.parse(key)] = (value as num).toDouble();
      });
      print(_weights);
      return true;
    }else {
      return false;
    }
  }

  /// ---------------- SAVE ----------------
  Future<void> saveWeight(
      DateTime date,
      double weight,
      ) async {
    final normalized =
    DateTime(date.year, date.month, date.day);
    _weights[normalized] = weight;
    await _saveToFirebase();
  }

  /// ---------------- DELETE ----------------
  Future<void> deleteWeight(DateTime date) async {
    final normalized =
    DateTime(date.year, date.month, date.day);
    _weights.remove(normalized);
    await _saveToFirebase();
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

  /// ---------------- SAVE TO FIREBASE ----------------
  Future<void> _saveToFirebase() async {
    final mapToSave = _weights.map(
          (k, v) => MapEntry(
        k.toIso8601String().split('T')[0],
        v,
      ),
    );
    await DbConnect().updateWeightMap(mapToSave);
  }

}
