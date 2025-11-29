import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:homework_buster/auth/cognito_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    // Use valid-looking values so CognitoUserPool constructor is happy
    dotenv.testLoad(fileInput: '''
COGNITO_USER_POOL_ID=eu-west-2_JEBY7kG9f
COGNITO_CLIENT_ID=4ekv3gumkp5ld1kup48k26vuto
COGNITO_REGION=eu-west-2
''');
  });

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  group('CognitoService – local session logic', () {
    test('isSignedIn returns false when there is no id_token', () async {
      final signedIn = await CognitoService.instance.isSignedIn();
      expect(signedIn, isFalse);
    });

    test('isSignedIn returns true when id_token is present', () async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('id_token', 'dummy-token');

      final signedIn = await CognitoService.instance.isSignedIn();
      expect(signedIn, isTrue);
    });

    test('signOut clears local tokens', () async {
      final prefs = await SharedPreferences.getInstance();

      await prefs.setString('username', 'test@example.com');
      await prefs.setString('id_token', 'dummy-id');
      await prefs.setString('access_token', 'dummy-access');
      await prefs.setString('refresh_token', 'dummy-refresh');

      await CognitoService.instance.signOut();

      final refreshedPrefs = await SharedPreferences.getInstance();

      expect(refreshedPrefs.getString('id_token'), isNull);
      expect(refreshedPrefs.getString('access_token'), isNull);
      expect(refreshedPrefs.getString('refresh_token'), isNull);
      expect(refreshedPrefs.getString('username'), isNull);
    });

    test('getIdToken returns existing token without refreshing', () async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('id_token', 'existing-id-token');

      final token = await CognitoService.instance.getIdToken();

      expect(token, equals('existing-id-token'));
    });

    test('getIdToken returns null when no token and no refresh possible', () async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('username');
      await prefs.remove('refresh_token');
      await prefs.remove('id_token');

      final token = await CognitoService.instance.getIdToken();

      expect(token, isNull);
    });
  });
}
