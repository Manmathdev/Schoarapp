import 'package:flutter/material.dart';
import 'theme.dart';
import 'widgets/app_shell.dart';
import 'pages/archive_page.dart';

void main() {
  runApp(const ScholarApp());
}

class ScholarApp extends StatelessWidget {
  const ScholarApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Scholar',
      theme: ScholarTheme.theme,
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => const AppShell(),
        '/archive': (context) => const ArchivePage(),
      },
    );
  }
}
