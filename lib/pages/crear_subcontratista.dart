import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CrearSubcontratistaPage extends StatefulWidget {
  final String projectId;

  const CrearSubcontratistaPage({super.key, required this.projectId});

  @override
  State<CrearSubcontratistaPage> createState() => _CrearSubcontratistaPageState();
}

class _CrearSubcontratistaPageState extends State<CrearSubcontratistaPage> {
  final _nombreController = TextEditingController();
  final supabase = Supabase.instance.client;
  bool _isLoading = false;

  Future<void> _crearSubcontratista() async {
    final nombre = _nombreController.text.trim();

    if (nombre.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, ingrese un nombre')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await supabase.from('subcontractors').insert({
        'name': nombre,
        'project_id': widget.projectId,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Subcontratista creado exitosamente')),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al crear subcontratista: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nuevo Subcontratista'),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Nombre del Subcontratista',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _nombreController,
              decoration: const InputDecoration(
                hintText: 'Ejemplo: Maestro ARES',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _crearSubcontratista,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Crear', style: TextStyle(fontSize: 16)),
              ),
            )
          ],
        ),
      ),
    );
  }
}
