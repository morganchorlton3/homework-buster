import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:homework_buster/auth/auth_gate.dart';
import 'package:homework_buster/auth/cognito_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    dotenv.testLoad(fileInput: '''
COGNITO_USER_POOL_ID=eu-west-2_JEBY7kG9f
COGNITO_CLIENT_ID=4ekv3gumkp5ld1kup48k26vuto
COGNITO_REGION=eu-west-2
''');
  });

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  group('AuthGate Widget Tests', () {
    testWidgets('shows loading indicator while checking auth status', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: AuthGate(),
        ),
      );

      // Initially should show loading
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows sign in screen when user is not signed in', (tester) async {
      // Ensure no tokens are stored
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('id_token');

      await tester.pumpWidget(
        const MaterialApp(
          home: AuthGate(),
        ),
      );

      // Wait for FutureBuilder to complete
      await tester.pumpAndSettle();

      // Should show sign in screen
      expect(find.text('Parent sign in'), findsOneWidget);
    });

    testWidgets('shows home screen when user is signed in', (tester) async {
      // Set up signed in state
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('id_token', 'valid-token');

      await tester.pumpWidget(
        const MaterialApp(
          home: AuthGate(),
        ),
      );

      // Wait for FutureBuilder to complete
      await tester.pumpAndSettle();

      // Should show home screen
      // Note: Adjust this based on what HomeScreen displays
      expect(find.text('Parent sign in'), findsNothing);
    });

    testWidgets('transitions from loading to sign in when not authenticated', (tester) async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('id_token');

      await tester.pumpWidget(
        const MaterialApp(
          home: AuthGate(),
        ),
      );

      // Initially loading
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Wait for async check
      await tester.pumpAndSettle();

      // Should transition to sign in
      expect(find.text('Parent sign in'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('transitions from loading to home when authenticated', (tester) async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('id_token', 'valid-token');

      await tester.pumpWidget(
        const MaterialApp(
          home: AuthGate(),
        ),
      );

      // Initially loading
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Wait for async check
      await tester.pumpAndSettle();

      // Should transition to home
      expect(find.text('Parent sign in'), findsNothing);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });
  });
}

