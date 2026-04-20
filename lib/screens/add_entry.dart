import 'package:chalthee/storage/weight_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../constants/CommonUI.dart';
import '../constants/constant_values.dart';
import '../helpers/WeightCalculator.dart';

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
          padding: const EdgeInsets.all(16),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
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
                        const SizedBox(width: 12),
                        Text(
                          ConstantValues.appName,
                          style: GoogleFonts.manrope(
                            fontSize: 20,
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
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      color: CommonUI().onSurface,
                      height: 1.1,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        weight.toStringAsFixed(3),
                        style: const TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.keyboard_arrow_up),
                            onPressed: () {
                              setState(() {
                                weight += 0.05;
                              });
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.keyboard_arrow_down),
                            onPressed: () {
                              setState(() {
                                if (weight > 0) weight -= 0.05;
                              });
                            },
                          ),
                        ],
                      ),
                      const SizedBox(width: 5),
                      Text(
                        isKg ? "kg" : "lbs",
                        style: const TextStyle(
                          fontSize: 20,
                          color: Colors.teal,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _unitButton("kg", isKg),
                      const SizedBox(width: 10),
                      _unitButton("lbs", !isKg),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  "MEASUREMENT DATE",
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 2.0,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: _pickDate,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    height: 60,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F7F7),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.calendar_today,
                              color: Colors.teal,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              "${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}",
                            ),
                          ],
                        ),
                        const Icon(Icons.calendar_today),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text("HOW DO YOU FEEL?"),
                const SizedBox(height: 10),
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
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: selectedMood == index
                              ? Colors.teal
                              : Colors.grey[200],
                          borderRadius: BorderRadius.circular(12),
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
                const SizedBox(height: 20),
                const Text("NOTES (OPTIONAL)"),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(12),
                  height: 100,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F7F7),
                    borderRadius: BorderRadius.circular(12),
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
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    onPressed: _saveEntry,
                    child: const Text(
                      "Save Entry",
                      style: TextStyle(
                        fontSize: 18,
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
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? Colors.tealAccent : Colors.grey[300],
          borderRadius: BorderRadius.circular(20),
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
