import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

class CrearProyectoPage extends StatefulWidget {
  const CrearProyectoPage({super.key});

  @override
  State<CrearProyectoPage> createState() => _CrearProyectoPageState();
}

class _CrearProyectoPageState extends State<CrearProyectoPage> {
  final _nombreController = TextEditingController();
  final _descripcionController = TextEditingController();
  final _ubicacionController = TextEditingController(); // NUEVO CAMPO
  File? _imagen;

  final SupabaseClient supabase = Supabase.instance.client;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _imagen = File(picked.path);
      });
    }
  }

 Future<void> _saveProyecto() async {
  if (_nombreController.text.isEmpty || _ubicacionController.text.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Completa al menos nombre y ubicación")),
    );
    return;
  }

  try {
    // 1. Insertar el proyecto sin imagen
    final responseInsert = await supabase.from('projects').insert({
      'name': _nombreController.text,
      'description': _descripcionController.text,
      'location': _ubicacionController.text,
      'image_url': null, // inicialmente null
    }).select().single(); // usamos `.single()` para obtener el objeto insertado

    final projectId = responseInsert['id']; // ID del proyecto insertado

    // 2. Si hay imagen, subirla y actualizar el proyecto
    if (_imagen != null) {
      final uuid = const Uuid().v4();
      final fileExt = _imagen!.path.split('.').last;
      final storagePath = 'proyectos/$uuid.$fileExt';

      // Subir imagen
      await supabase.storage
          .from('proyectos_imagenes')
          .upload(storagePath, _imagen!);

      // Obtener URL pública
      final imageUrl = supabase.storage
          .from('proyectos_imagenes')
          .getPublicUrl(storagePath);

      // Actualizar el proyecto con la URL
      await supabase.from('projects').update({
        'image_url': imageUrl,
      }).eq('id', projectId);
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Proyecto creado exitosamente")),
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
      appBar: AppBar(title: const Text("Nuevo Proyecto")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            TextField(
              controller: _nombreController,
              decoration: const InputDecoration(labelText: "Nombre del Proyecto"),
            ),
            TextField(
              controller: _descripcionController,
              decoration: const InputDecoration(labelText: "Descripción"),
              maxLines: 3,
            ),
            TextField(
              controller: _ubicacionController,
              decoration: const InputDecoration(labelText: "Ubicación"),
            ),
            const SizedBox(height: 12),
            _imagen != null
                ? Image.file(_imagen!, height: 120)
                : const Placeholder(fallbackHeight: 120),
            ElevatedButton(
              onPressed: _pickImage,
              child: const Text("Elegir Imagen desde Galería"),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _saveProyecto,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              child: const Text("Guardar Proyecto"),
            ),
          ],
        ),
      ),
    );
  }
}
