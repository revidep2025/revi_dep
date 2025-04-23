import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';


class CreateDepartmentPage extends StatefulWidget {
  final String projectId;

  const CreateDepartmentPage({super.key, required this.projectId});

  @override
  State<CreateDepartmentPage> createState() => _CreateDepartmentPageState();
}

class _CreateDepartmentPageState extends State<CreateDepartmentPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _unitCodeController = TextEditingController();
  final TextEditingController _planImageUrlController = TextEditingController();

  bool _isLoading = false;

  Future<void> _createDepartment() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final unitCode = int.parse(_unitCodeController.text);
      final planImageUrl = _planImageUrlController.text;
      final createdAt = DateTime.now();

      final newDepartment = {
        'unit_code': unitCode,
        'created_at': createdAt.toIso8601String(),
        'plan_image_url': planImageUrl,
        'project_id': widget.projectId,
      };

      final response = await Supabase.instance.client
          .from('departments')
          .insert(newDepartment);

      if (response.error != null) {
        throw response.error!;
      }

      if (mounted) {
        Navigator.pop(context); // Vuelve a la lista
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
    _planImageUrlController.dispose();
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
                decoration: const InputDecoration(labelText: 'Código de unidad (número)'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Ingrese un código de unidad';
                  if (int.tryParse(value) == null) return 'Debe ser un número';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _planImageUrlController,
                decoration: const InputDecoration(labelText: 'URL del plano'),
                validator: (value) => value == null || value.isEmpty
                    ? 'Ingrese una URL de imagen'
                    : null,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _createDepartment,
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Crear Departamento'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
