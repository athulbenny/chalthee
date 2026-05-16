import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/CommonUI.dart';

import '../storage/exercise_storage.dart';
import '../storage/food_storage.dart';

import 'package:intl/intl.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';


class FoodSummaryPage extends StatefulWidget {
  final VoidCallback onAddActivity;
  final Function() onOpenProfile;
  final ExerciseStorage exerciseStorage;
  final FoodStorage foodStorage;

  const FoodSummaryPage({
    super.key,
    required this.onAddActivity,
    required this.onOpenProfile,
    required this.exerciseStorage,
    required this.foodStorage,
  });

  @override
  State<FoodSummaryPage> createState() => _FoodSummaryPageState();
}

class _FoodSummaryPageState extends State<FoodSummaryPage> {
  bool _isLoading = true;
  Map<String, dynamic> _exerciseData = {};
  Map<String, dynamic> _foodData = {};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final now = DateTime.now();
    final exerciseData = await widget.exerciseStorage.getExercise(now);
    final foodData = await widget.foodStorage.getFood(now);

    if (mounted) {
      setState(() {
        _exerciseData = exerciseData;
        _foodData = foodData;
        _isLoading = false;
      });
    }
  }

  int get totalBurned => (_exerciseData['totalBurned'] as num?)?.toInt() ?? 0;

  int get eatenCalories {
    int total = 0;
    _foodData.forEach((key, value) {
      if (value is Map) {
        total += (value['inKCal'] as num?)?.toInt() ?? 0;
      }
    });
    return total;
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
    final ui = CommonUI();

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: ui.primary))
          : SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Daily Calorie Balance Card
            Container(
              padding: EdgeInsets.all(24.w),
              decoration: ui.cardDecorator.copyWith(
                color: ui.surfaceContainerLow,
                borderRadius: BorderRadius.circular(16.r),
                boxShadow: [], // Remove heavy shadow for internal cards to match design
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'DAILY CALORIE BALANCE',
                    style: GoogleFonts.inter(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: ui.onSurfaceVariant,
                      letterSpacing: 1.2,
                    ),
                  ),
                  SizedBox(height: 12.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            '${2600 - eatenCalories + totalBurned}',
                            style: GoogleFonts.inter(
                              fontSize: 40.sp,
                              fontWeight: FontWeight.w800,
                              color: ui.primary,
                            ),
                          ),
                          SizedBox(width: 8.w),
                          Text(
                            'kcal left',
                            style: GoogleFonts.inter(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w500,
                              color: ui.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                      Icon(
                        Icons.eco_outlined, // Leaf icon
                        size: 48.sp,
                        color: ui.outlineVariant.withOpacity(0.5),
                      ),
                    ],
                  ),
                  SizedBox(height: 20.h),
                  // Progress Bar
                  LayoutBuilder(
                      builder: (context, constraints) {
                        double progress = (eatenCalories / 2600.0).clamp(0.0, 1.0);
                        return Stack(
                          children: [
                            Container(
                              height: 8.h,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: ui.surfaceContainerHigh,
                                borderRadius: BorderRadius.circular(4.r),
                              ),
                            ),
                            Container(
                              height: 8.h,
                              width: constraints.maxWidth * progress,
                              decoration: BoxDecoration(
                                color: ui.primary,
                                borderRadius: BorderRadius.circular(4.r),
                              ),
                            ),
                          ],
                        );
                      }
                  ),
                  SizedBox(height: 12.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '$eatenCalories EATEN',
                        style: GoogleFonts.inter(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                          color: ui.onSurfaceVariant,
                        ),
                      ),
                      Text(
                        '2600 GOAL',
                        style: GoogleFonts.inter(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                          color: ui.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            SizedBox(height: 16.h),

            // Activity Card
            GestureDetector(
              onTap: () {
                widget.onAddActivity();
                // We could wait for the user to return and then refresh
                _loadData(); // Re-load when tapping (rough refresh trigger)
              },
              child: Container(
                padding: EdgeInsets.all(24.w),
                decoration: BoxDecoration(
                  color: ui.secondaryContainer,
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.fitness_center, color: ui.onSecondaryContainer),
                    SizedBox(height: 12.h),
                    Text(
                      'Activity',
                      style: GoogleFonts.inter(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w600,
                        color: ui.onSecondaryContainer,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          '$totalBurned',
                          style: GoogleFonts.inter(
                            fontSize: 24.sp,
                            fontWeight: FontWeight.w700,
                            color: ui.onSecondaryContainer,
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          'kcal burned',
                          style: GoogleFonts.inter(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w500,
                            color: ui.onSecondaryContainer.withOpacity(0.8),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 32.h),

            // Meal Logging Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Meal Logging',
                  style: GoogleFonts.inter(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                    color: ui.onSurface,
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    color: ui.primaryFixed,
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  child: Text(
                    DateFormat('MMMM d, yyyy').format(DateTime.now()),
                    style: GoogleFonts.inter(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w700,
                      color: ui.primary,
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: 16.h),

            // Meals List
            _buildMealCard(ui, 'Breakfast', '400-600', '${(_foodData['Breakfast']?['inKCal'] as num?)?.toInt() ?? 0}', Icons.breakfast_dining, ui.primaryFixedDim, isEmpty: (_foodData['Breakfast']?['inKCal'] ?? 0) == 0),
            SizedBox(height: 12.h),
            _buildMealCard(ui, 'Lunch', '600-800', '${(_foodData['Lunch']?['inKCal'] as num?)?.toInt() ?? 0}', Icons.lunch_dining, ui.secondary, isEmpty: (_foodData['Lunch']?['inKCal'] ?? 0) == 0),
            SizedBox(height: 12.h),
            _buildMealCard(ui, 'Dinner', '600-800', '${(_foodData['Dinner']?['inKCal'] as num?)?.toInt() ?? 0}', Icons.restaurant, ui.surfaceContainerHigh, isEmpty: (_foodData['Dinner']?['inKCal'] ?? 0) == 0),
            SizedBox(height: 12.h),
            _buildMealCard(ui, 'Snacks', '200-300', '${(_foodData['Snacks']?['inKCal'] as num?)?.toInt() ?? 0}', Icons.coffee, ui.onSurface, isEmpty: (_foodData['Snacks']?['inKCal'] ?? 0) == 0),

            SizedBox(height: 24.h),

            // Macros Card
            Container(
              padding: EdgeInsets.symmetric(vertical: 24.h),
              decoration: ui.cardDecorator.copyWith(
                color: ui.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(16.r),
                boxShadow: [],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildMacro(ui, 'CARBS', '${totalCarbs}g', ui.primary, progress: totalCarbs / 300),
                  _buildMacro(ui, 'PROTEIN', '${totalProtein}g', ui.secondary, progress: totalProtein / 150),
                  _buildMacro(ui, 'FAT', '${totalFat}g', ui.primaryContainer, progress: totalFat / 100),
                ],
              ),
            ),

            SizedBox(height: 100.h), // padding for bottom nav
          ],
        ),
      ),
    );
  }

  Widget _buildBar(CommonUI ui, double height, {bool isPrimary = false, bool isSecondary = false}) {
    return Container(
      width: 45.w,
      height: height,
      decoration: BoxDecoration(
        color: isPrimary ? ui.primary : (isSecondary ? ui.outlineVariant.withOpacity(0.5) : ui.surfaceContainerHigh),
        borderRadius: BorderRadius.circular(2.r),
      ),
    );
  }

  Widget _buildMealCard(CommonUI ui, String name, String rec, String cal, IconData icon, Color iconBg, {bool isEmpty = false}) {
    return InkWell(
        onTap: () => _showLogFoodDialog(name),
        borderRadius: BorderRadius.circular(16.r),
        child: Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: ui.surfaceContainerLow,
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: Row(
            children: [
              Container(
                width: 50.w,
                height: 50.h,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(icon, color: Colors.white, size: 28.sp),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: GoogleFonts.inter(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: ui.onSurface,
                      ),
                    ),
                    Text(
                      'Recommended: $rec kcal',
                      style: GoogleFonts.inter(
                        fontSize: 12.sp,
                        color: ui.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    cal,
                    style: GoogleFonts.inter(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w700,
                      color: isEmpty ? ui.outlineVariant : ui.primary,
                    ),
                  ),
                  Text(
                    'KCAL',
                    style: GoogleFonts.inter(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w700,
                      color: ui.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              SizedBox(width: 16.w),
              Container(
                width: 40.w,
                height: 40.h,
                decoration: BoxDecoration(
                  color: isEmpty ? ui.primary : Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    if (!isEmpty)
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      )
                  ],
                ),
                child: Icon(
                  Icons.add,
                  color: isEmpty ? Colors.white : ui.primary,
                ),
              )
            ],
          ),
        ));
    }

  Widget _buildMacro(CommonUI ui, String name, String amount, Color color, {double progress = 0.5}) {
    return Column(
      children: [
        Text(
          name,
          style: GoogleFonts.inter(
            fontSize: 10.sp,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
            color: ui.onSurfaceVariant,
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          amount,
          style: GoogleFonts.inter(
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
            color: ui.primary,
          ),
        ),
        SizedBox(height: 8.h),
        Container(
          width: 60.w,
          height: 4.h,
          decoration: BoxDecoration(
            color: ui.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(2.r),
          ),
          child: Row(
            children: [
              Container(
                width: 60.w * progress.clamp(0.0, 1.0),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showLogFoodDialog(String mealName) {
    final ui = CommonUI();
    final kcalController = TextEditingController();
    final carbsController = TextEditingController();
    final proteinController = TextEditingController();
    final fatController = TextEditingController();

    // pre-fill if data exists
    final mealData = _foodData[mealName];
    if (mealData != null && mealData is Map) {
      if (mealData['inKCal'] != null && mealData['inKCal'] != 0) kcalController.text = '${mealData['inKCal']}';
      if (mealData['inCarb'] != null && mealData['inCarb'] != 0) carbsController.text = '${mealData['inCarb']}';
      if (mealData['inProt'] != null && mealData['inProt'] != 0) proteinController.text = '${mealData['inProt']}';
      if (mealData['inFat'] != null && mealData['inFat'] != 0) fatController.text = '${mealData['inFat']}';
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            decoration: BoxDecoration(
              color: ui.surface,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
            ),
            padding: EdgeInsets.all(24.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Log $mealName',
                  style: GoogleFonts.manrope(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.bold,
                    color: ui.onSurface,
                  ),
                ),
                SizedBox(height: 16.h),
                _buildFoodInput(ui, 'Calories (kcal)', kcalController),
                _buildFoodInput(ui, 'Carbs (g)', carbsController),
                _buildFoodInput(ui, 'Protein (g)', proteinController),
                _buildFoodInput(ui, 'Fat (g)', fatController),
                SizedBox(height: 24.h),
                SizedBox(
                  width: double.infinity,
                  height: 56.h,
                  child: InkWell(
                    onTap: () async{
                      final now = DateTime.now();
                      final existingData = await widget.foodStorage.getFood(now);
                      final Map<String, dynamic> newData = Map.from(existingData);

                      newData[mealName] = {
                        'inKCal': int.tryParse(kcalController.text) ?? 0,
                        'inCarb': int.tryParse(carbsController.text) ?? 0,
                        'inProt': int.tryParse(proteinController.text) ?? 0,
                        'inFat': int.tryParse(fatController.text) ?? 0,
                      };

                      await widget.foodStorage.saveFood(now, newData);
                      _loadData();
                      Navigator.pop(context);
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
                            'Save Meal',
                            style: GoogleFonts.inter(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
            ),
          ]),
        ));
      },
    );
  }

  Widget _buildFoodInput(CommonUI ui, String label, TextEditingController controller) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.0.h),
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.inter(color: ui.onSurfaceVariant),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: BorderSide(color: ui.primary, width: 2.w),
          ),
        ),
      ),
    );
  }
}
