import 'package:chalthee/screens/CalenderPage.dart';
import 'package:chalthee/screens/login.dart';
import 'package:chalthee/storage/device_mapper.dart';
import 'package:chalthee/storage/firebase_connect.dart';
import 'package:chalthee/storage/session_router.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

class RouteDecider extends StatefulWidget {
  final bool isLoggedIn;

  const RouteDecider({
    required this.isLoggedIn,
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
        bool? fbStatus = await DeviceMapper().getFbStatus();
        if(!(fbStatus?? true)){
          SystemNavigator.pop();
        }
        String? uuid = await DeviceMapper().getUuid();
        print("App foreground uuid = $uuid");
      },
      onPause: () async {
        bool? isSynced = await DeviceMapper().isSyncedStatus();
        print("synced status = $isSynced");

        if (!(isSynced ?? true)) {
          Map<String, dynamic> session = await SessionManager.getSession();
          DbConnect().addProduct(session);
        }

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
        ? CalendarPage()
        : LoginPage();
  }
}
