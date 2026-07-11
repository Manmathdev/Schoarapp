import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme.dart';
import '../widgets/glass_card.dart';
import '../widgets/scholar_header.dart';
import '../widgets/scholar_footer.dart';
import '../widgets/scholar_dialog.dart';
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
    showScholarDialog(
      context: context,
      title: 'Clear Week',
      content: 'Clear your entire schedule and habit tracker?',
      actions: [
        ScholarDialogAction(label: 'Cancel', onPressed: () => Navigator.pop(context)),
        ScholarDialogAction(
          label: 'Clear',
          isDestructiveOrPrimary: true,
          onPressed: () async {
            Navigator.pop(context);
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
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const ScholarHeader(currentRoute: '/planner'),
      body: SafeArea(top: false, child: _buildBody()),
    );
  }

  Widget _buildBody() {
    final theme = Theme.of(context);
    if (_isLoading) {
      return Center(child: CircularProgressIndicator(color: theme.colorScheme.primary));
    }
    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline, size: 48, color: theme.colorScheme.error),
              const SizedBox(height: 16),
              Text(_errorMessage!, textAlign: TextAlign.center, style: theme.textTheme.bodyMedium),
              const SizedBox(height: 24),
              FilledButton(onPressed: _loadData, child: const Text('Retry')),
            ],
          ),
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: _loadData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [
            const SizedBox(height: 20),
            _buildPageHeader(),
            const SizedBox(height: 24),
            _buildLayout(),
            const ScholarFooter(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildPageHeader() {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('ARCHITECT', style: theme.textTheme.labelMedium?.copyWith(color: theme.colorScheme.primary, letterSpacing: 3)),
                    const SizedBox(height: 8),
                    Text('Weekly Architect', style: theme.textTheme.headlineMedium),
                    const SizedBox(height: 4),
                    Text('Design your week. Execute your plan.', style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerLeft,
            child: OutlinedButton.icon(
              onPressed: _clearWeek,
              icon: const Icon(Icons.delete_outline, size: 16),
              label: const Text('Clear Entire Week'),
            ),
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
                const SizedBox(width: 32),
                Expanded(child: _buildWeekGrid()),
              ],
            );
          }
          return Column(
            children: [
              _buildSidebar(),
              const SizedBox(height: 20),
              _buildWeekGrid(),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSidebar() {
    final theme = Theme.of(context);
    return GlassCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Weekly Habits', style: theme.textTheme.titleLarge),
          const SizedBox(height: 20),
          ...List.generate(_habitsList.length, (i) {
            _weeklyHabits.putIfAbsent(i, () => List.filled(7, false));
            return Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_habitsList[i].toUpperCase(), style: theme.textTheme.labelMedium),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(7, (d) {
                      final isChecked = _weeklyHabits[i]![d];
                      return Expanded(
                        child: Semantics(
                          button: true,
                          checked: isChecked,
                          label: '${_habitsList[i]} on ${_dayLabels[d]}',
                          child: InkWell(
                            borderRadius: BorderRadius.circular(ScholarTokens.shapeSM),
                            onTap: () {
                              HapticFeedback.selectionClick();
                              _onHabitChanged(i, d, !isChecked);
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 6),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(_dayLabels[d], style: theme.textTheme.labelSmall),
                                  const SizedBox(height: 4),
                                  IgnorePointer(
                                    child: Checkbox(
                                      value: isChecked,
                                      onChanged: (v) => _onHabitChanged(i, d, v ?? false),
                                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                      visualDensity: VisualDensity.compact,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: 12),
          Text(
            '\u201cSuccess is the sum of small efforts, repeated day in and day out.\u201d',
            style: theme.textTheme.bodySmall?.copyWith(fontStyle: FontStyle.italic, color: theme.colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }

  Widget _buildWeekGrid() {
    final theme = Theme.of(context);
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: List.generate(_daysOfWeek.length, (i) {
        final day = _daysOfWeek[i];
        _weeklyPlan.putIfAbsent(day, () => '');
        final borderColor = context.subjectColors.dayBorderColors[i];
        return SizedBox(
          width: 280,
          height: 250,
          child: GlassCard(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  decoration: BoxDecoration(border: Border(top: BorderSide(color: borderColor, width: 3))),
                  padding: const EdgeInsets.only(top: 10),
                  child: Text(day, style: theme.textTheme.titleLarge),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: TextField(
                    controller: _dayControllers[day],
                    onChanged: (v) => _onPlanChanged(day, v),
                    maxLines: null,
                    expands: true,
                    textAlignVertical: TextAlignVertical.top,
                    style: theme.textTheme.bodyMedium,
                    decoration: InputDecoration(
                      hintText: 'List your goals and tasks for $day',
                      filled: false,
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
