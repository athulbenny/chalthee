import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

enum AppBarAction { weekly, monthly, predictTarget }

class _CalendarPageState extends State<CalendarPage> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  DateTime? _rangeStart;
  DateTime? _rangeEnd;
  RangeSelectionMode _rangeSelectionMode =
      RangeSelectionMode.toggledOff;
  AppBarAction _appBarAction = AppBarAction.weekly;


  final TextEditingController _weightController = TextEditingController();
  final Map<DateTime, double> _weights = {};

  late SharedPreferences _prefs;
  final String _storageKey = 'weightMap';
  bool _isEditingWeight = false;


  @override
  void initState() {
    super.initState();
    _loadWeights();
  }

  // -------------------- SharedPreferences --------------------
  Future<void> _loadWeights() async {
    _prefs = await SharedPreferences.getInstance();
    final String? jsonString = _prefs.getString(_storageKey);
    if (jsonString != null) {
      final Map<String, dynamic> map = json.decode(jsonString);
      setState(() {
        _weights.clear();
        map.forEach((key, value) {
          final date = DateTime.parse(key);
          _weights[date] = (value as num).toDouble();
        });
      });
    }
  }

  Future<void> _saveWeightToPrefs(DateTime date, double weight) async {
    _weights[date] = weight;
    Map<String, double> mapToSave = {};
    _weights.forEach((key, value) {
      mapToSave[key.toIso8601String().split('T')[0]] = value;
    });
    await _prefs.setString(_storageKey, json.encode(mapToSave));
  }

  Future<void> _deleteWeightFromPrefs(DateTime date) async {
    final key = _normalizeDate(date);

    _weights.remove(key);

    final Map<String, double> mapToSave = {};
    _weights.forEach((k, v) {
      mapToSave[k.toIso8601String().split('T')[0]] = v;
    });

    if (mapToSave.isEmpty) {
      await _prefs.remove(_storageKey);
    } else {
      await _prefs.setString(_storageKey, json.encode(mapToSave));
    }
  }



  // -------------------- Helpers --------------------
  DateTime _normalizeDate(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  double? _getPreviousDayWeight(DateTime day) =>
      _weights[_normalizeDate(day.subtract(const Duration(days: 1)))];

  double? _getDayDifference(DateTime day) {
    final today = _weights[_normalizeDate(day)];
    final yesterday = _getPreviousDayWeight(day);
    if (today == null || yesterday == null) return null;
    return today - yesterday;
  }

  List<MapEntry<DateTime, double>> _getWeightsInRange() {
    if (_rangeStart == null || _rangeEnd == null) return [];
    final start = _normalizeDate(_rangeStart!);
    final end = _normalizeDate(_rangeEnd!);
    return _weights.entries
        .where((e) => !e.key.isBefore(start) && !e.key.isAfter(end))
        .toList()
      ..sort((a, b) => a.key.compareTo(b.key));
  }

  double? _calculateAverageWeight() {
    final entries = _getWeightsInRange();
    if (entries.isEmpty) return null;
    final sum = entries.map((e) => e.value).reduce((a, b) => a + b);
    return sum / entries.length;
  }

  double? _calculateSmartRangeDiff() {
    final entries = _getWeightsInRange();
    if (entries.length < 2) return null;
    final first = entries.first.value;
    final last = entries.last.value;
    return last - first;
  }

  DateTime? _getSmartStartDate() {
    final entries = _getWeightsInRange();
    return entries.isEmpty ? null : entries.first.key;
  }

  DateTime? _getSmartEndDate() {
    final entries = _getWeightsInRange();
    return entries.isEmpty ? null : entries.last.key;
  }

// ---------------------DatePrediction-----------------------------
  DateTime? predictDateForTargetWeight(
      double targetWeight, {
        int lookbackDays = 14,
      }) {
    if (_weights.length < 3) return null;

    // Sort entries
    final entries = _weights.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    final lastEntry = entries.last;

    // Take only recent entries
    final cutoffDate =
    lastEntry.key.subtract(Duration(days: lookbackDays));

    final recent = entries
        .where((e) => !e.key.isBefore(cutoffDate))
        .toList();

    if (recent.length < 2) return null;

    // Calculate daily deltas
    double totalDelta = 0;
    int dayCount = 0;

    for (int i = 1; i < recent.length; i++) {
      final days =
          recent[i].key.difference(recent[i - 1].key).inDays;
      if (days == 0) continue;

      final delta =
          recent[i].value - recent[i - 1].value;

      // Ignore wild jumps (> 1.5kg/day)
      if (delta.abs() > 1.5) continue;

      totalDelta += delta;
      dayCount += days;
    }

    if (dayCount == 0) return null;

    final dailyChange = totalDelta / dayCount;

    // Progress stalled or moving wrong way
    if (dailyChange == 0) return null;

    final remaining = targetWeight - lastEntry.value;

    // Direction check
    if (remaining.sign != dailyChange.sign) return null;

    final daysNeeded = (remaining / dailyChange).ceil();

    // Hard safety clamp (no insane predictions)
    if (daysNeeded < 0 || daysNeeded > 365) return null;

    return lastEntry.key.add(Duration(days: daysNeeded));
  }




  void _showTargetWeightDialog() {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.deepOrange[100],
          title: const Text('Target Weight'),
          content: TextField(
            controller: controller,
            keyboardType:
            const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              hintText: 'Enter target weight (kg)',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final target =
                double.tryParse(controller.text.trim());
                if (target != null) {
                  _showPredictionResult(target);
                }
              },
              child: const Text('Predict'),
            ),
          ],
        );
      },
    );
  }


  void _showPredictionResult(double targetWeight) {
    final predictedDate =
    predictDateForTargetWeight(targetWeight);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.deepOrange[100],
          title: const Text('Prediction Result'),
          content: Text(
            predictedDate == null
                ? 'Not enough data to predict.'
                : 'You may reach $targetWeight kg on\n'
                '${predictedDate.toLocal().toString().split(' ')[0]}',
            style: const TextStyle(fontSize: 16),
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }


  // -------------------- Weight dialog --------------------
  void _saveWeight() {
    if (_selectedDay == null) return;
    final key = _normalizeDate(_selectedDay!);
    final text = _weightController.text.trim();
    setState(() {
      if (text.isEmpty) {
        _deleteWeightFromPrefs(key);
      } else {
        final value = double.tryParse(text);
        if (value == null) return;
        _weights[key] = value;
        _saveWeightToPrefs(key, value);
      }
      _isEditingWeight = false;
      _weightController.clear();
    });
  }


  List<MapEntry<DateTime, double>> _getProgressEntries() {
    if (_focusedDay == null) return [];
    late DateTime start;
    late DateTime end;
    if (_appBarAction == AppBarAction.weekly) {
      start = _startOfWeek(_focusedDay);
      end = _endOfWeek(_focusedDay);
    } else {
      start = _startOfMonth(_focusedDay);
      end = _endOfMonth(_focusedDay);
    }
    return _weights.entries
        .where((e) =>
    !e.key.isBefore(start) &&
        !e.key.isAfter(end))
        .toList()
      ..sort((a, b) => a.key.compareTo(b.key));
  }

  double? _calculateProgressDiff() {
    final entries = _getProgressEntries();
    if (entries.length < 2) return null;
    return entries.last.value - entries.first.value;
  }

  double? _calculateProgressAverage() {
    final entries = _getProgressEntries();
    if (entries.isEmpty) return null;
    final sum = entries.map((e) => e.value).reduce((a, b) => a + b);
    return sum / entries.length;
  }

  double? _calculateProgressPercentage() {
    final entries = _getProgressEntries();
    if (entries.length < 2) return null;
    final startWeight = entries.first.value;
    final endWeight = entries.last.value;
    if (startWeight == 0) return null;
    return ((endWeight - startWeight) / startWeight) * 100;
  }

  double? _calculateSmartRangePercentage() {
    final entries = _getWeightsInRange();
    if (entries.length < 2) return null;
    final startWeight = entries.first.value;
    final endWeight = entries.last.value;
    if (startWeight == 0) return null;
    return ((endWeight - startWeight) / startWeight) * 100;
  }

  DateTime _startOfWeek(DateTime date) {
    final normalized = _normalizeDate(date);
    return normalized.subtract(Duration(days: normalized.weekday - 1));
  }

  DateTime _endOfWeek(DateTime date) {
    return _startOfWeek(date).add(const Duration(days: 6));
  }

  DateTime _startOfMonth(DateTime date) {
    return DateTime(date.year, date.month, 1);
  }

  DateTime _endOfMonth(DateTime date) {
    return DateTime(date.year, date.month + 1, 0);
  }


  void _startEditingWeight() {
    if (_selectedDay == null) return;
    final key = _normalizeDate(_selectedDay!);
    if (_weights.containsKey(key)) {
      _weightController.text = _weights[key]!.toString();
    } else {
      _weightController.clear();
    }

    setState(() {
      _isEditingWeight = true; // show inline input field
    });
  }

  Future<void> _showMonthYearPicker(BuildContext context) async {
    int selectedYear = _focusedDay.year;
    int selectedMonth = _focusedDay.month;

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.deepOrange[100],
          title: const Text('Select Month & Year'),
          content: SizedBox(
            height: 50,
            child: Row(
              children: [
                // Month picker
                Expanded(
                  child: Card(
                    child: ListWheelScrollView.useDelegate(
                      itemExtent: 40,
                      physics: const FixedExtentScrollPhysics(),
                      controller: FixedExtentScrollController(
                        initialItem: selectedMonth - 1,
                      ),
                      onSelectedItemChanged: (index) {
                        selectedMonth = index + 1;
                      },
                      childDelegate: ListWheelChildBuilderDelegate(
                        childCount: 12,
                        builder: (context, index) {
                          return Center(
                            child: Text(
                              DateTime(0, index + 1)
                                  .toLocal()
                                  .month
                                  .toString(),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),

                // Year picker
                Expanded(
                  child: Card(
                    child: ListWheelScrollView.useDelegate(
                      itemExtent: 40,
                      physics: const FixedExtentScrollPhysics(),
                      controller: FixedExtentScrollController(
                        initialItem: selectedYear - 2020,
                      ),
                      onSelectedItemChanged: (index) {
                        selectedYear = 2020 + index;
                      },
                      childDelegate: ListWheelChildBuilderDelegate(
                        childCount: 20, // 2020–2039
                        builder: (context, index) {
                          return Center(
                            child: Text(
                              (2020 + index).toString(),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _focusedDay = DateTime(selectedYear, selectedMonth, 1);
                });
                Navigator.pop(context);
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }


  // -------------------- UI --------------------
  @override
  Widget build(BuildContext context) {


    final progressDiff = _calculateProgressDiff();
    final progressAvg = _calculateProgressAverage();
    final progressPercentage  = _calculateProgressPercentage();
    final smartRangePercentage = _calculateSmartRangePercentage();

    final label =
    _appBarAction == AppBarAction.weekly ? 'This Week' : 'This Month';

    final avg = _calculateAverageWeight();
    final diff = _calculateSmartRangeDiff();
    final smartStart = _getSmartStartDate();
    final smartEnd = _getSmartEndDate();

    return Scaffold(
      backgroundColor: Colors.deepOrange[100],
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(
            bottom: Radius.circular(30),
          ),
          child: AppBar(
            centerTitle: true,
            title: const Text(
              'Weight Calendar',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
            actions: [
              PopupMenuButton<AppBarAction>(
                icon: const Icon(Icons.more_vert, color: Colors.black),
                onSelected: (action) {
                  switch (action) {
                    case AppBarAction.weekly:
                      setState(() => _appBarAction = AppBarAction.weekly);
                      break;

                    case AppBarAction.monthly:
                      setState(() => _appBarAction = AppBarAction.monthly);
                      break;

                    case AppBarAction.predictTarget:
                      _showTargetWeightDialog();
                      break;
                  }
                },
                itemBuilder: (context) => const [
                  PopupMenuItem(
                    value: AppBarAction.weekly,
                    child: Text('Weekly Progress'),
                  ),
                  PopupMenuItem(
                    value: AppBarAction.monthly,
                    child: Text('Monthly Progress'),
                  ),
                  PopupMenuDivider(),
                  PopupMenuItem(
                    value: AppBarAction.predictTarget,
                    child: Text('Predict Target Weight'),
                  ),
                ],
              ),

            ],
            flexibleSpace: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFFFF6543),
                    Color(0xFFFF7043),
                    Color(0xFFFFFFD0),
                  ],
                  stops: [0.0, 0.68, 1.0],
                ),
              ),
            ),
            elevation: 0,
            backgroundColor: Colors.transparent,
          ),
        ),
      ),

      body: SingleChildScrollView(
        child: Column(
          children: [
            TableCalendar(
                firstDay: DateTime.utc(2020, 1, 1),
                lastDay: DateTime.utc(2030, 12, 31),
                focusedDay: _focusedDay,

                headerStyle: const HeaderStyle(
                  formatButtonVisible: false,
                  titleTextStyle: TextStyle(
                    fontSize: 22,        // 👈 increase size here
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),

                onHeaderTapped: (focusedDay) {
                  _showMonthYearPicker(context);
                },

                daysOfWeekStyle: const DaysOfWeekStyle(
                  weekdayStyle: TextStyle(
                    fontSize: 16,          // Mon–Fri
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                  weekendStyle: TextStyle(
                    fontSize: 16,          // Sun
                    fontWeight: FontWeight.w600,
                    color: Colors.red,
                  ),
                ),

                // Disable future dates
                enabledDayPredicate: (day) {
                  // Only allow dates up to today
                  return !day.isAfter(DateTime.now());
                },

                selectedDayPredicate: (day) =>
                    isSameDay(_selectedDay, day),

                rangeStartDay: _rangeStart,
                rangeEndDay: _rangeEnd,
                rangeSelectionMode: _rangeSelectionMode,

                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                    _rangeStart = null;
                    _rangeEnd = null;
                    _rangeSelectionMode =
                        RangeSelectionMode.toggledOff;
                    _weightController.clear();
                  });
                },

                onRangeSelected: (start, end, focusedDay) {
                  setState(() {
                    _selectedDay = null;
                    _rangeStart = start;
                    _rangeEnd = end;
                    _focusedDay = focusedDay;
                    _rangeSelectionMode =
                        RangeSelectionMode.toggledOn;
                  });
                },

                calendarBuilders: CalendarBuilders(
                  defaultBuilder: (context, day, focusedDay) {
                    return Container(
                      margin: const EdgeInsets.all(6),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: isSameDay(day, _selectedDay)
                            ? Colors.blue
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${day.day}',
                        style: TextStyle(
                          color: day.isAfter(DateTime.now())
                              ? Colors.grey
                              : Colors.black,
                          fontWeight: isSameDay(day, DateTime.now())
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                    );
                  },
                  markerBuilder: (context, date, events) {
                    final normalized = _normalizeDate(date);
                    if (_weights.containsKey(normalized)) {
                      double? yesterdayWeight = _getPreviousDayWeight(normalized);
                      Color dotColor = Colors.green;
                      if (yesterdayWeight != null) {
                        dotColor = _weights[normalized]! < yesterdayWeight
                            ? Colors.green
                            : Colors.red;
                      }
                      return Positioned(
                        bottom: 4,
                        child: Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: dotColor,
                          ),
                        ),
                      );
                    }
                    return null;
                  },
                )

            ),

            const SizedBox(height: 16),

            // -------- Single day view --------
            if (_selectedDay != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 500), // max width for larger screens
                  child: Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 4,
                    child: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0xFFFF7043),
                            Color(0xFFFF7043),
                            Color(0xFFFFFFFF),
                          ],
                          stops: [0.0,0.7, 1.0],
                        ),
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                      ),
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Selected: ${_selectedDay!.toLocal().toString().split(' ')[0]}',
                            style: const TextStyle(
                                fontSize: 19,
                                fontWeight: FontWeight.bold,
                                color:  Colors.black),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            _weights.containsKey(_normalizeDate(_selectedDay!))
                                ? 'Weight: ${_weights[_normalizeDate(_selectedDay!)]} kg'
                                : 'No weight recorded',
                            style: const TextStyle(fontSize: 18, color: Colors.black87),
                          ),
                          if (_getPreviousDayWeight(_selectedDay!) != null)
                            Text(
                              'Yesterday: ${_getPreviousDayWeight(_selectedDay!)} kg',
                              style: const TextStyle(fontSize: 16, color: Colors.black54),
                            ),
                          if (_getDayDifference(_selectedDay!) != null)
                            Text(
                              _getDayDifference(_selectedDay!)! < 0
                                  ? '↓ ${_getDayDifference(_selectedDay!)!.abs().toStringAsFixed(3)} kg'
                                  : '↑ +${_getDayDifference(_selectedDay!)!.toStringAsFixed(3)} kg',
                              style: TextStyle(
                                fontSize: 20,
                                color: _getDayDifference(_selectedDay!)! < 0
                                    ? Colors.greenAccent
                                    : Colors.red[900],
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          const SizedBox(height: 10),
                          !_isEditingWeight
                              ? ElevatedButton(
                            onPressed: _startEditingWeight,
                            child: const Text('Add / Edit Weight'),
                          )
                              : Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _weightController,
                                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                  inputFormatters: [
                                    FilteringTextInputFormatter.allow(
                                        RegExp(r'^\d*\.?\d{0,3}$')),
                                  ],
                                  decoration: const InputDecoration(
                                    hintText: 'Weight (kg)',
                                    hintStyle: TextStyle(color: Colors.black87),
                                    isDense: true, // smaller height
                                    contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(color: Colors.white54),
                                      borderRadius: BorderRadius.all(Radius.circular(8)),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(color: Colors.black),
                                      borderRadius: BorderRadius.all(Radius.circular(8)),
                                    ),
                                  ),
                                  style: const TextStyle(color: Colors.black),
                                ),
                              ),
                              const SizedBox(width: 8),
                              IconButton(
                                icon: const Icon(Icons.check, color: Colors.green),
                                onPressed: _saveWeight,
                              ),
                              IconButton(
                                icon: const Icon(Icons.close, color: Colors.red),
                                onPressed: () {
                                  setState(() {
                                    _isEditingWeight = false;
                                    _weightController.clear();
                                  });
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),




            // -------- Smart range view --------
            if (_rangeStart != null && _rangeEnd != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 500), // limit width
                  child: Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 4,
                    child: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0xFFFF7043),
                            Color(0xFFFF7043),
                            Color(0xFFFFFFFF),
                          ],
                          stops: [0.0, 0.5, 1.0],
                        ),
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                      ),
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            smartStart != null && smartEnd != null
                                ? 'Effective Range: ${smartStart.toLocal().toString().split(' ')[0]} → ${smartEnd.toLocal().toString().split(' ')[0]}'
                                : 'No data in selected range',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 6),
                          if (avg != null)
                            Text(
                              'Average Weight: ${avg.toStringAsFixed(3)} kg',
                              style: const TextStyle(fontSize: 18, color: Colors.black87),
                            ),
                          const SizedBox(height: 4),
                          if (diff != null && smartRangePercentage != null)
                            Text(
                              diff < 0
                                  ? 'Weight Loss: ${diff.abs().toStringAsFixed(3)} kg '
                                  '(${smartRangePercentage.abs().toStringAsFixed(2)}%)'
                                  : 'Weight Gain: ${diff.toStringAsFixed(3)} kg '
                                  '(+${smartRangePercentage.toStringAsFixed(2)}%)',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: diff < 0 ? Colors.greenAccent : Colors.red[900],
                              ),
                            )

                          else
                            const Text(
                              'Not enough data to calculate change',
                              style: TextStyle(color: Colors.black),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),


            if (progressAvg != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                child: Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFFFF7043),
                          Color(0xFFFF7043),
                          Color(0xFFFFFFFF),
                        ],
                        stops: [0.0,0.7, 1.0],
                      ),
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '$label Progress',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Average Weight: ${progressAvg.toStringAsFixed(3)} kg',
                            style: const TextStyle(fontSize: 18),
                          ),
                          if (progressDiff != null && progressPercentage != null)
                            Text(
                              progressDiff < 0
                                  ? 'Loss: ${progressDiff.abs().toStringAsFixed(3)} kg '
                                  '(${progressPercentage.abs().toStringAsFixed(2)}%)'
                                  : 'Gain: ${progressDiff.toStringAsFixed(3)} kg '
                                  '(+${progressPercentage.toStringAsFixed(2)}%)',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: progressDiff < 0
                                    ? Colors.greenAccent
                                    : Colors.red[900],
                              ),
                            )

                          else
                            const Text('Not enough data'),
                        ],
                      ),
                    ),
                  ),
                ),
              ),




          ],
        ),
      ),
    );
  }
}
