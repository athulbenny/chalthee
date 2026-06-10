import 'package:chalthee/constants/CommonUI.dart';
import 'package:chalthee/screens/CalenderPage.dart';
import 'package:chalthee/screens/system_status_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/constant_values.dart';
import '../storage/session_router.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:chalthee/screens/register.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _passwordController = TextEditingController();
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
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
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
            SizedBox(height: 16.h),
            TextFormField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(
                hintText: 'Password',
                hintStyle: GoogleFonts.inter(color: uiVariables.outlineVariant),
                filled: true,
                fillColor: uiVariables.surfaceContainerLowest,
                prefixIcon: Icon(
                  Icons.lock_outline,
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
                  ? "Enter your password"
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
                    final connectivityResult = await Connectivity().checkConnectivity();
                    if (connectivityResult.contains(ConnectivityResult.none)) {
                      if (!mounted) return;
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const SystemStatusScreen()),
                      );
                      return;
                    }
                    await Future.any([
                      FirebaseAuth.instance.signInWithEmailAndPassword(
                        email: _emailController.text.trim(),
                        password: _passwordController.text.trim(),
                      ),
                      Future.delayed(const Duration(seconds: 15), () => throw Exception("Timeout")),
                    ]);
                    // Also ensure the session is properly cached
                    final result = await Future.any([
                      SessionManager.loginUser(
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
                  } on FirebaseAuthException catch (e) {
                    if (!mounted) return;
                    if (e.code == 'network-request-failed') {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const SystemStatusScreen()),
                      );
                    } else if (e.code == 'user-not-found' || e.code == 'invalid-credential') {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Account not found. Please register.')),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(e.message ?? 'Login failed')),
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
            SizedBox(height: 16.h),
            TextButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterPage()));
              },
              child: Text(
                'Don\'t have an account? Register Here',
                style: GoogleFonts.inter(
                  color: uiVariables.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 14.sp,
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
