import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

class CreateDepartmentPage extends StatefulWidget {
  final String projectId;

  const CreateDepartmentPage({super.key, required this.projectId});

  @override
  State<CreateDepartmentPage> createState() => _CreateDepartmentPageState();
}

class _CreateDepartmentPageState extends State<CreateDepartmentPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _unitCodeController = TextEditingController();
  File? _selectedImage;
  bool _isLoading = false;

  final SupabaseClient supabase = Supabase.instance.client;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _selectedImage = File(picked.path));
    }
  }

  Future<void> _createDepartment() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final unitCode = int.parse(_unitCodeController.text);

      // 1. Insertar el departamento sin imagen
      final insertResponse = await supabase.from('departments').insert({
        'unit_code': unitCode,
        'created_at': DateTime.now().toIso8601String(),
        'plan_image_url': null,
        'project_id': widget.projectId,
      }).select().single();

      final departmentId = insertResponse['id'];

      // 2. Si hay imagen, subirla y actualizar el registro
      if (_selectedImage != null) {
        final uuid = const Uuid().v4();
        final fileExt = _selectedImage!.path.split('.').last;
        final storagePath = 'departamentos/$uuid.$fileExt';

        await supabase.storage
            .from('department-plan-images')
            .upload(storagePath, _selectedImage!);

        final imageUrl = supabase.storage
            .from('department-plan-images')
            .getPublicUrl(storagePath);

        

        await supabase.from('departments').update({
          'plan_image_url': imageUrl,
        }).eq('id', departmentId);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Departamento creado exitosamente")),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error al crear el departamento: $e'),
        backgroundColor: Colors.red,
      ));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _unitCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Crear Departamento')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _unitCodeController,
                decoration: const InputDecoration(labelText: 'Depart. N°(número)'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Ingrese un código de unidad';
                  if (int.tryParse(value) == null) return 'Debe ser un número';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: _pickImage,
                child: _selectedImage == null
                    ? Container(
                        height: 150,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey),
                        ),
                        child: const Center(child: Text("Seleccionar imagen del plano (opcional)")),
                      )
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(_selectedImage!, height: 150),
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
                  onPressed: _isLoading ? null : _createDepartment,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Crear Departamento'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
