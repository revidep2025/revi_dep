import 'package:supabase_flutter/supabase_flutter.dart';

class VisitService {
  final SupabaseClient supabase = Supabase.instance.client;

Future<void> createVisit({
  required String? imageUrl,
  required String description,
  required int progress,
  required String observationId,
}) async {
  try {
    await supabase
        .from('visits')
        .insert({
          'image_url': imageUrl,
          'description': description,
          'progress': progress,
          'observation_id': observationId,
          'created_at': DateTime.now().toIso8601String(),
        })
        .select(); // 👈 Esto hace que se complete bien el insert
  } catch (e) {
    print('Error creando visita: $e');
    rethrow;
  }
}

  Future<Map<String, dynamic>> updateVisit({
    required String visitId,
    required String? imageUrl,
    required String? description,
    required int? progress,
  }) async {
    try {
      final updateData = <String, dynamic>{};
      if (imageUrl != null) updateData['image_url'] = imageUrl;
      if (description != null) updateData['description'] = description;
      if (progress != null) updateData['progress'] = progress;

      final response = await supabase
          .from('visits')
          .update(updateData)
          .eq('id', visitId)
          .select()
          .single();

      return response;
    } catch (e, stack) {
      print('Error al actualizar visita: $e');
      print('Stack trace: $stack');
      rethrow;
    }
  }

  Future<bool> deleteVisit({required String visitId}) async {
    try {
      final response = await supabase.from('visits').delete().eq('id', visitId);

      if (response == null || (response is List && response.isEmpty)) {
        throw Exception('No se encontró la visita a eliminar.');
      }

      return true;
    } catch (e, stack) {
      print('Error al eliminar visita: $e');
      print('Stack trace: $stack');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getVisitById({
    required String visitId,
  }) async {
    try {
      final response =
          await supabase.from('visits').select('*').eq('id', visitId);

      return List<Map<String, dynamic>>.from(response);
    } catch (e, stack) {
      print('Error al obtener visit: $e');
      print('Stack trace: $stack');
      rethrow;
    }
  }

Future<List<Map<String, dynamic>>> getAllVisitsByObservation({
    required String observationId,
  }) async {
    final response = await supabase
        .from('visits')
        .select('*')
        .eq('observation_id', observationId)
        .order('created_at', ascending: false);

    if (response == null || response.isEmpty) {
      return [];
    }

    return List<Map<String, dynamic>>.from(response);
  }
}
