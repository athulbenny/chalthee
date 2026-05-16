import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:chalthee/constants/CommonUI.dart';
import 'package:chalthee/constants/constant_values.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../main.dart';
import '../storage/session_router.dart';
import 'login.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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
    final result = await showModalBottomSheet<double>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Container(
          decoration: BoxDecoration(
            color: uiVariables.surfaceContainerHigh,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
          ),
          padding: EdgeInsets.all(24.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                (_goalWeight == 0.0) ? "Add Goal Weight" : "Edit Goal Weight",
                style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 20.sp),
              ),
              SizedBox(height: 16.h),
              TextField(
                controller: controller,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(suffixText: 'kg'),
              ),
              SizedBox(height: 24.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      "Cancel",
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w600,
                        color: uiVariables.error,
                        fontSize: 15.sp,
                      ),
                    ),
                  ),
                  SizedBox(width: 16.w),
                  InkWell(
                    onTap: () {
                      final val = double.tryParse(controller.text);
                      if (val != null) Navigator.pop(context, val);
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
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
        ),
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
    final height = await showModalBottomSheet<double>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Container(
          decoration: BoxDecoration(
            color: uiVariables.surfaceContainerHigh,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
          ),
          padding: EdgeInsets.all(24.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Add Current Height",
                style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 20.sp),
              ),
              SizedBox(height: 16.h),
              TextField(
                controller: controller,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(suffixText: 'cm'),
              ),
              SizedBox(height: 24.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      "Cancel",
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w600,
                        color: uiVariables.error,
                        fontSize: 15.sp,
                      ),
                    ),
                  ),
                  SizedBox(width: 16.w),
                  InkWell(
                    onTap: () {
                      final val = double.tryParse(controller.text);
                      if (val != null) Navigator.pop(context, val);
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
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
        ),
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
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            // Reset text scaling so the internal dialog constraints don't break
            textScaler: const TextScaler.linear(1.0),
          ),
          child: child!,
        );
      },
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
          padding: EdgeInsets.symmetric(horizontal: 24.0.w, vertical: 16.h),
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
                ],
              ),
              SizedBox(height: 32.h),
              Text(
                'Settings',
                style: GoogleFonts.manrope(
                  fontSize: 32.sp,
                  fontWeight: FontWeight.w800,
                  color: CommonUI().onSurface,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                'Manage your clinical profile and app\npreferences.',
                style: GoogleFonts.inter(
                  fontSize: 16.sp,
                  color: CommonUI().onSurfaceVariant,
                  height: 1.4.h,
                ),
              ),
              SizedBox(height: 32.h),
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
                    subtitle: '${_goalWeight > 0 ? _goalWeight : 'Add target weight in'} ${_isKg ? 'kg' : 'lbs'}',
                    trailing: IconButton(
                      icon: Icon(
                        Icons.edit,
                        size: 18.sp,
                        color: Colors.grey,
                      ),
                      onPressed: _editGoalWeight,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 24.h),
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
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          GestureDetector(
                            // onTap: () => _updateUnits(true),
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 16.w,
                                vertical: 6.h,
                              ),
                              decoration: BoxDecoration(
                                color: _isKg
                                    ? CommonUI().primary
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(20.r),
                              ),
                              child: Text(
                                'kg',
                                style: TextStyle(
                                  color: _isKg ? Colors.white : Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12.sp,
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
                        : 'Lock a suitable time',
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
                    subtitle: '${_currentHeight > 0 ? _currentHeight : 'Add height in '}cm',
                    trailing: IconButton(
                      icon: Icon(
                        Icons.edit,
                        size: 18.sp,
                        color: Colors.grey,
                      ),
                      onPressed: _editHeight,
                    ),
                  ),
                ],
              ),

              SizedBox(height: 24.h),

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
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 4.h,
                    ),
                    leading: Container(
                      padding: EdgeInsets.all(8.w),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.exit_to_app, color: Colors.red),
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

              SizedBox(height: 32.h),

              // DANGER ZONE
              Container(
                padding: EdgeInsets.all(24.w),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.05),
                  border: Border.all(color: Colors.red.withOpacity(0.1)),
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: Column(
                  children: [
                    Text(
                      'Danger Zone',
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                        fontSize: 16.sp,
                      ),
                    ),
                    SizedBox(height: 12.h),
                    Text(
                      'Deleting your account will permanently erase all tracking history and health data.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 13.sp,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 20.h),
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.red),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.r),
                        ),
                        padding: EdgeInsets.symmetric(
                          horizontal: 32.w,
                          vertical: 12.h,
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

              SizedBox(height: 80.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.only(left: 8.w, bottom: 8.h),
      child: Text(
        title,
        style: GoogleFonts.inter(
          fontSize: 12.sp,
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
        borderRadius: BorderRadius.circular(16.r),
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
      contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
      leading: Container(
        padding: EdgeInsets.all(8.w),
        decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
        child: Icon(iconData, color: iconColor),
      ),
      title: Text(
        title,
        style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 15.sp),
      ),
      subtitle: Text(
        subtitle,
        style: GoogleFonts.inter(color: Colors.grey[600], fontSize: 13.sp),
      ),
      trailing: trailing ?? Text(''),
      onTap: trailing != null && trailing is Switch ? null : () {},
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1.h,
      indent: 64,
      thickness: 0.5,
      color: Color(0xFFEEEEEE),
    );
  }
}
