import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:supabase_flutter/supabase_flutter.dart';


class AuthService {
  final SupabaseClient _client = Supabase.instance.client;

  String _hashPassword(String password) {
    return sha256.convert(utf8.encode(password)).toString();
  }

  Future<String?> registerUser({
    required String email,
    required String password,
    required String fullName,
    required String roleId,
    required String realEstateCompanyId,
  }) async {
    try {
      final signUpResponse = await _client.auth.signUp(
        email: email,
        password: password,
      );

      final userId = signUpResponse.user?.id;
      if (userId == null) {
        return "No se pudo obtener el ID del usuario";
      }

      await _client.from('user_profiles').insert({
        'id': userId,
        'full_name': fullName,
        'role_id': roleId,
        'real_estate_company_id': realEstateCompanyId,
      });

      return null;
    } catch (e) {
      return e.toString();
    }
  }

  Future<Map<String, dynamic>?> loginUser({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user != null) {
        final user = response.user!;
        final profile = await _client
            .from('user_profiles')
            .select('*, roles(*), real_estate_companies(*)')
            .eq('id', user.id)
            .maybeSingle();

        return {
          'user': user,
          'profile': profile,
        };
      } else {
        return null;
      }
    } catch (e) {
      print("Error al iniciar sesión: $e");
      return null;
    }
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
  }


  Future<String?> registerRealEstate({
  required String companyName,
  required String email,
  required String password,
}) async {
  final supabase = Supabase.instance.client;

  try {
    final authResponse = await supabase.auth.signUp(
      email: email,
      password: password,
    );

    final user = authResponse.user;
    if (user == null) {
      return 'No se pudo registrar el usuario.';
    }

    // Insertar la inmobiliaria en tu tabla
    final insertResponse = await supabase.from('real_estate_companies').insert({
      'name': companyName,
      'email': email,
      'user_id': user.id, // opcional: si quieres relacionar el usuario raíz
    });

    if (insertResponse.error != null) {
      return insertResponse.error!.message;
    }

    return null;
  } catch (e) {
    return 'Error: $e';
  }
}


Future<String?> createWorkerInternally({
  required String email,
  required String password,
  required String fullName,
  required String roleId,
  required String realEstateCompanyId,
}) async {
  try {
    final response = await _client.auth.admin.createUser(AdminUserAttributes(
      email: email,
      password: password,
      emailConfirm: true,
    ));

    final userId = response.user?.id;
    if (userId == null) {
      return 'No se pudo crear el usuario.';
    }

    // Insertar en user_profiles
    await _client.from('user_profiles').insert({
      'id': userId,
      'full_name': fullName,
      'role_id': roleId,
      'real_estate_company_id': realEstateCompanyId,
    });

    return null;
  } catch (e) {
    return 'Error al crear trabajador: $e';
  }
}

Future<String?> registerRootRealEstateCompany({
  required String email,
  required String password,
  required String companyName,
  String logoImageUrl = '',
}) async {
  final supabase = Supabase.instance.client;

  try {
    // Crear cuenta en Supabase Auth
    final authResponse = await supabase.auth.signUp(
      email: email,
      password: password,
    );

    final user = authResponse.user;
    if (user == null) return 'No se pudo registrar el usuario en Supabase Auth.';

    // Insertar datos adicionales en la tabla real_estate_companies
    final insertResponse = await supabase.from('real_estate_companies').insert({
      'id': user.id, // Asociación uno a uno con auth.users
      'name': companyName,
      'logo_image_url': logoImageUrl,
      'created_at': DateTime.now().toIso8601String(),
    });

    if (insertResponse.error != null) {
      return 'Error al guardar datos adicionales: ${insertResponse.error!.message}';
    }

    return null; // éxito
  } catch (e) {
    return 'Error general: $e';
  }
}




}
