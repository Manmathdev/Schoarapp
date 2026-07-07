class PyqEntry {
  final String subject;
  final int year;
  final String assetPath;

  const PyqEntry({
    required this.subject,
    required this.year,
    required this.assetPath,
  });

  String get fileName => assetPath.split('/').last;
}

/// Catalog built from the PDFs actually bundled with the app.
/// Only real, existing files are listed here — no dead links.
class PyqCatalog {
  PyqCatalog._();

  static const List<String> subjectOrder = [
    'Physics',
    'Chemistry',
    'Maths',
    'Botany',
    'Zoology',
    'English',
    'Sanskrit',
    'Odia',
  ];

  static const List<PyqEntry> _all = [
    PyqEntry(subject: 'Physics', year: 2026, assetPath: 'assets/pyqs/2026-Physics.pdf'),
    PyqEntry(subject: 'Physics', year: 2025, assetPath: 'assets/pyqs/2025-Physics.pdf'),
    PyqEntry(subject: 'Chemistry', year: 2026, assetPath: 'assets/pyqs/2026-Chemistry.pdf'),
    PyqEntry(subject: 'Chemistry', year: 2025, assetPath: 'assets/pyqs/2025-Chemistry.pdf'),
    PyqEntry(subject: 'Maths', year: 2026, assetPath: 'assets/pyqs/2026-Maths.pdf'),
    PyqEntry(subject: 'Maths', year: 2025, assetPath: 'assets/pyqs/2025-Maths.pdf'),
    PyqEntry(subject: 'Botany', year: 2026, assetPath: 'assets/pyqs/2026-Botany.pdf'),
    PyqEntry(subject: 'Botany', year: 2025, assetPath: 'assets/pyqs/2025-Botany.pdf'),
    PyqEntry(subject: 'Zoology', year: 2026, assetPath: 'assets/pyqs/2026-Zoology.pdf'),
    PyqEntry(subject: 'Zoology', year: 2025, assetPath: 'assets/pyqs/2025-Zoology.pdf'),
    PyqEntry(subject: 'English', year: 2026, assetPath: 'assets/pyqs/2026-English.pdf'),
    PyqEntry(subject: 'English', year: 2025, assetPath: 'assets/pyqs/2025-English.pdf'),
    PyqEntry(subject: 'Sanskrit', year: 2026, assetPath: 'assets/pyqs/2026-Sanskrit.pdf'),
    PyqEntry(subject: 'Odia', year: 2026, assetPath: 'assets/pyqs/2026-Odia.pdf'),
    PyqEntry(subject: 'Odia', year: 2025, assetPath: 'assets/pyqs/2025-Odia.pdf'),
  ];

  static Map<String, List<PyqEntry>> get bySubject {
    final map = <String, List<PyqEntry>>{};
    for (final subject in subjectOrder) {
      final entries = _all.where((e) => e.subject == subject).toList()
        ..sort((a, b) => b.year.compareTo(a.year));
      if (entries.isNotEmpty) map[subject] = entries;
    }
    return map;
  }
}
