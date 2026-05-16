import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/CommonUI.dart';
import '../constants/constant_values.dart';
import '../storage/exercise_storage.dart';
import '../storage/food_storage.dart';
import 'exercise_page.dart';
import 'food_summary_page.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ActivityTab extends StatefulWidget {
  final Function() onOpenProfile;

  const ActivityTab({super.key, required this.onOpenProfile});

  @override
  State<ActivityTab> createState() => _ActivityTabState();
}

class _ActivityTabState extends State<ActivityTab> {
  final ExerciseStorage _exerciseStorage = ExerciseStorage();
  final FoodStorage _foodStorage = FoodStorage();

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          // Header with App Name and Settings
          Padding(
            padding: EdgeInsets.only(left: 24.w, right: 24.w, top: 48.h, bottom: 8.h),
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
                  onPressed: widget.onOpenProfile,
                ),
              ],
            ),
          ),

          // TabBar
          Container(
            margin: EdgeInsets.symmetric(horizontal: 24.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: CommonUI().surfaceContainerHigh,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: TabBar(
              indicator: BoxDecoration(
                color: CommonUI().primary,
                borderRadius: BorderRadius.circular(12.r),
              ),
              labelColor: Colors.white,
              unselectedLabelColor: CommonUI().onSurfaceVariant,
              labelStyle: GoogleFonts.inter(fontWeight: FontWeight.bold),
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent,
              tabs: [
                Tab(text: "Food & Summary"),
                Tab(text: "Track Exercise"),
              ],
            ),
          ),

          // TabBarView
          Expanded(
            child: TabBarView(
              children: [
                Builder(
                    builder: (context) {
                      return FoodSummaryPage(
                        key: const PageStorageKey('food_summary'),
                        onAddActivity: () {
                          DefaultTabController.of(context).animateTo(1);
                        },
                        onOpenProfile: widget.onOpenProfile,
                        exerciseStorage: _exerciseStorage,
                        foodStorage: _foodStorage,
                      );
                    }
                ),
                Builder(
                    builder: (context) {
                      return AddExercisePage(
                        onBack: () {
                          DefaultTabController.of(context).animateTo(0);
                        },
                        exerciseStorage: _exerciseStorage,
                      );
                    }
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
