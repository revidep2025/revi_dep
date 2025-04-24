import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/theme.dart';
import 'package:revi_dep/data/auth_service.dart';

class CreateInternalUserPage extends StatefulWidget {
  const CreateInternalUserPage({super.key});

  @override
  State<CreateInternalUserPage> createState() => _CreateInternalUserPageState();
}

class _CreateInternalUserPageState extends State<CreateInternalUserPage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String _selectedRole = 'trabajador';

  final AuthService _authService = AuthService();

  // Simulación: reemplaza con el ID real de la inmobiliaria
  final String currentInmobiliariaId = "tu-real-estate-company-id";

  void _createUser() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Todos los campos son obligatorios")),
      );
      return;
    }

    final error = await _authService.createWorkerInternally(
      email: email,
      password: password,
      fullName: name,
      roleId: _selectedRole,
      realEstateCompanyId: currentInmobiliariaId,
    );

    if (error == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Usuario creado con éxito")),
      );
      _nameController.clear();
      _emailController.clear();
      _passwordController.clear();
      setState(() {
        _selectedRole = 'trabajador';
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $error")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.blanco,
      appBar: AppBar(
        title: const Text("Nuevo Usuario Interno"),
        backgroundColor: AppColors.amarilloBebe,
        foregroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(30.0),
        child: ListView(
          children: [
            _buildTextField("Nombre completo", _nameController, hint: "Carlos García"),
            const SizedBox(height: 15),
            _buildTextField("Correo de trabajo", _emailController, hint: "carlos@miinmobiliaria.com"),
            const SizedBox(height: 15),
            _buildTextField("Contraseña", _passwordController, obscure: true),
            const SizedBox(height: 15),
            const Text(
              "Rol del Usuario",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey),
            ),
            DropdownButton<String>(
              value: _selectedRole,
              items: ['trabajador', 'supervisor']
                  .map((role) => DropdownMenuItem(value: role, child: Text(role)))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _selectedRole = value!;
                });
              },
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.amarilloBebe,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                minimumSize: const Size.fromHeight(48),
              ),
              onPressed: _createUser,
              child: const Text("Crear Usuario", style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller,
      {String hint = '', bool obscure = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: obscure,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: const Color(0xFFF5F5F5),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }
}
