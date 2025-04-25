import 'package:flutter/material.dart';
import 'package:revi_dep/models/department_model.dart';
import 'package:revi_dep/pages/department_map_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'create_department_page.dart';

class DepartmentPage extends StatefulWidget {
  final String projectId;

  const DepartmentPage({super.key, required this.projectId});

  @override
  State<DepartmentPage> createState() => _DepartmentPageState();
}

class _DepartmentPageState extends State<DepartmentPage> {
  List<Department> departments = [];
  int? selectedFloor;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDepartments();
  }

  Future<void> _loadDepartments() async {
    setState(() => isLoading = true);

    final response = await Supabase.instance.client
        .from('departments')
        .select()
        .eq('project_id', widget.projectId)
        .order('unit_code', ascending: true);

    final data = response;
    final fetched = (data as List).map((e) => Department.fromJson(e)).toList();

    setState(() {
      departments = fetched;
      isLoading = false;
    });
  }

  List<Department> _filteredDepartments() {
    if (selectedFloor == null) return departments;
    return departments.where((d) {
      final piso = d.unitCode ~/ 100;
      return piso == selectedFloor;
    }).toList();
  }

  List<int> getFloors() {
    final floors = departments.map((d) => d.unitCode ~/ 100).toSet().toList();
    floors.sort();
    return floors;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Departamentos')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: DropdownButtonFormField<int>(
                    value: selectedFloor,
                    hint: const Text('Filtrar por piso'),
                    isExpanded: true,
                    items: getFloors().map((floor) {
                      return DropdownMenuItem<int>(
                        value: floor,
                        child: Text('Piso $floor'),
                      );
                    }).toList(),
                    onChanged: (value) => setState(() => selectedFloor = value),
                  ),
                ),
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.all(12),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 1.2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    itemCount: _filteredDepartments().length,
                    itemBuilder: (_, index) {
                      final dept = _filteredDepartments()[index];
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => DepartmentMapPage(
                                    departmentId: dept.id,
                                    imageUrl: dept.planImageUrl,
                                  ),
                            ),
                          );
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.red.shade300,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Text(
                              'Unidad ${dept.unitCode}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      );
                    },

                  ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green,
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => CreateDepartmentPage(projectId: widget.projectId),
            ),
          );
          _loadDepartments();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

