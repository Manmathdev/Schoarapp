import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme.dart';
import '../widgets/glass_card.dart';
import '../widgets/scholar_header.dart';
import '../widgets/scholar_footer.dart';
import '../widgets/scholar_dialog.dart';
import '../services/data_service.dart';
import '../models/resource.dart';

class ResourcesPage extends StatefulWidget {
  const ResourcesPage({super.key});

  @override
  State<ResourcesPage> createState() => _ResourcesPageState();
}

class _ResourcesPageState extends State<ResourcesPage> {
  final DataService _dataService = DataService();
  bool _isLoading = true;
  String? _errorMessage;
  late List<Resource> _resources;
  String _currentFilter = 'all';

  final _titleController = TextEditingController();
  final _urlController = TextEditingController();
  String _selectedSubject = 'Physics';
  String _selectedType = 'Video';

  @override
  void initState() {
    super.initState();
    _loadResources();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _urlController.dispose();
    super.dispose();
  }

  Future<void> _loadResources() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final resources = await _dataService.getResources();
      setState(() {
        _resources = resources;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load resources: $e';
        _isLoading = false;
      });
    }
  }

  void _setFilter(String filter) {
    setState(() => _currentFilter = filter);
  }

  Future<void> _openLink(String url) async {
    if (url == '/archive') {
      Navigator.pushNamed(context, '/archive');
      return;
    }
    final uri = Uri.tryParse(url);
    if (uri == null || !uri.hasScheme) {
      if (mounted) setState(() => _errorMessage = 'This link is not valid.');
      return;
    }
    try {
      final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!launched && mounted) setState(() => _errorMessage = 'Could not open link.');
    } catch (e) {
      if (mounted) setState(() => _errorMessage = 'Could not open link: $e');
    }
  }

  void _addResource() {
    final title = _titleController.text.trim();
    final url = _urlController.text.trim();

    if (title.isEmpty || url.isEmpty) {
      _showAlert('Please enter both a title and a valid URL.');
      return;
    }
    final sanitizedUrl = _validateUrl(url);
    if (sanitizedUrl == null) {
      _showAlert('Please enter a valid HTTP or HTTPS URL.');
      return;
    }

    final newResource = Resource(
      id: DateTime.now().millisecondsSinceEpoch,
      title: title,
      url: sanitizedUrl,
      subject: _selectedSubject,
      type: _selectedType,
    );

    HapticFeedback.lightImpact();
    setState(() => _resources.add(newResource));
    _dataService.saveResources(_resources).catchError((e) {
      if (mounted) setState(() => _errorMessage = 'Failed to save: $e');
    });
    _titleController.clear();
    _urlController.clear();
  }

  void _deleteResource(int id) {
    showScholarDialog(
      context: context,
      title: 'Remove Resource',
      content: 'Remove this link from your library?',
      actions: [
        ScholarDialogAction(label: 'Cancel', onPressed: () => Navigator.pop(context)),
        ScholarDialogAction(
          label: 'Remove',
          isDestructiveOrPrimary: true,
          onPressed: () async {
            Navigator.pop(context);
            setState(() => _resources.removeWhere((r) => r.id == id));
            try {
              await _dataService.saveResources(_resources);
            } catch (e) {
              if (mounted) setState(() => _errorMessage = 'Failed to save: $e');
            }
          },
        ),
      ],
    );
  }

  String? _validateUrl(String url) {
    url = url.trim();
    if (url.isEmpty) return null;
    final uri = Uri.tryParse(url);
    if (uri == null || !uri.hasScheme || !uri.hasAuthority) return null;
    if (uri.scheme != 'http' && uri.scheme != 'https') return null;
    return uri.toString();
  }

  void _showAlert(String message) {
    showScholarDialog(
      context: context,
      title: 'Heads up',
      content: message,
      actions: [ScholarDialogAction(label: 'OK', isDestructiveOrPrimary: true, onPressed: () => Navigator.pop(context))],
    );
  }

  Color _getSubjectColor(String subject) {
    final s = context.subjectColors;
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

  @override
  Widget build(BuildContext context) {
    final filtered = _resources.where((r) => _currentFilter == 'all' || r.subject == _currentFilter).toList();
    return Scaffold(
      appBar: const ScholarHeader(currentRoute: '/resources'),
      body: SafeArea(top: false, child: _buildBody(filtered)),
    );
  }

  Widget _buildBody(List<Resource> filtered) {
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
              FilledButton(onPressed: _loadResources, child: const Text('Retry')),
            ],
          ),
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: _loadResources,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [
            const SizedBox(height: 20),
            _buildPageHeader(),
            const SizedBox(height: 24),
            _buildLayout(filtered),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('LIBRARY', style: theme.textTheme.labelMedium?.copyWith(color: theme.colorScheme.primary, letterSpacing: 3)),
          const SizedBox(height: 8),
          Text('Digital Library', style: theme.textTheme.headlineMedium),
          const SizedBox(height: 4),
          Text('Curate your study materials. Find what you need, instantly.', style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
        ],
      ),
    );
  }

  Widget _buildLayout(List<Resource> resources) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 768;
        if (isWide) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(width: 300, child: _buildSidebar()),
                const SizedBox(width: 32),
                Expanded(child: _buildResourceGrid(resources)),
              ],
            ),
          );
        }
        return Column(
          children: [
            _buildMobileFilterChips(),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _buildResourceGrid(resources),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _buildAddResourceExpansion(),
            ),
          ],
        );
      },
    );
  }

  Widget _buildMobileFilterChips() {
    final filters = <(String, String)>[
      ('All Resources', 'all'),
      ('Physics', 'Physics'),
      ('Chemistry', 'Chemistry'),
      ('Mathematics', 'Mathematics'),
      ('English', 'English'),
      ('IT', 'IT'),
      ('Sanskrit', 'Sanskrit'),
      ('General', 'General'),
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
              avatar: filter == 'all' ? null : CircleAvatar(backgroundColor: _getSubjectColor(filter), radius: 5),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAddResourceExpansion() {
    final theme = Theme.of(context);
    return GlassCard(
      padding: EdgeInsets.zero,
      child: Theme(
        data: theme.copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
          childrenPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          title: Text('Save a Link', style: theme.textTheme.titleMedium),
          children: [
            _buildFormField('Resource Title', _titleController, hint: 'e.g., Physics PYQ Playlist'),
            const SizedBox(height: 14),
            _buildFormField('URL (Link)', _urlController, hint: 'https://...'),
            const SizedBox(height: 14),
            _buildDropdown('Subject', ['Physics', 'Chemistry', 'Mathematics', 'English', 'IT', 'Sanskrit', 'General'], _selectedSubject, (v) => setState(() => _selectedSubject = v!)),
            const SizedBox(height: 14),
            _buildDropdown('Format', ['Video', 'PDF', 'Website'], _selectedType, (v) => setState(() => _selectedType = v!)),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton(onPressed: _addResource, child: const Text('Save Resource')),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSidebar() {
    final theme = Theme.of(context);
    final s = context.subjectColors;
    return GlassCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Filter Library', style: theme.textTheme.titleLarge),
          const SizedBox(height: 14),
          _buildFilterItem('All Resources', 'all'),
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
          const SizedBox(height: 6),
          _buildFilterItem('General', 'General', color: s.general),
          const SizedBox(height: 20),
          Divider(color: theme.colorScheme.outlineVariant),
          const SizedBox(height: 20),
          Text('Save a Link', style: theme.textTheme.titleMedium),
          const SizedBox(height: 14),
          _buildFormField('Resource Title', _titleController, hint: 'e.g., Physics PYQ Playlist'),
          const SizedBox(height: 14),
          _buildFormField('URL (Link)', _urlController, hint: 'https://...'),
          const SizedBox(height: 14),
          _buildDropdown('Subject', ['Physics', 'Chemistry', 'Mathematics', 'English', 'IT', 'Sanskrit', 'General'], _selectedSubject, (v) => setState(() => _selectedSubject = v!)),
          const SizedBox(height: 14),
          _buildDropdown('Format', ['Video', 'PDF', 'Website'], _selectedType, (v) => setState(() => _selectedType = v!)),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton(onPressed: _addResource, child: const Text('Save Resource')),
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
                if (color != null) ...[CircleAvatar(backgroundColor: color, radius: 5), const SizedBox(width: 10)],
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

  Widget _buildFormField(String label, TextEditingController controller, {String? hint}) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(labelText: label, hintText: hint),
    );
  }

  Widget _buildDropdown(String label, List<String> options, String currentValue, ValueChanged<String?> onChanged) {
    return DropdownButtonFormField<String>(
      value: currentValue,
      decoration: InputDecoration(labelText: label),
      items: options.map((o) => DropdownMenuItem(value: o, child: Text(o))).toList(),
      onChanged: onChanged,
    );
  }

  Widget _buildResourceGrid(List<Resource> resources) {
    final theme = Theme.of(context);
    if (resources.isEmpty) {
      return GlassCard(
        padding: const EdgeInsets.all(40),
        child: Center(
          child: Column(
            children: [
              Text('No resources saved yet.', textAlign: TextAlign.center, style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
              const SizedBox(height: 6),
              Text('Use the form to add a link.', textAlign: TextAlign.center, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
            ],
          ),
        ),
      );
    }

    final reversed = resources.reversed.toList();
    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth;
        const spacing = 16.0;
        const minCardWidth = 300.0;
        final columns = (availableWidth / (minCardWidth + spacing)).floor().clamp(1, 4);
        final cardWidth = columns == 1 ? availableWidth : (availableWidth - spacing * (columns - 1)) / columns;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: reversed.map((r) => _buildResourceCard(theme, r, cardWidth)).toList(),
        );
      },
    );
  }

  Widget _buildResourceCard(ThemeData theme, Resource r, double cardWidth) {
    final tagColor = _getSubjectColor(r.subject);
    return SizedBox(
      width: cardWidth,
      child: GlassCard(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(r.subject, style: theme.textTheme.labelSmall?.copyWith(color: tagColor)),
                Chip(
                  label: Text(r.type.toUpperCase(), style: theme.textTheme.labelSmall),
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero,
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(r.title, style: theme.textTheme.titleMedium),
            const SizedBox(height: 12),
            Divider(color: theme.colorScheme.outlineVariant),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                OutlinedButton(
                  onPressed: () => _openLink(r.url),
                  child: Text(r.url == '/archive' ? 'Open Archive' : 'Open Link'),
                ),
                Semantics(
                  button: true,
                  label: 'Remove ${r.title} from resources',
                  child: TextButton(
                    onPressed: () => _deleteResource(r.id),
                    child: const Text('Remove'),
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
