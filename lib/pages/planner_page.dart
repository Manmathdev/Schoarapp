import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme.dart';
import '../widgets/glass_card.dart';
import '../widgets/scholar_header.dart';
import '../widgets/scholar_footer.dart';
import '../widgets/background_orbs.dart';
import '../services/data_service.dart';

const List<String> _daysOfWeek = [
  'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'
];
const List<String> _dayLabels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
const List<String> _habitsList = [
  '8 Hours Sleep', 'Hydration (3L)', 'Exercise', 'Work', 'No Gooning'
];

class PlannerPage extends StatefulWidget {
  const PlannerPage({super.key});

  @override
  State<PlannerPage> createState() => _PlannerPageState();
}

class _PlannerPageState extends State<PlannerPage> {
  final DataService _dataService = DataService();
  bool _isLoading = true;
  String? _errorMessage;
  late Map<String, String> _weeklyPlan;
  late Map<int, List<bool>> _weeklyHabits;

  final Map<String, TextEditingController> _dayControllers = {
    for (final day in _daysOfWeek) day: TextEditingController(),
  };

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    for (final c in _dayControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final plan = await _dataService.getPlanner();
      final habits = await _dataService.getHabits();
      setState(() {
        _weeklyPlan = plan;
        _weeklyHabits = habits;
        _isLoading = false;
      });
      for (final day in _daysOfWeek) {
        _dayControllers[day]!.text = _weeklyPlan[day] ?? '';
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load planner: $e';
        _isLoading = false;
      });
    }
  }

  void _onPlanChanged(String day, String value) {
    _weeklyPlan[day] = value;
    _dataService.savePlanner(_weeklyPlan);
  }

  void _onHabitChanged(int habitIndex, int dayIndex, bool value) async {
    HapticFeedback.selectionClick();
    setState(() {
      _weeklyHabits.putIfAbsent(habitIndex, () => List.filled(7, false));
      _weeklyHabits[habitIndex]![dayIndex] = value;
    });
    try {
      await _dataService.saveHabits(_weeklyHabits);
    } catch (e) {
      if (mounted) setState(() => _errorMessage = 'Failed to save habits: $e');
    }
  }

  void _clearWeek() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear Week'),
        content: const Text('Clear your entire schedule and habit tracker?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              setState(() => _isLoading = true);
              try {
                await _dataService.clearPlannerAndHabits();
                await _loadData();
                for (final c in _dayControllers.values) {
                  c.clear();
                }
              } catch (e) {
                setState(() {
                  _errorMessage = 'Failed to clear: $e';
                  _isLoading = false;
                });
              }
            },
            child: Text('Clear', style: TextStyle(color: ScholarColors.accent)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            const BackgroundOrbs(page: 'planner'),
            Column(
              children: [
                const ScholarHeader(currentRoute: '/planner'),
                Expanded(child: _buildBody()),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: ScholarColors.accent));
    }
    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline, size: 48, color: ScholarColors.statusRevision),
              const SizedBox(height: 16),
              Text(_errorMessage!, textAlign: TextAlign.center, style: ScholarStyles.sans(color: ScholarColors.textSecondary)),
              const SizedBox(height: 24),
              ElevatedButton(onPressed: _loadData, child: const Text('Retry')),
            ],
          ),
        ),
      );
    }
    return RefreshIndicator(
      color: ScholarColors.accent,
      onRefresh: _loadData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [
            const SizedBox(height: 24),
            _buildPageHeader(),
            const SizedBox(height: 32),
            _buildLayout(),
            const ScholarFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildPageHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Text('ARCHITECT', style: ScholarStyles.sans(fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 4, color: ScholarColors.accent)),
          const SizedBox(height: 12),
          Text('Weekly Architect', textAlign: TextAlign.center, style: ScholarStyles.serif(fontSize: 56, fontWeight: FontWeight.w500, letterSpacing: -0.03, height: 1.1)),
          const SizedBox(height: 8),
          Text('Design your week. Execute your plan.', textAlign: TextAlign.center, style: ScholarStyles.sans(fontSize: 16, fontWeight: FontWeight.w300, color: ScholarColors.textSecondary)),
          const SizedBox(height: 20),
          OutlinedButton(
            onPressed: _clearWeek,
            style: OutlinedButton.styleFrom(
              foregroundColor: ScholarColors.accent,
              side: BorderSide(color: ScholarColors.accent),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
            ),
            child: Text('Clear Entire Week', style: ScholarStyles.sans(fontSize: 11, fontWeight: FontWeight.w500, letterSpacing: 1.5)),
          ),
        ],
      ),
    );
  }

  Widget _buildLayout() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 768;
          if (isWide) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(width: 300, child: _buildSidebar()),
                const SizedBox(width: 48),
                Expanded(child: _buildWeekGrid()),
              ],
            );
          } else {
            return Column(
              children: [
                _buildSidebar(),
                const SizedBox(height: 24),
                _buildWeekGrid(),
              ],
            );
          }
        },
      ),
    );
  }

  Widget _buildSidebar() {
    return GlassCard(
      padding: const EdgeInsets.all(32),
      borderRadius: 20,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Weekly Habits', style: ScholarStyles.serif(fontSize: 19, fontWeight: FontWeight.w600)),
          const SizedBox(height: 24),
          ...List.generate(_habitsList.length, (i) {
            _weeklyHabits.putIfAbsent(i, () => List.filled(7, false));
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_habitsList[i].toUpperCase(), style: ScholarStyles.sans(fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 1.5)),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(7, (d) {
                      return Column(
                        children: [
                          GestureDetector(
                            onTap: () => _onHabitChanged(i, d, !_weeklyHabits[i]![d]),
                            child: Text(_dayLabels[d], style: ScholarStyles.sans(fontSize: 9, color: ScholarColors.textMuted, letterSpacing: 0.5)),
                          ),
                          const SizedBox(height: 5),
                          SizedBox(
                            width: 16,
                            height: 16,
                            child: Checkbox(
                              value: _weeklyHabits[i]![d],
                              onChanged: (v) => _onHabitChanged(i, d, v ?? false),
                              activeColor: ScholarColors.accent,
                              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              visualDensity: VisualDensity.compact,
                            ),
                          ),
                        ],
                      );
                    }),
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: 24),
          Text(
            '\u201cSuccess is the sum of small efforts, repeated day in and day out.\u201d',
            style: ScholarStyles.serif(fontSize: 12, fontStyle: FontStyle.italic, color: ScholarColors.textMuted, height: 1.6),
          ),
        ],
      ),
    );
  }

  Widget _buildWeekGrid() {
    return Wrap(
      spacing: 24,
      runSpacing: 24,
      children: List.generate(_daysOfWeek.length, (i) {
        final day = _daysOfWeek[i];
        _weeklyPlan.putIfAbsent(day, () => '');
        final borderColor = ScholarColors.dayBorderColors[i];
        return SizedBox(
          width: 280,
          child: GlassCard(
            padding: const EdgeInsets.all(28),
            borderRadius: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  decoration: BoxDecoration(
                    border: Border(top: BorderSide(color: borderColor, width: 3)),
                  ),
                  padding: const EdgeInsets.only(top: 12),
                  child: Text(day, style: ScholarStyles.serif(fontSize: 22, fontWeight: FontWeight.w600, letterSpacing: -0.01)),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: TextField(
                    controller: _dayControllers[day],
                    onChanged: (v) => _onPlanChanged(day, v),
                    maxLines: null,
                    expands: true,
                    textAlignVertical: TextAlignVertical.top,
                    style: ScholarStyles.sans(fontSize: 14, height: 1.7),
                    decoration: InputDecoration(
                      hintText: 'List your goals and tasks for $day',
                      hintStyle: ScholarStyles.sans(fontSize: 14, color: ScholarColors.textMuted, fontStyle: FontStyle.italic),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}
