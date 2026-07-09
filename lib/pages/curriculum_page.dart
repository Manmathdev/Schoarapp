import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme.dart';
import '../widgets/glass_card.dart';
import '../widgets/scholar_header.dart';
import '../widgets/scholar_footer.dart';
import '../widgets/background_orbs.dart';
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

  // Persistent per-task controllers, keyed by task id, so rebuilds (from
  // status changes, filter changes, etc.) don't reset cursor position or
  // interrupt typing in the notes field.
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

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Not Started':
        return ScholarColors.statusNotStarted;
      case 'In Progress':
        return ScholarColors.statusInProgress;
      case 'Revision Needed':
        return ScholarColors.statusRevision;
      case 'Mastered':
        return ScholarColors.statusMastered;
      default:
        return ScholarColors.textMuted;
    }
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _tasks.where((t) {
      if (_currentFilter == 'all') return t.status == 'In Progress';
      return t.subject == _currentFilter;
    }).toList();

    final pageTitle = _currentFilter == 'all' ? 'Active Dashboard' : '$_currentFilter Curriculum';
    final pageSubtitle = _currentFilter == 'all'
        ? 'Chapters currently in progress.'
        : 'Complete syllabus breakdown.';

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            const BackgroundOrbs(page: 'curriculum'),
            Column(
              children: [
                const ScholarHeader(currentRoute: '/curriculum'),
                Expanded(child: _buildBody(pageTitle, pageSubtitle, filtered)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(String title, String subtitle, List<Task> filtered) {
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
              Text(_errorMessage!, textAlign: TextAlign.center, style: ScholarStyles.sans(color: ScholarColors.textSecondary)),
              const SizedBox(height: 24),
              ElevatedButton(onPressed: _loadTasks, child: const Text('Retry')),
            ],
          ),
        ),
      );
    }
    return RefreshIndicator(
      color: ScholarColors.accent,
      onRefresh: _loadTasks,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [
            const SizedBox(height: 24),
            _buildPageHeader(title, subtitle),
            const SizedBox(height: 32),
            _buildLayout(filtered),
            const ScholarFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildPageHeader(String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Text('SYLLABUS', style: ScholarStyles.sans(fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 4, color: ScholarColors.accent)),
          const SizedBox(height: 12),
          Text(title, textAlign: TextAlign.center, style: ScholarStyles.serif(fontSize: 56, fontWeight: FontWeight.w500, letterSpacing: -0.03, height: 1.1)),
          const SizedBox(height: 8),
          Text(subtitle, textAlign: TextAlign.center, style: ScholarStyles.sans(fontSize: 16, fontWeight: FontWeight.w300, color: ScholarColors.textSecondary)),
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
                const SizedBox(width: 48),
                Expanded(child: _buildTaskGrid(filtered)),
              ],
            ),
          );
        }
        // On phones, a tall vertical filter sidebar sitting above the task
        // grid forces a lot of scrolling before reaching any content. A
        // horizontal scrolling chip row keeps filters reachable with a
        // thumb swipe while getting out of the way of the actual tasks.
        return Column(
          children: [
            _buildMobileFilterChips(),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: TextButton.icon(
                  onPressed: _resetCurriculum,
                  icon: Icon(Icons.refresh, size: 14, color: ScholarColors.textMuted),
                  label: Text(
                    'Reset Curriculum',
                    style: ScholarStyles.sans(fontSize: 11, fontWeight: FontWeight.w500, color: ScholarColors.textMuted),
                  ),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    minimumSize: const Size(0, ScholarTokens.minTouchTarget),
                    tapTargetSize: MaterialTapTargetSize.padded,
                  ),
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
    final filters = <(String, String, Color?)>[
      ('All Active', 'all', null),
      ('Physics', 'Physics', ScholarColors.physics),
      ('Chemistry', 'Chemistry', ScholarColors.chemistry),
      ('Mathematics', 'Mathematics', ScholarColors.mathematics),
      ('English', 'English', ScholarColors.english),
      ('IT', 'IT', ScholarColors.it),
      ('Sanskrit', 'Sanskrit', ScholarColors.sanskrit),
    ];
    return SizedBox(
      height: ScholarTokens.minTouchTarget,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: filters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final (label, filter, color) = filters[i];
          final isActive = _currentFilter == filter;
          return Semantics(
            button: true,
            selected: isActive,
            label: 'Filter by $label',
            child: GestureDetector(
              onTap: () => _setFilter(filter),
              child: AnimatedContainer(
                duration: ScholarTokens.motionMedium,
                curve: ScholarTokens.motionCurve,
                height: ScholarTokens.minTouchTarget,
                padding: const EdgeInsets.symmetric(horizontal: 18),
                decoration: BoxDecoration(
                  color: isActive ? ScholarColors.accent : ScholarColors.glassBg,
                  borderRadius: BorderRadius.circular(50),
                  border: Border.all(
                    color: isActive ? ScholarColors.accent : ScholarColors.glassBorder,
                    width: isActive ? 1.5 : 1,
                  ),
                ),
                child: Center(
                  child: Text(
                    label,
                    style: ScholarStyles.sans(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isActive
                          ? Colors.white
                          : (color ?? ScholarColors.textSecondary),
                    ),
                  ),
                ),
              ),
            ),
          );
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
          Text('Curriculum', style: ScholarStyles.serif(fontSize: 19, fontWeight: FontWeight.w600)),
          const SizedBox(height: 24),
          _buildFilterItem('All Active', 'all'),
          const SizedBox(height: 8),
          _buildFilterItem('Physics', 'Physics', color: ScholarColors.physics),
          const SizedBox(height: 8),
          _buildFilterItem('Chemistry', 'Chemistry', color: ScholarColors.chemistry),
          const SizedBox(height: 8),
          _buildFilterItem('Mathematics', 'Mathematics', color: ScholarColors.mathematics),
          const SizedBox(height: 8),
          _buildFilterItem('English', 'English', color: ScholarColors.english),
          const SizedBox(height: 8),
          _buildFilterItem('IT', 'IT', color: ScholarColors.it),
          const SizedBox(height: 8),
          _buildFilterItem('Sanskrit', 'Sanskrit', color: ScholarColors.sanskrit),
          const SizedBox(height: 32),
          Text('System', style: ScholarStyles.serif(fontSize: 17, fontWeight: FontWeight.w600)),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: _resetCurriculum,
              style: OutlinedButton.styleFrom(
                foregroundColor: ScholarColors.textMuted,
                side: BorderSide(color: ScholarColors.textMuted),
                padding: const EdgeInsets.symmetric(vertical: 10),
                minimumSize: const Size(0, ScholarTokens.minTouchTarget),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: Text('Reset / Reload Curriculum', style: ScholarStyles.sans(fontSize: 11, fontWeight: FontWeight.w500, color: ScholarColors.textMuted)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterItem(String label, String filter, {Color? color}) {
    final isActive = _currentFilter == filter;
    return Semantics(
      button: true,
      selected: isActive,
      child: GestureDetector(
        onTap: () => _setFilter(filter),
        child: Container(
          width: double.infinity,
          constraints: const BoxConstraints(minHeight: ScholarTokens.minTouchTarget),
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: isActive ? ScholarColors.white30 : ScholarColors.glassBg,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            label,
            style: ScholarStyles.sans(
              fontSize: 13,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
              color: color ?? (isActive ? ScholarColors.textPrimary : ScholarColors.textSecondary),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTaskGrid(List<Task> tasks) {
    if (tasks.isEmpty) {
      final emptyMessage = _currentFilter == 'all'
          ? 'No chapters in progress.\nSelect a subject to update a chapter to "In Progress".'
          : 'All chapters accounted for.';
      return GlassCard(
        padding: const EdgeInsets.all(48),
        borderRadius: 20,
        child: Center(
          child: Text(emptyMessage, textAlign: TextAlign.center, style: ScholarStyles.serif(fontSize: 19, color: ScholarColors.textMuted)),
        ),
      );
    }

    return Wrap(
      spacing: 24,
      runSpacing: 24,
      children: tasks.map((task) {
        final isMastered = task.status == 'Mastered';
        return SizedBox(
          width: 300,
          child: GlassCard(
            padding: const EdgeInsets.all(28),
            borderRadius: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  decoration: BoxDecoration(
                    border: Border(left: BorderSide(color: task.colorValue, width: 3)),
                  ),
                  padding: const EdgeInsets.only(left: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(task.subject.toUpperCase(), style: ScholarStyles.sans(fontSize: 10, fontWeight: FontWeight.w600, letterSpacing: 1.5, color: task.colorValue)),
                      const SizedBox(height: 4),
                      Text(
                        task.title,
                        style: ScholarStyles.serif(fontSize: 17, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _notesControllerFor(task),
                        onChanged: (v) => _saveNotes(task.id, v),
                        maxLines: 3,
                        style: ScholarStyles.sans(fontSize: 13, color: ScholarColors.textSecondary, height: 1.5),
                        decoration: InputDecoration(
                          hintText: 'Add study notes, formulas, or page numbers...',
                          hintStyle: ScholarStyles.sans(fontSize: 13, color: ScholarColors.textMuted, fontStyle: FontStyle.italic),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Divider(color: Colors.black.withOpacity(0.05)),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(task.status.toUpperCase(), style: ScholarStyles.sans(fontSize: 10, fontWeight: FontWeight.w600, letterSpacing: 1.5, color: _getStatusColor(task.status))),
                    Semantics(
                      button: true,
                      label: isMastered ? 'Chapter mastered' : 'Update status, currently ${task.status}',
                      child: TextButton(
                        onPressed: () => _cycleStatus(task.id),
                        style: TextButton.styleFrom(
                          backgroundColor: isMastered ? Colors.black.withOpacity(0.05) : ScholarColors.accentSoft,
                          foregroundColor: isMastered ? ScholarColors.textMuted : ScholarColors.accent,
                          padding: const EdgeInsets.symmetric(horizontal: 19, vertical: 8),
                          minimumSize: const Size(64, ScholarTokens.minTouchTarget),
                          tapTargetSize: MaterialTapTargetSize.padded,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
                        ),
                        child: Text(
                          isMastered ? 'Done' : 'Update Status',
                          style: ScholarStyles.sans(fontSize: 10, fontWeight: FontWeight.w600, letterSpacing: 1.5),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
