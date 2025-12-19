import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:untitled10/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    // We use SmartShoppingListApp instead of MyApp because we changed the class name in main.dart
    await tester.pumpWidget(const SmartShoppingListApp());

    // Verify that the app title is present.
    expect(find.text('Smart Shopping List'), findsOneWidget);
    
    // Verify that the add button is present.
    expect(find.byIcon(Icons.add), findsOneWidget);
  });
}
