import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/observation_model.dart';

class ObservationService {
  final SupabaseClient supabase = Supabase.instance.client;

  /// Crear una observación desde modelo
  Future<Observation> createObservation(Observation obs) async {
    try {
      final response = await supabase
          .from('observations')
          .insert(obs.toJson())
          .select()
          .single();

      return Observation.fromJson(response);
    } catch (e, stack) {
      print('Error al crear observación: $e');
      print('Stack trace: $stack');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getObservationById({
    required String observationId,
  }) async {
    try {
      final response = await supabase
          .from('observations')
          .select('*')
          .eq('id', observationId);

      return List<Map<String, dynamic>>.from(response);
    } catch (e, stack) {
      print('Error al obtener observation: $e');
      print('Stack trace: $stack');
      rethrow;
    }
  }

  /// Obtener observaciones por departamento
  Future<List<Observation>> getAllObservationsByDepartment(
      String departmentId) async {
    try {
      final response = await supabase
          .from('observations')
          .select()
          .eq('departament_id', departmentId)
          .order('created_at', ascending: true);

      return List<Map<String, dynamic>>.from(response)
          .map((json) => Observation.fromJson(json))
          .toList();
    } catch (e, stack) {
      print('Error al obtener observaciones: $e');
      print('Stack trace: $stack');
      rethrow;
    }
  }

  /// Actualizar una observación por campos opcionales
  Future<Observation> updateObservation({
    required String observationId,
    String? description,
    String? imageUrl,
    ObservationStatus? status,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (description != null) data['description'] = description;
      if (imageUrl != null) data['image_url'] = imageUrl;
      if (status != null) data['status'] = statusToString(status);

      final response = await supabase
          .from('observations')
          .update(data)
          .eq('id', observationId)
          .select()
          .single();

      return Observation.fromJson(response);
    } catch (e, stack) {
      print('Error al actualizar observación: $e');
      print('Stack trace: $stack');
      rethrow;
    }
  }

  /// Eliminar una observación
  Future<bool> deleteObservation(String observationId) async {
    try {
      final response =
          await supabase.from('observations').delete().eq('id', observationId);

      return true;
    } catch (e, stack) {
      print('Error al eliminar observación: $e');
      print('Stack trace: $stack');
      rethrow;
    }
  }

  /// Obtener el último estado de una observación por departamento (para el color del bloque)
  Future<ObservationStatus?> getLatestObservationStatus(
      String departmentId) async {
    try {
      final response = await supabase
          .from('observations')
          .select('status')
          .eq('departament_id', departmentId)
          .order('created_at', ascending: false)
          .limit(1);

      if (response.isEmpty) return null;
      return parseStatus(response.first['status']);
    } catch (e) {
      print('Error al obtener último estado de observación: $e');
      return null;
    }
  }
}
