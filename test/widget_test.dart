import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cameye/main.dart'; // Import your main.dart or any relevant entry point
import 'package:cameye/splash_screen.dart'; // Import the SplashScreen widget
import 'package:cameye/login.dart'; // Import the Login widget

void main() {
  testWidgets('SplashScreen displays and navigates to Login after delay',
      (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(MyApp());

    // Verify that SplashScreen is displayed initially.
    expect(find.byType(SplashScreen), findsOneWidget);
    expect(find.text('CamEye'), findsOneWidget);
    expect(find.text('Your security, our priority'), findsOneWidget);

    // Wait for the splash screen duration (3 seconds).
    await tester.pumpAndSettle(Duration(seconds: 3));

    // Verify that SplashScreen has navigated to Login screen.
    expect(find.byType(SplashScreen), findsNothing);
    expect(find.byType(Login), findsOneWidget);
  });
}
