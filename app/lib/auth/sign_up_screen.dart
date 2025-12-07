import 'package:flutter/material.dart';
import 'cognito_service.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _codeController = TextEditingController();

  bool _loading = false;
  bool _awaitingConfirmation = false;
  String? _error;

  Future<void> _handleSignUp() async {
    // Validate required fields
    if (_firstNameController.text.trim().isEmpty) {
      setState(() {
        _error = 'Please enter your first name';
      });
      return;
    }
    if (_lastNameController.text.trim().isEmpty) {
      setState(() {
        _error = 'Please enter your last name';
      });
      return;
    }
    if (_emailController.text.trim().isEmpty) {
      setState(() {
        _error = 'Please enter your email';
      });
      return;
    }
    if (_passwordController.text.isEmpty) {
      setState(() {
        _error = 'Please enter a password';
      });
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      await CognitoService.instance.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
      );
      setState(() {
        _awaitingConfirmation = true;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  Future<void> _handleConfirm() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      await CognitoService.instance.confirmSignUp(
        email: _emailController.text.trim(),
        code: _codeController.text.trim(),
      );
      if (!mounted) return;
      Navigator.of(context).pop(); // back to sign in
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final awaitingCode = _awaitingConfirmation;

    return Scaffold(
      appBar: AppBar(title: const Text('Create parent account')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            if (!awaitingCode) ...[
              TextField(
                controller: _firstNameController,
                decoration: const InputDecoration(labelText: 'First Name'),
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _lastNameController,
                decoration: const InputDecoration(labelText: 'Last Name'),
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
              ),
              const SizedBox(height: 24),
              _loading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                onPressed: _handleSignUp,
                child: const Text('Sign up as parent'),
              ),
            ] else ...[
              const Text('Enter the confirmation code sent to your email'),
              const SizedBox(height: 12),
              TextField(
                controller: _codeController,
                decoration:
                const InputDecoration(labelText: 'Confirmation code'),
              ),
              const SizedBox(height: 24),
              _loading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                onPressed: _handleConfirm,
                child: const Text('Confirm account'),
              ),
            ],
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(
                _error!,
                style: const TextStyle(color: Colors.red),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
