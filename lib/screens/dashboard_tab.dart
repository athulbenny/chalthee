import 'package:chalthee/constants/CommonUI.dart';
import 'package:chalthee/constants/constant_values.dart';
import 'package:chalthee/storage/session_router.dart';
import 'package:chalthee/storage/weight_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

class DashboardTab extends StatefulWidget {
  final String userName;
  final WeightStorage weightStorage;
  final Function(int) onSwitchTab;

  const DashboardTab({
    super.key,
    required this.userName,
    required this.weightStorage,
    required this.onSwitchTab,
  });

  @override
  State<DashboardTab> createState() => _DashboardTabState();
}

class _DashboardTabState extends State<DashboardTab> {
  double userHeight = 0.0;
  double goalWeight = 0.0;

  @override
  void initState() {
    super.initState();
    loadPrefs();
  }

  Future<void> loadPrefs() async {
    userHeight = await SessionManager.getLocalPreferencesHeight();
    goalWeight = await SessionManager.getLocalPreferencesWeight();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    loadPrefs();
    Widget header = Container(
      padding: EdgeInsets.only(left: 24.w, right: 24.w, top: 48.h, bottom: 16.h),
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
            onPressed: () => widget.onSwitchTab(4),
          ),
        ],
      ),
    );

    Widget welcomeCTA = Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.0.w, vertical: 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            DateTime.now().hour < 12
                ? 'GOOD MORNING, ${widget.userName.toUpperCase()}'
                : DateTime.now().hour < 17
                ? 'GOOD AFTERNOON, ${widget.userName.toUpperCase()}'
                : 'GOOD EVENING, ${widget.userName.toUpperCase()}',
            style: GoogleFonts.inter(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              color: CommonUI().onSurfaceVariant,
              letterSpacing: 1.0,
            ),
          ),
          SizedBox(height: 4.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Focus on your\nprogress.',
                style: GoogleFonts.manrope(
                  fontSize: 32.sp,
                  fontWeight: FontWeight.w800,
                  color: CommonUI().onSurface,
                  height: 1.1.h,
                ),
              ),
              InkWell(
                onTap: () {
                  widget.onSwitchTab(1);
                },
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 24.w,
                    vertical: 16.h,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [CommonUI().primary, CommonUI().primaryContainer],
                    ),
                    borderRadius: BorderRadius.circular(9999.r),
                    boxShadow: [
                      BoxShadow(
                        color: CommonUI().primary.withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.add, color: Colors.white, size: 20.sp),
                      SizedBox(width: 8.w),
                      Text(
                        'Add Entry',
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );

    double? currentWeight;
    DateTime? lastEntryDate;
    double? bmi;
    String bmiLabel = "No BMI details";
    int consistencyPercent = 0;
    List<double> weightList = [];

    void findWeightList() {
      final sortedKeys = widget.weightStorage.weights.keys.toList()
        ..sort((a, b) => b.compareTo(a));
      for (int i = 0; i < sortedKeys.length && i < 4; i++) {
        final date = sortedKeys[i];
        final w = widget.weightStorage.weights[date];
        weightList.add(w!);
      }
    }

    if (widget.weightStorage.weights.isNotEmpty) {
      final sortedKeys = widget.weightStorage.weights.keys.toList()
        ..sort((a, b) => b.compareTo(a));
      lastEntryDate = sortedKeys.first;
      currentWeight = widget.weightStorage.weights[lastEntryDate];

      // Calculate BMI
      if (currentWeight != null &&
          currentWeight > 0 &&
          userHeight != null &&
          userHeight > 0) {
        bmi = currentWeight / (userHeight * userHeight) * 10000;
        if (bmi < 18.5)
          bmiLabel = "Underweight";
        else if (bmi < 25)
          bmiLabel = "Healthy BMI";
        else if (bmi < 30)
          bmiLabel = "Overweight";
        else
          bmiLabel = "Obese";
      }

      // Calculate Consistency
      final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
      final recentEntries = widget.weightStorage.weights.keys
          .where((k) => k.isAfter(thirtyDaysAgo))
          .length;
      final firstEntry = sortedKeys
          .last; // Since it's sorted descending, 'last' is the earliest date
      final daysSinceFirst = DateTime.now().difference(firstEntry).inDays + 1;
      final daysToDivide = daysSinceFirst < 30 ? daysSinceFirst : 30;

      if (daysToDivide > 0) {
        consistencyPercent = ((recentEntries / daysToDivide) * 100)
            .clamp(0, 100)
            .toInt();
      }
    }
    findWeightList();
    Widget bentoGrid = Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.0.w),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Column(
            children: [
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(24.w),
                decoration: CommonUI().cardDecorator,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 4.h,
                      ),
                      decoration: BoxDecoration(
                        color: CommonUI().secondaryContainer,
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Text(
                        'CURRENT STATUS',
                        style: GoogleFonts.inter(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.5,
                          color: CommonUI().onSecondaryContainer,
                        ),
                      ),
                    ),
                    SizedBox(height: 16.h),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          currentWeight != null
                              ? currentWeight.toStringAsFixed(3)
                              : '',
                          style: GoogleFonts.manrope(
                            fontSize: 64.sp,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -2,
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          currentWeight != null ? 'kg' : '',
                          style: GoogleFonts.inter(
                            fontSize: 20.sp,
                            fontWeight: FontWeight.bold,
                            color: CommonUI().onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      'Keep logging to see your progress trends.',
                      style: GoogleFonts.inter(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                        color: CommonUI().onSurfaceVariant,
                      ),
                    ),
                    SizedBox(height: 24.h),
                    SizedBox(
                      height: 80.h,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          if (goalWeight == null ||
                              goalWeight == 0.0 &&
                              weightList.isEmpty)
                            Expanded(
                              child: Container(
                                margin: EdgeInsets.symmetric(
                                  horizontal: 2.w,
                                ),
                                height: 60.h,
                                decoration: BoxDecoration(
                                  color: CommonUI().primary,
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(8.r),
                                  ),
                                ),
                                child: Center(
                                  child: TextButton(
                                    onPressed: () => widget.onSwitchTab(4),
                                    child: Text(
                                      'Setup your profile',
                                      style: GoogleFonts.inter(
                                        fontSize: 16.sp, fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          if (goalWeight != null && goalWeight > 0.0)
                            Expanded(
                              child: Container(
                                margin: EdgeInsets.symmetric(
                                  horizontal: 2.w,
                                ),
                                height: goalWeight,
                                decoration: BoxDecoration(
                                  color: CommonUI().primary,
                                  borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(8.r),
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    weightList.isEmpty
                                        ? 'Target weight : $goalWeight'
                                        : '$goalWeight',
                                    style: GoogleFonts.inter(
                                      color: Colors.white,
                                      fontSize: 16.sp, fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          for (var i in weightList)
                            Expanded(
                              child: Container(
                                margin: EdgeInsets.symmetric(
                                  horizontal: 2.w,
                                ),
                                height: i.toDouble(),
                                decoration: BoxDecoration(
                                  color: i > goalWeight
                                      ? CommonUI().error
                                      : CommonUI().onSecondaryContainer,
                                  borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(8.r),
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    '$i',
                                    style: TextStyle(
                                      color: CommonUI().onError,
                                      fontSize: 16.sp,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16.h),
              Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: Container(
                      padding: EdgeInsets.all(20.w),
                      decoration: BoxDecoration(
                        color: CommonUI().surfaceContainerLow,
                        borderRadius: BorderRadius.circular(24.r),
                      ),
                      child: Column(
                        children: [
                          Container(
                            width: 64.w,
                            height: 64.h,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: CommonUI().secondaryFixedDim,
                                width: 4.w,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                bmi != null ? bmi.toStringAsFixed(1) : '',
                                style: GoogleFonts.manrope(
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.w800,
                                  color: CommonUI().secondary,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 12.h),
                          Text(
                            bmiLabel,
                            style: GoogleFonts.inter(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.bold,
                              color: CommonUI().onSurface,
                            ),
                          ),
                          Text(
                            userHeight != null && userHeight != 0.0
                                ? 'height: ${userHeight}cm'
                                : '',
                            style: GoogleFonts.inter(
                              fontSize: 12.sp,
                              color: CommonUI().onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    flex: 1,
                    child: Container(
                      padding: EdgeInsets.all(20.w),
                      decoration: CommonUI().cardDecorator,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            backgroundColor: CommonUI().surfaceContainerHigh,
                            child: Icon(
                              Icons.calendar_today,
                              color: CommonUI().primary,
                              size: 18.sp,
                            ),
                          ),
                          SizedBox(height: 16.h),
                          Text(
                            'LAST ENTRY',
                            style: GoogleFonts.inter(
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.5,
                              color: CommonUI().onSurfaceVariant,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            currentWeight != null
                                ? '${currentWeight.toStringAsFixed(3)} kg'
                                : 'No data available',
                            style: GoogleFonts.manrope(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            lastEntryDate != null
                                ? DateFormat('yyyy MMMM d').format(lastEntryDate) // '${lastEntryDate.day}-${lastEntryDate.month}-${lastEntryDate.year}'
                                : '',
                            style: GoogleFonts.inter(
                              fontSize: 12.sp,
                              color: CommonUI().onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.h),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(20.w),
                decoration: BoxDecoration(
                  color: CommonUI().surfaceContainerLow,
                  borderRadius: BorderRadius.circular(24.r),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'CONSISTENCY',
                      style: GoogleFonts.inter(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.5,
                        color: CommonUI().onSurfaceVariant,
                      ),
                    ),
                    SizedBox(height: 12.h),
                    Row(
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(9999.r),
                            child: LinearProgressIndicator(
                              value: consistencyPercent / 100,
                              minHeight: 8,
                              backgroundColor: CommonUI().surfaceContainer,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                CommonUI().secondary,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 16.w),
                        Text(
                          '$consistencyPercent%',
                          style: GoogleFonts.manrope(
                            fontSize: 20.sp,
                            fontWeight: FontWeight.bold,
                            color: CommonUI().secondary,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      consistencyPercent >= 80
                          ? 'Great job logging consistently!'
                          : 'Log daily to improve consistency.',
                      style: GoogleFonts.inter(
                        fontSize: 12.sp,
                        color: CommonUI().onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );

    List<Widget> historyItems = [];
    if (widget.weightStorage.weights.isNotEmpty) {
      final sortedKeys = widget.weightStorage.weights.keys.toList()
        ..sort((a, b) => b.compareTo(a));
      for (int i = 0; i < sortedKeys.length && i < 7; i++) {
        final date = sortedKeys[i];
        final w = widget.weightStorage.weights[date];
        historyItems.add(
          Container(
            margin: EdgeInsets.only(bottom: 12.h),
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: CommonUI().surfaceContainerLowest,
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 8.w,
                      height: 8.h,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: CommonUI().secondary,
                      ),
                    ),
                    SizedBox(width: 16.w),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${date.day}/${date.month}/${date.year}',
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.bold,
                            color: CommonUI().onSurface,
                          ),
                        ),
                        Text(
                          'Recorded Entry',
                          style: GoogleFonts.inter(
                            fontSize: 12.sp,
                            color: CommonUI().onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Text(
                  '${w?.toStringAsFixed(1)} kg',
                  style: GoogleFonts.manrope(
                    fontWeight: FontWeight.bold,
                    fontSize: 16.sp,
                  ),
                ),
              ],
            ),
          ),
        );
      }
    } else {
      historyItems.add(Text("No history available."));
    }

    Widget historySection = Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.0.w, vertical: 24.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Weekly History',
                style: GoogleFonts.manrope(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () {
                  widget.onSwitchTab(1);
                },
                child: Text(
                  'View All',
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.bold,
                    color: CommonUI().primary,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          ...historyItems,
          SizedBox(height: 100.h),
        ],
      ),
    );

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [header, welcomeCTA, bentoGrid, historySection],
      ),
    );
  }
}
