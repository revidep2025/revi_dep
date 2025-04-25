import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/theme.dart';
import 'package:revi_dep/services/auth_service.dart';

class CreateInternalUserPage extends StatefulWidget {
  const CreateInternalUserPage({super.key});

  @override
  State<CreateInternalUserPage> createState() => _CreateInternalUserPageState();
}

//VISTA SOLO DISPONIBLE PARA EL USER_PROFILE DE ROLE OWNER
class _CreateInternalUserPageState extends State<CreateInternalUserPage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String? _selectedRoleId;

  final AuthService _authService = AuthService();
  late final String currentInmobiliariaId;

  List<Map<String, dynamic>> _roles = [];

  //Aqui lo mejor seria obtener la INMOBILIARIA la cual pertenece al user_profile de role OWNER de la sesion
  //Para el caso de que ahiga mas de un OWNER por INMOBILIARIA
  //Pero al suponerse la INMOBILIARIA solo puede tener un OWNER el cual puede registrar usuarios internos
  //No habria problema con sacar el id de la INMOBILIARIA del id del OWNER
  //Ya que deberia el id(uuid) del usuario actual coincidir con le id(uuid) del la INMOBILIARIA
  @override
  void initState() {
    super.initState();
    _loadAssignableRoles();
    currentInmobiliariaId = _authService.getCurrentUser()?.id ?? '';
  }

  Future<void> _loadAssignableRoles() async {
    try {
      final roles = await _authService.getAssignableRoles();
      setState(() {
        _roles = roles;
        if (_roles.isNotEmpty) {
          _selectedRoleId = _roles.first['id'];
        }
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error al cargar roles: $e")),
      );
    }
  }

  void _createUser() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (name.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        _selectedRoleId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Todos los campos son obligatorios")),
      );
      return;
    }

    try {
      await _authService.registerUserProfile(
        email: email,
        password: password,
        fullName: name,
        roleId: _selectedRoleId!,
        realEstateCompanyId: currentInmobiliariaId,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Usuario creado con éxito")),
      );
      _nameController.clear();
      _emailController.clear();
      _passwordController.clear();
      setState(() {
        _selectedRoleId = _roles.isNotEmpty ? _roles.first['id'] : null;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
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
            _buildTextField("Nombre completo", _nameController,
                hint: "Carlos García"),
            const SizedBox(height: 15),
            _buildTextField("Correo de trabajo", _emailController,
                hint: "carlos@miinmobiliaria.com"),
            const SizedBox(height: 15),
            _buildTextField("Contraseña", _passwordController, obscure: true),
            const SizedBox(height: 15),
            const Text(
              "Rol del Usuario",
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: Colors.grey),
            ),
            DropdownButton<String>(
              value: _selectedRoleId,
              isExpanded: true,
              items: _roles
                  .map((role) => DropdownMenuItem(
                        value: role['id'].toString(),
                        child: Text(role['name'].toString()),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _selectedRoleId = value;
                });
              },
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.amarilloBebe,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
                minimumSize: const Size.fromHeight(48),
              ),
              onPressed: _createUser,
              child: const Text("Crear Usuario",
                  style: TextStyle(fontWeight: FontWeight.bold)),
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
        Text(label,
            style: const TextStyle(
                fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey)),
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
