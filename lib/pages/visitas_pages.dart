import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../services/visit_service.dart';

class VisitasPage extends StatefulWidget {
  final String observationId;

  const VisitasPage({super.key, required this.observationId});

  @override
  State<VisitasPage> createState() => _VisitasPageState();
}

class _VisitasPageState extends State<VisitasPage> {
  final VisitService _visitService = VisitService();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _progressController = TextEditingController(text: '0');
  File? _imageFile;
  List<Map<String, dynamic>> visits = [];

  @override
  void initState() {
    super.initState();
    _loadVisits();
  }

  Future<void> _loadVisits() async {
    try {
      final data = await _visitService.getAllVisitsByObservation(
        observationId: widget.observationId,
      );
      setState(() => visits = data);
    } catch (e) {
      print("Error cargando visitas: $e");
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.camera);
    if (picked != null) {
      setState(() => _imageFile = File(picked.path));
    }
  }

  Future<void> _guardarVisita() async {
    try {
      final imgUrl = _imageFile?.path; // deberías subir a Supabase storage
      final progress = int.tryParse(_progressController.text) ?? 0;
      await _visitService.createVisit(
        imageUrl: imgUrl,
        description: _descriptionController.text,
        progress: progress,
        observationId: widget.observationId,
      );
      _descriptionController.clear();
      _progressController.text = '0';
      _imageFile = null;
      _loadVisits();
    } catch (e) {
      print("Error guardando visita: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Visitas para Observación')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (visits.isNotEmpty)
              ...visits.map((v) => Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      leading: v['image_url'] != null
                          ? Image.file(File(v['image_url']), width: 60, height: 60, fit: BoxFit.cover)
                          : const Icon(Icons.image_not_supported),
                      title: Text("${DateFormat('d MMMM yyyy').format(DateTime.parse(v['created_at']))}"),
                      subtitle: Text(v['description'] ?? ''),
                      trailing: Text("${v['progress']}%"),
                    ),
                  )),
            const Divider(),
            const Text("Nueva Visita", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            if (_imageFile != null)
              Image.file(_imageFile!, height: 100),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: "Comentario del Responsable"),
              maxLines: 2,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _progressController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Avance (%)"),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _guardarVisita,
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
                  onPressed: _pickImage,
                  icon: const Icon(Icons.add_a_photo),
                  label: const Text("CAMARA"),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
