import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/proyecto_model.dart';

class ProyectoCard extends StatelessWidget {
  final Project proyecto;
  final VoidCallback? onTap; // Nueva propiedad opcional

  const ProyectoCard({
    super.key,
    required this.proyecto,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final formattedDate = DateFormat.yMMMd('es').format(proyecto.createdAt);

    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: proyecto.imageUrl != null && proyecto.imageUrl!.isNotEmpty
              ? Image.network(
                  proyecto.imageUrl!,
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) =>
                      const Icon(Icons.broken_image, size: 60, color: Colors.grey),
                )
              : Container(
                  width: 60,
                  height: 60,
                  color: Colors.grey.shade200,
                  child: const Icon(Icons.photo, color: Colors.grey),
                ),
        ),
        title: Text(
          proyecto.name,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
            fontSize: 16,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              proyecto.location,
              style: const TextStyle(color: Colors.grey, fontSize: 14),
            ),
            const SizedBox(height: 4),
            Text(
              'Creado el $formattedDate',
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        onTap: onTap, // Llama a la función que viene desde HomePage
      ),
    );
  }
}
