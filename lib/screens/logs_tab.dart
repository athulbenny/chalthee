import 'package:chalthee/constants/CommonUI.dart';
import 'package:chalthee/helpers/WeightCalculator.dart';
import 'package:chalthee/storage/weight_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import '../constants/constant_values.dart';
import 'activity_summary_page.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class LogsTab extends StatefulWidget {
  final WeightStorage weightStorage;
  final WeightCalculatorHelper calculator;
  final String userName;
  final Function() onOpenProfile;

  const LogsTab({
    super.key,
    required this.weightStorage,
    required this.calculator,
    required this.userName,
    required this.onOpenProfile,
  });

  @override
  State<LogsTab> createState() => _LogsTabState();
}

class _LogsTabState extends State<LogsTab> with TickerProviderStateMixin {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay = DateTime.now();
  DateTime? _rangeStart;
  DateTime? _rangeEnd;
  RangeSelectionMode _rangeSelectionMode = RangeSelectionMode.toggledOff;
  final TextEditingController _weightController = TextEditingController();
  bool _isEditingWeight = false;
  final CommonUI uiVariables = CommonUI();

  final GlobalKey _selectedDayKey = GlobalKey();
  final GlobalKey _addButtonKey = GlobalKey();

  @override
  void dispose() {
    _weightController.dispose();
    super.dispose();
  }

  void _showTopConfirmation({
    required String message,
    required VoidCallback onConfirm,
  }) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentMaterialBanner();

