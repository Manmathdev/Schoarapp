// Basic smoke test: verifies the app boots to the Dashboard tab without
// throwing, and that the bottom navigation is present.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:scholar/main.dart';

void main() {
  testWidgets('Scholar app launches to Dashboard', (WidgetTester tester) async {
    await tester.pumpWidget(const ScholarApp());
    await tester.pumpAndSettle();

    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Dashboard'), findsOneWidget);
    expect(find.text('Curriculum'), findsOneWidget);
    expect(find.text('Planner'), findsOneWidget);
    expect(find.text('Resources'), findsOneWidget);
  });
}
