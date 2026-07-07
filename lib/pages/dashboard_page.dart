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
      return const Center(
        child: CircularProgressIndicator(color: ScholarColors.accent),
      );
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
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: ScholarStyles.sans(color: ScholarColors.textSecondary),
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
      color: ScholarColors.accent,
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
              color: ScholarColors.accent,
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
                color: ScholarColors.textSecondary,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Container(
            width: 40,
            height: 2,
            color: ScholarColors.accent,
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
            style: ScholarStyles.serif(fontSize: 20, fontWeight: FontWeight.w600, letterSpacing: -0.01),
          ),
          const SizedBox(height: 28),
          ...List.generate(5, (i) {
            final task = _dailyTasks[i];
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: GlassCardSmall(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
                child: Row(
                  children: [
                    SizedBox(
                      width: 18,
                      height: 18,
                      child: Checkbox(
                        value: task.done,
                        onChanged: (v) => _onDailyTaskChanged(i, done: v),
                        activeColor: ScholarColors.accent,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        visualDensity: VisualDensity.compact,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: TextField(
                        controller: _controllers[i],
                        onChanged: (v) => _onDailyTaskChanged(i, text: v),
                        style: ScholarStyles.sans(
                          fontSize: 15,
                          fontWeight: FontWeight.w400,
                          color: task.done ? ScholarColors.textMuted : ScholarColors.textPrimary,
                          decoration: task.done ? TextDecoration.lineThrough : TextDecoration.none,
                        ),
                        decoration: InputDecoration(
                          hintText: 'What needs to be done today?',
                          hintStyle: ScholarStyles.sans(
                            fontSize: 15,
                            fontWeight: FontWeight.w300,
                            color: ScholarColors.textMuted,
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
            style: ScholarStyles.serif(fontSize: 20, fontWeight: FontWeight.w600, letterSpacing: -0.01),
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
          Divider(color: Colors.black.withOpacity(0.04)),
          const SizedBox(height: 24),
          Text(
            '\u201cDiscipline is simply choosing between what you want now and what you want most.\u201d',
            style: ScholarStyles.serif(
              fontSize: 15,
              fontStyle: FontStyle.italic,
              color: ScholarColors.textMuted,
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
            color: light ? ScholarColors.textPrimary : ScholarColors.accent,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label.toUpperCase(),
          style: ScholarStyles.sans(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            letterSpacing: 2.5,
            color: ScholarColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
