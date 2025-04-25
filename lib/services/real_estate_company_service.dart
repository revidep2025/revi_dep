// ignore: depend_on_referenced_packages
import 'package:supabase_flutter/supabase_flutter.dart';

class RealEstateCompanyService {
  final SupabaseClient supabase = Supabase.instance.client;

  // Crear una nueva empresa inmobiliaria y retornar la empresa creada
  Future<Map<String, dynamic>> createCompany({
    required String name,
    required String? logoImageUrl,
  }) async {
    try {
      final response = await supabase
          .from('real_estate_companies')
          .insert({
            'name': name,
            'logo_image_url': logoImageUrl,
          })
          .select()
          .single();

      return response;
    } catch (e, stack) {
      print('Error al crear empresa inmobiliaria: $e');
      print('Stack trace: $stack');
      rethrow;
    }
  }

  // Obtener todas las empresas inmobiliarias
  Future<List<Map<String, dynamic>>> getAllCompanies() async {
    try {
      final response = await supabase.from('real_estate_companies').select('*');

      return List<Map<String, dynamic>>.from(response);
    } catch (e, stack) {
      print('Error al obtener empresas inmobiliarias: $e');
      print('Stack trace: $stack');
      rethrow;
    }
  }

  // Actualizar una empresa inmobiliaria y retornar la empresa actualizada
  Future<Map<String, dynamic>> updateCompany({
    required String companyId,
    required String? name,
    required String? logoImageUrl,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (name != null) data['name'] = name;
      if (logoImageUrl != null) data['logo_image_url'] = logoImageUrl;

      final response = await supabase
          .from('real_estate_companies')
          .update(data)
          .eq('id', companyId)
          .select()
          .single();

      return response;
    } catch (e, stack) {
      print('Error al actualizar empresa inmobiliaria: $e');
      print('Stack trace: $stack');
      rethrow;
    }
  }

  // Eliminar una empresa inmobiliaria y retornar true si fue exitoso
  Future<bool> deleteCompany({required String companyId}) async {
    try {
      final response = await supabase
          .from('real_estate_companies')
          .delete()
          .eq('id', companyId);

      // Opcional para validar eliminación
      if (response == null || (response is List && response.isEmpty)) {
        throw Exception('No se encontró la empresa a eliminar.');
      }

      return true;
    } catch (e, stack) {
      print('Error al eliminar empresa inmobiliaria: $e');
      print('Stack trace: $stack');
      rethrow;
    }
  }

  // Obtener empresas inmobiliarias por usuario (asumiendo relación en auth.users)
  Future<List<Map<String, dynamic>>> getCompanyByUser(
      {required String userId}) async {
    try {
      // Esto depende de cómo esté estructurada tu relación entre usuarios y empresas
      // Ejemplo básico - ajusta según tu esquema real
      final response = await supabase
          .from('real_estate_companies')
          .select('*')
          .eq('user_id', userId); // Ajusta este campo según tu esquema

      return List<Map<String, dynamic>>.from(response);
    } catch (e, stack) {
      print('Error al obtener empresas por usuario: $e');
      print('Stack trace: $stack');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> createUserProfileProject({
    required String userProfileId,
    required String projectId,
  }) async {
    try {
      final response = await supabase
          .from('user_profile_projects')
          .insert({
            'user_profile_id ': userProfileId,
            'project_id': projectId,
          })
          .select()
          .single();

      return response;
    } catch (e, stack) {
      print('Error al crear relacion entre usuario y proyecto: $e');
      print('Stack trace: $stack');
      rethrow;
    }
  }

  Future<bool> deleteUserProfileProject({
    required String userProfileId,
    required String projectId,
  }) async {
    try {
      final response = await supabase
          .from('real_estate_companies')
          .delete()
          .eq('user_profile_id', userProfileId)
          .eq('project_id', projectId);

      // Opcional para validar eliminación
      if (response == null || (response is List && response.isEmpty)) {
        throw Exception('No se encontró la relacion a eliminar.');
      }

      return true;
    } catch (e, stack) {
      print('Error al eliminar relacion entre usuario y proyecto: $e');
      print('Stack trace: $stack');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> createSubcontractorWorkItem({
    required String subcontractorId,
    required String workItemId,
  }) async {
    try {
      final response = await supabase
          .from('subcontractor_work_items')
          .insert({
            'subcontractor_id': subcontractorId,
            'work_item_id': workItemId,
          })
          .select()
          .single();

      return response;
    } catch (e, stack) {
      print('Error al crear relación entre subcontractor y work item: $e');
      print('Stack trace: $stack');
      rethrow;
    }
  }

  Future<bool> deleteSubcontractorWorkItem({
    required String subcontractorId,
    required String workItemId,
  }) async {
    try {
      final response = await supabase
          .from('subcontractor_work_items')
          .delete()
          .eq('subcontractor_id', subcontractorId)
          .eq('work_item_id', workItemId);

      if (response == null || (response is List && response.isEmpty)) {
        throw Exception('No se encontró la relación a eliminar.');
      }

      return true;
    } catch (e, stack) {
      print('Error al eliminar relación entre subcontractor y work item: $e');
      print('Stack trace: $stack');
      rethrow;
    }
  }
}
