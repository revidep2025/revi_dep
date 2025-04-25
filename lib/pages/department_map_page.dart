import 'package:flutter/material.dart';
import '../models/observation_model.dart';
import '../services/observation_service.dart';

class DepartmentMapPage extends StatefulWidget {
  final String departmentId;
  final String imageUrl;

  const DepartmentMapPage({
    super.key,
    required this.departmentId,
    required this.imageUrl,
  });

  @override
  State<DepartmentMapPage> createState() => _DepartmentMapPageState();
}

class _DepartmentMapPageState extends State<DepartmentMapPage> {
  final ObservationService _obsService = ObservationService();
  List<Observation> observations = [];

  @override
  void initState() {
    super.initState();
    _loadObservations();
  }

  Future<void> _loadObservations() async {
    try {
      final data = await _obsService.getObservationsByDepartment(widget.departmentId);
      print('📍 Cargadas ${data.length} observaciones');
      for (final o in data) {
        print('🧭 Observación: x=${o.x}, y=${o.y}, estado=${o.status}');
      }
      setState(() => observations = data);
    } catch (e) {
      print('Error al obtener observaciones: $e');
    }
  }

  void _addObservationAt(Offset position, Size size) {
    final x = position.dx / size.width;
    final y = position.dy / size.height;
    print('🖱 TAP en posición: x=$x, y=$y');

    Navigator.pushNamed(
      context,
      '/crear-observacion',
      arguments: {
        'position': Offset(x, y),
        'departmentId': widget.departmentId,
      },
    ).then((_) => _loadObservations());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Plano del Departamento")),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final size = Size(constraints.maxWidth, constraints.maxHeight);

          return GestureDetector(
            onTapUp: (details) => _addObservationAt(details.localPosition, size),
            child: Stack(
              children: [
                Positioned.fill(
                  child: widget.imageUrl.isNotEmpty
                      ? Image.network(
                          widget.imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => const Center(
                            child: Text("Error al cargar imagen"),
                          ),
                        )
                      : Container(color: Colors.white),
                ),

                if (widget.imageUrl.isEmpty)
                  const Center(
                    child: Text(
                      "No hay imagen disponible",
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),

                ...observations.map((obs) {
                  final left = obs.x * size.width;
                  final top = obs.y * size.height;

                  return Positioned(
                    left: left,
                    top: top,
                    child: GestureDetector(
                      onTap: () => _showObservationDetails(obs),
                      child: Icon(
                        Icons.place,
                        size: 30,
                        color: _statusColor(obs.status),
                      ),
                    ),
                  );
                }).toList(),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showObservationDetails(Observation obs) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Observación'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (obs.imageUrl != null)
                Image.network(
                  obs.imageUrl!,
                  height: 120,
                  errorBuilder: (_, __, ___) => const Icon(Icons.broken_image),
                ),
              const SizedBox(height: 8),
              Text(obs.description),
              const SizedBox(height: 4),
              Text("Estado: ${statusToString(obs.status)}"),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cerrar"),
          )
        ],
      ),
    );
  }

  Color _statusColor(ObservationStatus status) {
    switch (status) {
      case ObservationStatus.resuelta:
        return Colors.green;
      case ObservationStatus.enProgreso:
        return Colors.orange;
      default:
        return Colors.red;
    }
  }
}