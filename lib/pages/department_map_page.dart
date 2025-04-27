import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:revi_dep/pages/department_observation_page.dart';
import '../models/observation_model.dart';
import '../services/observation_service.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';


class DepartmentMapPage extends StatefulWidget {
  final String departmentId;
  final String imageUrl;
   final String unitCode;

  const DepartmentMapPage({
    super.key,
    required this.departmentId,
    required this.imageUrl,
    required this.unitCode, 
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
      final data = await _obsService.getAllObservationsByDepartment(widget.departmentId);

      if (data.isEmpty) {
        print('⚠️ No hay observaciones para este departamento.');
      }

      for (final o in data) {
        print('🧭 Observación recuperada: id=${o.id}, x=${o.x}, y=${o.y}');
      }

      setState(() => observations = data);
    } catch (e) {
      print('Error al obtener observaciones: $e');
    }
  }


Future<void> _generatePdf() async {
  final pdf = pw.Document();

  pdf.addPage(
    pw.Page(
      margin: const pw.EdgeInsets.all(32),
      build: (context) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          // Título
          pw.Center(
            child: pw.Text(
              'ACTA DE DEPARTAMENTO ${widget.unitCode}',
              style: pw.TextStyle(
                fontSize: 22,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          ),
          pw.SizedBox(height: 20),

          // Fecha
          pw.Text('Fecha: ${DateFormat('dd/MM/yyyy').format(DateTime.now())}',
              style: pw.TextStyle(fontSize: 14)),
          pw.SizedBox(height: 20),

          // Observaciones
          pw.Text('Observaciones:', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 12),

          if (observations.isEmpty)
            pw.Text('No hay observaciones registradas.', style: const pw.TextStyle(fontSize: 14))
          else
            ...observations.asMap().entries.map((entry) {
              final idx = entry.key + 1;
              return pw.Container(
                margin: const pw.EdgeInsets.only(bottom: 16),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('Observación Nº$idx:', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
                    pw.SizedBox(height: 8),
                    pw.Text('Descripción: _______________________________________________', style: const pw.TextStyle(fontSize: 14)),
                    pw.SizedBox(height: 8),
                    pw.Text('Fecha límite: _______________________________________________', style: const pw.TextStyle(fontSize: 14)),
                    pw.SizedBox(height: 8),
                    pw.Text('Confirmado: _______________________________________________', style: const pw.TextStyle(fontSize: 14)),
                  ],
                ),
              );
            }).toList(),

          // Espacio para firma
          pw.Spacer(),
          pw.SizedBox(height: 40),
          pw.Divider(),
          pw.Center(
            child: pw.Text('Firma del responsable', style: const pw.TextStyle(fontSize: 14)),
          ),
        ],
      ),
    ),
  );

  await Printing.layoutPdf(
    onLayout: (PdfPageFormat format) async => pdf.save(),
  );
}








  void _addObservationAt(Offset position, Size size) {
    final x = (position.dx / size.width).clamp(0.0, 1.0);
    final y = (position.dy / size.height).clamp(0.0, 1.0);

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
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('PLANO'),
        centerTitle: true,
        actions: [

           IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            tooltip: 'Generar Acta',
            onPressed: _generatePdf,
          ),
                      IconButton(
              icon: const Icon(Icons.list_alt),
              tooltip: 'Ver Observaciones',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => DepartmentObservationsPage(
                      departmentId: widget.departmentId,
                       unitCode: widget.unitCode, 
                    ),
                  ),
                );
              },
            ),
          IconButton(
            icon: const Icon(Icons.notifications),
            tooltip: 'Notificaciones',
            onPressed: () {
              Navigator.pushNamed(context, '/notificaciones');
            },
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final size = Size(constraints.maxWidth, constraints.maxHeight);

          return GestureDetector(
            onTapUp: (details) => _addObservationAt(details.localPosition, size),
            child: Stack(
              children: [
                Positioned.fill(
                  child: widget.imageUrl.isNotEmpty
                      ? FittedBox(
                          fit: BoxFit.fill,
                          child: SizedBox(
                            width: size.width,
                            height: size.height,
                            child: Image.network(
                              widget.imageUrl,
                              fit: BoxFit.fill,
                              errorBuilder: (context, error, stackTrace) => const Center(
                                child: Text("Error al cargar imagen"),
                              ),
                            ),
                          ),
                        )
                      : Container(color: Colors.white),
                ),
                ...observations.map((obs) {
                  final left = (obs.x * size.width).clamp(0.0, size.width);
                  final top = (obs.y * size.height).clamp(0.0, size.height);
                  const squareSize = 24.0;

                  return Positioned(
                    left: left - squareSize / 2,
                    top: top - squareSize / 2,
                    child: GestureDetector(
                      onTap: () => _showObservationDetails(obs),
                      child: Container(
                        width: squareSize,
                        height: squareSize,
                        decoration: BoxDecoration(
                          color: _statusColor(obs.status).withOpacity(0.8),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: Colors.white, width: 1),
                        ),
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
              Text('Estado: ${statusToString(obs.status)}'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
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
