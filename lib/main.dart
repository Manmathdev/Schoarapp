import 'package:flutter/material.dart';
import 'theme.dart';
import 'pages/dashboard_page.dart';
import 'pages/curriculum_page.dart';
import 'pages/planner_page.dart';
import 'pages/resources_page.dart';
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
        '/': (context) => const DashboardPage(),
        '/curriculum': (context) => const CurriculumPage(),
        '/planner': (context) => const PlannerPage(),
        '/resources': (context) => const ResourcesPage(),
        '/archive': (context) => ArchivePage(),
      },
    );
  }
}
