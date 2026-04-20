import 'package:chalthee/constants/constant_values.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../constants/CommonUI.dart';

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
              const SizedBox(height: 20),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      _statusBadge(),
                      const SizedBox(height: 24),
                      _iconCard(),
                      const SizedBox(height: 32),
                      _titleText(),
                      const SizedBox(height: 12),
                      _subtitleText(),
                      const SizedBox(height: 32),
                      _retryButton(),
                      const SizedBox(height: 12),
                      _backButton(),
                      const SizedBox(height: 20),
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
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 24),
      child: Row(
        children: [
          // const Icon(Icons.arrow_back, color: Colors.teal),
          const SizedBox(width: 18),
          Text(
            "System Status",
            style: GoogleFonts.manrope(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: CommonUI().secondary,
            ),
          ),
          const Spacer(),
          CircleAvatar(
            backgroundColor: Colors.transparent,
            backgroundImage: AssetImage(ConstantValues.logo),
            radius: 20,
          ),
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
    );
  }

  // STATUS BADGE
  Widget _statusBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: CommonUI().primary,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.bolt, size: 18, color: CommonUI().outlineVariant),
          SizedBox(width: 6),
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
      height: 140,
      width: 140,
      decoration: BoxDecoration(
        color: CommonUI().surfaceContainerHigh,
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Center(
        child: Icon(Icons.cloud_off, size: 60, color: Colors.teal),
      ),
    );
  }

  // TITLE
  Widget _titleText() {
    return Text(
      "OOPS! \nSomething went wrong",
      textAlign: TextAlign.center,
      style: GoogleFonts.manrope(fontSize: 26, fontWeight: FontWeight.w800),
    );
  }

  // SUBTITLE
  Widget _subtitleText() {
    return Text(
      "You're having trouble connecting to our services. "
      "Please check your connection or try again later.",
      textAlign: TextAlign.center,
      style: GoogleFonts.inter(
        fontSize: 15,
        color: Colors.grey[600],
        height: 1.8,
      ),
    );
  }

  // RETRY BUTTON
  Widget _retryButton() {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        color: Colors.teal,
        borderRadius: BorderRadius.circular(30),
      ),
      child: InkWell(
        onTap: () {},
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
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
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.refresh, color: Colors.white, size: 20),
              const SizedBox(width: 8),
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
      height: 56,
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(30),
      ),
      child: ElevatedButton(
        onPressed: () => SystemNavigator.pop(),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        child: const Text(
          "Close Application",
          style: TextStyle(color: Colors.black),
        ),
      ),
    );
  }

  // ERROR ROW
  Widget _errorRow() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const CircleAvatar(radius: 5, backgroundColor: Colors.red),
          const SizedBox(width: 10),
          const Text("Error Code: 503_SERVICE_UNAVAILABLE"),
          const Spacer(),
          Text(
            "REPORT ISSUE",
            style: GoogleFonts.inter(
              color: Colors.teal.shade700,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
