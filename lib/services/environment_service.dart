// ignore: depend_on_referenced_packages
import 'package:supabase_flutter/supabase_flutter.dart';

class EnvironmentService {
  final SupabaseClient supabase = Supabase.instance.client;

  Future<List<Map<String, dynamic>>> getAllEnvironments() async {
    try {
      final response = await supabase.from('environments').select('*');

      return List<Map<String, dynamic>>.from(response);
    } catch (e, stack) {
      print('Error al obtener environments: $e');
      print('Stack trace: $stack');
      rethrow;
    }
  }
}