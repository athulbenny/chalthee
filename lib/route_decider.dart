import 'package:chalthee/screens/CalenderPage.dart';
import 'package:chalthee/screens/login.dart';
import 'package:chalthee/storage/device_mapper.dart';
import 'package:chalthee/storage/weight_storage.dart';
import 'package:flutter/cupertino.dart';

class RouteDecider extends StatefulWidget {
  final bool isLoggedIn;
  final WeightStorage? preloadedStorage;
  final Map<String, dynamic>? preloadedUser;

  const RouteDecider({
    required this.isLoggedIn,
    this.preloadedStorage,
    this.preloadedUser,
    super.key,
  });

  @override
  State<RouteDecider> createState() => _RouteDeciderState();
}

class _RouteDeciderState extends State<RouteDecider> {
  late final AppLifecycleListener _listener;

  @override
  void initState() {
    super.initState();

    _listener = AppLifecycleListener(
      onResume: () async {
        String? uuid = await DeviceMapper().getUuid();
        print("App foreground uuid");
      },
      onPause: () async {
        print("App background");
      },
      onDetach: () {
        print("App terminated");
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return widget.isLoggedIn
        ? CalendarPage(
            preloadedStorage: widget.preloadedStorage,
            preloadedUser: widget.preloadedUser,
          )
        : LoginPage();
  }
}
