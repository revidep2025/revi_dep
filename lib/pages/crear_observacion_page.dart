import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../pages/visitas_pages.dart';


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
  final _fechaLimiteController = TextEditingController();
  final _numeroAmbienteController = TextEditingController();
  final _confirmedAtController = TextEditingController();


  String ambiente = '';
  String? selectedWorkItemId;
  String? selectedSubcontractorId;
  File? _foto;
  String? _fotoUrlSubida;
  String _status = 'no_iniciada';

  final supabase = Supabase.instance.client;
  List<Map<String, dynamic>> ambientes = [];
  List<Map<String, dynamic>> workItems = [];
  List<Map<String, dynamic>> subcontractors = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final ambientesData = await supabase.from('environments').select('id, name');
    final workItemsData = await supabase.from('work_items').select('id, name');
    final subcontractorsData = await supabase.from('subcontractors').select('id, name');

    setState(() {
      ambientes = List<Map<String, dynamic>>.from(ambientesData);
      workItems = List<Map<String, dynamic>>.from(workItemsData);
      subcontractors = List<Map<String, dynamic>>.from(subcontractorsData);

      if (ambientes.isNotEmpty) ambiente = ambientes.first['id'];
    });
  }

  Future<void> _tomarFoto() async {
    final picker = ImagePicker();
    final imagen = await picker.pickImage(source: ImageSource.camera);

    if (imagen != null) {
      final file = File(imagen.path);
      final filename = DateTime.now().millisecondsSinceEpoch.toString();

      await supabase.storage.from('observation-images').upload(
            'evidencias/$filename.jpg',
            file,
            fileOptions: const FileOptions(upsert: true),
          );

      final publicUrl = supabase.storage
          .from('observation-images')
          .getPublicUrl('evidencias/$filename.jpg');

      setState(() {
        _foto = file;
        _fotoUrlSubida = publicUrl;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Foto subida exitosamente')),
      );
    }
  }

  Future<Map<String, dynamic>> createObservation({
    required String? imageUrl,
    required String description,
    required String environmentId,
    required String subcontractorWorkItemId,
    required String departmentId,
    required int environmentNumber,
    required double x, // <--- Añadimos
    required double y, // <--- Añadimos
    required DateTime expiresAt,
    required String status,
    DateTime? confirmedAt,
  }) async {
    try {
      final response = await supabase
          .from('observations')
          .insert({
            'image_url': imageUrl,
            'description': description,
            'environment_id': environmentId,
            'subcontractor_work_item_id': subcontractorWorkItemId,
            'departament_id': departmentId,
            'environment_number': environmentNumber,
            'x': x, // <- Guardamos coordenada
            'y': y, // <- Guardamos coordenada
            'expires_at': expiresAt.toIso8601String(),
            'confirmed_at': confirmedAt?.toIso8601String(),
            'status': _status,
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

  Future<void> _guardarObservacion() async {
    try {
      if (selectedWorkItemId == null || selectedSubcontractorId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Debes seleccionar una partida y contratista.")),
        );
        return;
      }

      // Buscar combinación en subcontractor_work_items
            final query = await supabase
                .from('subcontractor_work_items')
                .select('id')
                .eq('work_item_id', selectedWorkItemId!)
                .eq('subcontractor_id', selectedSubcontractorId!)
                .maybeSingle();

            String subcontractorWorkItemId;

                if (query != null) {
                  // ✅ Existe la combinación
                  subcontractorWorkItemId = query['id'] as String;
                } else {
                  // ⚡ No existe, entonces la creamos
                  final newLink = await supabase
                      .from('subcontractor_work_items')
                      .insert({
                        'work_item_id': selectedWorkItemId,
                        'subcontractor_id': selectedSubcontractorId,
                      })
                      .select('id')
                      .single();
                  
                  subcontractorWorkItemId = newLink['id'] as String;
                }

      DateTime? fechaLimite;
      if (_fechaLimiteController.text.isNotEmpty) {
        fechaLimite = DateFormat('yyyy-MM-dd').parse(_fechaLimiteController.text);
      }

      DateTime? fechaConfirmacion;
      if (_confirmedAtController.text.isNotEmpty) {
        fechaConfirmacion = DateFormat('yyyy-MM-dd').parse(_confirmedAtController.text);
      }

            if (_status == 'resuelta' && fechaConfirmacion == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Para marcar como resuelta, debes seleccionar una fecha de confirmación.")),
        );
        return;
      }

      await createObservation(
        imageUrl: _fotoUrlSubida,
        description: _descripcionController.text.trim(),
        environmentId: ambiente,
        subcontractorWorkItemId: subcontractorWorkItemId,
        departmentId: widget.departmentId,
        environmentNumber: int.tryParse(_numeroAmbienteController.text.trim()) ?? 1,
        x: widget.position.dx, // <- Aquí
        y: widget.position.dy, // <- Aquí
        expiresAt: fechaLimite ?? DateTime.now().add(const Duration(days: 7)),
        confirmedAt: fechaConfirmacion,
        status: _status,
         
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Observación guardada exitosamente")),
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
    appBar: AppBar(
      title: const Text("Recepción de Departamentos"),
      actions: [
        PopupMenuButton<String>(
          tooltip: 'Cambiar Estado',
          icon: const Icon(Icons.filter_alt),
          onSelected: (value) {
            setState(() {
              _status = value; // 👈 Actualizamos estado
            });
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'no_iniciada',
              child: Text('No iniciada'),
            ),
            const PopupMenuItem(
              value: 'en_progreso',
              child: Text('En progreso'),
            ),
            const PopupMenuItem(
              value: 'resuelta',
              child: Text('Resuelta'),
            ),
          ],
        ),
      ],
    ),
    body: SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          Center(
            child: _foto != null
                ? Image.file(_foto!, height: 150)
                : const Text("Evidencia Fotográfica", style: TextStyle(color: Colors.green)),
          ),
          const SizedBox(height: 8),
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _statusColor(_status),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                _statusText(_status),
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ),
          const SizedBox(height: 16),
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
                _fechaLimiteController.text = DateFormat('yyyy-MM-dd').format(date);
              }
            },
            controller: _fechaLimiteController,
            decoration: const InputDecoration(
              hintText: "Año-Mes-Día",
              suffixIcon: Icon(Icons.calendar_today),
            ),
          ),
// Dentro del body antes de "Observación"
const SizedBox(height: 12),
const Text("Fecha de Confirmación"),
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
      setState(() {
        _confirmedAtController.text = DateFormat('yyyy-MM-dd').format(date);
      });
    }
  },
  controller: _confirmedAtController,
  decoration: const InputDecoration(
    hintText: "Año-Mes-Día",
    suffixIcon: Icon(Icons.verified),
  ),
),
const SizedBox(height: 12),




          const SizedBox(height: 12),
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
            value: ambiente.isNotEmpty ? ambiente : null,
            items: ambientes.map<DropdownMenuItem<String>>((amb) {
              return DropdownMenuItem<String>(
                value: amb['id'].toString(),
                child: Text(amb['name'] ?? ''),
              );
            }).toList(),
            onChanged: (val) => setState(() => ambiente = val ?? ''),
          ),
          const SizedBox(height: 12),
          const Text("Partida"),
          DropdownButtonFormField<String>(
            value: selectedWorkItemId,
            items: workItems.map<DropdownMenuItem<String>>((item) {
              return DropdownMenuItem<String>(
                value: item['id'],
                child: Text(item['name']),
              );
            }).toList(),
            onChanged: (val) => setState(() => selectedWorkItemId = val),
          ),
          const SizedBox(height: 12),
          const Text("Contratista Responsable"),
          DropdownButtonFormField<String>(
            value: selectedSubcontractorId,
            items: subcontractors.map<DropdownMenuItem<String>>((item) {
              return DropdownMenuItem<String>(
                value: item['id'],
                child: Text(item['name']),
              );
            }).toList(),
            onChanged: (val) => setState(() => selectedSubcontractorId = val),
          ),
          const SizedBox(height: 12),
          const Text("Número de Ambiente"),
          TextFormField(
            controller: _numeroAmbienteController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              hintText: "Ej. 1, 2, 3",
              suffixIcon: Icon(Icons.numbers),
            ),
          ),
          const SizedBox(height: 16),
          Center(
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
          const SizedBox(height: 12),
          Center(
            child: ElevatedButton.icon(
              onPressed: _tomarFoto,
              icon: const Icon(Icons.camera_alt),
              label: const Text("Foto de la observación"),
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

/// 🔥 Función para obtener el color según estado
Color _statusColor(String status) {
  switch (status) {
    case 'resuelta':
      return Colors.green;
    case 'en_progreso':
      return Colors.orange;
    default:
      return Colors.red;
  }
}

/// 🔥 Función para mostrar el texto bonito según estado
String _statusText(String status) {
  switch (status) {
    case 'resuelta':
      return "Observación Resuelta";
    case 'en_progreso':
      return "Observación en Progreso";
    default:
      return "Observación no iniciada";
  }
}
}