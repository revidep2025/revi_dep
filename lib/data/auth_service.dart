import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final SupabaseClient _client = Supabase.instance.client;

  String _hashPassword(String password) {
    return sha256.convert(utf8.encode(password)).toString();
  }

  Future<String?> registerUser({
    required String nombre,
    required String apellido,
    required String codigoEstudiante,
    required String password,
  }) async {
    final hashedPassword = _hashPassword(password);

    try {
      final response = await _client.from('usuarios').insert({
        'nombre': nombre,
        'apellido': apellido,
        'codigo_estudiante': codigoEstudiante,
        'contrasena': hashedPassword,
      });

      // Si no lanza error, está bien
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  Future<bool> loginUser({
    required String codigoEstudiante,
    required String password,
  }) async {
    final hashedPassword = _hashPassword(password);

    try {
      final data = await _client
          .from('usuarios')
          .select()
          .eq('codigo_estudiante', codigoEstudiante)
          .eq('contrasena', hashedPassword)
          .maybeSingle();

      return data != null;
    } catch (e) {
      print("Error al iniciar sesión: $e");
      return false;
    }
  }
}
