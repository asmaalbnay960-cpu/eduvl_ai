import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:eduvl_ai/main.dart'; // Make sure this points to your main.dart

void main() {
  testWidgets('App loads without errors', (WidgetTester tester) async {
    // Build the app
    await tester.pumpWidget(const EduVLApp());

    // Verify that the SplashPage is shown initially
    expect(find.text('EduVL-AI'), findsOneWidget);
  });
}
