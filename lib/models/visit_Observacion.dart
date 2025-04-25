// MODELO: visita_observacion_model.dart

import 'package:flutter/material.dart';

class VisitaObservacion {
  final String id;
  final String observacionId;
  final String comentario;
  final String? imagenUrl;
  final DateTime fecha;

  VisitaObservacion({
    required this.id,
    required this.observacionId,
    required this.comentario,
    this.imagenUrl,
    required this.fecha,
  });

  factory VisitaObservacion.fromJson(Map<String, dynamic> json) {
    return VisitaObservacion(
      id: json['id'],
      observacionId: json['observacion_id'],
      comentario: json['comentario'],
      imagenUrl: json['imagen_url'],
      fecha: DateTime.parse(json['fecha']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'observacion_id': observacionId,
      'comentario': comentario,
      'imagen_url': imagenUrl,
      'fecha': fecha.toIso8601String(),
    };
  }
}
