import 'package:chalthee/constants/CommonUI.dart';
import 'package:chalthee/screens/CalenderPage.dart';
import 'package:chalthee/storage/device_mapper.dart';
import 'package:flutter/material.dart';

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
  final deviceSession = DeviceMapper();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: uiVariables.scaffoldBackgroundColor,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        /// Profile icon
                        Container(
                          decoration: uiVariables.bodyCircleDecorator.copyWith(shape: BoxShape.circle),
                          padding: const EdgeInsets.all(20),
                          child: const Icon(
                            Icons.person,
                            size: 50,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          "Welcome",
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          "Enter your details to continue",
                          style: TextStyle(
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 30),
                        /// Name Field
                        TextFormField(
                          controller: _nameController,
                          decoration: InputDecoration(
                            labelText: "Name",
                            prefixIcon: const Icon(Icons.person_outline),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return "Enter your name";
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        /// Email Field
                        TextFormField(
                          controller: _emailController,
                          decoration: InputDecoration(
                            labelText: "Email",
                            prefixIcon: const Icon(Icons.email_outlined),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty || value.length < 3) {
                              return "Enter email";
                            }
                            if (!value.contains("@")) {
                              return "Enter valid email";
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 30),
                        /// Button
                        SizedBox(
                          width: double.infinity,
                          height: 50,

                          child: ElevatedButton(

                            onPressed: () async {
                              if (_formKey.currentState!.validate()) {
                                if (mounted) {
                                  await SessionManager.loginUser(
                                    _nameController.text.trim(),
                                    _emailController.text.trim(),
                                  );
                                }
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => CalendarPage(),
                                  ),
                                );
                              }
                            },
                            style: uiVariables.elevatedButtonStyle,
                            child:  Text(
                              "Continue",
                              style: TextStyle(
                                color: uiVariables.textColorDefault,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
