import 'package:flutter/material.dart';
import '../models/observation_model.dart';
import '../services/observation_service.dart';
import '../pages/visitas_pages.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart'; // 👈 Importar para usar fecha actual

class DepartmentObservationsPage extends StatefulWidget {
  final String departmentId;
  final String unitCode;
  const DepartmentObservationsPage({super.key, required this.departmentId, required this.unitCode});

  @override
  State<DepartmentObservationsPage> createState() => _DepartmentObservationsPageState();
}

class _DepartmentObservationsPageState extends State<DepartmentObservationsPage> {
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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('⚠️ No se encontraron observaciones')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('✅ Observaciones cargadas: ${data.length}')),
        );
      }

      setState(() => observations = data);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Error al cargar observaciones: $e')),
      );
    }
  }

  Future<void> _generatePdf() async {
    final pdf = pw.Document();
    final String fechaActual = DateFormat('dd/MM/yyyy').format(DateTime.now()); // 📅 Fecha actual

    pdf.addPage(
      pw.Page(
        margin: const pw.EdgeInsets.all(32),
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('Observaciones del Departamento ${widget.unitCode}',
                style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 8),
            pw.Text('Fecha: $fechaActual',
                style: pw.TextStyle(fontSize: 14)),
            pw.SizedBox(height: 20),
            pw.Table.fromTextArray(
              headers: ['Fecha de Creación', 'Fecha de Expiración', 'Confirmado', 'Estado'],
              data: observations.map((obs) => [
                obs.createdAtFormatted(),
                obs.expiresAtFormatted(),
                obs.confirmedAtFormatted(),
                obs.statusFormatted(),
              ]).toList(),
              cellAlignment: pw.Alignment.center,
              headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
              headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              cellHeight: 30,
              cellAlignments: {
                0: pw.Alignment.center,
                1: pw.Alignment.center,
                2: pw.Alignment.center,
                3: pw.Alignment.center,
              },
            ),
            pw.SizedBox(height: 40),
            pw.Text('_________________________',
                style: pw.TextStyle(fontSize: 18),
                textAlign: pw.TextAlign.center),
            pw.SizedBox(height: 4),
            pw.Center(child: pw.Text('Firma Responsable', style: pw.TextStyle(fontSize: 14))),
          ],
        ),
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Observaciones del Departamento'),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            tooltip: 'Imprimir',
            onPressed: _generatePdf,
          )
        ],
      ),
      body: observations.isEmpty
          ? const Center(child: Text('No hay observaciones disponibles'))
          : SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('Fecha de Creación')),
                  DataColumn(label: Text('Fecha de Expiración')),
                  DataColumn(label: Text('Confirmado')),
                  DataColumn(label: Text('Estado')),
                  DataColumn(label: Text('Acciones')),
                ],
                rows: observations.map((obs) {
                  return DataRow(
                    cells: [
                      DataCell(Text(obs.createdAtFormatted())),
                      DataCell(Text(obs.expiresAtFormatted())),
                      DataCell(Text(obs.confirmedAtFormatted())),
                      DataCell(Text(obs.statusFormatted())),
                      DataCell(
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => VisitasPage(observationId: obs.id),
                              ),
                            );
                          },
                          child: const Text('+ Visitar'),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
    );
  }
}

extension ObservationFormat on Observation {
  String createdAtFormatted() => createdAt != null ? createdAt!.toLocal().toString().split(' ')[0] : '-';
  String expiresAtFormatted() => expiresAt != null ? expiresAt!.toLocal().toString().split(' ')[0] : '-';
  String confirmedAtFormatted() => confirmedAt != null ? confirmedAt!.toLocal().toString().split(' ')[0] : 'No';
  String statusFormatted() => statusToString(status);
}
