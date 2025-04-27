import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../services/visit_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class VisitasPage extends StatefulWidget {
  final String observationId;

  const VisitasPage({super.key, required this.observationId});

  @override
  State<VisitasPage> createState() => _VisitasPageState();
}

class _VisitasPageState extends State<VisitasPage> {
  final VisitService _visitService = VisitService();
  final SupabaseClient supabase = Supabase.instance.client;
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _progressController = TextEditingController(text: '0');
  File? _imageFile;
  List<Map<String, dynamic>> visits = [];
  String currentStatus = 'no_iniciada'; // <-- Default

  @override
  void initState() {
    super.initState();
    _loadVisits();
    _loadObservationStatus();
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

  Future<void> _loadObservationStatus() async {
    try {
      final response = await supabase
          .from('observations')
          .select('status')
          .eq('id', widget.observationId)
          .single();
      setState(() {
        currentStatus = response['status'] ?? 'no_iniciada';
      });
    } catch (e) {
      print("Error cargando status: $e");
    }
  }

  Future<void> _updateObservationStatus(String newStatus) async {
    try {
      await supabase
          .from('observations')
          .update({'status': newStatus})
          .eq('id', widget.observationId);
      setState(() => currentStatus = newStatus);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('✅ Estado actualizado a $newStatus')),
      );
    } catch (e) {
      print("Error actualizando status: $e");
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
      String? publicImageUrl;

      if (_imageFile != null) {
        final filename = DateTime.now().millisecondsSinceEpoch.toString();
        await Supabase.instance.client.storage
            .from('visit-images')
            .upload(
              'evidencias/$filename.jpg',
              _imageFile!,
              fileOptions: const FileOptions(upsert: true),
            );

        publicImageUrl = Supabase.instance.client.storage
            .from('visit-images')
            .getPublicUrl('evidencias/$filename.jpg');
      }

      final progress = int.tryParse(_progressController.text) ?? 0;
      await _visitService.createVisit(
        imageUrl: publicImageUrl,
        description: _descriptionController.text.trim(),
        progress: progress,
        observationId: widget.observationId,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Visita guardada exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
      }

      _descriptionController.clear();
      _progressController.text = '0';
      setState(() => _imageFile = null);
      _loadVisits();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error al guardar visita: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Visitas para Observación'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) => _updateObservationStatus(value),
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'no_iniciada', child: Text('No Iniciada')),
              const PopupMenuItem(value: 'en_progreso', child: Text('En Progreso')),
              const PopupMenuItem(value: 'resuelta', child: Text('Resuelta')),
            ],
            icon: const Icon(Icons.settings),
            tooltip: 'Cambiar Estado',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Estado actual: $currentStatus", style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            if (visits.isNotEmpty)
              ...visits.map((v) => Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      leading: v['image_url'] != null
                          ? Image.network(
                              v['image_url'],
                              width: 60,
                              height: 60,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => const Icon(Icons.broken_image),
                            )
                          : const Icon(Icons.image_not_supported),
                      title: Text("${DateFormat('d MMMM yyyy').format(DateTime.parse(v['created_at']))}"),
                      subtitle: Text(v['description'] ?? ''),
                      trailing: Text("${v['progress']}%"),
                    ),
                  )),
            const Divider(),
            const Text("Nueva Visita", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            if (_imageFile != null) Image.file(_imageFile!, height: 100),
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
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
