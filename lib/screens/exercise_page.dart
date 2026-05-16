import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/CommonUI.dart';

import '../storage/exercise_storage.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AddExercisePage extends StatefulWidget {
  final VoidCallback onBack;
  final ExerciseStorage exerciseStorage;

  const AddExercisePage({super.key, required this.onBack, required this.exerciseStorage});

  @override
  State<AddExercisePage> createState() => _AddExercisePageState();
}

class ActivityOption {
  final String name;
  final IconData icon;

  ActivityOption(this.name, this.icon);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is ActivityOption &&
              runtimeType == other.runtimeType &&
              name == other.name;

  @override
  int get hashCode => name.hashCode;
}

class _AddExercisePageState extends State<AddExercisePage> {
  List<ActivityOption> activities = [
    ActivityOption('Running', Icons.directions_run),
    ActivityOption('Swimming', Icons.pool),
    ActivityOption('Cycling', Icons.directions_bike),
    ActivityOption('Weights', Icons.fitness_center),
    ActivityOption('Skipping', Icons.sports_gymnastics),
    ActivityOption('Push up', Icons.arrow_downward),
    ActivityOption('Pull up', Icons.arrow_upward),
    ActivityOption('Tread mill', Icons.directions_run_outlined),
  ];
  late ActivityOption selectedActivityOption = activities.first;
  double intensity = 0.5; // 0.0 to 1.0
  TextEditingController notesController = TextEditingController();
  TextEditingController durationController = TextEditingController(text: '30');
  String selectedDurationUnit = 'minutes';
  final List<String> durationUnits = ['minutes', 'count', 'sets', 'hours'];

  int get calculatedCalories {
    int duration = int.tryParse(durationController.text) ?? 0;
    return (duration * (intensity * 10 + 2)).toInt();
  }

