// ignore: depend_on_referenced_packages
import 'package:supabase_flutter/supabase_flutter.dart';

class UserProfileService {
  final SupabaseClient supabase = Supabase.instance.client;

  // Crear un nuevo perfil de usuario
  Future<Map<String, dynamic>> createUserProfile({
    required String userId,
    required String roleId,
    required String fullName,
    required String realEstateCompanyId,
  }) async {
    try {
      final response = await supabase
          .from('user_profiles')
          .insert({
            'id': userId,
            'role_id': roleId,
            'full_name': fullName,
            'real_estate_company_id': realEstateCompanyId,
          })
          .select()
          .single();

      return response;
    } catch (e, stack) {
      print('Error al crear perfil de usuario: $e');
      print('Stack trace: $stack');
      rethrow;
    }
  }

  // Obtener perfiles filtrados por empresa
  Future<List<Map<String, dynamic>>> getUserProfilesByCompany({
    required String realEstateCompanyId,
  }) async {
    try {
      final response = await supabase
          .from('user_profiles')
          .select('*')
          .eq('real_estate_company_id', realEstateCompanyId);

      return List<Map<String, dynamic>>.from(response);
    } catch (e, stack) {
      print('Error al obtener perfiles: $e');
      print('Stack trace: $stack');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getUserProfilesByProject({
    required String projectId,
  }) async {
    try {
      final response = await supabase.rpc(
        'get_user_profiles_by_project',
        params: {'project_id': projectId},
      );

      return List<Map<String, dynamic>>.from(response);
    } catch (e, stack) {
      print('Error al obtener usuarios por proyecto: $e');
      print('Stack trace: $stack');
      rethrow;
    }
  }

  // Actualizar perfil de usuario
  Future<Map<String, dynamic>> updateUserProfile({
    required String userId,
    required String? fullName,
    required String? roleId,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (fullName != null) data['full_name'] = fullName;
      if (roleId != null) data['role_id'] = roleId;

      final response = await supabase
          .from('user_profiles')
          .update(data)
          .eq('id', userId)
          .select()
          .single();

      return response;
    } catch (e, stack) {
      print('Error al actualizar perfil: $e');
      print('Stack trace: $stack');
      rethrow;
    }
  }

  // Eliminar perfil de usuario
  Future<bool> deleteUserProfile({required String userId}) async {
    try {
      final response =
          await supabase.from('user_profiles').delete().eq('id', userId);

      if (response == null || (response is List && response.isEmpty)) {
        throw Exception('No se encontró el perfil a eliminar.');
      }

      return true;
    } catch (e, stack) {
      print('Error al eliminar perfil: $e');
      print('Stack trace: $stack');
      rethrow;
    }
  }
}
