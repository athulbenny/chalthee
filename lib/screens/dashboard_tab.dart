import 'package:chalthee/constants/CommonUI.dart';
import 'package:chalthee/constants/constant_values.dart';
import 'package:chalthee/screens/system_status_screen.dart';
import 'package:chalthee/storage/session_router.dart';
import 'package:chalthee/storage/weight_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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

  Future<void> loadPrefs() async{
    userHeight = await SessionManager.getLocalPreferencesHeight();
    goalWeight = await SessionManager.getLocalPreferencesWeight();
    setState(() {

    });
  }

  @override
  Widget build(BuildContext context) {
    loadPrefs();
    Widget header = Container(
      padding: const EdgeInsets.only(left: 24, right: 24, top: 48, bottom: 16),
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
            icon: Icon(Icons.settings, color: CommonUI().primary),
            onPressed: () => widget.onSwitchTab(3), // Navigate to settings/profile
          ),
        ],
      ),
    );

    Widget welcomeCTA = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16),
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
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: CommonUI().onSurfaceVariant,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Focus on your\nprogress.',
                style: GoogleFonts.manrope(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  color: CommonUI().onSurface,
                  height: 1.1,
                ),
              ),
              InkWell(
                onTap: () {
                  widget.onSwitchTab(1);
                  // Navigator.push(context, MaterialPageRoute(builder: (_){
                  //   return SystemStatusScreen();//AddWeightScreen(weightStorage: weightStorage, userName: userName, onSwitchTab: onSwitchTab);
                  // }));
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [CommonUI().primary, CommonUI().primaryContainer],
                    ),
                    borderRadius: BorderRadius.circular(9999),
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
                      const Icon(Icons.add, color: Colors.white, size: 20),
                      const SizedBox(width: 8),
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
      if (currentWeight != null && userHeight > 0) {
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

    Widget bentoGrid = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: LayoutBuilder(
        builder: (context, constraints) {
          findWeightList();
          return Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: CommonUI().cardDecorator,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: CommonUI().secondaryContainer,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'CURRENT STATUS',
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.5,
                          color: CommonUI().onSecondaryContainer,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          currentWeight != null
                              ? currentWeight.toStringAsFixed(1)
                              : '',
                          style: GoogleFonts.manrope(
                            fontSize: 64,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -2,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          currentWeight != null ?
                          'kg' : '',
                          style: GoogleFonts.inter(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: CommonUI().onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Keep logging to see your progress trends.',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: CommonUI().onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      height: 80,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 2),
                              height: goalWeight,
                              decoration: BoxDecoration(
                                color: CommonUI().primary,
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(8),
                                ),
                              ),
                              child: Center(
                                child: goalWeight != null && goalWeight != 0.0 ?
                                Text(
                                  weightList.isEmpty? 'Target weight : $goalWeight' : '$goalWeight',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                  ),
                                ): TextButton(onPressed: ()=> widget.onSwitchTab(3), child: Text('Setup your profile', style: GoogleFonts.inter(fontSize: 13,color: Colors.white))),
                              ),
                            ),
                          ),
                          for (var i in weightList)
                            Expanded(
                              child: Container(
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 2,
                                ),
                                height: i.toDouble(),
                                decoration: BoxDecoration(
                                  color: i > goalWeight
                                      ? CommonUI().error
                                      : CommonUI().onSecondaryContainer,
                                  borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(8),
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    '$i',
                                    style: TextStyle(
                                      color: CommonUI().onError,
                                      fontSize: 16,
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
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: CommonUI().surfaceContainerLow,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Column(
                        children: [
                          Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: CommonUI().secondaryFixedDim,
                                width: 4,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                bmi != null ? bmi.toStringAsFixed(1) : '',
                                style: GoogleFonts.manrope(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color: CommonUI().secondary,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            bmiLabel,
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: CommonUI().onSurface,
                            ),
                          ),
                          Text(
                            userHeight != null && userHeight != 0.0
                                ? 'height: ${userHeight}cm'
                                : '',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: CommonUI().onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 1,
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: CommonUI().cardDecorator,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            backgroundColor: CommonUI().surfaceContainerHigh,
                            child: Icon(
                              Icons.calendar_today,
                              color: CommonUI().primary,
                              size: 18,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'LAST ENTRY',
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.5,
                              color: CommonUI().onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            currentWeight != null
                                ? '${currentWeight.toStringAsFixed(3)} kg'
                                : 'No data available',
                            style: GoogleFonts.manrope(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            lastEntryDate != null
                                ? '${lastEntryDate.day}-${lastEntryDate.month}-${lastEntryDate.year}'
                                : '',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: CommonUI().onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: CommonUI().surfaceContainerLow,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'CONSISTENCY',
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.5,
                        color: CommonUI().onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(9999),
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
                        const SizedBox(width: 16),
                        Text(
                          '$consistencyPercent%',
                          style: GoogleFonts.manrope(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: CommonUI().secondary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      consistencyPercent >= 80
                          ? 'Great job logging consistently!'
                          : 'Log daily to improve consistency.',
                      style: GoogleFonts.inter(
                        fontSize: 12,
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
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: CommonUI().surfaceContainerLowest,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: CommonUI().secondary,
                      ),
                    ),
                    const SizedBox(width: 16),
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
                            fontSize: 12,
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
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        );
      }
    } else {
      historyItems.add(const Text("No history available."));
    }

    Widget historySection = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Weekly History',
                style: GoogleFonts.manrope(
                  fontSize: 20,
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
          const SizedBox(height: 16),
          ...historyItems,
          const SizedBox(height: 100),
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
