import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme.dart';
import '../pages/dashboard_page.dart';
import '../pages/curriculum_page.dart';
import '../pages/planner_page.dart';
import '../pages/resources_page.dart';

/// Root shell providing native bottom-tab navigation between the app's
/// four primary destinations. Each tab keeps its own scroll and state
/// alive via IndexedStack.
///
/// Uses Flutter's own Material 3 NavigationBar, styled globally via
/// navigationBarTheme in theme.dart, so this widget just supplies the
/// destinations rather than re-specifying colors here.
class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _index = 0;

  static const _pages = [
    DashboardPage(),
    CurriculumPage(),
    PlannerPage(),
    ResourcesPage(),
  ];

  static const _destinations = [
    (Icons.dashboard_outlined, Icons.dashboard, 'Dashboard'),
    (Icons.menu_book_outlined, Icons.menu_book, 'Curriculum'),
    (Icons.calendar_today_outlined, Icons.calendar_today, 'Planner'),
    (Icons.folder_outlined, Icons.folder, 'Resources'),
  ];

  void _onTap(int i) {
    if (i == _index) return;
    HapticFeedback.selectionClick();
    setState(() => _index = i);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: _onTap,
        animationDuration: ScholarTokens.motionMedium,
        destinations: _destinations
            .map((d) => NavigationDestination(icon: Icon(d.$1), selectedIcon: Icon(d.$2), label: d.$3, tooltip: d.$3))
            .toList(),
      ),
    );
  }
}
