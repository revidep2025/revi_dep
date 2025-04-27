import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/observation_model.dart'; // Asegúrate de importar tu modelo correcto

class ObservationService {
  final SupabaseClient supabase = Supabase.instance.client;

Future<List<Observation>> getAllObservationsByDepartment(String departmentId) async {
  final response = await supabase
      .from('observations')
      .select('id, image_url, description, x, y,status, created_at, expires_at, confirmed_at')
      .eq('departament_id', departmentId); // <- Bien escrito

  print('🛠 Respuesta de Supabase: $response'); // <-- AGREGA ESTO

  if (response == null || response.isEmpty) {
    return [];
  }

  return (response as List).map((item) {
    return Observation.fromMap(item as Map<String, dynamic>);
  }).toList();
}

}
