import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../data/auth_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';


class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _companyController = TextEditingController();

  final _authService = AuthService();

  void _registerCompany() async {
  final email = _emailController.text.trim();
  final password = _passwordController.text.trim();
  final companyName = _companyController.text.trim();

  final result = await _authService.registerRootRealEstateCompany(
    email: email,
    password: password,
    companyName: companyName,
    logoImageUrl: '', // Puedes usar file picker después para permitir subir logo
  );

  if (result == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Inmobiliaria registrada con éxito')),
    );
    Navigator.pop(context);
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error: $result')),
    );
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.blanco,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30.0),
        child: ListView(
          children: [
            const SizedBox(height: 80),
            Center(
              child: Text(
                "Registrar Inmobiliaria",
                style: TextStyle(
                  color: AppColors.verdeClaro,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 30),
            _buildTextField("NOMBRE COMPLETO", _nameController, hint: "Juan Pérez"),
            const SizedBox(height: 15),
            _buildTextField("EMAIL EMPRESARIAL", _emailController, hint: "empresa@ejemplo.com"),
            const SizedBox(height: 15),
            _buildTextField("NOMBRE DE LA INMOBILIARIA", _companyController, hint: "Mi Inmobiliaria SAC"),
            const SizedBox(height: 15),
            _buildTextField("CONTRASEÑA", _passwordController, hint: "••••••••", obscure: true),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.amarilloBebe,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: _registerCompany,
                child: const Text(
                  "Registrarse",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {String hint = '', bool obscure = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13,
              color: Colors.grey,
            )),
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
