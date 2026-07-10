import 'dart:ui' show ImageFilter;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme.dart';
import '../pages/dashboard_page.dart';
import '../pages/curriculum_page.dart';
import '../pages/planner_page.dart';
import '../pages/resources_page.dart';

/// Root shell providing native bottom-tab navigation between the app's
/// four primary destinations. Each tab keeps its own scroll and state
/// alive via IndexedStack, matching how the website's persistent header
/// nav behaved, but adapted to a thumb-reachable mobile pattern.
///
/// Built on Flutter's own NavigationBar (Material 3) rather than a custom
/// InkWell row — this gives correct screen-reader semantics (selected
/// state announcements), platform-consistent ripple/indicator behavior,
/// and keyboard/switch-access support for free, while still being fully
/// themed to match Scholar's glass aesthetic.
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
    final palette = context.palette;
    return Scaffold(
      body: IndexedStack(index: _index, children: _pages),
      bottomNavigationBar: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: NavigationBarTheme(
            data: NavigationBarThemeData(
              backgroundColor: palette.glassBg,
              indicatorColor: palette.accentSoft,
              surfaceTintColor: Colors.transparent,
              height: ScholarTokens.minTouchTarget + 18,
              labelTextStyle: WidgetStateProperty.resolveWith((states) {
                final isSelected = states.contains(WidgetState.selected);
                return ScholarStyles.sans(
                  fontSize: 10,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected ? palette.accent : palette.textMuted,
                );
              }),
              iconTheme: WidgetStateProperty.resolveWith((states) {
                final isSelected = states.contains(WidgetState.selected);
                return IconThemeData(
                  color: isSelected ? palette.accent : palette.textMuted,
                  size: 22,
                );
              }),
            ),
            child: Container(
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: palette.glassBorder)),
              ),
              child: NavigationBar(
                selectedIndex: _index,
                onDestinationSelected: _onTap,
                animationDuration: ScholarTokens.motionMedium,
                destinations: _destinations
                    .map((d) => NavigationDestination(
                          icon: Icon(d.$1),
                          selectedIcon: Icon(d.$2),
                          label: d.$3,
                          tooltip: d.$3,
                        ))
                    .toList(),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
