import 'package:flutter/material.dart';
import '../theme.dart';
import '../widgets/glass_card.dart';
import '../widgets/background_orbs.dart';
import '../widgets/scholar_footer.dart';

class ArchivePage extends StatelessWidget {
  const ArchivePage({super.key});

  static const _archiveData = [
    _ArchiveEntry('Physics', [2026, 2025, 2024, 2023]),
    _ArchiveEntry('Chemistry', [2026, 2025, 2024, 2023]),
    _ArchiveEntry('Mathematics', [2026, 2025, 2024, 2023]),
    _ArchiveEntry('Information Technology', [2026, 2025, 2024, 2023]),
    _ArchiveEntry('Botany', [2026, 2025, 2024, 2023]),
    _ArchiveEntry('Zoology', [2026, 2025, 2024, 2023]),
    _ArchiveEntry('English', [2026, 2025, 2024, 2023]),
    _ArchiveEntry('Sanskrit', [2026, 2025, 2024, 2023]),
    _ArchiveEntry('Odia', [2026, 2025, 2024, 2023]),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            const BackgroundOrbs(page: 'archive'),
            SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    const SizedBox(height: 32),
                    _buildBackLink(context),
                    const SizedBox(height: 48),
                    _buildArchiveHeader(),
                    const SizedBox(height: 64),
                    _buildArchiveGrid(),
                    const SizedBox(height: 32),
                    const ScholarFooter(),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackLink(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: GestureDetector(
        onTap: () => Navigator.pushNamed(context, '/resources'),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('\u2190', style: ScholarStyles.sans(fontSize: 14, color: ScholarColors.accent)),
            const SizedBox(width: 4),
            Text('Resources', style: ScholarStyles.sans(fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 2.5, color: ScholarColors.accent)),
          ],
        ),
      ),
    );
  }

  Widget _buildArchiveHeader() {
    return Column(
      children: [
        Text('THE REGISTRY', style: ScholarStyles.sans(fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 4, color: ScholarColors.accent)),
        const SizedBox(height: 16),
        Text('The Archive', textAlign: TextAlign.center, style: ScholarStyles.serif(fontSize: 64, fontWeight: FontWeight.w500, letterSpacing: -0.03, height: 1.1)),
        const SizedBox(height: 12),
        Text('A curated collection of past challenges.', textAlign: TextAlign.center, style: ScholarStyles.serif(fontSize: 17, fontStyle: FontStyle.italic, color: ScholarColors.textSecondary)),
      ],
    );
  }

  Widget _buildArchiveGrid() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 600;
        if (isWide) {
          return Wrap(
            spacing: 32,
            runSpacing: 32,
            children: _archiveData.map((entry) {
              return SizedBox(width: 300, child: _buildSubjectBlock(entry));
            }).toList(),
          );
        } else {
          return Column(
            children: _archiveData.map((entry) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 24),
                child: _buildSubjectBlock(entry),
              );
            }).toList(),
          );
        }
      },
    );
  }

  Widget _buildSubjectBlock(_ArchiveEntry entry) {
    return GlassCard(
      padding: const EdgeInsets.all(32),
      borderRadius: 20,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(entry.subject, style: ScholarStyles.serif(fontSize: 22, fontWeight: FontWeight.w600, letterSpacing: -0.01)),
          const SizedBox(height: 24),
          ...entry.years.map((year) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
                decoration: BoxDecoration(
                  color: ScholarColors.white25,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.transparent),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(year.toString(), style: ScholarStyles.sans(fontSize: 14, fontWeight: FontWeight.w500)),
                    Text('VIEW PDF', style: ScholarStyles.sans(fontSize: 9, fontWeight: FontWeight.w600, letterSpacing: 2, color: ScholarColors.accent)),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _ArchiveEntry {
  final String subject;
  final List<int> years;

  const _ArchiveEntry(this.subject, this.years);
}
