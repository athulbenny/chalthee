import 'package:chalthee/constants/CommonUI.dart';
import 'package:chalthee/constants/constant_values.dart';
import 'package:chalthee/helpers/WeightCalculator.dart';
import 'package:chalthee/storage/weight_storage.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class TrendsTab extends StatelessWidget {
  final String userName;
  final WeightStorage weightStorage;
  final Function() onOpenProfile;
  final WeightCalculatorHelper calculator;

  const TrendsTab({
    super.key,
    required this.userName,
    required this.weightStorage,
    required this.onOpenProfile,
    required this.calculator,
  });

  @override
  Widget build(BuildContext context) {
    int currentStreak = 0;
    bool hasLost5kg = false;
    String first5kgDate = "";
    double monthlyDiff = 0.0;
    final controller = TextEditingController();
    CommonUI uiVariables = CommonUI();
    Map<DateTime, double> weightEntry = {};
    List<FlSpot> spotList = [];

    final sortedKeys = weightStorage.weights.keys.toList()
      ..sort((a, b) => b.compareTo(a));
    if (sortedKeys.isNotEmpty) {
      //chart data
      for (var cdate in sortedKeys) {
        if (cdate.month == DateTime.now().month) {
          spotList.add(
            FlSpot(cdate.day.toDouble(), weightStorage.weights[cdate]!),
          );
        }
      }

      // Streak Calculation
      DateTime expectedDate = sortedKeys.first;
      for (var date in sortedKeys) {
        if (date.year == expectedDate.year &&
            date.month == expectedDate.month &&
            date.day == expectedDate.day) {
          currentStreak++;
          expectedDate = expectedDate.subtract(const Duration(days: 1));
        } else if (date.isBefore(expectedDate)) {
          break;
        }
      }

      if (weightStorage.weights.isNotEmpty) {
        final sortedWeightList = weightStorage.weights.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));
        weightEntry = Map.fromEntries(sortedWeightList);
        print("weight entry value $weightEntry");
      }

      // First 5kg milestone
      final firstEntryWeight = weightStorage.weights[sortedKeys.last]!;
      for (int i = sortedKeys.length - 1; i >= 0; i--) {
        final w = weightStorage.weights[sortedKeys[i]]!;
        if (firstEntryWeight - w >= 5.0) {
          hasLost5kg = true;
          first5kgDate =
              "${sortedKeys[i].day}/${sortedKeys[i].month}/${sortedKeys[i].year}";
          break;
        }
      }

      // Monthly Diff
      final now = DateTime.now();
      final thisMonthKeys = sortedKeys
          .where((d) => d.year == now.year && d.month == now.month)
          .toList();
      if (thisMonthKeys.length >= 2) {
        monthlyDiff =
            weightStorage.weights[thisMonthKeys.first]! -
            weightStorage.weights[thisMonthKeys.last]!;
      }
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24.0.w, vertical: 16.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
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
                    onPressed: onOpenProfile,
                  ),
                ],
              ),
              SizedBox(height: 32.h),

              // Trends Title
              Text(
                'Trends',
                style: GoogleFonts.manrope(
                  fontSize: 32.sp,
                  fontWeight: FontWeight.w800,
                  color: CommonUI().onSurface,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                'Analyze your weight milestones and progress\nover time.',
                style: GoogleFonts.inter(
                  fontSize: 16.sp,
                  color: CommonUI().onSurfaceVariant,
                  height: 1.4.h,
                ),
              ),
              SizedBox(height: 32.h),

              // OVERVIEW SECTION
              Padding(
                padding: EdgeInsets.only(left: 8.w, bottom: 8.h),
                child: Text(
                  'OVERVIEW',
                  style: GoogleFonts.inter(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 2.0,
                    color: Colors.grey[700],
                  ),
                ),
              ),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(24.w),
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'This Month',
                      style: GoogleFonts.inter(
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 12.h),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          monthlyDiff <= 0
                              ? monthlyDiff.toStringAsFixed(1)
                              : '+${monthlyDiff.toStringAsFixed(1)}',
                          style: GoogleFonts.manrope(
                            fontSize: 48.sp,
                            fontWeight: FontWeight.w800,
                            color: monthlyDiff <= 0
                                ? CommonUI().weightLossColor
                                : CommonUI().weightGainColor,
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          'kg',
                          style: GoogleFonts.inter(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16.h),
                    // Placeholder for a beautiful chart
                    Container(
                      height: 120.h,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: CommonUI().surfaceContainerLowest,
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(color: Colors.grey[200]!),
                      ),
                      child: (spotList.isEmpty)
                          ? Center(
                              child: Column(
                                children: [
                                  SizedBox(height: 10.h),
                                  Icon(
                                    Icons.show_chart,
                                    size: 55.sp,
                                    color: uiVariables.primary,
                                  ),
                                  SizedBox(height: 10.h),
                                  Text(
                                    'No data available',
                                    style: GoogleFonts.inter(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 15.sp,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : LineChart(
                              LineChartData(
                                gridData: FlGridData(show: false),
                                borderData: FlBorderData(show: false),
                                titlesData: FlTitlesData(
                                  topTitles: AxisTitles(
                                    sideTitles: SideTitles(showTitles: false),
                                  ),
                                  rightTitles: AxisTitles(
                                    sideTitles: SideTitles(showTitles: false),
                                  ),

                                  leftTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      reservedSize: 40,
                                      interval: 3,
                                      getTitlesWidget: (value, meta) {
                                        return Text(
                                          value.toStringAsFixed(0),
                                          style: TextStyle(fontSize: 12.sp),
                                        );
                                      },
                                    ),
                                  ),

                                  bottomTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      interval: 5,
                                      getTitlesWidget: (value, meta) {
                                        return Padding(
                                          padding: EdgeInsets.only(
                                            top: 8.h,
                                          ),
                                          child: Text(
                                            '${value.toInt()}',
                                            style: TextStyle(
                                              fontSize: 12.sp,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                                lineBarsData: [
                                  LineChartBarData(
                                    isCurved: true,
                                    color: Colors.teal,
                                    barWidth: 3,
                                    dotData: FlDotData(show: true),

                                    spots: spotList,
                                  ),
                                ],
                              ),
                            ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 24.h),

              // MILESTONES SECTION
              Padding(
                padding: EdgeInsets.only(left: 8.w, bottom: 8.h),
                child: Text(
                  'MILESTONES',
                  style: GoogleFonts.inter(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 2.0,
                    color: Colors.grey[700],
                  ),
                ),
              ),
              Container(
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
                child: Column(
                  children: [
                    if (hasLost5kg)
                      ListTile(
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 8.h,
                        ),
                        leading: Container(
                          padding: EdgeInsets.all(10.w),
                          decoration: BoxDecoration(
                            color: Colors.orange.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.workspace_premium,
                            color: Colors.orange,
                          ),
                        ),
                        title: Text(
                          'First 5kg Lost!',
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.w600,
                            fontSize: 15.sp,
                          ),
                        ),
                        subtitle: Text(
                          'Achieved on $first5kgDate',
                          style: GoogleFonts.inter(
                            color: Colors.grey[600],
                            fontSize: 13.sp,
                          ),
                        ),
                      ),
                    if (hasLost5kg && currentStreak >= 3)
                      Divider(
                        height: 1.h,
                        indent: 64,
                        thickness: 0.5,
                        color: Color(0xFFEEEEEE),
                      ),
                    if (currentStreak >= 3)
                      ListTile(
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 8.h,
                        ),
                        leading: Container(
                          padding: EdgeInsets.all(10.w),
                          decoration: BoxDecoration(
                            color: Colors.purple.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.local_fire_department,
                            color: Colors.purple,
                          ),
                        ),
                        title: Text(
                          '$currentStreak Day Streak',
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.w600,
                            fontSize: 15.sp,
                          ),
                        ),
                        subtitle: Text(
                          'Consistent daily logging.',
                          style: GoogleFonts.inter(
                            color: Colors.grey[600],
                            fontSize: 13.sp,
                          ),
                        ),
                      ),
                    if (!hasLost5kg && currentStreak < 3)
                      Padding(
                        padding: EdgeInsets.all(24.0.w),
                        child: Center(
                          child: Text(
                            "Keep logging entries to unlock achievements and streaks!",
                            style: GoogleFonts.inter(color: Colors.grey[600]),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              SizedBox(height: 10.h),
              if (weightEntry.isNotEmpty)
                Padding(
                  padding: EdgeInsets.only(left: 8.w, bottom: 8.h),
                  child: Text(
                    'TURNAROUNDS',
                    style: GoogleFonts.inter(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 2.0,
                      color: Colors.grey[700],
                    ),
                  ),
                ),
              if (weightEntry.isNotEmpty)
                Container(
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
                  child: Column(
                    children: [
                      ListTile(
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 8.h,
                        ),
                        leading: Container(
                          padding: EdgeInsets.all(10.w),
                          decoration: BoxDecoration(
                            color: Colors.orange.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.flight, color: Colors.orange[800]),
                        ),
                        title: Text(
                          'Highest Weight Recorded ${weightEntry.values.first}',
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.w600,
                            fontSize: 15.sp,
                          ),
                        ),
                        subtitle: Text(
                          'Achieved on ${weightEntry.keys.first.toIso8601String().split("T").first}',
                          style: GoogleFonts.inter(
                            color: Colors.grey[600],
                            fontSize: 13.sp,
                          ),
                        ),
                      ),
                      Divider(
                        height: 1.h,
                        indent: 64,
                        thickness: 0.5,
                        color: Color(0xFFEEEEEE),
                      ),
                      ListTile(
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 8.h,
                        ),
                        leading: Container(
                          padding: EdgeInsets.all(10.w),
                          decoration: BoxDecoration(
                            color: Colors.purple.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.flight_land_rounded,
                            color: Colors.lightGreen,
                          ),
                        ),
                        title: Text(
                          'Minimum Weight Recorded ${weightEntry.values.last}',
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.w600,
                            fontSize: 15.sp,
                          ),
                        ),
                        subtitle: Text(
                          'Achieved on ${weightEntry.keys.last.toIso8601String().split("T").first}',
                          style: GoogleFonts.inter(
                            color: Colors.grey[600],
                            fontSize: 13.sp,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              SizedBox(height: 30.h),
              Container(
                padding: EdgeInsets.all(16.w),
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Target Weight',
                          style: GoogleFonts.manrope(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: TextField(
                            controller: controller,
                            keyboardType: uiVariables.textEditingField,
                            inputFormatters: uiVariables.inputFormatter,
                            decoration: uiVariables.textEditingFieldDecoration,
                            style: TextStyle(
                              color: uiVariables.textColorDefault,
                            ),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 16.h),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          final target = double.tryParse(
                            controller.text.trim(),
                          );
                          if (target == null) return;
                          final predicted = calculator.predictDateForTarget(
                            target,
                          );
                          showDialog(
                            context: context,
                            builder: (_) => AlertDialog(
                              backgroundColor:
                                  uiVariables.scaffoldBackgroundColor,
                              title: Text('Prediction Result'),
                              content: Text(
                                predicted == null
                                    ? 'Not enough data to predict.'
                                    : 'You may reach $target kg on\n${predicted.toLocal().toString().split(' ')[0]}',
                                style: GoogleFonts.manrope(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              actions: [
                                ElevatedButton(
                                  style: uiVariables.elevatedButtonStyle,
                                  onPressed: () => Navigator.pop(context),
                                  child: Text(
                                    'OK',
                                    style: GoogleFonts.manrope(
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                        style: uiVariables.elevatedButtonStyle,
                        child: Text(
                          'Predict',
                          style: GoogleFonts.manrope(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
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
      ),
    );
  }

}
