import 'package:flutter/material.dart';
import 'theme.dart';
import 'theme_controller.dart';
import 'widgets/app_shell.dart';
import 'pages/archive_page.dart';

void main() {
  runApp(const ScholarApp());
}

class ScholarApp extends StatefulWidget {
  const ScholarApp({super.key});

  @override
  State<ScholarApp> createState() => _ScholarAppState();
}

class _ScholarAppState extends State<ScholarApp> {
  @override
  void initState() {
    super.initState();
    themeController.load();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: themeController,
      builder: (context, _) {
        return MaterialApp(
          title: 'Scholar',
          theme: ScholarTheme.light,
          darkTheme: ScholarTheme.dark,
          themeMode: themeController.mode,
          debugShowCheckedModeBanner: false,
          initialRoute: '/',
          routes: {
            '/': (context) => const AppShell(),
            '/archive': (context) => const ArchivePage(),
          },
        );
      },
    );
  }
}
