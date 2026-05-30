import 'dart:async';

import 'package:chalthee/constants/CommonUI.dart';
import 'package:chalthee/constants/constant_values.dart';
import 'package:chalthee/route_decider.dart';
import 'package:chalthee/storage/weight_storage.dart';
import 'package:chalthee/storage/session_router.dart';
import 'package:chalthee/screens/system_status_screen.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SplashScreen extends StatefulWidget {
  final bool isLoggedIn;

  const SplashScreen({super.key, required this.isLoggedIn});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  final Connectivity _connectivity = Connectivity();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1300),
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOutBack),
      ),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _controller,
            curve: const Interval(0.5, 1.0, curve: Curves.easeOutCubic),
          ),
        );

    _controller.forward();

    _fetchData();
  }

  void _fetchData() async {
    final weightStorage = WeightStorage();
    Map<String, dynamic>? user;
    bool dbStatus = true;
    await checkCurrentNetwork();

    Future<bool>? initFuture;
    Future<Map<String, dynamic>?>? userFuture;

    if (widget.isLoggedIn) {
      initFuture = weightStorage.init();
      userFuture = SessionManager.getCurrentUser();
    }

    await Future.delayed(
      const Duration(milliseconds: 1300),
    ); // 1800 anim + 500 delay

    if (widget.isLoggedIn && initFuture != null && userFuture != null) {
      dbStatus = await initFuture;
      user = await userFuture;
    }

    if (mounted) {
      if (widget.isLoggedIn && !dbStatus) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => const SystemStatusScreen(),
            transitionDuration: const Duration(milliseconds: 500),
            transitionsBuilder: (_, animation, __, child) {
              return FadeTransition(opacity: animation, child: child);
            },
          ),
        );
      } else {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => RouteDecider(
              isLoggedIn: widget.isLoggedIn,
              preloadedStorage: widget.isLoggedIn ? weightStorage : null,
              preloadedUser: widget.isLoggedIn ? user : null,
            ),
            transitionDuration: const Duration(milliseconds: 500),
            transitionsBuilder: (_, animation, __, child) {
              return FadeTransition(opacity: animation, child: child);
            },
          ),
        );
      }
    }
  }

  // 1. One-time Network Status Check
  Future<void> checkCurrentNetwork() async {
    try {
      final List<ConnectivityResult> results = await _connectivity.checkConnectivity();
      if (results.contains(ConnectivityResult.none) || results.isEmpty) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => const SystemStatusScreen(),
            transitionDuration: const Duration(milliseconds: 10),
            transitionsBuilder: (_, animation, __, child) {
              return FadeTransition(opacity: animation, child: child);
            },
          ),
        );
      }
    } on PlatformException catch (e) {
      debugPrint('Could not check network status: $e');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ScaleTransition(
              scale: _scaleAnimation,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Image.asset(
                  ConstantValues.logo,
                  width: 120.w,
                  height: 120.h,
                ),
              ),
            ),
            SizedBox(height: 24.h),
            SlideTransition(
              position: _slideAnimation,
              child: FadeTransition(
                opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
                  CurvedAnimation(
                    parent: _controller,
                    curve: const Interval(0.5, 1.0, curve: Curves.easeIn),
                  ),
                ),
                child: Text(
                  ConstantValues.appName,
                  style: GoogleFonts.manrope(
                    fontSize: 32.sp,
                    fontWeight: FontWeight.w800,
                    color: CommonUI().primary,
                    letterSpacing: -0.5,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
