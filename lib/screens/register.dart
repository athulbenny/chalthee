import 'package:chalthee/constants/CommonUI.dart';
import 'package:chalthee/constants/constant_values.dart';
import 'package:chalthee/screens/CalenderPage.dart';
import 'package:chalthee/screens/system_status_screen.dart';
import 'package:chalthee/storage/firebase_connect.dart';
import 'package:chalthee/storage/session_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  final CommonUI uiVariables = CommonUI();

  bool _isLoading = false;
  bool _termsAccepted = false;
  int _currentStep = 0;
  String terms = 'kkkjkjkj';

  @override
  void initState() {
    super.initState();
    loadTerms();
  }

  Future<void> loadTerms() async {
    final content =
    await rootBundle.loadString('assets/termsAndCondition.txt');

    setState(() {
      terms = content;
    });
    print(terms);
  }

  @override
  Widget build(BuildContext context) {
    Widget header = Container(
      padding: EdgeInsets.only(
        left: 24.w,
        right: 24.w,
        top: 60.h,
        bottom: 20.h,
      ),
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
            'Create Account',
            style: GoogleFonts.manrope(
              fontSize: 32.sp,
              fontWeight: FontWeight.w800,
              color: uiVariables.primary,
              letterSpacing: -1.0,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            _currentStep == 0
                ? 'Fill in your details to get started.'
                : 'Please read and accept the terms and conditions.',
            style: GoogleFonts.inter(
              fontSize: 14.sp,
              color: uiVariables.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );

    Widget detailsForm = Form(
      key: _formKey,
      child: Column(
        children: [
          _buildTextField(
            _nameController,
            'Display Name',
            Icons.person_outline,
            false,
          ),
          SizedBox(height: 16.h),
          _buildTextField(
            _emailController,
            'Email Address',
            Icons.email_outlined,
            false,
            isEmail: true,
          ),
          SizedBox(height: 16.h),
          _buildTextField(
            _passwordController,
            'Password',
            Icons.lock_outline,
            true,
          ),
          SizedBox(height: 16.h),
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  _ageController,
                  'Age',
                  Icons.cake_outlined,
                  false,
                  isNumber: true,
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: _buildTextField(
                  _weightController,
                  'Weight (kg)',
                  Icons.monitor_weight_outlined,
                  false,
                  isNumber: true,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          _buildTextField(
            _heightController,
            'Height (cm)',
            Icons.height_outlined,
            false,
            isNumber: true,
          ),
          SizedBox(height: 32.h),
          _buildButton('Next', () {
            if (_formKey.currentState!.validate()) {
              setState(() => _currentStep = 1);
            }
          }),
        ],
      ),
    );

    Widget termsForm = Column(
      children: [
        Container(
          padding: EdgeInsets.all(16.w),
          height: 300.h,
          width: 300.w,
          decoration: BoxDecoration(
            color: uiVariables.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: SingleChildScrollView(
            child: Text(
              terms,
              style: GoogleFonts.inter(
                fontSize: 14.sp,
                color: uiVariables.onSurfaceVariant,
              ),
            ),
          ),
        ),
        SizedBox(height: 16.h),
        Row(
          children: [
            Checkbox(
              value: _termsAccepted,
              activeColor: uiVariables.primary,
              onChanged: (val) {
                setState(() => _termsAccepted = val ?? false);
              },
            ),
            Expanded(
              child: Text(
                'I accept the terms and conditions',
                style: GoogleFonts.inter(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: uiVariables.onSurface,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 32.h),
        Row(
          children: [
            Expanded(
              child: _buildButton('Back', () {
                setState(() => _currentStep = 0);
              }, isOutlined: true),
            ),
            SizedBox(width: 16.w),
            Expanded(
              flex: 2,
              child: _buildButton('Register', () async {
                if (!_termsAccepted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Please accept the terms and conditions.'),
                    ),
                  );
                  return;
                }

                setState(() => _isLoading = true);
                try {
                  final email = _emailController.text.trim();
                  final password = _passwordController.text.trim();
                  final name = _nameController.text.trim();
                  final age = double.tryParse(_ageController.text.trim()) ?? 0;
                  final weight =
                      double.tryParse(_weightController.text.trim()) ?? 0;
                  final height =
                      double.tryParse(_heightController.text.trim()) ?? 0;

                  // 0. Connectivity Check
                  final connectivityResult = await Connectivity()
                      .checkConnectivity();
                  if (connectivityResult.contains(ConnectivityResult.none)) {
                    if (!mounted) return;
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const SystemStatusScreen(),
                      ),
                    );
                    return;
                  }

                  // 1. Firebase Auth Registration with Timeout
                  UserCredential cred;
                  try {
                    cred = await Future.any([
                      FirebaseAuth.instance.createUserWithEmailAndPassword(
                        email: email,
                        password: password,
                      ),
                      Future.delayed(
                        const Duration(seconds: 15),
                        () => throw Exception("Timeout"),
                      ),
                    ]);
                  } catch (e) {
                    throw e; // Caught by the outer catch blocks
                  }

                  if (cred.user != null) {
                    // 2. Create User Record in Firestore
                    final existingUserMap = await DbConnect().getProductsByMail(
                      email,
                    );
                    if (existingUserMap == null) {
                      await DbConnect().createNewUserRecord(
                        name,
                        email,
                      ); // Uses Firebase UID in modified DbConnect
                    }
                    // 3. Cache Registration Details locally
                    await SessionManager.cacheRegistrationDetails(
                      name,
                      email,
                      age,
                      weight,
                      height,
                    );

                    if (!mounted) return;
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => const CalendarPage()),
                      (route) => false,
                    );
                  }
                } on FirebaseAuthException catch (e) {
                  if (!mounted) return;
                  if (e.code == 'network-request-failed') {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const SystemStatusScreen(),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(e.message ?? 'Registration failed'),
                      ),
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
                  if (mounted) setState(() => _isLoading = false);
                }
              }),
            ),
          ],
        ),
      ],
    );

    return Scaffold(
      backgroundColor: uiVariables.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: uiVariables.onSurface),
          onPressed: () {
            if (_currentStep == 1) {
              setState(() => _currentStep = 0);
            } else {
              Navigator.pop(context);
            }
          },
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                header,
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: _currentStep == 0 ? detailsForm : termsForm,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String hint,
    IconData icon,
    bool isPassword, {
    bool isEmail = false,
    bool isNumber = false,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword,
      keyboardType: isNumber
          ? TextInputType.number
          : (isEmail ? TextInputType.emailAddress : TextInputType.text),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.inter(color: uiVariables.outlineVariant),
        filled: true,
        fillColor: uiVariables.surfaceContainerLowest,
        prefixIcon: Icon(icon, color: uiVariables.primary),
        contentPadding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 20.w),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16.r),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16.r),
          borderSide: BorderSide(color: uiVariables.primary, width: 2.w),
        ),
      ),
      validator: (val) {
        if (val == null || val.trim().isEmpty) return "Required";
        if (isEmail && (!val.contains("@") || val.length < 2))
          return "Invalid email";
        return null;
      },
    );
  }

  Widget _buildButton(
    String text,
    VoidCallback onTap, {
    bool isOutlined = false,
  }) {
    return InkWell(
      onTap: _isLoading ? null : onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 20.h),
        decoration: BoxDecoration(
          color: isOutlined ? Colors.transparent : uiVariables.primary,
          border: isOutlined
              ? Border.all(color: uiVariables.primary, width: 2.w)
              : null,
          borderRadius: BorderRadius.circular(9999.r),
          boxShadow: isOutlined
              ? []
              : [
                  BoxShadow(
                    color: uiVariables.primary.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
        ),
        child: Center(
          child: _isLoading && !isOutlined
              ? SizedBox(
                  width: 20.w,
                  height: 20.h,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : Text(
                  text,
                  style: GoogleFonts.inter(
                    color: isOutlined ? uiVariables.primary : Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16.sp,
                  ),
                ),
        ),
      ),
    );
  }
}
