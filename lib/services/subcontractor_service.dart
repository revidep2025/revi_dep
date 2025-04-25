// ignore: depend_on_referenced_packages
import 'package:supabase_flutter/supabase_flutter.dart';

class SubcontractorService {
  final SupabaseClient supabase = Supabase.instance.client;

  Future<Map<String, dynamic>> createSubcontractor({
    required String name,
    required String projectId,
  }) async {
    try {
      final response = await supabase
          .from('subcontractors')
          .insert({
            'name': name,
            'project_id': projectId,
          })
          .select()
          .single();

      return response;
    } catch (e, stack) {
      print('Error al crear subcontractor: $e');
      print('Stack trace: $stack');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> updateSubcontractor({
    required String subcontractorId,
    required String? name,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (name != null) data['name'] = name;

      final response = await supabase
          .from('subcontractors')
          .update(data)
          .eq('id', subcontractorId)
          .select()
          .single();

      return response;
    } catch (e, stack) {
      print('Error al actualizar subcontractor: $e');
      print('Stack trace: $stack');
      rethrow;
    }
  }

  Future<bool> deleteSubcontractor({required String subcontractorId}) async {
    try {
      final response = await supabase
          .from('subcontractors')
          .delete()
          .eq('id', subcontractorId);

      if (response == null || (response is List && response.isEmpty)) {
        throw Exception('No se encontró el subcontractor a eliminar.');
      }

      return true;
    } catch (e, stack) {
      print('Error al eliminar subcontractor: $e');
      print('Stack trace: $stack');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getSubcontractorById({
    required String subcontractorId,
  }) async {
    try {
      final response = await supabase
          .from('subcontractors')
          .select('*')
          .eq('id', subcontractorId);

      return List<Map<String, dynamic>>.from(response);
    } catch (e, stack) {
      print('Error al obtener subcontractor: $e');
      print('Stack trace: $stack');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getAllSubcontractorsByWorkItemAndProject({
    required String workItemId,
    required String projectId
  }) async {
    try {
      final response = await supabase.rpc(
        'get_subcontractors_by_work_item_and_project',
        params: {'work_item_id': workItemId, 'project_id': projectId},
      );
      return List<Map<String, dynamic>>.from(response);
    } catch (e, stack) {
      print('Error al obtener subcontractors por work item y proyecto: $e');
      print('Stack trace: $stack');
      rethrow;
    }
  }
}
