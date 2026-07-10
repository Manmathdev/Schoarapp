import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme.dart';
import '../widgets/glass_card.dart';
import '../widgets/scholar_header.dart';
import '../widgets/scholar_footer.dart';
import '../widgets/background_orbs.dart';
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

  // Set once per build() call; helper methods below read this rather than
  // each calling Theme.of(context) independently, since they're all
  // invoked synchronously within the same build pass.
  late ScholarPalette _palette;

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
    // Internal in-app destinations (e.g. the bundled PYQ archive) are routed
    // natively instead of being treated as web links.
    if (url == '/archive') {
      Navigator.pushNamed(context, '/archive');
      return;
    }
    final uri = Uri.tryParse(url);
    if (uri == null || !uri.hasScheme) {
      if (mounted) {
        setState(() => _errorMessage = 'This link is not valid.');
      }
      return;
    }
    try {
      final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!launched && mounted) {
        setState(() => _errorMessage = 'Could not open link.');
      }
    } catch (e) {
      if (mounted) {
        setState(() => _errorMessage = 'Could not open link: $e');
      }
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
    setState(() {
      _resources.add(newResource);
    });
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
      actions: [
        ScholarDialogAction(label: 'OK', isDestructiveOrPrimary: true, onPressed: () => Navigator.pop(context)),
      ],
    );
  }

  Color _getSubjectColor(String subject) {
    switch (subject) {
      case 'Physics': return _palette.physics;
      case 'Chemistry': return _palette.chemistry;
      case 'Mathematics': return _palette.mathematics;
      case 'English': return _palette.english;
      case 'IT': return _palette.it;
      case 'Sanskrit': return _palette.sanskrit;
      default: return _palette.textMuted;
    }
  }

  @override
  Widget build(BuildContext context) {
    _palette = context.palette;
    final filtered = _resources.where((r) {
      if (_currentFilter == 'all') return true;
      return r.subject == _currentFilter;
    }).toList();

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            const BackgroundOrbs(page: 'resources'),
            Column(
              children: [
                const ScholarHeader(currentRoute: '/resources'),
                Expanded(child: _buildBody(filtered)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(List<Resource> filtered) {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator(color: _palette.accent));
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
              Text(_errorMessage!, textAlign: TextAlign.center, style: ScholarStyles.sans(color: _palette.textSecondary)),
              const SizedBox(height: 24),
              ElevatedButton(onPressed: _loadResources, child: const Text('Retry')),
            ],
          ),
        ),
      );
    }
    return RefreshIndicator(
      color: _palette.accent,
      onRefresh: _loadResources,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [
            const SizedBox(height: 24),
            _buildPageHeader(),
            const SizedBox(height: 32),
            _buildLayout(filtered),
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
          Text('LIBRARY', style: ScholarStyles.sans(fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 4, color: _palette.accent)),
          const SizedBox(height: 12),
          Text('Digital Library', textAlign: TextAlign.center, style: ScholarStyles.serif(fontSize: 56, fontWeight: FontWeight.w500, letterSpacing: -0.03, height: 1.1, color: _palette.textPrimary)),
          const SizedBox(height: 8),
          Text('Curate your study materials. Find what you need, instantly.', textAlign: TextAlign.center, style: ScholarStyles.sans(fontSize: 16, fontWeight: FontWeight.w300, color: _palette.textSecondary)),
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
                const SizedBox(width: 48),
                Expanded(child: _buildResourceGrid(resources)),
              ],
            ),
          );
        }
        // On phones, stacking the full filter sidebar AND the "Save a Link"
        // form above the resource grid meant scrolling past a large form
        // just to see saved links. Filters become a horizontal chip row
        // (same pattern as Curriculum) and the add-form moves into a
        // collapsed expansion tile below the grid — a standard "add new"
        // placement that doesn't compete with existing content for space.
        return Column(
          children: [
            _buildMobileFilterChips(),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _buildResourceGrid(resources),
            ),
            const SizedBox(height: 20),
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
    final filters = <(String, String, Color?)>[
      ('All Resources', 'all', null),
      ('Physics', 'Physics', _palette.physics),
      ('Chemistry', 'Chemistry', _palette.chemistry),
      ('Mathematics', 'Mathematics', _palette.mathematics),
      ('English', 'English', _palette.english),
      ('IT', 'IT', _palette.it),
      ('Sanskrit', 'Sanskrit', _palette.sanskrit),
      ('General', 'General', _palette.general),
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
                  color: isActive ? _palette.accent : _palette.glassBg,
                  borderRadius: BorderRadius.circular(50),
                  border: Border.all(
                    color: isActive ? _palette.accent : _palette.glassBorder,
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
                          ? (Theme.of(context).brightness == Brightness.dark ? Colors.black : Colors.white)
                          : (color ?? _palette.textSecondary),
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

  Widget _buildAddResourceExpansion() {
    return GlassCard(
      padding: EdgeInsets.zero,
      borderRadius: 20,
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
          childrenPadding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          title: Text('Save a Link', style: ScholarStyles.serif(fontSize: 17, fontWeight: FontWeight.w600, color: _palette.textPrimary)),
          iconColor: _palette.accent,
          collapsedIconColor: _palette.textMuted,
          children: [
            _buildFormField('Resource Title', _titleController, hint: 'e.g., Physics PYQ Playlist'),
            const SizedBox(height: 16),
            _buildFormField('URL (Link)', _urlController, hint: 'https://...'),
            const SizedBox(height: 16),
            _buildDropdown('Subject', ['Physics', 'Chemistry', 'Mathematics', 'English', 'IT', 'Sanskrit', 'General'], _selectedSubject, (v) => setState(() => _selectedSubject = v!)),
            const SizedBox(height: 16),
            _buildDropdown('Format', ['Video', 'PDF', 'Website'], _selectedType, (v) => setState(() => _selectedType = v!)),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _addResource,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _palette.accentSoft,
                  foregroundColor: _palette.accent,
                  elevation: 0,
                  side: BorderSide(color: _palette.accent),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  minimumSize: const Size(0, ScholarTokens.minTouchTarget),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: Text('Save Resource', style: ScholarStyles.sans(fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 2, color: _palette.accent)),
              ),
            ),
          ],
        ),
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
          Text('Filter Library', style: ScholarStyles.serif(fontSize: 19, fontWeight: FontWeight.w600, color: _palette.textPrimary)),
          const SizedBox(height: 16),
          _buildFilterItem('All Resources', 'all'),
          const SizedBox(height: 8),
          _buildFilterItem('Physics', 'Physics', color: _palette.physics),
          const SizedBox(height: 8),
          _buildFilterItem('Chemistry', 'Chemistry', color: _palette.chemistry),
          const SizedBox(height: 8),
          _buildFilterItem('Mathematics', 'Mathematics', color: _palette.mathematics),
          const SizedBox(height: 8),
          _buildFilterItem('English', 'English', color: _palette.english),
          const SizedBox(height: 8),
          _buildFilterItem('IT', 'IT', color: _palette.it),
          const SizedBox(height: 8),
          _buildFilterItem('Sanskrit', 'Sanskrit', color: _palette.sanskrit),
          const SizedBox(height: 8),
          _buildFilterItem('General', 'General', color: _palette.general),
          const SizedBox(height: 24),
          Divider(color: _palette.textMuted.withOpacity(0.15)),
          const SizedBox(height: 24),
          Text('Save a Link', style: ScholarStyles.serif(fontSize: 16, fontWeight: FontWeight.w600, color: _palette.textPrimary)),
          const SizedBox(height: 16),
          _buildFormField('Resource Title', _titleController, hint: 'e.g., Physics PYQ Playlist'),
          const SizedBox(height: 16),
          _buildFormField('URL (Link)', _urlController, hint: 'https://...'),
          const SizedBox(height: 16),
          _buildDropdown('Subject', ['Physics', 'Chemistry', 'Mathematics', 'English', 'IT', 'Sanskrit', 'General'], _selectedSubject, (v) => setState(() => _selectedSubject = v!)),
          const SizedBox(height: 16),
          _buildDropdown('Format', ['Video', 'PDF', 'Website'], _selectedType, (v) => setState(() => _selectedType = v!)),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _addResource,
              style: ElevatedButton.styleFrom(
                backgroundColor: _palette.accentSoft,
                foregroundColor: _palette.accent,
                elevation: 0,
                side: BorderSide(color: _palette.accent),
                padding: const EdgeInsets.symmetric(vertical: 12),
                minimumSize: const Size(0, ScholarTokens.minTouchTarget),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: Text('Save Resource', style: ScholarStyles.sans(fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 2, color: _palette.accent)),
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
            color: isActive ? _palette.surfaceOverlay30 : _palette.glassBg,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            label,
            style: ScholarStyles.sans(
              fontSize: 13,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
              color: color ?? (isActive ? _palette.textPrimary : _palette.textSecondary),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFormField(String label, TextEditingController controller, {String? hint}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label.toUpperCase(), style: ScholarStyles.sans(fontSize: 10, fontWeight: FontWeight.w500, letterSpacing: 1.5, color: _palette.textMuted)),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          style: ScholarStyles.sans(fontSize: 13, color: _palette.textPrimary),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: ScholarStyles.sans(fontSize: 13, color: _palette.textMuted, fontStyle: FontStyle.italic),
            filled: true,
            fillColor: _palette.surfaceOverlay40,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: _palette.textMuted.withOpacity(0.15))),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: _palette.textMuted.withOpacity(0.15))),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: _palette.accent)),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown(String label, List<String> options, String currentValue, ValueChanged<String?> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label.toUpperCase(), style: ScholarStyles.sans(fontSize: 10, fontWeight: FontWeight.w500, letterSpacing: 1.5, color: _palette.textMuted)),
        const SizedBox(height: 4),
        DropdownButtonFormField<String>(
          value: currentValue,
          items: options
              .map((o) => DropdownMenuItem(
                    value: o,
                    child: Text(o, style: ScholarStyles.sans(fontSize: 13, color: _palette.textPrimary)),
                  ))
              .toList(),
          onChanged: onChanged,
          icon: Icon(Icons.keyboard_arrow_down, color: _palette.textMuted, size: 20),
          dropdownColor: _palette.bgBase,
          borderRadius: BorderRadius.circular(14),
          style: ScholarStyles.sans(fontSize: 13, color: _palette.textPrimary),
          decoration: InputDecoration(
            filled: true,
            fillColor: _palette.surfaceOverlay40,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: _palette.textMuted.withOpacity(0.15))),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: _palette.textMuted.withOpacity(0.15))),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: _palette.accent)),
          ),
        ),
      ],
    );
  }

  Widget _buildResourceGrid(List<Resource> resources) {
    if (resources.isEmpty) {
      return GlassCard(
        padding: const EdgeInsets.all(48),
        borderRadius: 20,
        child: Center(
          child: Column(
            children: [
              Text('No resources saved yet.', textAlign: TextAlign.center, style: ScholarStyles.serif(fontSize: 19, color: _palette.textMuted)),
              const SizedBox(height: 8),
              Text('Use the form to add a link.', textAlign: TextAlign.center, style: ScholarStyles.sans(fontSize: 13, color: _palette.textMuted)),
            ],
          ),
        ),
      );
    }

    final reversed = resources.reversed.toList();
    return Wrap(
      spacing: 24,
      runSpacing: 24,
      children: reversed.map((r) {
        final tagColor = _getSubjectColor(r.subject);
        return SizedBox(
          width: 300,
          child: GlassCard(
            padding: const EdgeInsets.all(28),
            borderRadius: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(r.subject, style: ScholarStyles.sans(fontSize: 10, fontWeight: FontWeight.w600, letterSpacing: 1.5, color: tagColor)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                      decoration: BoxDecoration(color: _palette.textMuted.withOpacity(0.10), borderRadius: BorderRadius.circular(50)),
                      child: Text(r.type.toUpperCase(), style: ScholarStyles.sans(fontSize: 9, fontWeight: FontWeight.w600, letterSpacing: 1.5, color: _palette.textMuted)),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(r.title, style: ScholarStyles.serif(fontSize: 19, fontWeight: FontWeight.w600, height: 1.3, color: _palette.textPrimary)),
                const SizedBox(height: 16),
                Divider(color: _palette.textMuted.withOpacity(0.12)),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    OutlinedButton(
                      onPressed: () => _openLink(r.url),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: _palette.textSecondary,
                        side: BorderSide(color: _palette.textMuted.withOpacity(0.2)),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        minimumSize: const Size(0, ScholarTokens.minTouchTarget),
                        tapTargetSize: MaterialTapTargetSize.padded,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
                      ),
                      child: Text(
                        r.url == '/archive' ? 'Open Archive' : 'Open Link',
                        style: ScholarStyles.sans(fontSize: 10, fontWeight: FontWeight.w600, letterSpacing: 1.5, color: _palette.textSecondary),
                      ),
                    ),
                    Semantics(
                      button: true,
                      label: 'Remove ${r.title} from resources',
                      child: TextButton(
                        onPressed: () => _deleteResource(r.id),
                        style: TextButton.styleFrom(
                          foregroundColor: _palette.textMuted,
                          minimumSize: const Size(0, ScholarTokens.minTouchTarget),
                          tapTargetSize: MaterialTapTargetSize.padded,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                        ),
                        child: Text('Remove', style: ScholarStyles.sans(fontSize: 11, color: _palette.textMuted, decoration: TextDecoration.underline)),
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
