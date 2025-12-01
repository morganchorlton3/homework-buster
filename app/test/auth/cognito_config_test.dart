import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:homework_buster/auth/cognito_config.dart';

void main() {
  group('CognitoConfig', () {
    setUp(() {
      // Clear any existing env vars
      dotenv.testLoad(fileInput: '');
    });

    test('userPoolId returns value from environment', () {
      dotenv.testLoad(fileInput: 'COGNITO_USER_POOL_ID=test-pool-id');
      
      expect(CognitoConfig.userPoolId, equals('test-pool-id'));
    });

    test('userPoolId returns empty string when not set', () {
      dotenv.testLoad(fileInput: '');
      
      expect(CognitoConfig.userPoolId, equals(''));
    });

    test('clientId returns value from environment', () {
      dotenv.testLoad(fileInput: 'COGNITO_CLIENT_ID=test-client-id');
      
      expect(CognitoConfig.clientId, equals('test-client-id'));
    });

    test('clientId returns empty string when not set', () {
      dotenv.testLoad(fileInput: '');
      
      expect(CognitoConfig.clientId, equals(''));
    });

    test('region returns value from environment', () {
      dotenv.testLoad(fileInput: 'COGNITO_REGION=us-east-1');
      
      expect(CognitoConfig.region, equals('us-east-1'));
    });

    test('region returns default eu-west-2 when not set', () {
      dotenv.testLoad(fileInput: '');
      
      expect(CognitoConfig.region, equals('eu-west-2'));
    });

    test('all config values can be set together', () {
      dotenv.testLoad(fileInput: '''
COGNITO_USER_POOL_ID=eu-west-2_ABC123
COGNITO_CLIENT_ID=xyz789client
COGNITO_REGION=us-west-2
''');
      
      expect(CognitoConfig.userPoolId, equals('eu-west-2_ABC123'));
      expect(CognitoConfig.clientId, equals('xyz789client'));
      expect(CognitoConfig.region, equals('us-west-2'));
    });
  });
}

