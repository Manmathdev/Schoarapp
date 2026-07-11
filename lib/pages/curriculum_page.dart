import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme.dart';
import '../widgets/glass_card.dart';
import '../widgets/scholar_header.dart';
import '../widgets/scholar_footer.dart';
import '../widgets/scholar_dialog.dart';
import '../services/data_service.dart';
import '../models/task.dart';

class CurriculumPage extends StatefulWidget {
  const CurriculumPage({super.key});

  @override
  State<CurriculumPage> createState() => _CurriculumPageState();
}

class _CurriculumPageState extends State<CurriculumPage> {
  final DataService _dataService = DataService();
  bool _isLoading = true;
  String? _errorMessage;
  late List<Task> _tasks;
  String _currentFilter = 'all';

  final Map<int, TextEditingController> _notesControllers = {};

  TextEditingController _notesControllerFor(Task task) {
    final existing = _notesControllers[task.id];
    if (existing != null) return existing;
    final controller = TextEditingController(text: task.notes);
    _notesControllers[task.id] = controller;
    return controller;
  }

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  @override
  void dispose() {
    for (final c in _notesControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _loadTasks() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final tasks = await _dataService.getTasks();
      setState(() {
        _tasks = tasks;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load curriculum: $e';
        _isLoading = false;
      });
    }
  }

  void _setFilter(String filter) {
    setState(() => _currentFilter = filter);
  }

  void _cycleStatus(int taskId) async {
    final idx = _tasks.indexWhere((t) => t.id == taskId);
    if (idx == -1) return;
    HapticFeedback.selectionClick();
    setState(() {
      _tasks[idx].status = _cycleStatusHelper(_tasks[idx].status);
    });
    try {
      await _dataService.saveTasks(_tasks);
    } catch (e) {
      if (mounted) {
        setState(() => _errorMessage = 'Failed to save: $e');
        _loadTasks();
      }
    }
  }

  String _cycleStatusHelper(String current) {
    const flow = ['Not Started', 'In Progress', 'Revision Needed', 'Mastered'];
    final idx = flow.indexOf(current);
    return flow[(idx + 1) % flow.length];
  }

  void _resetCurriculum() {
    showScholarDialog(
      context: context,
      title: 'Reset Curriculum',
      content: 'Are you sure you want to load the fresh 76-chapter syllabus? Any custom notes and status updates will be lost.',
      actions: [
        ScholarDialogAction(label: 'Cancel', onPressed: () => Navigator.pop(context)),
        ScholarDialogAction(
          label: 'Reset',
          isDestructiveOrPrimary: true,
          onPressed: () async {
            Navigator.pop(context);
            setState(() => _isLoading = true);
            try {
              await _dataService.resetCurriculum();
              final tasks = await _dataService.getTasks();
              for (final c in _notesControllers.values) {
                c.dispose();
              }
              _notesControllers.clear();
              setState(() {
                _tasks = tasks;
                _isLoading = false;
              });
            } catch (e) {
              setState(() {
                _errorMessage = 'Failed to reset: $e';
                _isLoading = false;
              });
            }
          },
        ),
      ],
    );
  }

  void _saveNotes(int taskId, String value) async {
    final idx = _tasks.indexWhere((t) => t.id == taskId);
    if (idx == -1) return;
    _tasks[idx].notes = value;
    try {
      await _dataService.saveTasks(_tasks);
    } catch (e) {
      if (mounted) setState(() => _errorMessage = 'Failed to save notes: $e');
    }
  }

  Color _getStatusColor(BuildContext context, String status) {
    final s = context.subjectColors;
    switch (status) {
      case 'Not Started': return s.statusNotStarted;
      case 'In Progress': return s.statusInProgress;
      case 'Revision Needed': return s.statusRevision;
      case 'Mastered': return s.statusMastered;
      default: return s.general;
    }
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _tasks.where((t) {
      if (_currentFilter == 'all') return t.status == 'In Progress';
      return t.subject == _currentFilter;
    }).toList();

    final pageTitle = _currentFilter == 'all' ? 'Active Dashboard' : '$_currentFilter Curriculum';
    final pageSubtitle = _currentFilter == 'all' ? 'Chapters currently in progress.' : 'Complete syllabus breakdown.';

    return Scaffold(
      appBar: const ScholarHeader(currentRoute: '/curriculum'),
      body: SafeArea(top: false, child: _buildBody(pageTitle, pageSubtitle, filtered)),
    );
  }

