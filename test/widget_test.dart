import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ride_karo/main.dart';

void main() {
  testWidgets('App boots and shows initial screen', (WidgetTester tester) async {
    // Set up mock SharedPreferences with default values
    SharedPreferences.setMockInitialValues({});

    // Build our app and trigger a frame.
    await tester.pumpWidget(const RideKaroApp());
    await tester.pumpAndSettle();

    // Verify the app renders without error - should show first screen
    // since loginCheck defaults to true (first run)
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
