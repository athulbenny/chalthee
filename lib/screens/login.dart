import 'package:chalthee/constants/CommonUI.dart';
import 'package:chalthee/screens/CalenderPage.dart';
import 'package:chalthee/screens/system_status_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../constants/constant_values.dart';
import '../storage/session_router.dart';

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
      padding: const EdgeInsets.only(left: 24, right: 24, top: 80, bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: uiVariables.primaryContainer,
              shape: BoxShape.circle,
            ),
            child:  CircleAvatar(
              backgroundColor: Colors.transparent,
              backgroundImage: AssetImage(ConstantValues.logo),
              radius: 20,
            ),
          ),
          const SizedBox(height: 24),
          Text('Welcome to', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600, color: uiVariables.onSurfaceVariant)),
          Text('The Chalthee Verse', style: GoogleFonts.manrope(fontSize: 36, fontWeight: FontWeight.w800, color: uiVariables.primary, letterSpacing: -1.0)),
          const SizedBox(height: 8),
          Text('Sign in to continue your wellness journey.', style: GoogleFonts.inter(fontSize: 14, color: uiVariables.onSurfaceVariant)),
        ],
      ),
    );

    Widget form = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
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
                prefixIcon: Icon(Icons.person_outline, color: uiVariables.primary),
                contentPadding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: uiVariables.primary, width: 2),
                ),
              ),
              validator: (val) => (val == null || val.trim().isEmpty) ? "Enter your name" : null,
            ),
            const SizedBox(height: 16),
             TextFormField(
              controller: _emailController,
              decoration: InputDecoration(
                hintText: 'Email Address',
                hintStyle: GoogleFonts.inter(color: uiVariables.outlineVariant),
                filled: true,
                fillColor: uiVariables.surfaceContainerLowest,
                prefixIcon: Icon(Icons.email_outlined, color: uiVariables.primary),
                contentPadding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: uiVariables.primary, width: 2),
                ),
              ),
              validator: (val) => (val == null || !val.contains("@")) ? "Enter valid email" : null,
            ),
            const SizedBox(height: 32),
            InkWell(
              onTap: () async {
                 // if (_formKey.currentState!.validate()) {
                 //    setState(() { _isLoading = true; });
                 //    await SessionManager.loginUser(
                 //      _nameController.text.trim(),
                 //      _emailController.text.trim(),
                 //    );
                 //    if (mounted) {
                 //      Navigator.pushReplacement(
                 //        context,
                 //        MaterialPageRoute(builder: (_) => const CalendarPage()),
                 //      );
                 //    }
                 // }
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
                      Future.delayed(const Duration(seconds: 5), () => false),
                    ]);

                    if (!mounted) return;

                    if (!result) {
                      // 🚨 Go to error screen
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const SystemStatusScreen(),
                        ),
                      );
                    } else {
                      // ✅ Success
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const CalendarPage(),
                        ),
                      );
                    }
                  } catch (e) {
                    if (!mounted) return;

                    // ❌ Any error → error screen
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
                padding: const EdgeInsets.symmetric(vertical: 20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [uiVariables.primary, uiVariables.primaryContainer]),
                  borderRadius: BorderRadius.circular(9999),
                  boxShadow: [BoxShadow(color: uiVariables.primary.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4))]
                ),
                child: Center(
                  child: _isLoading 
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : Text('Continue', style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
            )
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
              children: [
                header,
                form,
              ],
            ),
          ),
          // if (_isLoading) const Center(child: CircularProgressIndicator()),
        ],
      )
    );
  }
}
