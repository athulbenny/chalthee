import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../constants/constant_values.dart';
import '../storage/exercise_storage.dart';
import '../storage/food_storage.dart';
import 'package:intl/intl.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class DailySummaryPage extends StatefulWidget {
  final DateTime date;

  const DailySummaryPage({
    super.key,
    required this.date,
  });

  @override
  State<DailySummaryPage> createState() => _DailySummaryPageState();
}

class _DailySummaryPageState extends State<DailySummaryPage> {
  bool _isLoading = true;
  Map<String, dynamic> _exerciseData = {};
  Map<String, dynamic> _foodData = {};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final exerciseData = await ExerciseStorage().getExercise(widget.date);
    final foodData = await FoodStorage().getFood(widget.date);

    if (mounted) {
      setState(() {
        _exerciseData = exerciseData;
        _foodData = foodData;
        _isLoading = false;
      });

      if (_exerciseData.isEmpty && _foodData.isEmpty) {
        _showNoDataBanner();
      }
    }
  }

  ScaffoldMessengerState? _scaffoldMessenger;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _scaffoldMessenger = ScaffoldMessenger.maybeOf(context);
  }

  @override
  void dispose() {
    _scaffoldMessenger?.hideCurrentMaterialBanner();
    super.dispose();
  }

  void _showNoDataBanner() {
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentMaterialBanner();

    messenger.showMaterialBanner(
      MaterialBanner(
        content: Text(
          'No data is present for this date.',
          style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: Colors.white),
        ),
        backgroundColor: const Color(0xFF0B5D5D),
        elevation: 2,
        leading: Icon(Icons.warning_amber_rounded, color: Colors.white),
        actions: [
          TextButton(
            onPressed: () {
              messenger.hideCurrentMaterialBanner();
            },
            child: Text(
              'DISMISS',
              style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  int get totalBurned => (_exerciseData['totalBurned'] as num?)?.toInt() ?? 0;

  int get totalIntake {
    int total = 0;
    _foodData.forEach((key, value) {
      if (value is Map) {
        total += (value['inKCal'] as num?)?.toInt() ?? 0;
      }
    });
    return total;
  }

  int get netKcal => totalIntake - totalBurned;

  double get progressValue {
    // Assuming a 2000 goal for simplicity
    double ratio = totalBurned / totalIntake;
    if (ratio > 1.0) return 1.0;
    return ratio;
  }

  int get totalProtein {
    int total = 0;
    _foodData.forEach((key, value) {
      if (value is Map) total += (value['inProt'] as num?)?.toInt() ?? 0;
    });
    return total;
  }

  int get totalCarbs {
    int total = 0;
    _foodData.forEach((key, value) {
      if (value is Map) total += (value['inCarb'] as num?)?.toInt() ?? 0;
    });
    return total;
  }

  int get totalFat {
    int total = 0;
    _foodData.forEach((key, value) {
      if (value is Map) total += (value['inFat'] as num?)?.toInt() ?? 0;
    });
    return total;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFFF6F9F9),
        body: Center(child: CircularProgressIndicator(color: Color(0xFF0B5D5D))),
      );
    }
    return Scaffold(
      backgroundColor: const Color(0xFFF6F9F9),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _buildHeader()),
            SliverToBoxAdapter(child: _buildEnergyBalanceCard()),
            SliverToBoxAdapter(child: _buildNutritionSection()),
            SliverToBoxAdapter(child: _buildExerciseSection()),
            SliverToBoxAdapter(child: _buildVitalityStreakCard()),
            SliverToBoxAdapter(child: SizedBox(height: 100.h)), // Space for bottom nav
          ],
        ),
      ),
      extendBody: true,
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.0.w, vertical: 16.0.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const BackButton(),
          Text(
            DateFormat('MMMM d, yyyy').format(widget.date),
            style: GoogleFonts.manrope(
              fontSize: 26.sp,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF0B5D5D),
            ),
          ),
          CircleAvatar(
            backgroundColor: Colors.transparent,
            backgroundImage: AssetImage(ConstantValues.logo),
            radius: 20,
          ),
        ],
      ),
    );
  }

  Widget _buildEnergyBalanceCard() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 24.0.w, vertical: 8.0.h),
      padding: EdgeInsets.all(24.0.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'ENERGY BALANCE',
            style: GoogleFonts.inter(
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.5,
              color: const Color(0xFF4A4A4A),
            ),
          ),
          SizedBox(height: 12.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '$netKcal',
                style: GoogleFonts.manrope(
                  fontSize: 48.sp,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF1A1A1A),
                ),
              ),
              SizedBox(width: 8.w),
              Text(
                'net kcal',
                style: GoogleFonts.inter(
                  fontSize: 16.sp,
                  color: const Color(0xFF6B6B6B),
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Text(
            'Keep tracking your food and exercise!',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 13.sp,
              color: const Color(0xFF6B6B6B),
              height: 1.5.h,
            ),
          ),
          SizedBox(height: 24.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Intake',
                    style: GoogleFonts.inter(fontSize: 12.sp, color: const Color(0xFF6B6B6B)),
                  ),
                  Text(
                    '$totalIntake',
                    style: GoogleFonts.manrope(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF0B5D5D),
                    ),
                  ),
                ],
              ),
              Container(
                height: 30.h,
                width: 1.w,
                color: Colors.grey.withOpacity(0.3),
                margin: EdgeInsets.symmetric(horizontal: 24.w),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Burned',
                    style: GoogleFonts.inter(fontSize: 12.sp, color: const Color(0xFF6B6B6B)),
                  ),
                  Text(
                    '$totalBurned',
                    style: GoogleFonts.manrope(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF2E8B57),
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 32.h),
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 160.w,
                height: 160.h,
                child: CircularProgressIndicator(
                  value: progressValue.isFinite ? progressValue : 0,
                  strokeWidth: 12,
                  backgroundColor: const Color(0xFFF1F4F4),
                  valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF0B5D5D)),
                  strokeCap: StrokeCap.round,
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.bolt, color: Color(0xFF0B5D5D), size: 28.sp),
                  Text(
                    '${progressValue.isFinite ? (progressValue * 100).toInt() : 0}%',
                    style: GoogleFonts.manrope(
                      fontSize: 24.sp,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF1A1A1A),
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 16.h),
        ],
      ),
    );
  }

  Widget _buildNutritionSection() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.0.w, vertical: 16.0.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Nutrition',
                    style: GoogleFonts.manrope(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1A1A1A),
                    ),
                  ),
                  Text(
                    'Fueling your vitality',
                    style: GoogleFonts.inter(
                      fontSize: 12.sp,
                      color: const Color(0xFF6B6B6B),
                    ),
                  ),
                ],
              ),
              TextButton(
                onPressed: () {},
                child: Text(
                  'Log Meal',
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF0B5D5D),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Container(
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F4F4),
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Daily Macros',
                  style: GoogleFonts.manrope(
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1A1A1A),
                  ),
                ),
                SizedBox(height: 16.h),
                if (totalCarbs == 0 && totalProtein == 0 && totalFat == 0)
                  Text(
                    'No nutrition data available today. Log your meals to see your macros!',
                    style: GoogleFonts.inter(fontSize: 13.sp, color: const Color(0xFF6B6B6B)),
                  )
                else ...[
                  _buildMacroBar('Carbs', '${totalCarbs}g', '210g', (totalCarbs / 210).clamp(0.0, 1.0), const Color(0xFF0B5D5D)),
                  SizedBox(height: 12.h),
                  _buildMacroBar('Protein', '${totalProtein}g', '130g', (totalProtein / 130).clamp(0.0, 1.0), const Color(0xFF2E8B57)),
                  SizedBox(height: 12.h),
                  _buildMacroBar('Fat', '${totalFat}g', '65g', (totalFat / 65).clamp(0.0, 1.0), const Color(0xFF4A80A0)),
                ],
              ],
            ),
          ),
          SizedBox(height: 16.h),
          Row(
            children: [
              Expanded(child: _buildMealCard('Breakfast', '${(_foodData['Breakfast']?['inKCal'] as num?)?.toInt() ?? 0} kcal', Icons.local_cafe_outlined)),
              SizedBox(width: 16.w),
              Expanded(child: _buildMealCard('Lunch', '${(_foodData['Lunch']?['inKCal'] as num?)?.toInt() ?? 0} kcal', Icons.lunch_dining_outlined)),
            ],
          ),
          SizedBox(height: 16.h),
          Row(
            children: [
              Expanded(child: _buildMealCard('Dinner', '${(_foodData['Dinner']?['inKCal'] as num?)?.toInt() ?? 0} kcal', Icons.restaurant_outlined)),
              SizedBox(width: 16.w),
              Expanded(child: _buildMealCard('Snacks', '${(_foodData['Snacks']?['inKCal'] as num?)?.toInt() ?? 0} kcal', Icons.icecream_outlined)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMacroBar(String name, String current, String total, double progress, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(name, style: GoogleFonts.inter(fontSize: 12.sp, color: const Color(0xFF4A4A4A))),
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: current,
                    style: GoogleFonts.inter(
                        fontSize: 12.sp, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A1A)),
                  ),
                  TextSpan(
                    text: ' / $total',
                    style: GoogleFonts.inter(fontSize: 12.sp, color: const Color(0xFF6B6B6B)),
                  ),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: 6.h),
        ClipRRect(
          borderRadius: BorderRadius.circular(4.r),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 6,
            backgroundColor: color.withOpacity(0.2),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }

  Widget _buildMealCard(String title, String subtitle, IconData icon) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xFF0B5D5D), size: 24.sp),
          SizedBox(height: 16.h),
          Text(
            title,
            style: GoogleFonts.manrope(
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1A1A1A),
            ),
          ),
          Text(
            subtitle,
            style: GoogleFonts.inter(
              fontSize: 12.sp,
              color: const Color(0xFF6B6B6B),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExerciseSection() {
    List activities = _exerciseData['activities'] ?? [];

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.0.w, vertical: 16.0.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Exercise',
                    style: GoogleFonts.manrope(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1A1A1A),
                    ),
                  ),
                  Text(
                    'Today\'s movement',
                    style: GoogleFonts.inter(
                      fontSize: 12.sp,
                      color: const Color(0xFF6B6B6B),
                    ),
                  ),
                ],
              ),
              TextButton(
                onPressed: () {},
                child: Text(
                  'Track Activity',
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF0B5D5D),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          if (activities.isEmpty)
            Text(
              'No activities tracked today.',
              style: GoogleFonts.inter(color: const Color(0xFF6B6B6B)),
            ),
          ...activities.map((activity) {
            final name = activity['name'] ?? 'Activity';
            final calories = (activity['calories'] as num?)?.toString() ?? '0';
            final intensity = (activity['intensity'] as num?)?.toDouble() ?? 0.5;
            // mock duration/stats based on data we have if duration is missing
            final stat1 = activity['duration']?.toString() ?? '${(30 * intensity * 2).toInt()} min';

            return Padding(
              padding: EdgeInsets.only(bottom: 12.0.h),
              child: _buildActivityCard(
                name,
                stat1,
                'Intensity ${(intensity * 10).toInt()}/10',
                calories,
                Icons.fitness_center,
                const Color(0xFF9DF3C4),
                Icons.local_fire_department_outlined,
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildActivityCard(
      String title, String stat1, String stat2, String calories, IconData icon, Color color, IconData stat2Icon) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F4F4),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(icon, color: const Color(0xFF0B5D5D)),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.manrope(
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1A1A1A),
                  ),
                ),
                SizedBox(height: 4.h),
                Row(
                  children: [
                    Icon(Icons.schedule, size: 12.sp, color: const Color(0xFF6B6B6B)),
                    SizedBox(width: 4.w),
                    Text(stat1, style: GoogleFonts.inter(fontSize: 11.sp, color: const Color(0xFF6B6B6B))),
                    SizedBox(width: 12.w),
                    Icon(stat2Icon, size: 12.sp, color: const Color(0xFF6B6B6B)),
                    SizedBox(width: 4.w),
                    Text(stat2, style: GoogleFonts.inter(fontSize: 11.sp, color: const Color(0xFF6B6B6B))),
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                calories,
                style: GoogleFonts.manrope(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF0B5D5D),
                ),
              ),
              Text(
                'kcal',
                style: GoogleFonts.inter(
                  fontSize: 11.sp,
                  color: const Color(0xFF6B6B6B),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVitalityStreakCard() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 24.0.w, vertical: 16.0.h),
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: const Color(0xFF0A5C5C),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -20,
            bottom: -20,
            child: Icon(
              Icons.stop_circle_outlined,
              size: 140.sp,
              color: Colors.white.withOpacity(0.1),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Vitality Streak',
                style: GoogleFonts.manrope(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                'Got hit your calorie target for 5 days\nstraight!',
                style: GoogleFonts.inter(
                  fontSize: 13.sp,
                  color: Colors.white.withOpacity(0.8),
                  height: 1.4.h,
                ),
              ),
              SizedBox(height: 20.h),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Text(
                  'View Achievements',
                  style: GoogleFonts.inter(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

}
