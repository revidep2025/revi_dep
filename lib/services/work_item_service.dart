// ignore: depend_on_referenced_packages
import 'package:supabase_flutter/supabase_flutter.dart';

class WorkItemService {
  final SupabaseClient supabase = Supabase.instance.client;

  Future<Map<String, dynamic>> createWorkItem({
    required String name,
  }) async {
    try {
      final response = await supabase
          .from('work_items')
          .insert({'name': name})
          .select()
          .single();

      return response;
    } catch (e, stack) {
      print('Error al crear work item: $e');
      print('Stack trace: $stack');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> updateWorkItem({
    required String workItemId,
    required String? name,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (name != null) data['name'] = name;

      final response = await supabase
          .from('work_items')
          .update(data)
          .eq('id', workItemId)
          .select()
          .single();

      return response;
    } catch (e, stack) {
      print('Error al actualizar work item: $e');
      print('Stack trace: $stack');
      rethrow;
    }
  }

  Future<bool> deleteWorkItem({required String workItemId}) async {
    try {
      final response = await supabase
          .from('work_items')
          .delete()
          .eq('id', workItemId);

      if (response == null || (response is List && response.isEmpty)) {
        throw Exception('No se encontró el work item a eliminar.');
      }

      return true;
    } catch (e, stack) {
      print('Error al eliminar work item: $e');
      print('Stack trace: $stack');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getWorkItemsBySubcontractor({
    required String subcontractorId,
  }) async {
    try {
      final response = await supabase.rpc(
        'get_work_items_by_subcontractor',
        params: {'subcontractor_id': subcontractorId},
      );
      return List<Map<String, dynamic>>.from(response);
    } catch (e, stack) {
      print('Error al obtener work items por subcontractor: $e');
      print('Stack trace: $stack');
      rethrow;
    }
  }
}
