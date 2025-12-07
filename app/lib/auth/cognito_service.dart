import 'package:amazon_cognito_identity_dart_2/cognito.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'cognito_config.dart';

class CognitoService {
  CognitoService._internal();

  static final CognitoService instance = CognitoService._internal();

  final CognitoUserPool _userPool = CognitoUserPool(
    CognitoConfig.userPoolId,
    CognitoConfig.clientId,
  );

  static const _keyIdToken = 'id_token';
  static const _keyAccessToken = 'access_token';
  static const _keyRefreshToken = 'refresh_token';
  static const _keyUsername = 'username';

  Future<SharedPreferences> get _prefs async =>
      SharedPreferences.getInstance();

  // ---------- SIGN UP ----------
  Future<void> signUp({
    required String email,
    required String password,
    String? firstName,
    String? lastName,
  }) async {
    final userAttributes = [
      AttributeArg(name: 'email', value: email),
    ];

    // Add first name and last name if provided
    // Using 'given_name' and 'family_name' as standard Cognito attributes
    if (firstName != null && firstName.isNotEmpty) {
      userAttributes.add(AttributeArg(name: 'given_name', value: firstName));
    }
    if (lastName != null && lastName.isNotEmpty) {
      userAttributes.add(AttributeArg(name: 'family_name', value: lastName));
    }

    await _userPool.signUp(
      email,
      password,
      userAttributes: userAttributes,
    );
  }

  // ---------- CONFIRM SIGN UP ----------
  Future<void> confirmSignUp({
    required String email,
    required String code,
  }) async {
    final user = CognitoUser(email, _userPool);
    await user.confirmRegistration(code);
  }

  // ---------- SIGN IN ----------
  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    final user = CognitoUser(email, _userPool);
    final authDetails = AuthenticationDetails(
      username: email,
      password: password,
    );

    final session = await user.authenticateUser(authDetails);

    // All of these are nullable in the SDK, so pull them out safely
    final idToken = session?.idToken.jwtToken;
    final accessToken = session?.accessToken.jwtToken;
    final refreshToken = session?.refreshToken?.token;

    if (idToken == null || accessToken == null || refreshToken == null) {
      throw Exception('Missing tokens from Cognito session');
    }

    final prefs = await _prefs;
    await prefs.setString(_keyUsername, email);
    await prefs.setString(_keyIdToken, idToken);
    await prefs.setString(_keyAccessToken, accessToken);
    await prefs.setString(_keyRefreshToken, refreshToken);
  }

  // ---------- SIGN OUT ----------
  Future<void> signOut() async {
    final prefs = await _prefs;
    final username = prefs.getString(_keyUsername);

    if (username != null) {
      final user = CognitoUser(username, _userPool);
      try {
        await user.globalSignOut();
      } catch (_) {
        // ignore – e.g. token already invalid
      }
    }

    await prefs.remove(_keyUsername);
    await prefs.remove(_keyIdToken);
    await prefs.remove(_keyAccessToken);
    await prefs.remove(_keyRefreshToken);
  }

  // ---------- SESSION / TOKENS ----------
  Future<bool> isSignedIn() async {
    final prefs = await _prefs;
    final idToken = prefs.getString(_keyIdToken);
    return idToken != null;
  }

  /// Get a valid ID token, refreshing if needed.
  Future<String?> getIdToken() async {
    final prefs = await _prefs;
    final idToken = prefs.getString(_keyIdToken);

    if (idToken != null) {
      return idToken;
    }

    // if no id token, try to refresh
    return _refreshSession();
  }

  Future<String?> _refreshSession() async {
    final prefs = await _prefs;
    final username = prefs.getString(_keyUsername);
    final storedRefreshToken = prefs.getString(_keyRefreshToken);

    if (username == null || storedRefreshToken == null) {
      return null;
    }

    final user = CognitoUser(username, _userPool);
    final session = await user.refreshSession(
      CognitoRefreshToken(storedRefreshToken),
    );

    final idToken = session?.idToken.jwtToken;
    final accessToken = session?.accessToken.jwtToken;
    final newRefreshToken = session?.refreshToken?.token;

    if (idToken == null || accessToken == null || newRefreshToken == null) {
      return null;
    }

    await prefs.setString(_keyIdToken, idToken);
    await prefs.setString(_keyAccessToken, accessToken);
    await prefs.setString(_keyRefreshToken, newRefreshToken);

    return idToken;
  }
}
