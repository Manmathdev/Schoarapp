import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme.dart';
import '../widgets/glass_card.dart';
import '../widgets/scholar_header.dart';
import '../widgets/scholar_footer.dart';
import '../widgets/background_orbs.dart';
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
    if (url.startsWith('/')) return;
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
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
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remove Resource'),
        content: const Text('Remove this link from your library?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              setState(() => _resources.removeWhere((r) => r.id == id));
              try {
                await _dataService.saveResources(_resources);
              } catch (e) {
                if (mounted) setState(() => _errorMessage = 'Failed to save: $e');
              }
            },
            child: Text('Remove', style: TextStyle(color: ScholarColors.accent)),
          ),
        ],
      ),
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
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(content: Text(message), actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('OK'))]),
    );
  }

  Color _getSubjectColor(String subject) {
    switch (subject) {
      case 'Physics': return ScholarColors.physics;
      case 'Chemistry': return ScholarColors.chemistry;
      case 'Mathematics': return ScholarColors.mathematics;
      case 'English': return ScholarColors.english;
      case 'IT': return ScholarColors.it;
      case 'Sanskrit': return ScholarColors.sanskrit;
      default: return ScholarColors.textMuted;
    }
  }

  @override
  Widget build(BuildContext context) {
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
              ElevatedButton(onPressed: _loadResources, child: const Text('Retry')),
            ],
          ),
        ),
      );
    }
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 64),
          _buildPageHeader(),
          const SizedBox(height: 32),
          _buildLayout(filtered),
          const ScholarFooter(),
        ],
      ),
    );
  }

  Widget _buildPageHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Text('LIBRARY', style: ScholarStyles.sans(fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 4, color: ScholarColors.accent)),
          const SizedBox(height: 12),
          Text('Digital Library', textAlign: TextAlign.center, style: ScholarStyles.serif(fontSize: 56, fontWeight: FontWeight.w500, letterSpacing: -0.03, height: 1.1)),
          const SizedBox(height: 8),
          Text('Curate your study materials. Find what you need, instantly.', textAlign: TextAlign.center, style: ScholarStyles.sans(fontSize: 16, fontWeight: FontWeight.w300, color: ScholarColors.textSecondary)),
        ],
      ),
    );
  }

  Widget _buildLayout(List<Resource> resources) {
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
                Expanded(child: _buildResourceGrid(resources)),
              ],
            );
          } else {
            return Column(
              children: [
                _buildSidebar(),
                const SizedBox(height: 24),
                _buildResourceGrid(resources),
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
          Text('Filter Library', style: ScholarStyles.serif(fontSize: 19, fontWeight: FontWeight.w600)),
          const SizedBox(height: 16),
          _buildFilterItem('All Resources', 'all'),
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
          const SizedBox(height: 8),
          _buildFilterItem('General', 'General', color: ScholarColors.general),
          const SizedBox(height: 24),
          Divider(color: Colors.black.withOpacity(0.04)),
          const SizedBox(height: 24),
          Text('Save a Link', style: ScholarStyles.serif(fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 16),
          _buildFormField('Resource Title', _titleController, hint: 'e.g., Physics PYQ Playlist'),
          const SizedBox(height: 16),
          _buildFormField('URL (Link)', _urlController, hint: 'https://...'),
          const SizedBox(height: 16),
          _buildDropdown('Subject', ['Physics', 'Chemistry', 'Mathematics', 'English', 'IT', 'Sanskrit', 'General'], (v) => _selectedSubject = v!),
          const SizedBox(height: 16),
          _buildDropdown('Format', ['Video', 'PDF', 'Website'], (v) => _selectedType = v!),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _addResource,
              style: ElevatedButton.styleFrom(
                backgroundColor: ScholarColors.accentSoft,
                foregroundColor: ScholarColors.accent,
                elevation: 0,
                side: BorderSide(color: ScholarColors.accent),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: Text('Save Resource', style: ScholarStyles.sans(fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 2)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterItem(String label, String filter, {Color? color}) {
    final isActive = _currentFilter == filter;
    return GestureDetector(
      onTap: () => _setFilter(filter),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? ScholarColors.white30 : ScholarColors.glassBg,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: ScholarStyles.sans(
            fontSize: 12,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
            color: color ?? (isActive ? ScholarColors.textPrimary : ScholarColors.textSecondary),
          ),
        ),
      ),
    );
  }

  Widget _buildFormField(String label, TextEditingController controller, {String? hint}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label.toUpperCase(), style: ScholarStyles.sans(fontSize: 10, fontWeight: FontWeight.w500, letterSpacing: 1.5, color: ScholarColors.textMuted)),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: ScholarStyles.sans(fontSize: 13, color: ScholarColors.textMuted, fontStyle: FontStyle.italic),
            filled: true,
            fillColor: ScholarColors.white40,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.black.withOpacity(0.05))),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.black.withOpacity(0.05))),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: ScholarColors.accent)),
          ),
          style: ScholarStyles.sans(fontSize: 13),
        ),
      ],
    );
  }

  Widget _buildDropdown(String label, List<String> options, ValueChanged<String?> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label.toUpperCase(), style: ScholarStyles.sans(fontSize: 10, fontWeight: FontWeight.w500, letterSpacing: 1.5, color: ScholarColors.textMuted)),
        const SizedBox(height: 4),
        DropdownButtonFormField<String>(
          value: options.first,
          items: options.map((o) => DropdownMenuItem(value: o, child: Text(o))).toList(),
          onChanged: onChanged,
          decoration: InputDecoration(
            filled: true,
            fillColor: ScholarColors.white40,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.black.withOpacity(0.05))),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.black.withOpacity(0.05))),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: ScholarColors.accent)),
          ),
          style: ScholarStyles.sans(fontSize: 13),
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
              Text('No resources saved yet.', textAlign: TextAlign.center, style: ScholarStyles.serif(fontSize: 19, color: ScholarColors.textMuted)),
              const SizedBox(height: 8),
              Text('Use the form to add a link.', textAlign: TextAlign.center, style: ScholarStyles.sans(fontSize: 13, color: ScholarColors.textMuted)),
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
                      decoration: BoxDecoration(color: Colors.black.withOpacity(0.04), borderRadius: BorderRadius.circular(50)),
                      child: Text(r.type.toUpperCase(), style: ScholarStyles.sans(fontSize: 9, fontWeight: FontWeight.w600, letterSpacing: 1.5, color: ScholarColors.textMuted)),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(r.title, style: ScholarStyles.serif(fontSize: 19, fontWeight: FontWeight.w600, height: 1.3)),
                const SizedBox(height: 16),
                Divider(color: Colors.black.withOpacity(0.04)),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    OutlinedButton(
                      onPressed: () => _openLink(r.url),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: ScholarColors.textSecondary,
                        side: BorderSide(color: Colors.black.withOpacity(0.08)),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
                      ),
                      child: Text('Open Link', style: ScholarStyles.sans(fontSize: 10, fontWeight: FontWeight.w600, letterSpacing: 1.5)),
                    ),
                    GestureDetector(
                      onTap: () => _deleteResource(r.id),
                      child: Text('Remove', style: ScholarStyles.sans(fontSize: 10, color: ScholarColors.textMuted, decoration: TextDecoration.underline)),
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
