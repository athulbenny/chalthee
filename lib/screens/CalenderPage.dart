import 'package:chalthee/constants/CommonUI.dart';
import 'package:flutter/material.dart';

import '../helpers/WeightCalculator.dart';
import '../storage/session_router.dart';
import '../storage/weight_storage.dart';
import 'package:google_fonts/google_fonts.dart';

import 'dashboard_tab.dart';
import 'logs_tab.dart';
import 'trends_tab.dart';
import 'profile_tab.dart';

class CalendarPage extends StatefulWidget {
  final WeightStorage? preloadedStorage;
  final Map<String, dynamic>? preloadedUser;

  const CalendarPage({this.preloadedStorage, this.preloadedUser, super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  late WeightStorage _weightStorage;
  late WeightCalculatorHelper _calculator;
  int _selectedIndex = 0;
  String _userName = "";
  String _email = "";
  double currentHeight = 0.0;
  double goalWeight = 0.0;
  Map<String, dynamic>? user;
  bool result = false;

  // We no longer strictly need this ScaffoldKey for drawer handling,
  // but we keep it in case we need to show Snackbars or other scaffold traits in the future.
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();

    updateUserIfNull();

    _weightStorage = widget.preloadedStorage ?? WeightStorage();
    _calculator = WeightCalculatorHelper(_weightStorage);

    // Just in case it wasn't preloaded, we fallback to initializing it here (but splash screen handles this normally)
    if (widget.preloadedStorage == null) {
      _weightStorage.init().then((_) {
        if (mounted) setState(() {});
      });
    }
  }

  void _onSwitchTab(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void updateUserIfNull() async {
    // Use preloaded data from splash screen, falling back to empty/new if missing
    user = widget.preloadedUser;
    if (widget.preloadedUser == null) {
      user = await SessionManager.getCurrentUser();
    }
    _userName = user?["username"] ?? "User";
    _email = user?["usermail"] ?? "";
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Make the rain loader optional or background for everything
        // Note: The UI image for profile shows a light UI.
        // Dashboard also has a different UI.
        // If we want RainLoader behind everything, we keep it here.
        // if (_selectedIndex == 1) const RainLoader(),
        Scaffold(
          key: _scaffoldKey,
          backgroundColor: CommonUI().surface,
          body: IndexedStack(
            index: _selectedIndex,
            children: [
              DashboardTab(
                userName: _userName,
                weightStorage: _weightStorage,
                // userHeight: currentHeight,
                // goalWeight : goalWeight,
                onSwitchTab: _onSwitchTab,
              ),
              LogsTab(
                userName: _userName,
                weightStorage: _weightStorage,
                calculator: _calculator,
                onOpenProfile: () => _onSwitchTab(3),
              ),
              TrendsTab(
                userName: _userName,
                weightStorage: _weightStorage,
                onOpenProfile: () => _onSwitchTab(3),
                calculator: _calculator,
              ),
              ProfileTab(userName: _userName, email: _email),
            ],
          ),
          bottomNavigationBar: _buildBottomNav(),
        ),
      ],
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: CommonUI().floatingNavDecorator,
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        child: BottomNavigationBar(
          backgroundColor: CommonUI().surface.withOpacity(0.8),
          elevation: 0,
          type: BottomNavigationBarType.fixed,
          currentIndex: _selectedIndex,
          selectedItemColor: CommonUI().primary,
          unselectedItemColor: CommonUI().onSurfaceVariant,
          selectedLabelStyle: GoogleFonts.inter(
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: GoogleFonts.inter(
            fontSize: 11,
            fontWeight: FontWeight.normal,
          ),
          onTap: _onSwitchTab,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_outlined),
              activeIcon: Icon(Icons.dashboard),
              label: 'DASHBOARD',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.add_circle_outline),
              activeIcon: Icon(Icons.add_circle),
              label: 'LOGS',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.insights_outlined),
              activeIcon: Icon(Icons.insights),
              label: 'TRENDS',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'PROFILE',
            ),
          ],
        ),
      ),
    );
  }
}
