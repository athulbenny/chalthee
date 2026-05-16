import 'package:chalthee/storage/weight_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../constants/CommonUI.dart';
import '../constants/constant_values.dart';
import '../helpers/WeightCalculator.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AddWeightScreen extends StatefulWidget {
  final WeightStorage weightStorage;
  final String userName;
  final Function(int) onSwitchTab;

  const AddWeightScreen({
    super.key,
    required this.weightStorage,
    required this.userName,
    required this.onSwitchTab,
  });

  @override
  State<AddWeightScreen> createState() => _AddWeightScreenState();
}

class _AddWeightScreenState extends State<AddWeightScreen> {
  double weight = 0;
  DateTime lastEntryDate = DateTime.now();
  bool isKg = true;
  DateTime selectedDate = DateTime.now();
  int selectedMood = 2;
  final TextEditingController notesController = TextEditingController();

  @override
  void dispose() {
    notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sortedKeys = widget.weightStorage.weights.keys.toList()
      ..sort((a, b) => b.compareTo(a));
    lastEntryDate = sortedKeys.first;
    weight = widget.weightStorage.weights[lastEntryDate]!;
    return Scaffold(
      backgroundColor: const Color(0xFFEFF3F3),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16.w),
          child: Container(
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () => widget.onSwitchTab(3),
                          child: CircleAvatar(
                            backgroundColor: CommonUI().surfaceContainerHighest,
                            child: Text(
                              widget.userName.isNotEmpty
                                  ? widget.userName[0].toUpperCase()
                                  : 'U',
                              style: GoogleFonts.inter(
                                color: CommonUI().primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
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
                      icon: Icon(Icons.close, color: CommonUI().primary),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                Center(
                  child: Text(
                    "CURRENT WEIGHT",
                    style: GoogleFonts.manrope(
                      fontSize: 32.sp,
                      fontWeight: FontWeight.w800,
                      color: CommonUI().onSurface,
                      height: 1.1.h,
                    ),
                  ),
                ),
                SizedBox(height: 20.h),
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        weight.toStringAsFixed(3),
                        style: TextStyle(
                          fontSize: 48.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                      SizedBox(width: 10.w),
                      Column(
                        children: [
                          IconButton(
                            icon: Icon(Icons.keyboard_arrow_up),
                            onPressed: () {
                              setState(() {
                                weight += 0.05;
                              });
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.keyboard_arrow_down),
                            onPressed: () {
                              setState(() {
                                if (weight > 0) weight -= 0.05;
                              });
                            },
                          ),
                        ],
                      ),
                      SizedBox(width: 5.w),
                      Text(
                        isKg ? "kg" : "lbs",
                        style: TextStyle(
                          fontSize: 20.sp,
                          color: Colors.teal,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20.h),
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _unitButton("kg", isKg),
                      SizedBox(width: 10.w),
                      _unitButton("lbs", !isKg),
                    ],
                  ),
                ),
                SizedBox(height: 20.h),
                Text(
                  "MEASUREMENT DATE",
                  style: GoogleFonts.inter(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 2.0,
                    color: Colors.grey[700],
                  ),
                ),
                SizedBox(height: 10.h),
                GestureDetector(
                  onTap: _pickDate,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    height: 60.h,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F7F7),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.calendar_today,
                              color: Colors.teal,
                            ),
                            SizedBox(width: 10.w),
                            Text(
                              "${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}",
                            ),
                          ],
                        ),
                        Icon(Icons.calendar_today),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 20.h),
                Text("HOW DO YOU FEEL?"),
                SizedBox(height: 10.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(5, (index) {
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedMood = index;
                        });
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: EdgeInsets.all(12.w),
                        decoration: BoxDecoration(
                          color: selectedMood == index
                              ? Colors.teal
                              : Colors.grey[200],
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Icon(
                          _getMoodIcon(index),
                          color: selectedMood == index
                              ? Colors.white
                              : Colors.black,
                        ),
                      ),
                    );
                  }),
                ),
                SizedBox(height: 20.h),
                Text("NOTES (OPTIONAL)"),
                SizedBox(height: 10.h),
                Container(
                  padding: EdgeInsets.all(12.w),
                  height: 100.h,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F7F7),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: TextField(
                    controller: notesController,
                    maxLines: null,
                    decoration: const InputDecoration.collapsed(
                      hintText:
                          "Add details about your morning routine, water intake, etc...",
                    ),
                  ),
                ),
                SizedBox(height: 30.h),
                SizedBox(
                  width: double.infinity,
                  height: 55.h,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.r),
                      ),
                    ),
                    onPressed: _saveEntry,
                    child: Text(
                      "Save Entry",
                      style: TextStyle(
                        fontSize: 18.sp,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _unitButton(String label, bool selected) {
    return GestureDetector(
      onTap: () {
        setState(() {
          isKg = label == "kg";
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: selected ? Colors.tealAccent : Colors.grey[300],
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Text(label),
      ),
    );
  }

  IconData _getMoodIcon(int index) {
    switch (index) {
      case 0:
        return Icons.sentiment_very_satisfied;
      case 1:
        return Icons.sentiment_satisfied;
      case 2:
        return Icons.sentiment_neutral;
      case 3:
        return Icons.sentiment_dissatisfied;
      case 4:
        return Icons.sentiment_very_dissatisfied;
      default:
        return Icons.sentiment_neutral;
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  void _saveEntry() {
    String formattedDate =
        "${selectedDate.year}-"
        "${selectedDate.month.toString().padLeft(2, '0')}-"
        "${selectedDate.day.toString().padLeft(2, '0')}";
    final key = WeightCalculatorHelper.normalizeDate(
      DateTime.parse(formattedDate),
    );
    debugPrint(
      "Saved: date: $key,  ${weight.toStringAsFixed(3)} ${isKg ? 'kg' : 'lbs'} | Mood: $selectedMood | Notes: ${notesController.text}",
    );
    widget.weightStorage.saveWeight(
      key,
      double.parse(weight.toStringAsFixed(3)),
    );
  }
}
