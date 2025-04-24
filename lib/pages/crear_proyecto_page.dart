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
   String? get _userId => supabase.auth.currentUser?.id;

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


  if (_userId == null) {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text("Usuario no autenticado")),
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
      'real_estate_company_id':  _userId,
    }).select().single(); // usamos `.single()` para obtener el objeto insertado

    final projectId = responseInsert['id']; // ID del proyecto insertado

    // 2. Si hay imagen, subirla y actualizar el proyecto
    if (_imagen != null) {
      final uuid = const Uuid().v4();
      final fileExt = _imagen!.path.split('.').last;
      final storagePath = 'proyectos/$uuid.$fileExt';

      // Subir imagen
      await supabase.storage
          .from('project-images')
          .upload(storagePath, _imagen!);

      // Obtener URL pública
      final imageUrl = supabase.storage
          .from('project-images')
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
          body: Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    TextField(
                      controller: _nombreController,
                      decoration: const InputDecoration(labelText: "Nombre del Proyecto"),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _descripcionController,
                      decoration: const InputDecoration(labelText: "Descripción"),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _ubicacionController,
                      decoration: const InputDecoration(labelText: "Ubicación"),
                    ),
                    const SizedBox(height: 20),
                    GestureDetector(
                      onTap: _pickImage,
                      child: _imagen != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.file(_imagen!, height: 150),
                            )
                          : Container(
                              height: 150,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.grey),
                              ),
                              child: const Center(
                                child: Text(
                                  "Sube una imagen del proyecto",
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ),
                            ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _pickImage,
                      icon: const Icon(Icons.image),
                      label: const Text("Elegir Imagen desde Galería"),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _saveProyecto,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: const Text("Guardar Proyecto"),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

    );
  }
}
