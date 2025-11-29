import 'package:flutter_dotenv/flutter_dotenv.dart';

class CognitoConfig {
  static String get userPoolId =>
      dotenv.env['COGNITO_USER_POOL_ID'] ?? '';

  static String get clientId =>
      dotenv.env['COGNITO_CLIENT_ID'] ?? '';

  static String get region =>
      dotenv.env['COGNITO_REGION'] ?? 'eu-west-2';
}
