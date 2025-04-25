// ignore: depend_on_referenced_packages
import 'package:supabase_flutter/supabase_flutter.dart';

class WorkItemService {
  final SupabaseClient supabase = Supabase.instance.client;

  Future<List<Map<String, dynamic>>> getAllWorkItems() async {
    try {
      final response = await supabase.from('work_items').select('*');

      return List<Map<String, dynamic>>.from(response);
    } catch (e, stack) {
      print('Error al obtener work items: $e');
      print('Stack trace: $stack');
      rethrow;
    }
  }

  //Existe pero talvez no se utilize ya que solo es un lista estatica
  Future<List<Map<String, dynamic>>> getAllWorkItemsBySubcontractor({
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
