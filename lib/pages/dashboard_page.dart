import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme.dart';
import '../widgets/glass_card.dart';
import '../widgets/scholar_header.dart';
import '../widgets/scholar_footer.dart';
import '../services/data_service.dart';
import '../models/daily_task_item.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final DataService _dataService = DataService();
  bool _isLoading = true;
  String? _errorMessage;
  List<DailyTaskItem> _dailyTasks = [];
  int _remainingChapters = 0;
  int _daysUntilExam = 0;

  final List<TextEditingController> _controllers =
      List.generate(5, (_) => TextEditingController());

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    for (final c in _controllers) {
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
      final tasks = await _dataService.getTasks();
      final dailyTasks = await _dataService.getDailyTasks();
      final remaining = tasks.where((t) => t.status != 'Mastered').length;
      final examDate = DateTime(2027, 2, 18);
      final days = examDate.difference(DateTime.now()).inDays.clamp(0, 9999);
      setState(() {
        _dailyTasks = dailyTasks;
        _remainingChapters = remaining;
        _daysUntilExam = days;
        _isLoading = false;
      });
      for (var i = 0; i < 5 && i < _dailyTasks.length; i++) {
        _controllers[i].text = _dailyTasks[i].text;
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load dashboard data: $e';
        _isLoading = false;
      });
    }
  }

  void _onDailyTaskChanged(int index, {String? text, bool? done}) async {
    if (done != null) HapticFeedback.selectionClick();
    setState(() {
      if (text != null) {
        _dailyTasks[index] = DailyTaskItem(text: text, done: _dailyTasks[index].done);
      }
      if (done != null) {
        _dailyTasks[index] = DailyTaskItem(text: _dailyTasks[index].text, done: done);
      }
    });
    try {
      await _dataService.saveDailyTasks(_dailyTasks);
    } catch (e) {
      if (mounted) {
        setState(() => _errorMessage = 'Failed to save: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const ScholarHeader(currentRoute: '/'),
      body: SafeArea(top: false, child: _buildBody()),
    );
  }

  Widget _buildBody() {
    final colors = Theme.of(context).colorScheme;
    if (_isLoading) {
      return Center(child: CircularProgressIndicator(color: colors.primary));
    }
    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline, size: 48, color: colors.error),
              const SizedBox(height: 16),
              Text(_errorMessage!, textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyMedium),
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
            const SizedBox(height: 32),
            _buildDashboardHeader(),
            const SizedBox(height: 32),
            _buildWidgetGrid(),
            const ScholarFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardHeader() {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('CLASS 12 CURRICULUM', style: theme.textTheme.labelMedium?.copyWith(color: colors.primary, letterSpacing: 3)),
          const SizedBox(height: 8),
          Text('Welcome back.', style: theme.textTheme.headlineLarge),
          const SizedBox(height: 8),
          Text(
            'Focus on the syllabus. Master the fundamentals. Build your future.',
            style: theme.textTheme.bodyLarge?.copyWith(color: colors.onSurfaceVariant),
          ),
        ],
      ),
    );
  }

  Widget _buildWidgetGrid() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 600;
          if (isWide) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 16, child: _buildTodayObjectives()),
                const SizedBox(width: 24),
                Expanded(flex: 10, child: _buildTheHorizon()),
              ],
            );
          }
          return Column(
            children: [
              _buildTodayObjectives(),
              const SizedBox(height: 20),
              _buildTheHorizon(),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTodayObjectives() {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return GlassCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Today's Objectives", style: theme.textTheme.titleLarge),
          const SizedBox(height: 20),
          ...List.generate(5, (i) {
            final task = _dailyTasks[i];
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: GlassCardSmall(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Row(
                  children: [
                    Semantics(
                      label: task.text.isEmpty ? 'Task checkbox' : '${task.text}, ${task.done ? 'completed' : 'not completed'}',
                      child: SizedBox(
                        width: ScholarTokens.minTouchTarget,
                        height: ScholarTokens.minTouchTarget,
                        child: Center(
                          child: Checkbox(
                            value: task.done,
                            onChanged: (v) => _onDailyTaskChanged(i, done: v),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: TextField(
                        controller: _controllers[i],
                        onChanged: (v) => _onDailyTaskChanged(i, text: v),
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: task.done ? colors.onSurfaceVariant : colors.onSurface,
                          decoration: task.done ? TextDecoration.lineThrough : TextDecoration.none,
                        ),
                        decoration: InputDecoration(
                          hintText: 'What needs to be done today?',
                          filled: false,
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(vertical: 4, horizontal: 5),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildTheHorizon() {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return GlassCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('The Horizon', style: theme.textTheme.titleLarge),
          const SizedBox(height: 20),
          _buildCountdownSection(_remainingChapters.toString(), 'Chapters Remaining to Master'),
          const SizedBox(height: 20),
          _buildCountdownSection(_daysUntilExam.toString(), 'Days until Board Exams', usePrimary: false),
          const SizedBox(height: 16),
          Divider(color: colors.outlineVariant),
          const SizedBox(height: 16),
          Text(
            '\u201cDiscipline is simply choosing between what you want now and what you want most.\u201d',
            style: theme.textTheme.bodyMedium?.copyWith(fontStyle: FontStyle.italic, color: colors.onSurfaceVariant),
          ),
        ],
      ),
    );
  }

  Widget _buildCountdownSection(String number, String label, {bool usePrimary = true}) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          number,
          style: theme.textTheme.displaySmall?.copyWith(color: usePrimary ? colors.primary : colors.onSurface),
        ),
        const SizedBox(height: 2),
        Text(label.toUpperCase(), style: theme.textTheme.labelMedium?.copyWith(color: colors.onSurfaceVariant)),
      ],
    );
  }
}
