// department_detail_page.dart
import 'package:flutter/material.dart';
import 'package:revi_dep/data/department.dart';

class DepartmentDetailPage extends StatelessWidget {
  final Department department;

  const DepartmentDetailPage({super.key, required this.department});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Unidad ${department.unitCode}')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: department.planImageUrl != null && department.planImageUrl!.isNotEmpty
            ? Image.network(department.planImageUrl!)
            : const Center(child: Text('No hay imagen disponible')),
      ),
    );
  }
}

