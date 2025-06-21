// widget_test.dart
// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:serre/main.dart';

void main() {
  testWidgets('App loads correctly', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const SerreApp());

    // Verify that the app title is visible
    expect(find.text('Serre Intelligente'), findsOneWidget);

    // Verify that the initial page (Accueil) is loaded
    expect(find.text('Bienvenue dans la Serre Intelligente'), findsOneWidget);
  });

  testWidgets('Navigation works correctly', (WidgetTester tester) async {
    await tester.pumpWidget(const SerreApp());

    // Verify initial page
    expect(find.text('Bienvenue dans la Serre Intelligente'), findsOneWidget);

    // Tap on the Capteurs tab
    await tester.tap(find.byIcon(Icons.sensors));
    await tester.pump();

    // Verify we're on the Capteurs page
    expect(find.text('Température'), findsOneWidget);

    // Tap on the Actionneurs tab
    await tester.tap(find.byIcon(Icons.power));
    await tester.pump();

    // Verify we're on the Actionneurs page
    expect(find.text('Pompe à eau'), findsOneWidget);

    // Tap on the Alertes tab
    await tester.tap(find.byIcon(Icons.warning));
    await tester.pump();

    // Verify we're on the Alertes page
    expect(find.text('Température élevée détectée'), findsOneWidget);
  });
}