import 'package:chalthee/constants/CommonUI.dart';
import 'package:chalthee/screens/CalenderPage.dart';
import 'package:chalthee/screens/system_status_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../constants/constant_values.dart';
import '../storage/session_router.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final CommonUI uiVariables = CommonUI();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    Widget header = Container(
      padding: EdgeInsets.only(left: 24.w, right: 24.w, top: 80.h, bottom: 20.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor: CommonUI().outlineVariant,
            backgroundImage: AssetImage(ConstantValues.logo),
            radius: 20,
          ),
          SizedBox(height: 24.h),
          Text(
            'Welcome to',
            style: GoogleFonts.inter(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: uiVariables.onSurfaceVariant,
            ),
          ),
          Text(
            'The Chalthee Verse',
            style: GoogleFonts.manrope(
              fontSize: 36.sp,
              fontWeight: FontWeight.w800,
              color: uiVariables.primary,
              letterSpacing: -1.0,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Sign in to continue your wellness journey.',
            style: GoogleFonts.inter(
              fontSize: 14.sp,
              color: uiVariables.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );

    Widget form = Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                hintText: 'Display Name',
                hintStyle: GoogleFonts.inter(color: uiVariables.outlineVariant),
                filled: true,
                fillColor: uiVariables.surfaceContainerLowest,
                prefixIcon: Icon(
                  Icons.person_outline,
                  color: uiVariables.primary,
                ),
                contentPadding: EdgeInsets.symmetric(
                  vertical: 20.h,
                  horizontal: 20.w,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16.r),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16.r),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16.r),
                  borderSide: BorderSide(color: uiVariables.primary, width: 2.w),
                ),
              ),
              validator: (val) => (val == null || val.trim().isEmpty)
                  ? "Enter your name"
                  : null,
            ),
            SizedBox(height: 16.h),
            TextFormField(
              controller: _emailController,
              decoration: InputDecoration(
                hintText: 'Email Address',
                hintStyle: GoogleFonts.inter(color: uiVariables.outlineVariant),
                filled: true,
                fillColor: uiVariables.surfaceContainerLowest,
                prefixIcon: Icon(
                  Icons.email_outlined,
                  color: uiVariables.primary,
                ),
                contentPadding: EdgeInsets.symmetric(
                  vertical: 20.h,
                  horizontal: 20.w,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16.r),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16.r),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16.r),
                  borderSide: BorderSide(color: uiVariables.primary, width: 2.w),
                ),
              ),
              validator: (val) => (val == null || !val.contains("@") || val.length<2)
                  ? "Enter valid email"
                  : null,
            ),
            SizedBox(height: 32.h),
            InkWell(
              onTap: () async {
                if (_formKey.currentState!.validate()) {
                  setState(() {
                    _isLoading = true;
                  });
                  try {
                    final result = await Future.any([
                      SessionManager.loginUser(
                        _nameController.text.trim(),
                        _emailController.text.trim(),
                      ),
                      Future.delayed(const Duration(seconds: 15), () => false),
                    ]);
                    if (!mounted) return;
                    if (!result) {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const SystemStatusScreen(),
                        ),
                      );
                    } else {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const CalendarPage()),
                      );
                    }
                  } catch (e) {
                    if (!mounted) return;
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const SystemStatusScreen(),
                      ),
                    );
                  } finally {
                    if (mounted) {
                      setState(() {
                        _isLoading = false;
                      });
                    }
                  }
                }
              },
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 20.h),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [uiVariables.primary, uiVariables.primaryContainer],
                  ),
                  borderRadius: BorderRadius.circular(9999.r),
                  boxShadow: [
                    BoxShadow(
                      color: uiVariables.primary.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: _isLoading
                      ? SizedBox(
                          width: 20.w,
                          height: 20.h,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          'Continue',
                          style: GoogleFonts.inter(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16.sp,
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );

    return Scaffold(
      backgroundColor: uiVariables.surface,
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [header, form],
            ),
          ),
        ],
      ),
    );
  }
}
