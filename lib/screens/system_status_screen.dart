import 'package:chalthee/constants/constant_values.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../constants/CommonUI.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SystemStatusScreen extends StatelessWidget {
  const SystemStatusScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CommonUI().surface,
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0, -0.3),
            radius: 1.2,
            colors: [Color(0xFFDFF5F1), Color(0xFFF4F6F6)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              SizedBox(height: 20.h),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  child: Column(
                    children: [
                      _statusBadge(),
                      SizedBox(height: 24.h),
                      _iconCard(),
                      SizedBox(height: 32.h),
                      _titleText(),
                      SizedBox(height: 12.h),
                      _subtitleText(),
                      SizedBox(height: 32.h),
                      _retryButton(),
                      SizedBox(height: 12.h),
                      _backButton(),
                      SizedBox(height: 20.h),
                      _errorRow(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // HEADER
  Widget _buildHeader() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 30.w, vertical: 24.h),
      child: Row(
        children: [
          // Icon(Icons.arrow_back, color: Colors.teal),
          SizedBox(width: 18.w),
          Text(
            "System Status",
            style: GoogleFonts.manrope(
              fontSize: 24.sp,
              fontWeight: FontWeight.w700,
              color: CommonUI().secondary,
            ),
          ),
          Spacer(),
          CircleAvatar(
            backgroundColor: Colors.transparent,
            backgroundImage: AssetImage(ConstantValues.logo),
            radius: 20,
          ),
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
    );
  }

  // STATUS BADGE
  Widget _statusBadge() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: CommonUI().primary,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.bolt, size: 18.sp, color: CommonUI().outlineVariant),
          SizedBox(width: 6.w),
          Text(
            "Service Disruption",
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: CommonUI().outlineVariant,
            ),
          ),
        ],
      ),
    );
  }

  // ICON CARD
  Widget _iconCard() {
    return Container(
      height: 140.h,
      width: 140.w,
      decoration: BoxDecoration(
        color: CommonUI().surfaceContainerHigh,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Center(
        child: Icon(Icons.cloud_off, size: 60.sp, color: Colors.teal),
      ),
    );
  }

  // TITLE
  Widget _titleText() {
    return Text(
      "OOPS! \nSomething went wrong",
      textAlign: TextAlign.center,
      style: GoogleFonts.manrope(fontSize: 26.sp, fontWeight: FontWeight.w800),
    );
  }

  // SUBTITLE
  Widget _subtitleText() {
    return Text(
      "You're having trouble connecting to our services. "
      "Please check your connection or try again later.",
      textAlign: TextAlign.center,
      style: GoogleFonts.inter(
        fontSize: 15.sp,
        color: Colors.grey[600],
        height: 1.8.h,
      ),
    );
  }

  // RETRY BUTTON
  Widget _retryButton() {
    return Container(
      width: double.infinity,
      height: 56.h,
      decoration: BoxDecoration(
        color: Colors.teal,
        borderRadius: BorderRadius.circular(30.r),
      ),
      child: InkWell(
        onTap: () {},
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
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
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.refresh, color: Colors.white, size: 20.sp),
              SizedBox(width: 8.w),
              Text(
                'Retry Connection',
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // BACK BUTTON
  Widget _backButton() {
    return Container(
      width: double.infinity,
      height: 56.h,
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(30.r),
      ),
      child: ElevatedButton(
        onPressed: () => SystemNavigator.pop(),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30.r),
          ),
        ),
        child: Text(
          "Close Application",
          style: TextStyle(color: Colors.black),
        ),
      ),
    );
  }

  // ERROR ROW
  Widget _errorRow() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          const CircleAvatar(radius: 5, backgroundColor: Colors.red),
          SizedBox(width: 10.w),
          Text("Error Code: 503_SERVICE_UNAVAILABLE"),
          Spacer(),
          Text(
            "REPORT ISSUE",
            style: GoogleFonts.inter(
              color: Colors.teal.shade700,
              fontSize: 12.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
