import 'package:supabase_flutter/supabase_flutter.dart';

class ObservationService {
  final SupabaseClient supabase = Supabase.instance.client;

  Future<Map<String, dynamic>> createObservation({
    required String? imageUrl,
    required String description,
    required String environmentId,
    required String subcontractorWorkItemId,
    required String departmentId,
    required int environmentNumber,
    required DateTime expiresAt,
    required DateTime? confirmedAt,
  }) async {
    try {
      final response = await supabase
          .from('observations')
          .insert({
            'image_url': imageUrl,
            'description': description,
            'environment_id': environmentId,
            'subcontractor_work_item_id': subcontractorWorkItemId,
            'department_id': departmentId,
            'environment_number': environmentNumber,
            'expires_at': expiresAt.toIso8601String(),
            'confirmed_at': confirmedAt?.toIso8601String(),
          })
          .select()
          .single();

      return response;
    } catch (e, stack) {
      print('Error al crear observación: $e');
      print('Stack trace: $stack');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> updateObservation({
    required String observationId,
    String? imageUrl,
    String? description,
    DateTime? expiresAt,
    DateTime? confirmedAt,
    String? environmentId,
    String? subcontractorWorkItemId,
  }) async {
    try {
      final updateData = <String, dynamic>{};
      if (imageUrl != null) updateData['image_url'] = imageUrl;
      if (description != null) updateData['description'] = description;
      if (expiresAt != null)
        updateData['expires_at'] = expiresAt.toIso8601String();
      if (confirmedAt != null)
        updateData['confirmed_at'] = confirmedAt.toIso8601String();
      if (environmentId != null) updateData['environment_id'] = environmentId;
      if (subcontractorWorkItemId != null)
        updateData['subcontractor_work_item_id'] = subcontractorWorkItemId;

      final response = await supabase
          .from('observations')
          .update(updateData)
          .eq('id', observationId)
          .select()
          .single();

      return response;
    } catch (e, stack) {
      print('Error al actualizar observación: $e');
      print('Stack trace: $stack');
      rethrow;
    }
  }

  Future<bool> deleteObservation({required String observationId}) async {
    try {
      final response =
          await supabase.from('observations').delete().eq('id', observationId);

      if (response == null || (response is List && response.isEmpty)) {
        throw Exception('No se encontró la observación a eliminar.');
      }

      return true;
    } catch (e, stack) {
      print('Error al eliminar observación: $e');
      print('Stack trace: $stack');
      rethrow;
    }
  }
}
