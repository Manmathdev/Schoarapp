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
    return Container(
      decoration: BoxDecoration(
        color: ScholarColors.bgBase,
        border: Border(top: BorderSide(color: Colors.black.withOpacity(0.06))),
      ),
      child: SafeArea(
        child: SizedBox(
          height: 64,
          child: Row(
            children: [
              _navItem(context, 0, Icons.dashboard_outlined, Icons.dashboard, 'Dashboard'),
              _navItem(context, 1, Icons.menu_book_outlined, Icons.menu_book, 'Curriculum'),
              _navItem(context, 2, Icons.calendar_today_outlined, Icons.calendar_today, 'Planner'),
              _navItem(context, 3, Icons.folder_outlined, Icons.folder, 'Resources'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navItem(BuildContext context, int index, IconData icon, IconData activeIcon, String label) {
    final isActive = _index == index;
    return Expanded(
      child: InkWell(
        onTap: () => _onTap(index),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isActive ? activeIcon : icon,
              size: 22,
              color: isActive ? ScholarColors.accent : ScholarColors.textMuted,
            ),
            const SizedBox(height: 4),
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
    );
  }
}
