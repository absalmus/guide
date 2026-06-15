import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:stitch_smart_church_guide/screens/booking/booking_screen.dart';
import 'package:stitch_smart_church_guide/screens/churches/churches_explore_screen.dart';
import 'package:stitch_smart_church_guide/screens/home/home_screen.dart';
import 'package:stitch_smart_church_guide/screens/monasteries/monasteries_screen.dart';
import 'package:stitch_smart_church_guide/screens/profile/profile_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key, required this.child});

  final Widget child;

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _indexFromLocation(String location) {
    if (location.startsWith('/home')) return 0;
    if (location.startsWith('/churches')) return 1;
    if (location.startsWith('/booking')) return 2;
    if (location.startsWith('/monasteries')) return 3;
    if (location.startsWith('/profile')) return 4;
    return 0;
  }

  void _onTap(int index) {
    switch (index) {
      case 0:
        context.go('/home');
      case 1:
        context.go('/churches');
      case 2:
        context.go('/booking');
      case 3:
        context.go('/monasteries');
      case 4:
        context.go('/profile');
    }
  }

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    final index = _indexFromLocation(location);

    return Scaffold(
      body: widget.child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: _onTap,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'الرئيسية',
          ),
          NavigationDestination(
            icon: Icon(Icons.church_outlined),
            selectedIcon: Icon(Icons.church),
            label: 'الكنائس',
          ),
          NavigationDestination(
            icon: Icon(Icons.event_available_outlined),
            selectedIcon: Icon(Icons.event_available),
            label: 'الحجز',
          ),
          NavigationDestination(
            icon: Icon(Icons.temple_buddhist_outlined),
            selectedIcon: Icon(Icons.temple_buddhist),
            label: 'الأديرة',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'حسابي',
          ),
        ],
      ),
    );
  }
}

class MainShellRoutes {
  static const home = HomeScreen();
  static const churches = ChurchesExploreScreen();
  static const booking = BookingScreen();
  static const monasteries = MonasteriesScreen();
  static const profile = ProfileScreen();
}