  @override
  Widget build(BuildContext context) {
    final ui = CommonUI();

    return Scaffold(
      backgroundColor:  Colors.transparent,
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Carousel Header
            Container(
              height: 180.h,
              decoration: BoxDecoration(
                color: ui.primary,
                borderRadius: BorderRadius.circular(24.r),
              ),
              child: Stack(
                children: [
                  // Placeholder for the actual image.
                  // For now, using a stylized color block with opacity
                  Positioned.fill(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(24.r),
                      child: Container(
                        color: ui.primaryContainer,
                        child: Row(
                          children: [
                            Expanded(child: Container()),
                            Expanded(
                              flex: 2,
                              child: Container(
                                margin: EdgeInsets.all(16.w),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(16.r),
                                ),
                                child: Center(
                                  child: Icon(Icons.fitness_center, size: 64.sp, color: Colors.white.withOpacity(0.5)),
                                ),
                              ),
                            ),
                            Expanded(child: Container()),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 24.h,
                    left: 24.w,
                    child: Text(
                      'Log your progress',
                      style: GoogleFonts.inter(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Positioned(
                    right: 24.w,
                    top: 0.h,
                    bottom: 0.h,
                    child: Center(
                      child: Icon(Icons.chevron_right, color: Colors.white54, size: 32.sp),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 24.h),

            Text(
              'Select Activity Type',
              style: GoogleFonts.inter(
                fontSize: 16.sp,
                fontWeight: FontWeight.w700,
                color: ui.onSurface,
              ),
            ),

            SizedBox(height: 16.h),

            // Activity Dropdown
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<ActivityOption>(
                  value: selectedActivityOption,
                  isExpanded: true,
                  icon: Icon(Icons.arrow_drop_down, color: ui.onSurfaceVariant),
                  items: [
                    ...activities.map((ActivityOption option) {
                      return DropdownMenuItem<ActivityOption>(
                        value: option,
                        child: Row(
                          children: [
                            Icon(option.icon, color: ui.primary),
                            SizedBox(width: 12.w),
                            Text(
                              option.name,
                              style: GoogleFonts.inter(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w600,
                                color: ui.onSurface,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                    DropdownMenuItem<ActivityOption>(
                      value: ActivityOption('Add Custom...', Icons.add),
                      child: Row(
                        children: [
                          Icon(Icons.add_circle_outline, color: ui.primary),
                          SizedBox(width: 12.w),
                          Text(
                            'Add Custom...',
                            style: GoogleFonts.inter(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                              color: ui.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  onChanged: (ActivityOption? newValue) {
                    if (newValue?.name == 'Add Custom...') {
                      _showAddCustomActivityDialog();
                    } else if (newValue != null) {
                      setState(() {
                        selectedActivityOption = newValue;
                      });
                    }
                  },
                ),
              ),
            ),

            SizedBox(height: 24.h),

            // Session Duration
            Container(
              padding: EdgeInsets.all(24.w),
              decoration: BoxDecoration(
                color: ui.surfaceContainerLow,
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'SESSION DURATION',
                    style: GoogleFonts.inter(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                      color: ui.onSurfaceVariant,
                    ),
                  ),
                  SizedBox(height: 16.h),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      SizedBox(
                        width: 80.w,
                        child: TextField(
                          controller: durationController,
                          keyboardType: TextInputType.number,
                          style: GoogleFonts.inter(
                            fontSize: 40.sp,
                            fontWeight: FontWeight.w800,
                            color: ui.onSurfaceVariant,
                          ),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                          ),
                          onChanged: (val) {
                            setState(() {}); // trigger rebuild to recalculate calories
                          },
                        ),
                      ),
                      SizedBox(width: 12.w),
                      DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: selectedDurationUnit,
                          icon: Icon(Icons.keyboard_arrow_down, color: ui.onSurfaceVariant),
                          style: GoogleFonts.inter(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w600,
                            color: ui.onSurface,
                          ),
                          items: durationUnits.map((String unit) {
                            return DropdownMenuItem<String>(
                              value: unit,
                              child: Text(unit),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            if (newValue != null) {
                              setState(() {
                                selectedDurationUnit = newValue;
                              });
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            SizedBox(height: 16.h),

            // Intensity Level
            Container(
              padding: EdgeInsets.all(24.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'INTENSITY LEVEL',
                    style: GoogleFonts.inter(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                      color: ui.onSurfaceVariant,
                    ),
                  ),
                  SizedBox(height: 16.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Low', style: GoogleFonts.inter(color: ui.secondary, fontWeight: FontWeight.w600)),
                      Text('Moderate', style: GoogleFonts.inter(color: ui.primary, fontWeight: FontWeight.w600)),
                      Text('High', style: GoogleFonts.inter(color: ui.error, fontWeight: FontWeight.w600)),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  SliderTheme(
                    data: SliderThemeData(
                      trackHeight: 6,
                      activeTrackColor: ui.surfaceContainerHigh,
                      inactiveTrackColor: ui.surfaceContainerHigh,
                      thumbColor: ui.primary,
                      overlayColor: ui.primary.withOpacity(0.2),
                    ),
                    child: Slider(
                      value: intensity,
                      onChanged: (val) {
                        setState(() {
                          intensity = val;
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 16.h),

            // Calories Burned
            Container(
              padding: EdgeInsets.all(24.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'EST. CALORIES BURNED',
                    style: GoogleFonts.inter(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                      color: ui.onSurfaceVariant,
                    ),
                  ),
                  SizedBox(height: 16.h),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        padding: EdgeInsets.all(12.w),
                        decoration: BoxDecoration(
                          color: ui.primaryFixed,
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Icon(Icons.local_fire_department, color: ui.primary, size: 28.sp),
                      ),
                      SizedBox(width: 16.w),
                      Text(
                        '$calculatedCalories',
                        style: GoogleFonts.inter(
                          fontSize: 32.sp,
                          fontWeight: FontWeight.w800,
                          color: ui.onSurface,
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Padding(
                        padding: EdgeInsets.only(top: 8.0.h),
                        child: Text(
                          'kcal',
                          style: GoogleFonts.inter(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            color: ui.onSurface,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            SizedBox(height: 16.h),

            // Notes
            Container(
              padding: EdgeInsets.all(24.w),
              decoration: BoxDecoration(
                color: ui.surfaceContainerLow,
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'NOTES & PERFORMANCE',
                    style: GoogleFonts.inter(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                      color: ui.onSurfaceVariant,
                    ),
                  ),
                  SizedBox(height: 16.h),
                  Container(
                    height: 100.h,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    padding: EdgeInsets.all(16.w),
                    child: TextField(
                      controller: notesController,
                      maxLines: null,
                      decoration: InputDecoration.collapsed(
                        hintText: 'How did you feel today?',
                        hintStyle: GoogleFonts.inter(
                          color: ui.outlineVariant,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 32.h),

            // Save Button
            SizedBox(
              width: double.infinity,
              height: 60.h,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: ui.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.r),
                  ),
                  elevation: 0,
                ),
                onPressed: () async {
                  final now = DateTime.now();
                  final existingData = await widget.exerciseStorage.getExercise(now);
                  final Map<String, dynamic> newData = Map.from(existingData);

                  int totalBurned = (newData['totalBurned'] as num?)?.toInt() ?? 0;
                  totalBurned += calculatedCalories;
                  newData['totalBurned'] = totalBurned;

                  List activitiesList = newData['activities'] ?? [];
                  activitiesList.add({
                    'name': selectedActivityOption.name,
                    'intensity': intensity,
                    'duration': '${durationController.text} $selectedDurationUnit',
                    'calories': calculatedCalories,
                    'notes': notesController.text,
                    'time': now.toIso8601String(),
                  });
                  newData['activities'] = activitiesList;

                  await widget.exerciseStorage.saveExercise(now, newData);

                  widget.onBack();
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check_circle_outline),
                    SizedBox(width: 8.w),
                    Text(
                      'Save Activity',
                      style: GoogleFonts.inter(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 100.h), // padding for bottom nav
          ],
        ),
      ),
    );
  }

  void _showAddCustomActivityDialog() {
    TextEditingController controller = TextEditingController();
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            backgroundColor: CommonUI().surface,
            title: Text(
              'Add Custom Activity',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.bold,
                color: CommonUI().onSurface,
              ),
            ),
            content: TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: 'Activity Name',
                hintStyle: GoogleFonts.inter(color: CommonUI().outlineVariant),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: CommonUI().primary),
                ),
              ),
              style: GoogleFonts.inter(color: CommonUI().onSurface),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Cancel',
                  style: GoogleFonts.inter(color: CommonUI().onSurfaceVariant),
                ),
              ),
              ElevatedButton(
                style: CommonUI().elevatedButtonStyle,
                onPressed: () {
                  if (controller.text.trim().isNotEmpty) {
                    setState(() {
                      final newOption = ActivityOption(controller.text.trim(), Icons.fitness_center);
                      activities.add(newOption);
                      selectedActivityOption = newOption;
                    });
                  }
                  Navigator.pop(context);
                },
                child: Text(
                  'Add',
                  style: GoogleFonts.inter(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          );
        }
    );
  }
}
