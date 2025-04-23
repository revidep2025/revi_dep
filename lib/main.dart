import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart'; // Necesario para locales
import 'package:revi_dep/pages/login_page.dart';
import 'package:revi_dep/screen/LoginScreen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar Supabase
  await Supabase.initialize(
    url: 'https://cbtsdzncjmxzquqvnfez.supabase.co', 
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImNidHNkem5jam14enF1cXZuZmV6Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDUzMjc0MDQsImV4cCI6MjA2MDkwMzQwNH0.a9Zr-7HJd24nTmayC3TVO-f6r0LRF-BMHkLZ6UT6vqw',
  );

  // 👇 Inicializar formatos de fecha para locales
  await initializeDateFormatting('es', null);
  await initializeDateFormatting('en', null);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gestión Constructora',
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFFFE066),
          primary: const Color(0xFFFFE066),
          secondary: const Color(0xFF81C784),
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Color(0xFF81C784)),
          bodyMedium: TextStyle(color: Color(0xFF81C784)),
        ),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      home: const LoginPage(), // Pantalla inicial
    );
  }
}
