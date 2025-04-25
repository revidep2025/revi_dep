// ignore: depend_on_referenced_packages
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final SupabaseClient supabase = Supabase.instance.client;
  static const String ownerRoleId = 'f0e8eed0-b1fd-44bc-8416-9436a9a43986';

  Future<void> loginUser({
    required String email,
    required String password,
  }) async {
    try {
      final response = await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      final user = response.user;
      if (user == null) {
        throw Exception('No se pudo logear el usuario en Supabase Auth.');
      }
    } catch (e, stack) {
      print("Error al iniciar sesión: $e");
      print("Stack trace: $stack");
      rethrow;
    }
  }

  User? getCurrentUser() {
    return supabase.auth.currentUser;
  }

  Session? getCurrentSession() {
    return supabase.auth.currentSession;
  }

  Future<void> signOut() async {
    await supabase.auth.signOut();
  }

  Future<List<Map<String, dynamic>>> getAssignableRoles() async {
    try {
      final response =
          await supabase.from('roles').select().neq('id', ownerRoleId);
      return List<Map<String, dynamic>>.from(response);
    } catch (e, stack) {
      print('Error al obtener roles: $e');
      print('Stack trace: $stack');
      rethrow;
    }
  }

  Future<void> registerUserProfile({
    required String email,
    required String password,
    required String fullName,
    required String roleId,
    required String realEstateCompanyId,
  }) async {
    try {
      if (roleId == ownerRoleId) {
        throw Exception(
            'No está permitido registrar un usuario con rol Owner.');
      }

      final userResponse = await supabase.auth.signUp(
        email: email,
        password: password,
      );

      final user = userResponse.user;
      if (user == null) {
        throw Exception('No se pudo registrar el usuario en Supabase Auth.');
      }

      await supabase.from('user_profiles').insert({
        'id': user.id,
        'full_name': fullName,
        'role_id': roleId,
        'real_estate_company_id': realEstateCompanyId,
      });
    } catch (e, stack) {
      print('Error: $e');
      print('Stack trace: $stack');
      rethrow;
    }
  }

  Future<void> registerRealEstateCompany({
    required String email,
    required String password,
    required String companyName,
    required String userFullName,
  }) async {
    try {
      final userResponse = await supabase.auth.signUp(
        email: email,
        password: password,
      );

      final user = userResponse.user;
      if (user == null) {
        throw Exception('No se pudo registrar el usuario en Supabase Auth.');
      }

      await supabase.from('real_estate_companies').insert({
        'id': user.id,
        'name': companyName,
      });

      await supabase.from('user_profiles').insert({
        'id': user.id,
        'full_name': userFullName,
        'role_id': ownerRoleId,
        'real_estate_company_id': user.id,
      });
    } catch (e, stack) {
      print('Error: $e');
      print('Stack trace: $stack');
      rethrow;
    }
  }
}
