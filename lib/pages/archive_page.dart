import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme.dart';
import '../widgets/glass_card.dart';
import '../widgets/scholar_footer.dart';
import '../models/pyq.dart';
import 'pdf_viewer_page.dart';

class ArchivePage extends StatelessWidget {
  const ArchivePage({super.key});

  @override
  Widget build(BuildContext context) {
    final catalog = PyqCatalog.bySubject;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Resources'),
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                const SizedBox(height: 20),
                _buildArchiveHeader(context),
                const SizedBox(height: 32),
                _buildArchiveGrid(context, catalog),
                const SizedBox(height: 24),
                const ScholarFooter(),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildArchiveHeader(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('THE REGISTRY', style: theme.textTheme.labelMedium?.copyWith(color: theme.colorScheme.primary, letterSpacing: 3)),
        const SizedBox(height: 8),
        Text('The Archive', style: theme.textTheme.headlineMedium),
        const SizedBox(height: 4),
        Text('A curated collection of past challenges.', style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
      ],
    );
  }

  Widget _buildArchiveGrid(BuildContext context, Map<String, List<PyqEntry>> catalog) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 600;
        final blocks = catalog.entries.map((e) => _buildSubjectBlock(context, e.key, e.value)).toList();
        if (isWide) {
          return Wrap(
            spacing: 16,
            runSpacing: 16,
            children: blocks.map((b) => SizedBox(width: 300, child: b)).toList(),
          );
        }
        return Column(
          children: blocks.map((b) => Padding(padding: const EdgeInsets.only(bottom: 16), child: b)).toList(),
        );
      },
    );
  }

  Widget _buildSubjectBlock(BuildContext context, String subject, List<PyqEntry> entries) {
    final theme = Theme.of(context);
    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(subject, style: theme.textTheme.titleLarge),
          const SizedBox(height: 14),
          ...entries.map((entry) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(ScholarTokens.shapeMD),
                  onTap: () {
                    HapticFeedback.lightImpact();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PdfViewerPage(assetPath: entry.assetPath, title: '$subject ${entry.year}'),
                      ),
                    );
                  },
                  child: Semantics(
                    button: true,
                    label: 'View $subject ${entry.year} question paper PDF',
                    child: Container(
                      constraints: const BoxConstraints(minHeight: ScholarTokens.minTouchTarget),
                      alignment: Alignment.centerLeft,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHigh,
                        borderRadius: BorderRadius.circular(ScholarTokens.shapeMD),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(entry.year.toString(), style: theme.textTheme.bodyMedium),
                          Row(
                            children: [
                              Text('VIEW PDF', style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.primary)),
                              const SizedBox(width: 4),
                              Icon(Icons.chevron_right, size: 16, color: theme.colorScheme.primary),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
