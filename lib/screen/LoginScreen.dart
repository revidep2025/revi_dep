import 'package:flutter/material.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          'Bienvenido a la App de Gestión',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ),
    );
  }
}
