
import 'package:flutter/material.dart';
import '../pages/login_page.dart';
import '../pages/register_page.dart';

Map<String, WidgetBuilder> appRoutes = {
  '/': (context) => const LoginPage(),
  //'/register': (context) => const RegisterPage(),
};
