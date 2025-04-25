// ignore: depend_on_referenced_packages
import 'package:supabase_flutter/supabase_flutter.dart';

class DepartmentService {
  final SupabaseClient supabase = Supabase.instance.client;

  // Crear un nuevo departamento
  Future<Map<String, dynamic>> createDepartment({
    required int unitCode,
    required String projectId,
    required String? planImageUrl,
  }) async {
    try {
      final response = await supabase
          .from('departments')
          .insert({
            'unit_code': unitCode,
            'project_id': projectId,
            'plan_image_url': planImageUrl,
          })
          .select()
          .single();

      return response;
    } catch (e, stack) {
      print('Error al crear departamento: $e');
      print('Stack trace: $stack');
      rethrow;
    }
  }

  // Obtener departamentos por proyecto, opcionalmente filtrando por piso
  Future<List<Map<String, dynamic>>> getDepartmentsByProjectAndFloor({
    required String projectId,
    required int? floor,
  }) async {
    try {
      final response = await supabase.rpc(
        'get_departments_by_project_and_floor',
        params: {
          'project_id': projectId,
          'floor': floor,
        },
      );

      return List<Map<String, dynamic>>.from(response);
    } catch (e, stack) {
      print('Error al obtener departamentos por proyecto: $e');
      print('Stack trace: $stack');
      rethrow;
    }
  }

  // Actualizar un departamento
  Future<Map<String, dynamic>> updateDepartment({
    required String departmentId,
    required int? unitCode,
    required String? planImageUrl,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (unitCode != null) data['unit_code'] = unitCode;
      if (planImageUrl != null) data['plan_image_url'] = planImageUrl;

      final response = await supabase
          .from('departments')
          .update(data)
          .eq('id', departmentId)
          .select()
          .single();

      return response;
    } catch (e, stack) {
      print('Error al actualizar departamento: $e');
      print('Stack trace: $stack');
      rethrow;
    }
  }

  // Eliminar un departamento
  Future<bool> deleteDepartment({
    required String departmentId,
  }) async {
    try {
      final response =
          await supabase.from('departments').delete().eq('id', departmentId);

      if (response == null || (response is List && response.isEmpty)) {
        throw Exception('No se encontró el departamento a eliminar.');
      }

      return true;
    } catch (e, stack) {
      print('Error al eliminar departamento: $e');
      print('Stack trace: $stack');
      rethrow;
    }
  }
}
