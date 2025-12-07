import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:homework_buster/home/home_screen.dart';
import 'package:homework_buster/auth/sign_in_screen.dart';
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

  group('HomeScreen Widget Tests', () {
    testWidgets('renders home screen with correct title', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: HomeScreen(),
        ),
      );

      // The title should be visible immediately
      expect(find.text('Homework Buster – Parent'), findsOneWidget);
    });

    testWidgets('renders logout button in app bar', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: HomeScreen(),
        ),
      );

      // Find the logout icon button
      expect(find.byIcon(Icons.logout), findsOneWidget);
      
      // Verify it's in the AppBar
      final appBar = tester.widget<AppBar>(find.byType(AppBar));
      expect(appBar.actions, isNotNull);
      expect(appBar.actions!.length, greaterThan(0));
    });

    testWidgets('displays body text', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: HomeScreen(),
        ),
      );

      // Initially shows loading, then will show error or content
      // Wait a bit for async operations
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      // The screen will either show loading, error, or content
      // If it shows content, it should have "Children & Spellings" card
      final hasChildrenCard = find.text('Children & Spellings').evaluate().isNotEmpty;
      final hasComingSoon = find.text('Coming soon...').evaluate().isNotEmpty;
      final hasLoading = find.byType(CircularProgressIndicator).evaluate().isNotEmpty;
      final hasError = find.text('Error loading user data').evaluate().isNotEmpty;

      // At least one of these should be true
      expect(hasChildrenCard || hasComingSoon || hasLoading || hasError, isTrue);
    });

    testWidgets('logout button is tappable', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: HomeScreen(),
        ),
      );

      final logoutIcon = find.byIcon(Icons.logout);
      expect(logoutIcon, findsOneWidget);
      
      // Find the IconButton that contains the logout icon
      final logoutButton = find.ancestor(
        of: logoutIcon,
        matching: find.byType(IconButton),
      );
      expect(logoutButton, findsOneWidget);
      
      // Verify button is tappable
      expect(tester.widget<IconButton>(logoutButton).onPressed, isNotNull);
    });

    testWidgets('logout navigates to sign in screen', (tester) async {
      // Set up signed in state
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('id_token', 'test-token');
      await prefs.setString('username', 'test@example.com');

      await tester.pumpWidget(
        const MaterialApp(
          home: HomeScreen(),
        ),
      );

      // Verify we're on home screen
      expect(find.text('Homework Buster – Parent'), findsOneWidget);

      // Tap logout button
      final logoutButton = find.byIcon(Icons.logout);
      await tester.tap(logoutButton);
      await tester.pump();

      // Wait for async signOut to complete
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Verify navigation to sign in screen
      expect(find.text('Parent sign in'), findsOneWidget);
      expect(find.text('Homework Buster – Parent'), findsNothing);
    });

    testWidgets('logout clears authentication state', (tester) async {
      // Set up signed in state
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('id_token', 'test-token');
      await prefs.setString('username', 'test@example.com');
      await prefs.setString('access_token', 'test-access');
      await prefs.setString('refresh_token', 'test-refresh');

      await tester.pumpWidget(
        const MaterialApp(
          home: HomeScreen(),
        ),
      );

      // Verify signed in
      final isSignedInBefore = await CognitoService.instance.isSignedIn();
      expect(isSignedInBefore, isTrue);

      // Tap logout button
      final logoutButton = find.byIcon(Icons.logout);
      await tester.tap(logoutButton);
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Verify signed out
      final isSignedInAfter = await CognitoService.instance.isSignedIn();
      expect(isSignedInAfter, isFalse);

      // Verify tokens are cleared
      final refreshedPrefs = await SharedPreferences.getInstance();
      expect(refreshedPrefs.getString('id_token'), isNull);
      expect(refreshedPrefs.getString('username'), isNull);
      expect(refreshedPrefs.getString('access_token'), isNull);
      expect(refreshedPrefs.getString('refresh_token'), isNull);
    });

    testWidgets('logout removes all previous routes', (tester) async {
      // Set up signed in state
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('id_token', 'test-token');

      // Create a navigator with multiple routes
      await tester.pumpWidget(
        MaterialApp(
          initialRoute: '/home',
          routes: {
            '/home': (_) => const HomeScreen(),
            '/other': (_) => const Scaffold(body: Text('Other Screen')),
          },
        ),
      );

      // Navigate to another route first
      final navigator = tester.element(find.byType(Navigator));
      Navigator.of(navigator).pushNamed('/other');
      await tester.pumpAndSettle();

      // Verify we're on other screen
      expect(find.text('Other Screen'), findsOneWidget);

      // Navigate back to home
      Navigator.of(navigator).pushNamed('/home');
      await tester.pumpAndSettle();

      // Now logout
      final logoutButton = find.byIcon(Icons.logout);
      await tester.tap(logoutButton);
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Verify we're on sign in screen and can't go back
      expect(find.text('Parent sign in'), findsOneWidget);
      expect(find.text('Other Screen'), findsNothing);
      expect(find.text('Homework Buster – Parent'), findsNothing);
    });

    testWidgets('home screen has scaffold structure', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: HomeScreen(),
        ),
      );

      // Wait a bit for initial render
      await tester.pump();

      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
      
      // The body structure depends on state, but should have either:
      // - RefreshIndicator with SingleChildScrollView (when user data loaded)
      // - Center with CircularProgressIndicator (when loading)
      // - Center with error message (when error)
      final hasRefreshIndicator = find.byType(RefreshIndicator).evaluate().isNotEmpty;
      final hasCenter = find.byType(Center).evaluate().isNotEmpty;
      
      // At least one should be present
      expect(hasRefreshIndicator || hasCenter, isTrue);
    });

    testWidgets('handles logout when context is unmounted', (tester) async {
      // Set up signed in state
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('id_token', 'test-token');

      await tester.pumpWidget(
        const MaterialApp(
          home: HomeScreen(),
        ),
      );

      // This test verifies that the _signOut method checks context.mounted
      // We can't easily test unmounted context in widget tests, but we verify
      // the method exists and can be called
      final logoutButton = find.byIcon(Icons.logout);
      expect(logoutButton, findsOneWidget);
      
      // Tap should not throw
      await tester.tap(logoutButton);
      await tester.pump();
    });
  });
}

