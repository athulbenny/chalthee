import 'package:chalthee/constants/CommonUI.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

import '../constants/AppBarAction.dart';
import '../helpers/WeightCalculator.dart';
import '../storage/weight_storage.dart';
import '../storage/session_router.dart';
import 'login.dart';


class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  late WeightStorage _weightStorage;
  late WeightCalculatorHelper _calculator;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay = DateTime.now();
  DateTime? _rangeStart;
  DateTime? _rangeEnd;
  RangeSelectionMode _rangeSelectionMode = RangeSelectionMode.toggledOff;
  AppBarAction _appBarAction = AppBarAction.weekly;
  final TextEditingController _weightController = TextEditingController();
  bool _isEditingWeight = false;
  final CommonUI uiVariables = CommonUI();
  String _userName = "";
  String _email = "";
  Map<String, dynamic>? user;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();


  @override
  void initState() {
    super.initState();
    loadUser();
    _weightStorage = WeightStorage();
    _calculator = WeightCalculatorHelper(_weightStorage);
    _weightStorage.init().then((_) {
      if (mounted) setState(() {});
    });
  }

  // -------------------- Helpers --------------------


  void loadUser() async {
    user = await SessionManager.getCurrentUser();
    setState(() {
      _userName = user?["username"] ?? "User";
      _email =  user?["usermail"] ?? "";
    });
  }

  List<MapEntry<DateTime, double>> _getWeekEntries(DateTime anchor) {
    final start = WeightCalculatorHelper.normalizeDate(
      anchor.subtract(Duration(days: anchor.weekday - 1)),
    );
    final end = start.add(const Duration(days: 6));
    return _weightStorage.weights.entries
        .where((e) => !e.key.isBefore(start) && !e.key.isAfter(end))
        .toList()
      ..sort((a, b) => a.key.compareTo(b.key));
  }

  List<MapEntry<DateTime, double>> _getMonthEntries(DateTime anchor) {
    final start = DateTime(anchor.year, anchor.month, 1);
    final end = DateTime(anchor.year, anchor.month + 1, 0);
    return _weightStorage.weights.entries
        .where((e) => !e.key.isBefore(start) && !e.key.isAfter(end))
        .toList()
      ..sort((a, b) => a.key.compareTo(b.key));
  }


  List<MapEntry<DateTime, double>> _getSelectedEntries() {
    if (_selectedDay != null) {
      final day = WeightCalculatorHelper.normalizeDate(_selectedDay!);
      return _weightStorage.weights.entries
          .where((e) => isSameDay(e.key, day))
          .toList();
    }
    if (_rangeStart != null && _rangeEnd != null) {
      final start = WeightCalculatorHelper.normalizeDate(_rangeStart!);
      final end = WeightCalculatorHelper.normalizeDate(_rangeEnd!);
      return _weightStorage.weights.entries
          .where((e) => !e.key.isBefore(start) && !e.key.isAfter(end))
          .toList()
        ..sort((a, b) => a.key.compareTo(b.key));
    }
    return [];
  }

  double? get dailyDiff =>
      _selectedDay != null ? _calculator.dailyDifference(_selectedDay!) : null;
  double? get progressDiff =>
      _calculator.calculateDiff(_getSelectedEntries());
  double? get progressAvg =>
      _calculator.calculateAverage(_getSelectedEntries());
  double? get progressPercentage =>
      _calculator.calculatePercentChange(_getSelectedEntries());

  // -------------------- Weight edit --------------------

  void _startEditingWeight() {
    if (_selectedDay == null) return;
    final key = WeightCalculatorHelper.normalizeDate(_selectedDay!);
    _weightController.text =
        _weightStorage.weights[key]?.toString() ?? '';
    setState(() => _isEditingWeight = true);
  }

  void _saveWeight() {
    if (_selectedDay == null) return;
    final key = WeightCalculatorHelper.normalizeDate(_selectedDay!);
    final text = _weightController.text.trim();
    setState(() {
      if (text.isEmpty) {
        _weightStorage.deleteWeight(key);
      } else {
        final value = double.tryParse(text);
        if (value != null) {
          _weightStorage.saveWeight(key, value);
        }
      }
      _isEditingWeight = false;
      _weightController.clear();
    });
  }



  // -------------------- UI --------------------

  @override
  Widget build(BuildContext context) {
    final entries = _getSelectedEntries();
    final smartStart = entries.isNotEmpty ? entries.first.key : null;
    final smartEnd = entries.length > 1 ? entries.last.key : null;
    final avg =
    entries.isNotEmpty ? _calculator.getInitialWeight(entries) : null;
    final diff =
    entries.length > 1 ? _calculator.calculateDiff(entries) : null;
    final label = _appBarAction == AppBarAction.weekly
        ? 'Selected Week'
        : 'Selected Month';

    final smartRangePercentage =
    (avg != null && diff != null && avg != 0)
        ? (diff / avg) * 100
        : null;
    final progressEntries = _appBarAction == AppBarAction.weekly
        ? _getWeekEntries(_focusedDay)
        : _getMonthEntries(_focusedDay);
    final progressInitialWeight = progressEntries.isNotEmpty
        ? _calculator.getInitialWeight(progressEntries): null;
    final progressAvg = progressEntries.isNotEmpty
        ? _calculator.calculateAverage(progressEntries): null;
    final progressDiff = progressEntries.length > 1
        ? _calculator.calculateDiff(progressEntries)
        : null;
    final progressPercentage =
    (progressAvg != null && progressDiff != null && progressAvg != 0
        && progressInitialWeight != null && progressInitialWeight != 0)
        ? (progressDiff / progressInitialWeight) * 100
        : null;

    final selectedKey = _selectedDay != null
        ? WeightCalculatorHelper.normalizeDate(_selectedDay!)
        : null;

    return Scaffold(
      key: _scaffoldKey, // add this
      drawer: _buildProfileDrawer(),
      backgroundColor: uiVariables.scaffoldBackgroundColor,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(75),
        child: AppBar(
          leading: Padding(
            padding: const EdgeInsets.only(left: 8),
            child: GestureDetector(
              onTap: () {
                _scaffoldKey.currentState?.openDrawer();
              },
              child: CircleAvatar(
                radius: 20,
                backgroundColor: uiVariables.scaffoldBackgroundColor,
                child: Text(
                  _userName.isNotEmpty
                      ? _userName[0].toUpperCase()
                      : "U",
                  style: TextStyle(
                    color: uiVariables.textColorDefault,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
          centerTitle: true,
          title: const Text('Weight Calendar',
            style: TextStyle(fontWeight: FontWeight.bold),),
          flexibleSpace: Container(
            decoration: uiVariables.bodyBoxDecorator.copyWith(
                borderRadius: BorderRadius.circular(30)),
          ),
          actions: [
            PopupMenuButton<AppBarAction>(
              onSelected: (action) {
                if (action == AppBarAction.predictTarget) {
                  _showTargetWeightDialog();
                } else {
                  setState(() => _appBarAction = action);
                }
              },
              itemBuilder: (_) => const [
                PopupMenuItem(
                    value: AppBarAction.weekly,
                    child: Text('Weekly Progress')),
                PopupMenuItem(
                    value: AppBarAction.monthly,
                    child: Text('Monthly Progress')),
                PopupMenuDivider(),
                PopupMenuItem(
                    value: AppBarAction.predictTarget,
                    child: Text('Predict Target Weight')),
              ],
            )
          ],
          backgroundColor: Colors.transparent,
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            TableCalendar(
              firstDay: DateTime.utc(2020, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: _focusedDay,
              selectedDayPredicate: (d) => isSameDay(_selectedDay, d),
              rangeStartDay: _rangeStart,
              rangeEndDay: _rangeEnd,
              rangeSelectionMode: _rangeSelectionMode,
              headerStyle: HeaderStyle(
                formatButtonVisible: false,
                titleTextStyle: TextStyle(
                  fontSize: 22,        // 👈 increase size here
                  fontWeight: FontWeight.bold,
                  color: uiVariables.textColorDefault,
                ),
              ),
              onHeaderTapped: (focusedDay) {
                _showMonthYearPicker(context);
              },
              daysOfWeekStyle: DaysOfWeekStyle(
                weekdayStyle: TextStyle(
                  fontSize: uiVariables.subHeadingSize,          // Mon–Fri
                  fontWeight: FontWeight.w600,
                  color: uiVariables.textColorDefault,
                ),
                weekendStyle: TextStyle(
                  fontSize: uiVariables.subHeadingSize,          // Sun
                  fontWeight: FontWeight.w600,
                  color: uiVariables.weightGainColor,
                ),
              ),
              enabledDayPredicate: (day) {
                return !day.isAfter(DateTime.now());
              },
              onDaySelected: (day, focused) {
                setState(() {
                  _weightController.clear();
                  _selectedDay = day;
                  _focusedDay = focused;
                  _rangeStart = null;
                  _rangeEnd = null;
                  _rangeSelectionMode =
                      RangeSelectionMode.toggledOff;
                });
              },
              onRangeSelected: (start, end, focused) {
                setState(() {
                  _selectedDay = null;
                  _rangeStart = start;
                  _rangeEnd = end;
                  _focusedDay = focused;
                  _rangeSelectionMode =
                      RangeSelectionMode.toggledOn;
                });
              },
              calendarBuilders: CalendarBuilders(
                defaultBuilder: (_, d, _) => _dayCell(d),
                selectedBuilder: (_, d, _) =>
                    _dayCell(d, isSelected: true),
                todayBuilder: (_, d, _) =>
                    _dayCell(d, isToday: true),
                rangeStartBuilder: (_, d, _) =>
                    _dayCell(d, isRangeStart: true),
                rangeEndBuilder: (_, d, _) =>
                    _dayCell(d, isRangeEnd: true),
                withinRangeBuilder: (_, d, _) =>
                    _dayCell(d, isWithinRange: true),
              ),
            ),

  //---------------- selected day ---------------------
            if (_selectedDay != null)
              Padding(
                padding:  EdgeInsets.all(uiVariables.subHeadingSize),
                child: Card(
                  elevation: 4,
                  child: Container(
                    decoration: uiVariables.bodyBoxDecorator,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Date: ${_selectedDay!.toLocal().toString().split(' ')[0]}',
                            style: TextStyle(
                                fontSize: uiVariables.mainHeadingSize,
                                fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 6),
                          if(_weightStorage.weights.containsKey(selectedKey))
                          Text(
                            _weightStorage.weights.containsKey(selectedKey)
                                ? 'Weight: ${_weightStorage.weights[selectedKey]} kg'
                                : 'No weight recorded',
                            style:  TextStyle(fontSize: uiVariables.mediumHeadingSize, color: uiVariables.textColorDefault),
                          ),
                          if(_weightStorage.weights.containsKey(selectedKey?.subtract(const Duration(days: 1))))
                          Text('Yesterday: ${_weightStorage.weights[selectedKey?.subtract(const Duration(days: 1))]} Kg',
                              style:  TextStyle(fontSize: uiVariables.subHeadingSize, color: Colors.black54),
                          ),
                          if (dailyDiff != null)
                            Text(
                              dailyDiff! < 0
                                  ? '↓ ${dailyDiff!.abs().toStringAsFixed(3)} kg'
                                  : '↑ +${dailyDiff!.toStringAsFixed(3)} kg',
                              style: TextStyle(
                                fontSize: uiVariables.mainHeadingSize,
                                fontWeight: FontWeight.bold,
                                color: dailyDiff! < 0
                                    ? uiVariables.weightLossColor
                                    : uiVariables.weightGainColor,
                              ),
                            ),
                          const SizedBox(height: 10),
                          !_isEditingWeight
                              ? ElevatedButton(
                            onPressed: _startEditingWeight,
                            style : uiVariables.elevatedButtonStyle,
                            child:
                             Text('Add / Edit Weight',
                               style: TextStyle(
                                   color: uiVariables.textColorDefault,
                                   fontWeight: FontWeight.bold,
                                   fontSize: uiVariables.subHeadingSize
                               ),),
                          )
                              : Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _weightController,
                                  keyboardType: uiVariables.textEditingField,
                                  inputFormatters: uiVariables.inputFormatter,
                                  decoration: uiVariables.textEditingFieldDecoration,
                                  style: TextStyle(color: uiVariables.textColorDefault)
                                ),
                              ),
                              IconButton(
                                icon: Icon(Icons.check, color: uiVariables.weightLossColor,),
                                onPressed: _saveWeight,
                              ),
                              IconButton(
                                icon:  Icon(Icons.close, color: uiVariables.weightGainColor),
                                onPressed: () {
                                  setState(() {
                                    _isEditingWeight = false;
                                    _weightController.clear();
                                  });
                                },
                              )
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

  // -----------RANGE SUMMARY CARD (unchanged UI)---------------
            if (_rangeStart != null && _rangeEnd != null)
              Padding(
                padding:
                EdgeInsets.symmetric(horizontal: uiVariables.subHeadingSize, vertical: uiVariables.subHeadingSize),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 500),
                  child: Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    elevation: 4,
                    child: Container(
                      decoration: CommonUI().bodyBoxDecorator,
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            smartStart != null && smartEnd != null
                                ? 'Effective Range: ${smartStart.toLocal().toString().split(' ')[0]} → ${smartEnd.toLocal().toString().split(' ')[0]}'
                                : 'No data in selected range',
                            style: TextStyle(
                              fontSize: uiVariables.mediumHeadingSize,
                              fontWeight: FontWeight.bold,
                              color: uiVariables.textColorDefault,
                            ),
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
                                fontSize: uiVariables.mainHeadingSize,
                                fontWeight: FontWeight.bold,
                                color: diff < 0
                                    ? uiVariables.weightLossColor
                                    : uiVariables.weightGainColor,
                              ),
                            )
                          else
                             Text(
                              'Not enough data to calculate change',
                              style: TextStyle(color: uiVariables.textColorDefault),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),


  //-----------weekly/monthly progress---------------
            if (progressAvg != null)
              Padding(
                padding:  EdgeInsets.symmetric(horizontal: uiVariables.subHeadingSize, vertical: 6),
                child: Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Container(
                    decoration: CommonUI().bodyBoxDecorator,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '$label Progress',
                            style:  TextStyle(
                              fontSize: uiVariables.mainHeadingSize,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Average Weight: ${progressAvg.toStringAsFixed(3)} kg',
                            style:  TextStyle(fontSize: uiVariables.mediumHeadingSize),
                          ),
                          if (progressDiff != null && progressPercentage != null)
                            Text(
                              progressDiff < 0
                                  ? 'Loss: ${progressDiff.abs().toStringAsFixed(3)} kg '
                                  '(${progressPercentage.abs().toStringAsFixed(2)}%)'
                                  : 'Gain: ${progressDiff.toStringAsFixed(3)} kg '
                                  '(+${progressPercentage.toStringAsFixed(2)}%)',
                              style: TextStyle(
                                fontSize: uiVariables.mainHeadingSize,
                                fontWeight: FontWeight.bold,
                                color: progressDiff < 0
                                    ? uiVariables.weightLossColor
                                    : uiVariables.weightGainColor,
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


  // -------------------- Calendar cell --------------------
  Widget _dayCell(
      DateTime day, {
        bool isSelected = false,
        bool isToday = false,
        bool isRangeStart = false,
        bool isRangeEnd = false,
        bool isWithinRange = false,
      }) {
    final key = WeightCalculatorHelper.normalizeDate(day);
    final hasWeight = _weightStorage.weights.containsKey(key);
    final yesterdayKey = WeightCalculatorHelper.normalizeDate(
        day.subtract(const Duration(days: 1)));
    final yesterday = _weightStorage.weights[yesterdayKey];
    Color? dotColor;
    if (hasWeight) {
      dotColor = yesterday != null
          ? (_weightStorage.weights[key]! < yesterday
          ? uiVariables.weightLossColor
          : uiVariables.weightGainColor)
          : uiVariables.weightLossColor;
    }
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          margin: const EdgeInsets.all(6),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isSelected
                ? Colors.blue[700] // 🔵 single selected
                : (isRangeStart || isRangeEnd)
                ? Colors.blue[300] // 🔵 range edges
                : isWithinRange
                ? Colors.blue[300] // 🟦 range middle
                : isToday
                ? Colors.blueAccent
                : Colors.transparent,
          ),
          child: Text(
            '${day.day}',
            style: TextStyle(
              fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
              color: day.isAfter(DateTime.now())
                  ? Colors.grey
                  : uiVariables.textColorDefault,
            ),
          ),
        ),
        if (hasWeight)
          Positioned(
            bottom: 4,
            child: Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: dotColor,
              ),
            ),
          ),
      ],
    );
  }

//-------------select month-year combo--------------------------
  Future<void> _showMonthYearPicker(BuildContext context) async {
    int selectedYear = _focusedDay.year;
    int selectedMonth = _focusedDay.month;

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: uiVariables.scaffoldBackgroundColor,
          title: Text('Select Month & Year',
              style: TextStyle(color : uiVariables.textColorDefault,
                  fontWeight: FontWeight.w400,
                  fontSize: 25
              )),
          content: SizedBox(
            height: 50,
            child: Row(
              children: [
                // Month picker
                Expanded(
                  child: Card(
                    color: Colors.lightGreenAccent[100],
                    elevation: 4,
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
                                style: TextStyle(color : uiVariables.textColorDefault,
                                fontWeight: FontWeight.bold
                                ))
                          );
                        },
                      ),
                    ),
                  ),
                ),

//--------------- Year picker ------------------------------
                Expanded(
                  child: Card(
                    color: Colors.lightGreenAccent[100],
                    elevation: 4,
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
                                style: TextStyle(color : uiVariables.textColorDefault,
                                    fontWeight: FontWeight.bold
                                )
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
              child: Text('Cancel',
                style: TextStyle(
                    color: uiVariables.weightGainColor,
                    fontWeight: FontWeight.bold,
                    fontSize: uiVariables.subHeadingSize
                ),),
            ),
            ElevatedButton(
              style : uiVariables.elevatedButtonStyle,
              onPressed: () {
                setState(() {
                  _focusedDay = DateTime(selectedYear, selectedMonth, 1);
                });
                Navigator.pop(context);
              },
              child: Text('OK',
                style: TextStyle(
                    color: uiVariables.textColorDefault,
                    fontWeight: FontWeight.bold,
                    fontSize: uiVariables.subHeadingSize
                ),),
            ),
          ],
        );
      },
    );
  }

  // -------------------- Prediction --------------------
  void _showTargetWeightDialog() {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: uiVariables.scaffoldBackgroundColor,
        title: const Text('Target Weight'),
        content: TextField(
            controller: controller,
            autofocus: true,
            keyboardType: uiVariables.textEditingField,
            inputFormatters: uiVariables.inputFormatter,
            decoration: uiVariables.textEditingFieldDecoration,
            style: TextStyle(color: uiVariables.textColorDefault)
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel',
              style: TextStyle(color : uiVariables.weightGainColor,
                  fontWeight: FontWeight.bold,
                  fontSize: uiVariables.subHeadingSize
              )),
          ),
          ElevatedButton(
            onPressed: () {
              final target = double.tryParse(controller.text.trim());
              if (target == null) return;

              final predicted =
              _calculator.predictDateForTarget(target);

              Navigator.pop(context);

              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  backgroundColor: uiVariables.scaffoldBackgroundColor,
                  title: const Text('Prediction Result'),
                  content: Text(
                    predicted == null
                        ? 'Not enough data to predict.'
                        : 'You may reach $target kg on\n'
                        '${predicted.toLocal().toString().split(' ')[0]}',
                  ),
                  actions: [
                    ElevatedButton(
                        style : uiVariables.elevatedButtonStyle,
                      onPressed: () => Navigator.pop(context),
                      child: Text('OK',
                        style: TextStyle(
                            color: uiVariables.textColorDefault,
                            fontWeight: FontWeight.bold,
                            fontSize: uiVariables.subHeadingSize
                        ),)
                    )
                  ],
                ),
              );
            },
            style : uiVariables.elevatedButtonStyle,
            child: Text('Predict',
              style: TextStyle(
                  color: uiVariables.textColorDefault,
                  fontWeight: FontWeight.bold,
                  fontSize: uiVariables.subHeadingSize
              ),),
          )
        ],
      ),
    );
  }

  //-----------profile---------------

  Widget _buildProfileDrawer() {
    final todayKey = DateTime.now();
    double? currentWeight;
    if (_weightStorage.weights.containsKey(todayKey)) {
      currentWeight = _weightStorage.weights[todayKey];
    } else if (_weightStorage.weights.isNotEmpty) {
      final sortedKeys = _weightStorage.weights.keys.toList()
        ..sort((a, b) => b.compareTo(a));
      currentWeight = _weightStorage.weights[sortedKeys.first];
    }
    return Drawer(
      child: Container(
        color: uiVariables.scaffoldBackgroundColor,
        padding: const EdgeInsets.all(20),
        // decoration: uiVariables.bodyBoxDecorator,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 16),
            /// Avatar
            CircleAvatar(
              radius: 40,
              backgroundColor: Color(0xFFFFFFFF),
              child: Text(
                _userName.isNotEmpty
                    ? _userName[0].toUpperCase()
                    : "U",
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: uiVariables.textColorDefault,
                ),
              ),
            ),
            const SizedBox(height: 12),
            /// Name
            Text(
              _userName,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _email,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 20),
            /// Weight card
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.monitor_weight,
                    size: 32,
                    color: Color(0xFFFF7043),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Current Weight",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                        ),
                      ),
                      Text(
                        currentWeight != null
                            ? "${currentWeight.toStringAsFixed(2)} kg"
                            : "No weight recorded",
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Spacer(),
            Divider(color: uiVariables.textColorDefault, thickness: 0.5,),
            /// Close button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  await SessionManager.logout();
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => LoginPage()),
                        (route) => false,
                  );
                },//=> Navigator.pop(context),
                style: uiVariables.elevatedButtonStyle,
                child: Text("logout", style: TextStyle(color : uiVariables.textColorDefault,
                    fontWeight: FontWeight.bold,
                    fontSize: uiVariables.subHeadingSize ),),
              ),
            )
          ],
        ),
      ),
    );
  }


}
