import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme.dart';
import '../widgets/glass_card.dart';
import '../widgets/background_orbs.dart';
import '../widgets/scholar_footer.dart';
import '../models/pyq.dart';
import 'pdf_viewer_page.dart';

class ArchivePage extends StatelessWidget {
  const ArchivePage({super.key});

  @override
  Widget build(BuildContext context) {
    final catalog = PyqCatalog.bySubject;

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            const BackgroundOrbs(page: 'archive'),
            Column(
              children: [
                _buildTopBar(context),
                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        children: [
                          const SizedBox(height: 24),
                          _buildArchiveHeader(),
                          const SizedBox(height: 48),
                          _buildArchiveGrid(context, catalog),
                          const SizedBox(height: 32),
                          const ScholarFooter(),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.arrow_back_ios_new, size: 18, color: ScholarColors.accent),
            tooltip: 'Back to Resources',
            onPressed: () => Navigator.of(context).pop(),
          ),
          Text(
            'RESOURCES',
            style: ScholarStyles.sans(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 2.5,
              color: ScholarColors.accent,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildArchiveHeader() {
    return Column(
      children: [
        Text(
          'THE REGISTRY',
          style: ScholarStyles.sans(fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 4, color: ScholarColors.accent),
        ),
        const SizedBox(height: 16),
        Text(
          'The Archive',
          textAlign: TextAlign.center,
          style: ScholarStyles.serif(fontSize: 48, fontWeight: FontWeight.w500, letterSpacing: -0.03, height: 1.1),
        ),
        const SizedBox(height: 12),
        Text(
          'A curated collection of past challenges.',
          textAlign: TextAlign.center,
          style: ScholarStyles.serif(fontSize: 16, fontStyle: FontStyle.italic, color: ScholarColors.textSecondary),
        ),
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
            spacing: 24,
            runSpacing: 24,
            children: blocks.map((b) => SizedBox(width: 300, child: b)).toList(),
          );
        }
        return Column(
          children: blocks
              .map((b) => Padding(padding: const EdgeInsets.only(bottom: 20), child: b))
              .toList(),
        );
      },
    );
  }

  Widget _buildSubjectBlock(BuildContext context, String subject, List<PyqEntry> entries) {
    return GlassCard(
      padding: const EdgeInsets.all(28),
      borderRadius: 20,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(subject, style: ScholarStyles.serif(fontSize: 20, fontWeight: FontWeight.w600, letterSpacing: -0.01)),
          const SizedBox(height: 20),
          ...entries.map((entry) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () {
                    HapticFeedback.lightImpact();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PdfViewerPage(
                          assetPath: entry.assetPath,
                          title: '$subject ${entry.year}',
                        ),
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
                        color: ScholarColors.white25,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(entry.year.toString(), style: ScholarStyles.sans(fontSize: 14, fontWeight: FontWeight.w500)),
                          Row(
                            children: [
                              Text(
                                'VIEW PDF',
                                style: ScholarStyles.sans(fontSize: 9, fontWeight: FontWeight.w600, letterSpacing: 2, color: ScholarColors.accent),
                              ),
                              const SizedBox(width: 4),
                              Icon(Icons.chevron_right, size: 14, color: ScholarColors.accent),
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
