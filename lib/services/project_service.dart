// ignore: depend_on_referenced_packages
import 'package:supabase_flutter/supabase_flutter.dart';

class ProjectService {
  final SupabaseClient supabase = Supabase.instance.client;

  // Crear un nuevo proyecto y retornar el proyecto creado
  Future<Map<String, dynamic>> createProject({
    required String name,
    required String? imageUrl,
    required String? description,
    required String location,
    required String realEstateCompanyId,
  }) async {
    try {
      final response = await supabase
          .from('projects')
          .insert({
            'name': name,
            'image_url': imageUrl,
            'description': description,
            'location': location,
            'real_estate_company_id': realEstateCompanyId,
          })
          .select()
          .single();

      return response;
    } catch (e, stack) {
      print('Error al crear proyecto: $e');
      print('Stack trace: $stack');
      rethrow;
    }
  }

  // Obtener proyectos filtrados por empresa
  Future<List<Map<String, dynamic>>> getProjectsByCompany({
    required String realEstateCompanyId,
  }) async {
    try {
      final response = await supabase
          .from('projects')
          .select('*')
          .eq('real_estate_company_id', realEstateCompanyId);

      return List<Map<String, dynamic>>.from(response);
    } catch (e, stack) {
      print('Error al obtener proyectos: $e');
      print('Stack trace: $stack');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getProjectsByUserProfile({
    required String userProfileId,
  }) async {
    try {
      final response = await supabase.rpc(
        'get_projects_by_user_profile',
        params: {'user_profile_id': userProfileId},
      );

      return List<Map<String, dynamic>>.from(response);
    } catch (e, stack) {
      print('Error al obtener proyectos por usuario: $e');
      print('Stack trace: $stack');
      rethrow;
    }
  }

  // Actualizar un proyecto y retornar el proyecto actualizado
  Future<Map<String, dynamic>> updateProject({
    required String projectId,
    required String? name,
    required String? imageUrl,
    required String? description,
    required String? location,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (name != null) data['name'] = name;
      if (imageUrl != null) data['image_url'] = imageUrl;
      if (description != null) data['description'] = description;
      if (location != null) data['location'] = location;

      final response = await supabase
          .from('projects')
          .update(data)
          .eq('id', projectId)
          .select()
          .single();

      return response;
    } catch (e, stack) {
      print('Error al actualizar proyecto: $e');
      print('Stack trace: $stack');
      rethrow;
    }
  }

  // Eliminar un proyecto y retornar true si fue exitoso
  Future<bool> deleteProject({required String projectId}) async {
    try {
      final response =
          await supabase.from('projects').delete().eq('id', projectId);

      //Opcional para que me retorne true para validad eliminacion
      if (response == null || (response is List && response.isEmpty)) {
        throw Exception('No se encontró el proyecto a eliminar.');
      }

      return true;
    } catch (e, stack) {
      print('Error al eliminar proyecto: $e');
      print('Stack trace: $stack');
      rethrow;
    }
  }
}
