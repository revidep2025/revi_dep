import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:revi_dep/pages/visitas_pages.dart';
import '../services/observation_service.dart';
import '../models/observation_model.dart';


class CrearObservacionPage extends StatefulWidget {
  final Offset position;
  final String departmentId;

  const CrearObservacionPage({
    super.key,
    required this.position,
    required this.departmentId,
  });

  @override
  State<CrearObservacionPage> createState() => _CrearObservacionPageState();
}

class _CrearObservacionPageState extends State<CrearObservacionPage> {
  final _descripcionController = TextEditingController();
  final _fechaInicioController = TextEditingController();
  final _fechaLimiteController = TextEditingController();
  final _partidaController = TextEditingController();

  String estado = 'no_iniciada';
  String ambiente = 'Lavandería';
  String contratista = 'Maestro ARES';
  File? _foto;
  final ObservationService _obsService = ObservationService();

  Future<void> _tomarFoto() async {
    final picker = ImagePicker();
    final imagen = await picker.pickImage(source: ImageSource.camera);

    if (imagen != null) {
      setState(() {
        _foto = File(imagen.path);
      });
    }
  }

  Future<void> _guardarObservacion() async {
    try {
      final obs = Observation.createNew(
        departmentId: widget.departmentId,
        position: widget.position,
        description: _descripcionController.text.trim(),
        status: ObservationStatus.noIniciada,
        imageUrl: null, // podrías subir y asignar URL si usas storage
      );

      await _obsService.createObservation(obs);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Observación guardada")),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error al guardar: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Recepción de Departamentos")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.red.shade600,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.filter_alt, color: Colors.white, size: 18),
                      SizedBox(width: 6),
                      Text("Observación no iniciada", style: TextStyle(color: Colors.white)),
                    ],
                  ),
                ),
                const Spacer(),
                const CircleAvatar(
                  radius: 14,
                  backgroundColor: Colors.red,
                  child: Text("1", style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Center(
              child: _foto != null
                  ? Image.file(_foto!, height: 150)
                  : const Text("Evidencia Fotográfica", style: TextStyle(color: Colors.green)),
            ),
            const SizedBox(height: 16),
            const Text("Fecha de Inicio"),
            TextFormField(
              readOnly: true,
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2030),
                );
                if (date != null) {
                  _fechaInicioController.text = "${date.day}-${date.month}-${date.year}";
                }
              },
              controller: _fechaInicioController,
              decoration: const InputDecoration(hintText: "día-mes-año"),
            ),
            const SizedBox(height: 12),
            const Text("Fecha Límite de entrega"),
            TextFormField(
              readOnly: true,
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2030),
                );
                if (date != null) {
                  _fechaLimiteController.text = "${date.day}-${date.month}-${date.year}";
                }
              },
              controller: _fechaLimiteController,
              decoration: const InputDecoration(
                hintText: "día-mes-año",
                suffixIcon: Icon(Icons.calendar_today),
              ),
            ),
            const SizedBox(height: 16),
            const Text("Observación"),
            TextFormField(
              controller: _descripcionController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: "Describa la observación",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            const Text("Ambiente"),
            DropdownButtonFormField<String>(
              value: ambiente,
              items: const [
                DropdownMenuItem(value: "Lavandería", child: Text("Lavandería")),
                DropdownMenuItem(value: "Cocina", child: Text("Cocina")),
                DropdownMenuItem(value: "Dormitorio", child: Text("Dormitorio")),
              ],
              onChanged: (val) => setState(() => ambiente = val!),
            ),
            const SizedBox(height: 12),
            const Text("Partida"),
            TextFormField(
              controller: _partidaController,
              decoration: const InputDecoration(
                hintText: "Ej. Puertas",
                suffixIcon: Icon(Icons.remove_red_eye),
              ),
            ),
            const SizedBox(height: 12),
            const Text("Contratista Responsable"),
            DropdownButtonFormField<String>(
              value: contratista,
              items: const [
                DropdownMenuItem(value: "Maestro ARES", child: Text("Maestro ARES")),
                DropdownMenuItem(value: "Empresa XYZ", child: Text("Empresa XYZ")),
              ],
              onChanged: (val) => setState(() => contratista = val!),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _guardarObservacion,
                    icon: const Icon(Icons.save_alt),
                    label: const Text("GUARDAR"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber.shade200,
                      foregroundColor: Colors.black,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => VisitasPage(observationId: 'demo_id'),
                      ),
                    );
                  },
                  icon: const Icon(Icons.add),
                  label: const Text("VISITAS"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber.shade700,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Center(
              child: ElevatedButton.icon(
                onPressed: _tomarFoto,
                icon: const Icon(Icons.camera_alt),
                label: const Text("OBSERVACIÓN RESUELTA"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
