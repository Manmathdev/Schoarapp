import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme.dart';
import '../widgets/glass_card.dart';
import '../widgets/scholar_header.dart';
import '../widgets/scholar_footer.dart';
import '../widgets/background_orbs.dart';
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

  // Set once per build() call; helper methods below read this rather than
  // each calling Theme.of(context) independently, since they're all
  // invoked synchronously within the same build pass.
  late ScholarPalette _palette;

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
    _palette = context.palette;
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            const BackgroundOrbs(page: 'dashboard'),
            Column(
              children: [
                const ScholarHeader(currentRoute: '/'),
                Expanded(
                  child: _buildBody(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return Center(
        child: CircularProgressIndicator(color: _palette.accent),
      );
    }
    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline, size: 48, color: _palette.statusRevision),
              const SizedBox(height: 16),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: ScholarStyles.sans(color: _palette.textSecondary),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _loadData,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }
    return RefreshIndicator(
      color: _palette.accent,
      onRefresh: _loadData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [
            const SizedBox(height: 40),
            _buildDashboardHeader(),
            const SizedBox(height: 48),
            _buildWidgetGrid(),
            const ScholarFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Text(
            'CLASS 12 CURRICULUM',
            style: ScholarStyles.sans(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 4,
              color: _palette.accent,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Welcome back.',
            textAlign: TextAlign.center,
            style: ScholarStyles.serif(
              fontSize: 52,
              fontWeight: FontWeight.w500,
              letterSpacing: -0.03,
              height: 1.1,
              color: _palette.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              'Focus on the syllabus. Master the fundamentals. Build your future.',
              textAlign: TextAlign.center,
              style: ScholarStyles.sans(
                fontSize: 16,
                fontWeight: FontWeight.w300,
                color: _palette.textSecondary,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Container(
            width: 40,
            height: 2,
            color: _palette.accent,
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
                const SizedBox(width: 32),
                Expanded(flex: 10, child: _buildTheHorizon()),
              ],
            );
          } else {
            return Column(
              children: [
                _buildTodayObjectives(),
                const SizedBox(height: 24),
                _buildTheHorizon(),
              ],
            );
          }
        },
      ),
    );
  }

  Widget _buildTodayObjectives() {
    return GlassCard(
      padding: const EdgeInsets.all(40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Today's Objectives",
            style: ScholarStyles.serif(fontSize: 20, fontWeight: FontWeight.w600, letterSpacing: -0.01, color: _palette.textPrimary),
          ),
          const SizedBox(height: 28),
          ...List.generate(5, (i) {
            final task = _dailyTasks[i];
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
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
                          child: Transform.scale(
                            scale: 1.15,
                            child: Checkbox(
                              value: task.done,
                              onChanged: (v) => _onDailyTaskChanged(i, done: v),
                              activeColor: _palette.accent,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: TextField(
                        controller: _controllers[i],
                        onChanged: (v) => _onDailyTaskChanged(i, text: v),
                        style: ScholarStyles.sans(
                          fontSize: 15,
                          fontWeight: FontWeight.w400,
                          color: task.done ? _palette.textMuted : _palette.textPrimary,
                          decoration: task.done ? TextDecoration.lineThrough : TextDecoration.none,
                        ),
                        decoration: InputDecoration(
                          hintText: 'What needs to be done today?',
                          hintStyle: ScholarStyles.sans(
                            fontSize: 15,
                            fontWeight: FontWeight.w300,
                            color: _palette.textMuted,
                            fontStyle: FontStyle.italic,
                          ),
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
    return GlassCard(
      padding: const EdgeInsets.all(40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'The Horizon',
            style: ScholarStyles.serif(fontSize: 20, fontWeight: FontWeight.w600, letterSpacing: -0.01, color: _palette.textPrimary),
          ),
          const SizedBox(height: 28),
          _buildCountdownSection(
            _remainingChapters.toString(),
            'Chapters Remaining to Master',
          ),
          const SizedBox(height: 28),
          _buildCountdownSection(
            _daysUntilExam.toString(),
            'Days until Board Exams',
            light: true,
          ),
          const SizedBox(height: 24),
          Divider(color: _palette.textMuted.withOpacity(0.15)),
          const SizedBox(height: 24),
          Text(
            '\u201cDiscipline is simply choosing between what you want now and what you want most.\u201d',
            style: ScholarStyles.serif(
              fontSize: 15,
              fontStyle: FontStyle.italic,
              color: _palette.textMuted,
              height: 1.7,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCountdownSection(String number, String label, {bool light = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          number,
          style: ScholarStyles.serif(
            fontSize: 51,
            fontWeight: FontWeight.w500,
            letterSpacing: -0.03,
            height: 1,
            color: light ? _palette.textPrimary : _palette.accent,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label.toUpperCase(),
          style: ScholarStyles.sans(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            letterSpacing: 2.5,
            color: _palette.textSecondary,
          ),
        ),
      ],
    );
  }
}
