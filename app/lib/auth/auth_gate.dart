import 'package:flutter/material.dart';

import 'cognito_service.dart';
import '../home/home_screen.dart';
import 'sign_in_screen.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: CognitoService.instance.isSignedIn(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final signedIn = snapshot.data ?? false;

        if (signedIn) {
          return const HomeScreen();
        } else {
          return const SignInScreen();
        }
      },
    );
  }
}
