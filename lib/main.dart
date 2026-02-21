import 'package:chalthee/storage/session_router.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'route_decider.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  bool loggedIn = await SessionManager.isLoggedIn();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp(loggedIn));
}

class MyApp extends StatelessWidget {
  final bool loggedIn;
  const MyApp(this.loggedIn, {super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: RouteDecider(isLoggedIn: loggedIn,)
    );
  }
}
