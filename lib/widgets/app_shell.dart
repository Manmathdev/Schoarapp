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

  static const _icons = [
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
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          decoration: BoxDecoration(
            color: ScholarColors.glassBg,
            border: Border(top: BorderSide(color: ScholarColors.glassBorder)),
          ),
          child: SafeArea(
            child: SizedBox(
              height: 66,
              child: Row(
                children: List.generate(_icons.length, (i) {
                  final (icon, activeIcon, label) = _icons[i];
                  return _navItem(i, icon, activeIcon, label);
                }),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _navItem(int index, IconData icon, IconData activeIcon, String label) {
    final isActive = _index == index;
    return Expanded(
      child: InkWell(
        onTap: () => _onTap(index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
          margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
          decoration: BoxDecoration(
            color: isActive ? ScholarColors.accentSoft : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isActive ? activeIcon : icon,
                size: 21,
                color: isActive ? ScholarColors.accent : ScholarColors.textMuted,
              ),
              const SizedBox(height: 3),
              Text(
                label,
                style: ScholarStyles.sans(
                  fontSize: 10,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                  color: isActive ? ScholarColors.accent : ScholarColors.textMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
