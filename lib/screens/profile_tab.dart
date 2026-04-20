import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:chalthee/constants/CommonUI.dart';
import 'package:chalthee/constants/constant_values.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../main.dart';
import '../storage/session_router.dart';
import 'login.dart';

class ProfileTab extends StatefulWidget {
  final String userName;
  final String email;

  const ProfileTab({super.key, required this.userName, required this.email});

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  double _currentHeight = 0.0;
  bool _isKg = true; // true for kg, false for lbs
  double _goalWeight = 0.0;
  CommonUI uiVariables = CommonUI();
  String _alarmTime = "";
  TimeOfDay selectedTime = TimeOfDay.now();

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _currentHeight = prefs.getDouble('height') ?? 0.0;
      _isKg = prefs.getBool('isKg') ?? true;
      _goalWeight = prefs.getDouble('goalWeight') ?? 0.0;
      _alarmTime = prefs.getString('alarmTime') ?? "";
      if (_alarmTime.isNotEmpty) {
        selectedTime = TimeOfDay(
          hour: int.parse(_alarmTime.split(':').first),
          minute: int.parse(_alarmTime.split(':').last),
        );
      }
    });
  }

  Future<void> _updateAlarmTime(TimeOfDay? time) async {
    final prefs = await SharedPreferences.getInstance();
    String updatedAlarmTimeToCache = '';
    if (time != null) {
      updatedAlarmTimeToCache = '${time.hour}:${time.minute}';
    }
    await prefs.setString('alarmTime', updatedAlarmTimeToCache);
    setState(() => _alarmTime = updatedAlarmTimeToCache);
  }

  Future<void> _editGoalWeight() async {
    final controller = TextEditingController(text: _goalWeight.toString());
    final result = await showDialog<double>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: uiVariables.surfaceContainerHigh,
        title: Text(
          (_goalWeight == 0.0) ? "Add Goal Weight" : "Edit Goal Weight",
          style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 20),
        ),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(suffixText: 'kg'),
        ),
        actions: [
          Row(
            children: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  "Cancel",
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w600,
                    color: uiVariables.error,
                    fontSize: 15,
                  ),
                ),
              ),
              InkWell(
                onTap: () {
                  final val = double.tryParse(controller.text);
                  if (val != null) Navigator.pop(context, val);
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
                  child: Text(
                    'Save',
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );

    if (result != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble('goalWeight', result);
      setState(() => _goalWeight = result);
    }
  }

  Future<void> _editHeight() async {
    final controller = TextEditingController(text: _currentHeight.toString());
    final height = await showDialog<double>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: uiVariables.surfaceContainerHigh,
        title: Text(
          "Add Current Height",
          style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 20),
        ),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(suffixText: 'cm'),
        ),
        actions: [
          Row(
            children: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  "Cancel",
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w600,
                    color: uiVariables.error,
                    fontSize: 15,
                  ),
                ),
              ),
              InkWell(
                onTap: () {
                  final val = double.tryParse(controller.text);
                  if (val != null) Navigator.pop(context, val);
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
                  child: Text(
                    'Save',
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );

    if (height != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble('height', height);
      setState(() => _currentHeight = height);
    }
  }

  Future<void> _editAlarm(bool val) async {
    if (_alarmTime.isEmpty && val) {
      pickTime(context);
    } else {
      _updateAlarmTime(null);
      await AndroidAlarmManager.cancel(0);
    }
  }

  Future<void> pickTime(BuildContext context) async {
    final time = await showTimePicker(
      context: context,
      initialTime: selectedTime,
    );
    if (time != null) {
      setState(() => selectedTime = time);
      await scheduleDailyAlarm();
      _updateAlarmTime(selectedTime);
    }
  }

  Future<void> scheduleDailyAlarm() async {
    final now = DateTime.now();
    DateTime nextRun = DateTime(
      now.year,
      now.month,
      now.day,
      selectedTime.hour,
      selectedTime.minute,
    );
    if (nextRun.isBefore(now)) {
      nextRun = nextRun.add(const Duration(days: 1));
    }
    await AndroidAlarmManager.oneShotAt(
      nextRun,
      1,
      alarmCallback,
      exact: true,
      wakeup: true,
      rescheduleOnReboot: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                    onPressed: () {},
                  ),
                ],
              ),
              const SizedBox(height: 32),
              Text(
                'Settings',
                style: GoogleFonts.manrope(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  color: CommonUI().onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Manage your clinical profile and app\npreferences.',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  color: CommonUI().onSurfaceVariant,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 32),
              _buildSectionTitle('PROFILE'),
              _buildCardContainer(
                items: [
                  _buildListItem(
                    iconData: Icons.person,
                    iconColor: Colors.cyan,
                    iconBg: Colors.cyan.withOpacity(0.2),
                    title: 'Display Name',
                    subtitle: widget.userName.isNotEmpty ? widget.userName : '',
                  ),
                  _buildDivider(),
                  _buildListItem(
                    iconData: Icons.track_changes,
                    iconColor: Colors.green,
                    iconBg: Colors.green.withOpacity(0.2),
                    title: 'Goal Weight',
                    subtitle: '$_goalWeight ${_isKg ? 'kg' : 'lbs'}',
                    trailing: IconButton(
                      icon: const Icon(
                        Icons.edit,
                        size: 18,
                        color: Colors.grey,
                      ),
                      onPressed: _editGoalWeight,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildSectionTitle('PREFERENCES'),
              _buildCardContainer(
                items: [
                  _buildListItem(
                    iconData: Icons.straighten,
                    iconColor: Colors.grey[700]!,
                    iconBg: Colors.grey[300]!,
                    title: 'Measurement Units',
                    subtitle: 'Metric (kg)',
                    trailing: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          GestureDetector(
                            // onTap: () => _updateUnits(true),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: _isKg
                                    ? CommonUI().primary
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                'kg',
                                style: TextStyle(
                                  color: _isKg ? Colors.white : Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  _buildDivider(),
                  _buildListItem(
                    iconData: Icons.add_alarm,
                    iconColor: Colors.grey[700]!,
                    iconBg: Colors.grey[300]!,
                    title: 'Reminder Times',
                    subtitle: _alarmTime.isNotEmpty
                        ? "Daily at ${selectedTime.hour > 12 ? selectedTime.hour - 12 : selectedTime.hour}:${selectedTime.minute.toString().padLeft(2, '0')} ${selectedTime.hour > 12 ? 'PM' : 'AM'}"
                        : 'Pick up your time',
                    trailing: Switch(
                      value: _alarmTime.isNotEmpty,
                      onChanged: _editAlarm,
                      activeColor: Colors.green,
                    ),
                  ),
                  _buildDivider(),
                  _buildListItem(
                    iconData: Icons.person,
                    iconColor: Colors.grey[700]!,
                    iconBg: Colors.grey[300]!,
                    title: 'Current Height',
                    subtitle: '${_currentHeight}cm',
                    trailing: IconButton(
                      icon: const Icon(
                        Icons.edit,
                        size: 18,
                        color: Colors.grey,
                      ),
                      onPressed: _editHeight,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // ACCOUNT SECTION
              _buildSectionTitle('ACCOUNT'),
              _buildCardContainer(
                items: [
                  _buildListItem(
                    iconData: Icons.star,
                    iconColor: Colors.blue,
                    iconBg: Colors.blue.withOpacity(0.2),
                    title: 'Subscription',
                    subtitle: 'Chalthee Premium',
                  ),
                  _buildDivider(),
                  _buildListItem(
                    iconData: Icons.email,
                    iconColor: Colors.grey[700]!,
                    iconBg: Colors.grey[300]!,
                    title: 'Email Address',
                    subtitle: widget.email.isNotEmpty ? widget.email : '',
                  ),
                  _buildDivider(),
                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.exit_to_app, color: Colors.red),
                    ),
                    title: Text(
                      'Sign Out',
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                    onTap: () async {
                      await SessionManager.logout();
                      if (context.mounted) {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (_) => const LoginPage()),
                          (route) => false,
                        );
                      }
                    },
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // DANGER ZONE
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.05),
                  border: Border.all(color: Colors.red.withOpacity(0.1)),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Text(
                      'Danger Zone',
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Deleting your account will permanently erase all tracking history and health data.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 20),
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.red),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 12,
                        ),
                      ),
                      onPressed: () {},
                      child: Text(
                        'Delete Account',
                        style: GoogleFonts.inter(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 8),
      child: Text(
        title,
        style: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w800,
          letterSpacing: 2.0,
          color: Colors.grey[700],
        ),
      ),
    );
  }

  Widget _buildCardContainer({required List<Widget> items}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
        child: Icon(iconData, color: iconColor),
      ),
      title: Text(
        title,
        style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 15),
      ),
      subtitle: Text(
        subtitle,
        style: GoogleFonts.inter(color: Colors.grey[600], fontSize: 13),
      ),
      trailing: trailing ?? Text(''),
      onTap: trailing != null && trailing is Switch ? null : () {},
    );
  }

  Widget _buildDivider() {
    return const Divider(
      height: 1,
      indent: 64,
      thickness: 0.5,
      color: Color(0xFFEEEEEE),
    );
  }
}
