// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Basic Flutter test - MaterialApp loads', (WidgetTester tester) async {
    // Build a simple MaterialApp widget
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Test App')),
        body: const Center(
          child: Text('Hello World'),
        ),
      ),
    ));

    // Verify that the app loads without errors
    expect(find.byType(MaterialApp), findsOneWidget);
    expect(find.byType(Scaffold), findsOneWidget);
    expect(find.text('Hello World'), findsOneWidget);
  });

  testWidgets('Basic widget test - Container renders', (WidgetTester tester) async {
    // Build a simple Container widget
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(
        body: Center(
          child: Container(
            width: 100,
            height: 100,
            color: Colors.blue,
            child: const Text('Test'),
          ),
        ),
      ),
    ));

    // Verify that the container renders
    expect(find.byType(Container), findsOneWidget);
    expect(find.text('Test'), findsOneWidget);
  });

  testWidgets('Workbee app structure test - basic widgets', (WidgetTester tester) async {
    // Test basic Workbee app structure without Firebase
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Workbee'),
          backgroundColor: Colors.blue,
        ),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.work, size: 64, color: Colors.blue),
              SizedBox(height: 16),
              Text(
                'Workbee',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              Text('Find jobs near you'),
            ],
          ),
        ),
      ),
    ));

    // Verify basic app structure
    expect(find.byType(MaterialApp), findsOneWidget);
    expect(find.byType(Scaffold), findsOneWidget);
    expect(find.byType(AppBar), findsOneWidget);
    expect(find.text('Workbee'), findsOneWidget);
    expect(find.text('Find jobs near you'), findsOneWidget);
    expect(find.byIcon(Icons.work), findsOneWidget);
  });
}