  Widget _buildBody(String title, String subtitle, List<Task> filtered) {
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
              FilledButton(onPressed: _loadTasks, child: const Text('Retry')),
            ],
          ),
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: _loadTasks,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [
            const SizedBox(height: 20),
            _buildPageHeader(title, subtitle),
            const SizedBox(height: 24),
            _buildLayout(filtered),
            const ScholarFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildPageHeader(String title, String subtitle) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text('SYLLABUS', textAlign: TextAlign.center, style: theme.textTheme.labelMedium?.copyWith(color: theme.colorScheme.primary, letterSpacing: 3)),
          const SizedBox(height: 8),
          Text(title, textAlign: TextAlign.center, style: theme.textTheme.headlineMedium),
          const SizedBox(height: 4),
          Text(subtitle, textAlign: TextAlign.center, style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
        ],
      ),
    );
  }

  Widget _buildLayout(List<Task> filtered) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 768;
        if (isWide) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(width: 260, child: _buildSidebar()),
                const SizedBox(width: 32),
                Expanded(child: _buildTaskGrid(filtered)),
              ],
            ),
          );
        }
        return Column(
          children: [
            _buildMobileFilterChips(),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: TextButton.icon(
                  onPressed: _resetCurriculum,
                  icon: const Icon(Icons.refresh, size: 16),
                  label: const Text('Reset Curriculum'),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _buildTaskGrid(filtered),
            ),
          ],
        );
      },
    );
  }

  Widget _buildMobileFilterChips() {
    final s = context.subjectColors;
    final filters = <(String, String)>[
      ('All Active', 'all'),
      ('Physics', 'Physics'),
      ('Chemistry', 'Chemistry'),
      ('Mathematics', 'Mathematics'),
      ('English', 'English'),
      ('IT', 'IT'),
      ('Sanskrit', 'Sanskrit'),
    ];
    return SizedBox(
      height: ScholarTokens.minTouchTarget,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: filters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final (label, filter) = filters[i];
          final isActive = _currentFilter == filter;
          return Semantics(
            button: true,
            selected: isActive,
            label: 'Filter by $label',
            child: ChoiceChip(
              label: Text(label),
              selected: isActive,
              onSelected: (_) => _setFilter(filter),
              avatar: filter == 'all' ? null : CircleAvatar(backgroundColor: _colorForSubject(s, filter), radius: 5),
            ),
          );
        },
      ),
    );
  }

  Color _colorForSubject(ScholarSubjectColors s, String subject) {
    switch (subject) {
      case 'Physics': return s.physics;
      case 'Chemistry': return s.chemistry;
      case 'Mathematics': return s.mathematics;
      case 'English': return s.english;
      case 'IT': return s.it;
      case 'Sanskrit': return s.sanskrit;
      default: return s.general;
    }
  }

  Widget _buildSidebar() {
    final theme = Theme.of(context);
    final s = context.subjectColors;
    return GlassCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Curriculum', style: theme.textTheme.titleLarge),
          const SizedBox(height: 20),
          _buildFilterItem('All Active', 'all'),
          const SizedBox(height: 6),
          _buildFilterItem('Physics', 'Physics', color: s.physics),
          const SizedBox(height: 6),
          _buildFilterItem('Chemistry', 'Chemistry', color: s.chemistry),
          const SizedBox(height: 6),
          _buildFilterItem('Mathematics', 'Mathematics', color: s.mathematics),
          const SizedBox(height: 6),
          _buildFilterItem('English', 'English', color: s.english),
          const SizedBox(height: 6),
          _buildFilterItem('IT', 'IT', color: s.it),
          const SizedBox(height: 6),
          _buildFilterItem('Sanskrit', 'Sanskrit', color: s.sanskrit),
          const SizedBox(height: 24),
          Text('System', style: theme.textTheme.titleMedium),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _resetCurriculum,
              icon: const Icon(Icons.refresh, size: 16),
              label: const Text('Reset / Reload Curriculum'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterItem(String label, String filter, {Color? color}) {
    final isActive = _currentFilter == filter;
    final theme = Theme.of(context);
    return Semantics(
      button: true,
      selected: isActive,
      child: Material(
        color: isActive ? theme.colorScheme.secondaryContainer : Colors.transparent,
        borderRadius: BorderRadius.circular(ScholarTokens.shapeSM),
        child: InkWell(
          borderRadius: BorderRadius.circular(ScholarTokens.shapeSM),
          onTap: () => _setFilter(filter),
          child: Container(
            width: double.infinity,
            constraints: const BoxConstraints(minHeight: ScholarTokens.minTouchTarget),
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                if (color != null) ...[
                  CircleAvatar(backgroundColor: color, radius: 5),
                  const SizedBox(width: 10),
                ],
                Text(
                  label,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                    color: isActive ? theme.colorScheme.onSecondaryContainer : theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTaskGrid(List<Task> tasks) {
    final theme = Theme.of(context);
    if (tasks.isEmpty) {
      final emptyMessage = _currentFilter == 'all'
          ? 'No chapters in progress.\nSelect a subject to update a chapter to "In Progress".'
          : 'All chapters accounted for.';
      return GlassCard(
        padding: const EdgeInsets.all(40),
        child: Center(
          child: Text(emptyMessage, textAlign: TextAlign.center, style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        // On narrow (phone) widths, a single full-width column reads far
        // better than a fixed 300px card with wasted margin beside it. On
        // wider screens, fit as many 300px-ish columns as the space allows.
        final availableWidth = constraints.maxWidth;
        const spacing = 16.0;
        const minCardWidth = 300.0;
        final columns = (availableWidth / (minCardWidth + spacing)).floor().clamp(1, 4);
        final cardWidth = columns == 1 ? availableWidth : (availableWidth - spacing * (columns - 1)) / columns;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: tasks.map((task) => _buildTaskCard(theme, task, cardWidth)).toList(),
        );
      },
    );
  }

  Widget _buildTaskCard(ThemeData theme, Task task, double cardWidth) {
    final isMastered = task.status == 'Mastered';
    return SizedBox(
      width: cardWidth,
      child: GlassCard(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(border: Border(left: BorderSide(color: task.colorValue, width: 3))),
              padding: const EdgeInsets.only(left: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(task.subject.toUpperCase(), style: theme.textTheme.labelSmall?.copyWith(color: task.colorValue)),
                  const SizedBox(height: 4),
                  Text(task.title, style: theme.textTheme.titleMedium),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _notesControllerFor(task),
                    onChanged: (v) => _saveNotes(task.id, v),
                    maxLines: 3,
                    style: theme.textTheme.bodySmall,
                    decoration: const InputDecoration(
                      hintText: 'Add study notes, formulas, or page numbers...',
                      filled: false,
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Divider(color: theme.colorScheme.outlineVariant),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(task.status.toUpperCase(), style: theme.textTheme.labelSmall?.copyWith(color: _getStatusColor(context, task.status))),
                Semantics(
                  button: true,
                  label: isMastered ? 'Chapter mastered' : 'Update status, currently ${task.status}',
                  child: isMastered
                      ? TonalActionChip(label: 'Done', onTap: () => _cycleStatus(task.id))
                      : FilledButton.tonal(
                          onPressed: () => _cycleStatus(task.id),
                          style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 16)),
                          child: const Text('Update Status'),
                        ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Small helper chip-button used for the "Done" state where a full
/// FilledButton.tonal would look too prominent for a completed item.
class TonalActionChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const TonalActionChip({super.key, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return TextButton(
      onPressed: onTap,
      style: TextButton.styleFrom(
        backgroundColor: colors.surfaceContainerHighest,
        foregroundColor: colors.onSurfaceVariant,
        padding: const EdgeInsets.symmetric(horizontal: 16),
      ),
      child: Text(label),
    );
  }
}
