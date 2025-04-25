import 'package:flutter/material.dart';
import 'package:revi_dep/pages/crear_proyecto_page.dart';
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

  @override
  void initState() {
    super.initState();
    _loadProyectos();
  }

  Future<void> _loadProyectos() async {
    try {
      final data = await Supabase.instance.client
          .from('projects')
          .select()
          .order('created_at', ascending: false);

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Proyectos Multifamiliares"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.green,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),

      floatingActionButton: FloatingActionButton.extended(
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
      ),

      body: Column(
        children: [
          // Botón de crear trabajador justo debajo del título
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

          // Lista de proyectos
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : proyectos.isEmpty
                    ? Center(child: Text(_errorMsg ?? "No hay proyectos disponibles"))
                    : ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: proyectos.length,
                        itemBuilder: (_, i) => ProyectoCard(
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
                      ),
          ),
        ],
      ),
    );
  }
}
