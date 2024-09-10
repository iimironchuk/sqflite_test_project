import 'package:flutter/material.dart';
import 'package:shopping_cart/main.dart';
import 'package:shopping_cart/screens/login_screen.dart';
import 'package:shopping_cart/screens/products_screen.dart';
import 'package:shopping_cart/services/database_service.dart';

class SignUpScreen extends StatefulWidget {
  static const routeName = '/signup-screen';

  const SignUpScreen({super.key});

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String? _email;
  String? _password;
  String? _confirmPassword;

  final DatabaseService _databaseService = DatabaseService.instance;

  void _signUp() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      if (_password != _confirmPassword) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Passwords do not match'),
          ),
        );
        return;
      }
      _databaseService.addUser(_email!, _password!).then(
        (_) async {
          Navigator.of(context).pushNamed(ProductsScreen.routeName);
          int userId = await _databaseService.getUserIdByEmail(_email!);
          selectedUserService.setUser(userId);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Sign Up successful!'),
            ),
          );
        },
      );
    }
  }

  void _goToLogInScreen() {
    Navigator.of(context).pushNamed(LoginScreen.routeName);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Sign Up',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Enter your email:',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  } else if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
                onSaved: (value) {
                  _email = value;
                },
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Enter your password:',
                ),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password';
                  } else if (value.length < 6) {
                    return 'Password must be at least 6 characters long';
                  }
                  return null;
                },
                onSaved: (value) {
                  _password = value;
                },
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Confirm your password:',
                ),
                obscureText: true,
                onSaved: (value) {
                  _confirmPassword = value;
                },
              ),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: _signUp,
                child: const Text(
                  'Sign Up',
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Already have an account?'),
                  TextButton(
                    onPressed: _goToLogInScreen,
                    child: const Text(
                      'Log In',
                    ),
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
