import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:chalthee/storage/session_router.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'screens/splash_screen.dart';
import 'firebase_options.dart';

final FlutterLocalNotificationsPlugin notificationsPlugin = FlutterLocalNotificationsPlugin();

@pragma('vm:entry-point')
Future<void> alarmCallback() async {
  final FlutterLocalNotificationsPlugin plugin =
  FlutterLocalNotificationsPlugin();

  const AndroidInitializationSettings androidSettings =
  AndroidInitializationSettings('@mipmap/ic_launcher');

  const InitializationSettings settings =
  InitializationSettings(android: androidSettings);

  await plugin.initialize(settings: settings);

  // ✅ ADD THIS HERE (channel creation)
  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'reminder_channel',
    'Reminders',
    importance: Importance.max,
  );

  final androidPlugin = plugin
      .resolvePlatformSpecificImplementation<
      AndroidFlutterLocalNotificationsPlugin>();

  await androidPlugin?.createNotificationChannel(channel);

  // ✅ Then show notification
  await plugin.show(
    id : 0,
    title: 'Chalthee Reminder 💪',
    body: 'Time to log your weight!',
    notificationDetails: const NotificationDetails(
      android: AndroidNotificationDetails(
        'reminder_channel',
        'Reminders',
        importance: Importance.max,
        priority: Priority.high,
      ),
    ),
  );
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await AndroidAlarmManager.initialize();

  const AndroidInitializationSettings androidSettings =
  AndroidInitializationSettings('@mipmap/ic_launcher');

  const InitializationSettings settings =
  InitializationSettings(android: androidSettings);

  await notificationsPlugin.initialize(settings: settings);

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
        home: SplashScreen(isLoggedIn: loggedIn,)
    );
  }
}
