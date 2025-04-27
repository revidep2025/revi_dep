import 'package:flutter/material.dart';
import 'package:revi_dep/pages/crear_proyecto_page.dart';
import 'package:revi_dep/pages/crear_subcontratista.dart';
import 'package:revi_dep/pages/create_internal_user_page.dart';
import 'package:revi_dep/pages/department_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/proyecto_model.dart';
import '../widgets/proyecto_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Project> proyectos = [];
  bool _isLoading = true;
  String? _errorMsg;
  String? roleName;
  final supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    _loadProyectos();
  }

  Future<void> _loadProyectos() async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) {
        setState(() {
          _errorMsg = "Usuario no autenticado.";
          _isLoading = false;
        });
        return;
      }

      final profile = await supabase
          .from('user_profiles')
          .select('id, role_id, real_estate_company_id')
          .eq('id', user.id)
          .single();

      final roleData = await supabase
          .from('roles')
          .select('name')
          .eq('id', profile['role_id'])
          .single();

      roleName = roleData['name'];

      List<dynamic> data = [];

      if (roleName == 'Owner' || roleName == 'Supervisor') {
        data = await supabase
            .from('projects')
            .select()
            .eq('real_estate_company_id', profile['real_estate_company_id'])
            .order('created_at', ascending: false);
      } else if (roleName == 'Inspector') {
        data = await supabase
            .from('user_profile_projects')
            .select('projects(*)')
            .eq('user_profile_id', profile['id']);
        data = data.map((e) => e['projects']).toList();
      }

      final proyectosList = (data as List)
          .map((e) => Project.fromJson(e as Map<String, dynamic>))
          .toList();

      setState(() {
        proyectos = proyectosList;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMsg = 'Error al cargar proyectos: $e';
        _isLoading = false;
      });
    }
  }

  void _goToCreateTrabajador() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CreateInternalUserPage()),
    );
  }

  Future<void> asignarProyectoAInspector(String projectId, String inspectorId) async {
    try {
      await supabase.from('user_profile_projects').insert({
        'user_profile_id': inspectorId,
        'project_id': projectId,
      });
    } catch (e, stack) {
      print('Error al asignar proyecto: $e');
      print(stack);
    }
  }

  Future<void> _mostrarInspectores(String projectId) async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    try {
      final proyecto = await supabase
          .from('projects')
          .select('real_estate_company_id')
          .eq('id', projectId)
          .single();

      final companyId = proyecto['real_estate_company_id'];

      final perfiles = await supabase
          .from('user_profiles')
          .select('id, full_name')
          .eq('role_id', '8b9569d8-bcab-41f5-90af-83d704ff1c0f') // Inspectores
          .eq('real_estate_company_id', companyId);

      if (perfiles == null || perfiles.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("No hay inspectores disponibles.")),
        );
        return;
      }

      showModalBottomSheet(
        context: context,
        builder: (context) => ListView.builder(
          itemCount: perfiles.length,
          itemBuilder: (_, i) {
            final inspector = perfiles[i];
            return ListTile(
              leading: const Icon(Icons.person),
              title: Text(inspector['full_name'] ?? 'Inspector'),
              onTap: () async {
                Navigator.pop(context);
                await asignarProyectoAInspector(projectId, inspector['id']);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Proyecto asignado")),
                );
              },
            );
          },
        ),
      );
    } catch (e) {
      print('Error al mostrar inspectores: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error al obtener inspectores.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Proyectos Multifamiliares"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.green,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.logout),
          onPressed: () async {
            await supabase.auth.signOut();
            Navigator.pushReplacementNamed(context, '/');
          },
        ),
      ),
      floatingActionButton: roleName == 'Owner'
          ? FloatingActionButton.extended(
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CrearProyectoPage()),
                );
                _loadProyectos();
              },
              label: const Text("Crear nuevo proyecto"),
              icon: const Icon(Icons.add),
              backgroundColor: Colors.green,
            )
          : null,
      body: Column(
        children: [
          if (roleName == 'Owner')
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: _goToCreateTrabajador,
                  icon: const Icon(Icons.person_add_alt_1),
                  label: const Text(
                    "Crear trabajador",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade600,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ),
          const SizedBox(height: 10),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : proyectos.isEmpty
                    ? Center(child: Text(_errorMsg ?? "No hay proyectos disponibles"))
                    : ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: proyectos.length,
                        itemBuilder: (_, i) => Column(
                          children: [
                            ProyectoCard(
                              proyecto: proyectos[i],
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => DepartmentPage(
                                      projectId: proyectos[i].id,
                                    ),
                                  ),
                                );
                              },
                            ),
                            if (roleName == 'Owner')
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 4),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                                      onPressed: () => _mostrarInspectores(proyectos[i].id),
                                      child: const Text("Asignar", style: TextStyle(color: Colors.white)),
                                    ),
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => CrearSubcontratistaPage(projectId: proyectos[i].id),
                                          ),
                                        );
                                      },
                                      child: const Text("+Añadir Contratista", style: TextStyle(color: Colors.white)),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}