    messenger.showMaterialBanner(
      MaterialBanner(
        margin: EdgeInsetsGeometry.symmetric(horizontal: 25.w),
        content: Text(
          message,
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w800,
            color: Colors.white,
            fontSize: 16.sp,
          ),
        ),
        backgroundColor: uiVariables.primary,
        elevation: 5,
        leading: Icon(Icons.info_outline, color: Colors.white),
        actions: [
          TextButton(
            onPressed: () {
              messenger.hideCurrentMaterialBanner();
            },
            child: Text(
              'CANCEL',
              style: GoogleFonts.inter(
                color: Colors.white70,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              messenger.hideCurrentMaterialBanner();
              onConfirm();
            },
            child: Text(
              'OK',
              style: GoogleFonts.inter(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<MapEntry<DateTime, double>> _getWeekEntries(DateTime anchor) {
    final start = WeightCalculatorHelper.normalizeDate(
      anchor.subtract(Duration(days: anchor.weekday - 1)),
    );
    final end = start.add(const Duration(days: 6));
    return widget.weightStorage.weights.entries
        .where((e) => !e.key.isBefore(start) && !e.key.isAfter(end))
        .toList()
      ..sort((a, b) => a.key.compareTo(b.key));
  }

  List<MapEntry<DateTime, double>> _getMonthEntries(DateTime anchor) {
    final start = DateTime(anchor.year, anchor.month, 1);
    final end = DateTime(anchor.year, anchor.month + 1, 0);
    return widget.weightStorage.weights.entries
        .where((e) => !e.key.isBefore(start) && !e.key.isAfter(end))
        .toList()
      ..sort((a, b) => a.key.compareTo(b.key));
  }

  List<MapEntry<DateTime, double>> _getSelectedEntries() {
    if (_selectedDay != null) {
      final day = WeightCalculatorHelper.normalizeDate(_selectedDay!);
      return widget.weightStorage.weights.entries
          .where((e) => isSameDay(e.key, day))
          .toList();
    }
    if (_rangeStart != null && _rangeEnd != null) {
      final start = WeightCalculatorHelper.normalizeDate(_rangeStart!);
      final end = WeightCalculatorHelper.normalizeDate(_rangeEnd!);
      return widget.weightStorage.weights.entries
          .where((e) => !e.key.isBefore(start) && !e.key.isAfter(end))
          .toList()
        ..sort((a, b) => a.key.compareTo(b.key));
    }
    return [];
  }

  double? get dailyDiff => _selectedDay != null
      ? widget.calculator.dailyDifference(_selectedDay!)
      : null;

  double? get progressDiff =>
      widget.calculator.calculateDiff(_getSelectedEntries());

  double? get progressAvg =>
      widget.calculator.calculateAverage(_getSelectedEntries());

  double? get progressPercentage =>
      widget.calculator.calculatePercentChange(_getSelectedEntries());

  void _startEditingWeight() {
    if (_selectedDay == null) return;
    final key = WeightCalculatorHelper.normalizeDate(_selectedDay!);
    _weightController.text =
        widget.weightStorage.weights[key]?.toString() ?? '';
    setState(() => _isEditingWeight = true);
  }

  void _playAddBubbleAnimation(double value, VoidCallback onComplete) {
    final RenderBox? buttonBox = _addButtonKey.currentContext?.findRenderObject() as RenderBox?;
    final RenderBox? dayBox = _selectedDayKey.currentContext?.findRenderObject() as RenderBox?;

    if (buttonBox == null || dayBox == null) {
      onComplete();
      return;
    }

    final startPosition = buttonBox.localToGlobal(buttonBox.size.center(Offset.zero));
    final endPosition = dayBox.localToGlobal(Offset(dayBox.size.width / 2, dayBox.size.height - 4.h));

    OverlayEntry? entry;
    final controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    final animationX = Tween<double>(begin: startPosition.dx, end: endPosition.dx).animate(CurvedAnimation(parent: controller, curve: Curves.easeInOut));
    final animationY = Tween<double>(begin: startPosition.dy, end: endPosition.dy).animate(CurvedAnimation(parent: controller, curve: Curves.easeInOut));
    final scaleAnimation = Tween<double>(begin: 30.0, end: 6.w).animate(CurvedAnimation(parent: controller, curve: Curves.easeIn));

    entry = OverlayEntry(
      builder: (context) {
        return AnimatedBuilder(
          animation: controller,
          builder: (context, child) {
            return Positioned(
              left: animationX.value - scaleAnimation.value / 2,
              top: animationY.value - scaleAnimation.value / 2,
              child: Container(
                width: scaleAnimation.value,
                height: scaleAnimation.value,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: uiVariables.primary,
                ),
              ),
            );
          },
        );
      },
    );

    Overlay.of(context).insert(entry);
    controller.forward().then((_) {
      entry?.remove();
      controller.dispose();
      onComplete();
    });
  }

  void _playDeleteBubbleAnimation(VoidCallback onComplete) {
    final RenderBox? dayBox = _selectedDayKey.currentContext?.findRenderObject() as RenderBox?;

    if (dayBox == null) {
      onComplete();
      return;
    }

    final position = dayBox.localToGlobal(Offset(dayBox.size.width / 2, dayBox.size.height - 4.h));

    OverlayEntry? entry;
    final controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    final scaleAnimation = Tween<double>(begin: 6.w, end: 30.0).animate(CurvedAnimation(parent: controller, curve: Curves.easeOut));
    final opacityAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(CurvedAnimation(parent: controller, curve: Curves.easeOut));

    entry = OverlayEntry(
      builder: (context) {
        return AnimatedBuilder(
          animation: controller,
          builder: (context, child) {
            return Positioned(
              left: position.dx - scaleAnimation.value / 2,
              top: position.dy - scaleAnimation.value / 2,
              child: Opacity(
                opacity: opacityAnimation.value,
                child: Container(
                  width: scaleAnimation.value,
                  height: scaleAnimation.value,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: uiVariables.weightGainColor,
                  ),
                ),
              ),
            );
          },
        );
      },
    );

    Overlay.of(context).insert(entry);
    controller.forward().then((_) {
      entry?.remove();
      controller.dispose();
      onComplete();
    });
  }

  void _saveWeight() {
    if (_selectedDay == null) return;
    final text = _weightController.text.trim();
    final value = double.tryParse(text);
    if (value == null || value <= 0) return;

    _showTopConfirmation(
      message: 'Save weight entry ($value kg)?',
      onConfirm: () {
        final key = WeightCalculatorHelper.normalizeDate(_selectedDay!);
        _playAddBubbleAnimation(value, () {
          setState(() {
            widget.weightStorage.saveWeight(key, value);
            _isEditingWeight = false;
            _weightController.clear();
          });
        });
      },
    );
  }

  void _dltWeight() {
    if (_selectedDay == null) return;
    _showTopConfirmation(
      message:
      'Delete weight entry of ${_selectedDay?.toIso8601String().split("T").first}?',
      onConfirm: () {
        final key = WeightCalculatorHelper.normalizeDate(_selectedDay!);
        _playDeleteBubbleAnimation(() {
          setState(() {
            widget.weightStorage.deleteWeight(key);
            _isEditingWeight = false;
            _weightController.clear();
          });
        });
      },
    );
  }

  Widget _dayCell(
      DateTime day, {
        bool isSelected = false,
        bool isToday = false,
        bool isRangeStart = false,
        bool isRangeEnd = false,
        bool isWithinRange = false,
      }) {
    final key = WeightCalculatorHelper.normalizeDate(day);
    final hasWeight = widget.weightStorage.weights.containsKey(key);
    final yesterdayKey = WeightCalculatorHelper.normalizeDate(
      day.subtract(const Duration(days: 1)),
    );
    final yesterday = widget.weightStorage.weights[yesterdayKey];
    Color? dotColor;
    if (hasWeight) {
      dotColor = yesterday != null
          ? (widget.weightStorage.weights[key]! < yesterday
          ? uiVariables.weightLossColor
          : uiVariables.weightGainColor)
          : uiVariables.weightLossColor;
    }
    return Stack(
      key: isSelected ? _selectedDayKey : null,
      alignment: Alignment.center,
      children: [
        Container(
          margin: EdgeInsets.all(6.w),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isSelected
                ? Colors.blue[700]
                : (isRangeStart || isRangeEnd)
                ? Colors.blue[300]
                : isWithinRange
                ? Colors.blue[300]
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
            bottom: 4.h,
            child: Container(
              width: 6.w,
              height: 6.h,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: dotColor,
              ),
            ),
          ),
      ],
    );
  }

  Future<void> _showMonthYearPicker(BuildContext context) async {
    int selectedYear = _focusedDay.year;
    int selectedMonth = _focusedDay.month;

    final monthController = FixedExtentScrollController(
      initialItem: selectedMonth - 1,
    );
    final yearController = FixedExtentScrollController(
      initialItem: selectedYear - 2020,
    );

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: uiVariables.surface,
          title: Text(
            'Select Month & Year',
            style: GoogleFonts.inter(
              color: CommonUI().onSurface,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: SizedBox(
            height: 80.h,
            child: Row(
              children: [
                Expanded(
                  child: Card(
                    color: uiVariables.surfaceContainerHigh,
                    elevation: 4,
                    child: ListWheelScrollView.useDelegate(
                      controller: monthController,
                      itemExtent: 30,
                      perspective: 0.003,
                      diameterRatio: 1.8,
                      physics: const FixedExtentScrollPhysics(),
                      onSelectedItemChanged: (index) {
                        selectedMonth = index + 1;
                      },
                      childDelegate: ListWheelChildBuilderDelegate(
                        childCount: 12,
                        builder: (context, index) {
                          return AnimatedBuilder(
                            animation: monthController,
                            builder: (context, child) {
                              int diff = (monthController.selectedItem - index)
                                  .abs();
                              double scale = (1 - (diff * 0.2)).clamp(0.7, 1.2);
                              return Transform(
                                alignment: Alignment.center,
                                transform: Matrix4.identity()
                                  ..scale(scale)
                                  ..rotateX(diff * 0.2),
                                child: child,
                              );
                            },
                            child: Center(
                              child: Text(
                                DateTime(0, index + 1).month.toString(),
                                style: TextStyle(
                                  fontSize: 20.sp,
                                  color: uiVariables.textColorDefault,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Card(
                    color: uiVariables.surfaceContainerHigh,
                    elevation: 4,
                    child: ListWheelScrollView.useDelegate(
                      controller: yearController,
                      itemExtent: 30,
                      perspective: 0.003,
                      diameterRatio: 1.8,
                      physics: const FixedExtentScrollPhysics(),
                      onSelectedItemChanged: (index) {
                        selectedYear = 2020 + index;
                      },
                      childDelegate: ListWheelChildBuilderDelegate(
                        childCount: 20,
                        builder: (context, index) {
                          return AnimatedBuilder(
                            animation: yearController,
                            builder: (context, child) {
                              int diff = (yearController.selectedItem - index)
                                  .abs();
                              double scale = (1 - (diff * 0.2)).clamp(0.7, 1.2);
                              return Transform(
                                alignment: Alignment.center,
                                transform: Matrix4.identity()
                                  ..scale(scale)
                                  ..rotateX(diff * 0.2),
                                child: child,
                              );
                            },
                            child: Center(
                              child: Text(
                                (2020 + index).toString(),
                                style: TextStyle(
                                  fontSize: 20.sp,
                                  color: uiVariables.textColorDefault,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
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
              child: Text(
                'Cancel',
                style: GoogleFonts.inter(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ElevatedButton(
              style: uiVariables.elevatedButtonStyle,
              onPressed: () {
                setState(() {
                  _focusedDay = DateTime(selectedYear, selectedMonth, 1);
                });
                Navigator.pop(context);
              },
              child: Text(
                'OK',
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final entries = _getSelectedEntries();
    final highestEntry = entries.isNotEmpty
        ? entries.reduce((a, b) => a.value > b.value ? a : b)
        : null;
    final lowestEntry = entries.isNotEmpty
        ? entries.reduce((a, b) => a.value < b.value ? a : b)
        : null;
    final smartStart = entries.isNotEmpty ? entries.first.key : null;
    final smartEnd = entries.length > 1 ? entries.last.key : null;
    final avg = entries.isNotEmpty
        ? widget.calculator.getInitialWeight(entries)
        : null;
    final diff = entries.length > 1
        ? widget.calculator.calculateDiff(entries)
        : null;

    final smartRangePercentage = (avg != null && diff != null && avg != 0)
        ? (diff / avg) * 100
        : null;
    final weeklyProgress = _getWeekEntries(_focusedDay);
    final monthlyProgress = _getMonthEntries(_focusedDay);
    final progressInitialWeeklyWeight = weeklyProgress.isNotEmpty
        ? widget.calculator.getInitialWeight(weeklyProgress)
        : null;
    final progressInitialMonthlyWeight = monthlyProgress.isNotEmpty
        ? widget.calculator.getInitialWeight(monthlyProgress)
        : null;
    final progressWeeklyAvg = weeklyProgress.isNotEmpty
        ? widget.calculator.calculateAverage(weeklyProgress)
        : null;
    final progressMonthlyAvg = monthlyProgress.isNotEmpty
        ? widget.calculator.calculateAverage(monthlyProgress)
        : null;
    final progressWeeklyDiff = weeklyProgress.length > 1
        ? widget.calculator.calculateDiff(weeklyProgress)
        : null;
    final progressMonthlyDiff = monthlyProgress.length > 1
        ? widget.calculator.calculateDiff(monthlyProgress)
        : null;
    final progressWeeklyPercentage =
    (progressWeeklyAvg != null &&
        progressWeeklyDiff != null &&
        progressWeeklyAvg != 0 &&
        progressInitialWeeklyWeight != null &&
        progressInitialWeeklyWeight != 0)
        ? (progressWeeklyDiff / progressInitialWeeklyWeight) * 100
        : null;
    final progressMonthlyPercentage =
    (progressMonthlyAvg != null &&
        progressMonthlyDiff != null &&
        progressMonthlyAvg != 0 &&
        progressInitialMonthlyWeight != null &&
        progressInitialWeeklyWeight != 0)
        ? (progressMonthlyDiff / progressInitialMonthlyWeight) * 100
        : null;
    final selectedKey = _selectedDay != null
        ? WeightCalculatorHelper.normalizeDate(_selectedDay!)
        : null;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.only(
                left: 24.w,
                right: 24.w,
                top: 48.h,
                bottom: 16.h,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.transparent,
                        backgroundImage: AssetImage(ConstantValues.logo),
                        radius: 20,
                      ),
                      SizedBox(width: 12.w),
                      Text(
                        ConstantValues.appName,
                        style: GoogleFonts.manrope(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.w800,
                          color: CommonUI().primary,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: Icon(Icons.settings, color: CommonUI().primary),
                    onPressed: () => widget.onOpenProfile,
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 24.0.w,
                vertical: 16.h,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Track your weight',
                    style: GoogleFonts.manrope(
                      fontSize: 32.sp,
                      fontWeight: FontWeight.w800,
                      color: CommonUI().onSurface,
                    ),
                  ),
                  SizedBox(height: 20.h),
                  Card(
                    child: Container(
                      decoration: uiVariables.bodyBoxDecorator,
                      child: TableCalendar(
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
                            fontSize: 22.sp,
                            fontWeight: FontWeight.bold,
                            color: uiVariables.textColorDefault,
                          ),
                        ),
                        onHeaderTapped: (focusedDay) {
                          _showMonthYearPicker(context);
                        },
                        daysOfWeekStyle: DaysOfWeekStyle(
                          weekdayStyle: TextStyle(
                            fontSize: uiVariables.subHeadingSize,
                            fontWeight: FontWeight.w600,
                            color: uiVariables.textColorDefault,
                          ),
                          weekendStyle: TextStyle(
                            fontSize: uiVariables.subHeadingSize,
                            fontWeight: FontWeight.w600,
                            color: uiVariables.weightGainColor,
                          ),
                        ),
                        enabledDayPredicate: (day) =>
                        !day.isAfter(DateTime.now()),
                        onDaySelected: (day, focused) {
                          setState(() {
                            _weightController.clear();
                            _selectedDay = day;
                            _focusedDay = focused;
                            _rangeStart = null;
                            _rangeEnd = null;
                            _rangeSelectionMode = RangeSelectionMode.toggledOff;
                          });
                        },
                        onRangeSelected: (start, end, focused) {
                          setState(() {
                            _selectedDay = null;
                            _rangeStart = start;
                            _rangeEnd = end;
                            _focusedDay = focused;
                            _rangeSelectionMode = RangeSelectionMode.toggledOn;
                          });
                        },
                        calendarBuilders: CalendarBuilders(
                          defaultBuilder: (_, d, _) => _dayCell(d),
                          selectedBuilder: (_, d, _) =>
                              _dayCell(d, isSelected: true),
                          todayBuilder: (_, d, _) => _dayCell(d, isToday: true),
                          rangeStartBuilder: (_, d, _) =>
                              _dayCell(d, isRangeStart: true),
                          rangeEndBuilder: (_, d, _) =>
                              _dayCell(d, isRangeEnd: true),
                          withinRangeBuilder: (_, d, _) =>
                              _dayCell(d, isWithinRange: true),
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 20.h),

                  //DAILY
                  if (_selectedDay != null)
                    _buildCardContainer(
                      items: [
                        SizedBox(height: 10.h),
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 24.0.w,
                            vertical: 16.h,
                          ),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Text(
                                    'Weight on ${DateFormat('MMMM d, yyyy').format(_focusedDay)}',
                                    style: GoogleFonts.manrope(
                                      fontSize: 18.sp,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(width: 12.w),
                                  Expanded(
                                    child: TextField(
                                      controller: _weightController,
                                      keyboardType:
                                      uiVariables.textEditingField,
                                      inputFormatters:
                                      uiVariables.inputFormatter,
                                      decoration: uiVariables
                                          .textEditingFieldDecoration,
                                      style: TextStyle(
                                        color: uiVariables.textColorDefault,
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              SizedBox(height: 16.h),
                              Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceAround,
                                children: [
                                  InkWell(
                                    key: _addButtonKey,
                                    onTap: _saveWeight,
                                    child: _button(
                                      icon: Icons.add,
                                      text: 'Add Entry',
                                      colors: [
                                        CommonUI().primary,
                                        CommonUI().primaryContainer,
                                      ],
                                    ),
                                  ),

                                  SizedBox(width: 12.w),

                                  InkWell(
                                    onTap: () {
                                      _weightController.clear();
                                      _dltWeight();
                                    },
                                    child: _button(
                                      icon: Icons.delete,
                                      text: 'Dlt Entry',
                                      colors: [
                                        CommonUI().weightGainColor,
                                        CommonUI().weightGainColor,
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        _buildListItem(
                          iconData: Icons.calendar_today_outlined,
                          iconColor: Colors.blue[700]!,
                          iconBg: Colors.blue[200]!,
                          title:
                          "Day weight [${DateFormat('MMMM d, yyyy').format(_focusedDay)}]",
                          trailing: Text(
                            widget.weightStorage.weights.containsKey(
                              selectedKey,
                            )
                                ? '${widget.weightStorage.weights[selectedKey]} kg'
                                : 'Not recorded',
                            style: GoogleFonts.manrope(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle:
                          (widget.weightStorage.weights.containsKey(
                            selectedKey?.subtract(const Duration(days: 1)),
                          ))
                              ? 'Previous Day: ${widget.weightStorage.weights[selectedKey?.subtract(const Duration(days: 1))]} Kg'
                              : '',
                        ),
                        _buildListItem(
                          iconData: Icons.calendar_today_outlined,
                          iconColor: Colors.blue[700]!,
                          iconBg: Colors.blue[200]!,
                          title: "Daily progress",
                          trailing: (dailyDiff != null)
                              ? Text(
                            dailyDiff! < 0
                                ? '↓ ${dailyDiff!.abs().toStringAsFixed(3)} kg'
                                : dailyDiff! > 0
                                ? '↑ +${dailyDiff!.toStringAsFixed(3)} kg'
                                : '${dailyDiff!.toStringAsFixed(3)} kg',
                            style: GoogleFonts.manrope(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                              : Text(
                            'No enough data',
                            style: GoogleFonts.manrope(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: dailyDiff != null
                              ? dailyDiff! < 0
                              ? 'Loss'
                              : dailyDiff! > 0
                              ? 'Gain'
                              : 'No change'
                              : "",
                        ),
                        SizedBox(height: 16.h),
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 16.0.w,
                            vertical: 8.0.h,
                          ),
                          child: InkWell(
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (ctx) =>
                                    DailySummaryPage(date: _selectedDay!),
                              ),
                            ),
                            borderRadius: BorderRadius.circular(12.r),
                            child: Container(
                              width: double.infinity,
                              padding: EdgeInsets.symmetric(vertical: 16.h),
                              decoration: BoxDecoration(
                                color: uiVariables.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12.r),
                                border: Border.all(
                                  color: uiVariables.primary.withOpacity(0.3),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.insights,
                                    color: uiVariables.primary,
                                  ),
                                  SizedBox(width: 8.w),
                                  Text(
                                    'View Activity Summary',
                                    style: GoogleFonts.inter(
                                      color: uiVariables.primary,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16.sp,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 8.h),
                      ],
                    ),

                  //SELECTION IN RANGE
                  if (_rangeStart != null && _rangeEnd != null)
                    _buildCardContainer(
                      items: [
                        _buildListItem(
                          iconData: Icons.calendar_today_outlined,
                          iconColor: Colors.blue[700]!,
                          iconBg: Colors.blue[200]!,
                          title: smartStart != null && smartEnd != null
                              ? 'Range: ${DateFormat('MMMM d, yyyy').format(smartStart)} -> ${DateFormat('MMMM d, yyyy').format(smartEnd)}'
                              : 'No data in selected range',
                          trailing:
                          (diff != null && smartRangePercentage != null)
                              ? Text(
                            diff < 0
                                ? 'Loss: ${diff.abs().toStringAsFixed(3)} kg (${smartRangePercentage.abs().toStringAsFixed(2)}%)'
                                : 'Gain: ${diff.toStringAsFixed(3)} kg (+${smartRangePercentage.toStringAsFixed(2)}%)',
                            style: GoogleFonts.manrope(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                              color: diff < 0
                                  ? uiVariables.weightGainColor
                                  : uiVariables.weightLossColor,
                            ),
                          )
                              : Text(
                            'No enough data',
                            style: GoogleFonts.manrope(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                              color: uiVariables.textColorDefault,
                            ),
                          ),
                          subtitle: '',
                        ),
                        if (highestEntry != null)
                          _buildListItem(
                            iconData: Icons.trending_up,
                            iconColor: uiVariables.weightGainColor,
                            iconBg: uiVariables.weightGainColor.withOpacity(
                              0.2,
                            ),
                            title: 'Highest Weight',
                            trailing: Text(
                              '${highestEntry.value} kg',
                              style: GoogleFonts.manrope(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle:
                            'On ${DateFormat('MMMM d, yyyy').format(highestEntry.key)}',
                          ),
                        if (lowestEntry != null)
                          _buildListItem(
                            iconData: Icons.trending_down,
                            iconColor: uiVariables.weightLossColor,
                            iconBg: uiVariables.weightLossColor.withOpacity(
                              0.2,
                            ),
                            title: 'Lowest Weight',
                            trailing: Text(
                              '${lowestEntry.value} kg',
                              style: GoogleFonts.manrope(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle:
                            'On ${DateFormat('MMMM d, yyyy').format(lowestEntry.key)}',
                          ),
                      ],
                    ),
                  SizedBox(height: 20.h),

                  //MONTHLY/WEEKLY
                  if (progressWeeklyAvg != null && !(_rangeStart != null && _rangeEnd != null))
                    _buildCardContainer(
                      items: [
                        _buildListItem(
                          iconData: Icons.calendar_view_week_outlined,
                          iconColor: Colors.blue[700]!,
                          iconBg: Colors.blue[200]!,
                          title: "Weekly progress",
                          trailing:
                          (progressWeeklyDiff != null &&
                              progressWeeklyPercentage != null)
                              ? Text(
                            progressWeeklyDiff < 0
                                ? 'Loss: ${progressWeeklyDiff.abs().toStringAsFixed(3)} kg (${progressWeeklyPercentage.abs().toStringAsFixed(2)}%)'
                                : 'Gain: ${progressWeeklyDiff.toStringAsFixed(3)} kg (+${progressWeeklyPercentage.toStringAsFixed(2)}%)',
                            style: GoogleFonts.manrope(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                              color: progressWeeklyDiff < 0
                                  ? uiVariables.weightLossColor
                                  : uiVariables.weightGainColor,
                            ),
                          )
                              : Text(
                            'Not enough data',
                            style: GoogleFonts.manrope(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle:
                          'Weekly Average Weight: ${progressWeeklyAvg.toStringAsFixed(3)} kg',
                        ),
                        _buildListItem(
                          iconData: Icons.calendar_month_outlined,
                          iconColor: Colors.blue[700]!,
                          iconBg: Colors.blue[200]!,
                          title: "Monthly progress",
                          trailing:
                          (progressMonthlyDiff != null &&
                              progressMonthlyPercentage != null)
                              ? Text(
                            progressMonthlyDiff < 0
                                ? 'Loss: ${progressMonthlyDiff.abs().toStringAsFixed(3)} kg (${progressMonthlyPercentage.abs().toStringAsFixed(2)}%)'
                                : 'Gain: ${progressMonthlyDiff.toStringAsFixed(3)} kg (+${progressMonthlyPercentage.toStringAsFixed(2)}%)',
                            style: GoogleFonts.manrope(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                              color: progressMonthlyDiff < 0
                                  ? uiVariables.weightLossColor
                                  : uiVariables.weightGainColor,
                            ),
                          )
                              : Text(
                            'No enough data',
                            style: GoogleFonts.manrope(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle:
                          'Monthly Average Weight: ${progressMonthlyAvg?.toStringAsFixed(3)} kg',
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardContainer({required List<Widget> items}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(children: items),
    );
  }

  Widget _buildListItem({
    required IconData iconData,
    required Color iconColor,
    required Color iconBg,
    required String title,
    required String subtitle,
    Widget? trailing,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
      leading: Container(
        padding: EdgeInsets.all(8.w),
        decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
        child: Icon(iconData, color: iconColor),
      ),
      title: Text(
        title,
        style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 15.sp),
      ),
      subtitle: Text(
        subtitle,
        style: GoogleFonts.inter(color: Colors.grey[600], fontSize: 13.sp),
      ),
      trailing: trailing ?? Icon(Icons.chevron_right, color: Colors.grey),
      onTap: trailing != null && trailing is Switch ? null : () {},
    );
  }

  Widget _button({
    required IconData icon,
    required String text,
    required List<Color> colors,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 12.h),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: colors),
        borderRadius: BorderRadius.circular(9999.r),
        boxShadow: [
          BoxShadow(
            color: colors.first.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 20.sp),
          SizedBox(width: 8.w),
          Text(
            text,
            style: GoogleFonts.inter(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
