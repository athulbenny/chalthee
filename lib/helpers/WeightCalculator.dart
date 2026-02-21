import '../storage/weight_storage.dart';

class WeightCalculatorHelper {
  final WeightStorage storage;

  WeightCalculatorHelper(this.storage);

  static DateTime normalizeDate(DateTime date) => DateTime(date.year, date.month, date.day);
  static DateTime startOfWeek(DateTime date) => normalizeDate(date).subtract(Duration(days: date.weekday - 1));
  static DateTime endOfWeek(DateTime date) => startOfWeek(date).add(const Duration(days: 6));
  static DateTime startOfMonth(DateTime date) => DateTime(date.year, date.month, 1);
  static DateTime endOfMonth(DateTime date) => DateTime(date.year, date.month + 1, 0);

  double? dailyDifference(DateTime day) {
    final today = storage.weights[DateTime(day.year, day.month, day.day)];
    final yesterday = storage.getPreviousDayWeight(day);
    if (today == null || yesterday == null) return null;
    return today - yesterday;
  }

  double? calculateAverage(List<MapEntry<DateTime, double>> entries) {
    if (entries.isEmpty) return null;
    final sum = entries.map((e) => e.value).reduce((a, b) => a + b);
    return sum / entries.length;
  }

  double? getInitialWeight(List<MapEntry<DateTime, double>> entries){
  if (entries.isEmpty) return null;
  return entries.first.value;
  }

  double? calculateDiff(List<MapEntry<DateTime, double>> entries) {
    if (entries.length < 2) return null;
    return entries.last.value - entries.first.value;
  }

  double? calculatePercentChange(List<MapEntry<DateTime, double>> entries) {
    if (entries.length < 2) return null;
    final start = entries.first.value;
    final end = entries.last.value;
    return ((end - start) / start) * 100;
  }

  DateTime? predictDateForTarget(double targetWeight, {int lookbackDays = 14}) {
    if (storage.weights.length < 3) return null;
    final entries = storage.weights.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    final lastEntry = entries.last;
    final cutoffDate = lastEntry.key.subtract(Duration(days: lookbackDays));
    final recent = entries.where((e) => !e.key.isBefore(cutoffDate)).toList();
    if (recent.length < 2) return null;
    double totalDelta = 0;
    int dayCount = 0;
    for (int i = 1; i < recent.length; i++) {
      final days = recent[i].key.difference(recent[i - 1].key).inDays;
      if (days == 0) continue;
      final delta = recent[i].value - recent[i - 1].value;
      if (delta.abs() > 1.5) continue;
      totalDelta += delta;
      dayCount += days;
    }
    if (dayCount == 0) return null;
    final dailyChange = totalDelta / dayCount;
    if (dailyChange == 0) return null;
    final remaining = targetWeight - lastEntry.value;
    if (remaining.sign != dailyChange.sign) return null;
    final daysNeeded = (remaining / dailyChange).ceil();
    if (daysNeeded < 0 || daysNeeded > 365) return null;
    return lastEntry.key.add(Duration(days: daysNeeded));
  }
}
