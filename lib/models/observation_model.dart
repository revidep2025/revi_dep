import 'package:flutter/material.dart';

enum ObservationStatus {
  noIniciada,
  enProgreso,
  resuelta,
}

String statusToString(ObservationStatus status) {
  switch (status) {
    case ObservationStatus.noIniciada:
      return "No iniciada";
    case ObservationStatus.enProgreso:
      return "En progreso";
    case ObservationStatus.resuelta:
      return "Resuelta";
  }
}

class Observation {
  final String id;
  final String? imageUrl;
  final String description;
  final double x; // <- Coordenada X
  final double y; // <- Coordenada Y
  final ObservationStatus status;
  final DateTime? createdAt;    // 🔥 Agregado
  final DateTime? expiresAt;    // 🔥 Agregado
  final DateTime? confirmedAt;  // 🔥 Agregado

  Observation({
    required this.id,
    this.imageUrl,
    required this.description,
    required this.x,
    required this.y,
    required this.status,
    this.createdAt,     // 🔥 Agregado
    this.expiresAt,     // 🔥 Agregado
    this.confirmedAt,   // 🔥 Agregado
  });

  factory Observation.fromMap(Map<String, dynamic> map) {
  return Observation(
    id: map['id'] as String,
    imageUrl: map['image_url'] as String?,
    description: map['description'] as String,
    x: (map['x'] as num).toDouble(),
    y: (map['y'] as num).toDouble(),
    status: _parseStatus(map['status']), // <-- CAMBIA ESTO

    // 🔥 Agregamos mapeo de fechas
      createdAt: map['created_at'] != null ? DateTime.parse(map['created_at']) : null,
      expiresAt: map['expires_at'] != null ? DateTime.parse(map['expires_at']) : null,
      confirmedAt: map['confirmed_at'] != null ? DateTime.parse(map['confirmed_at']) : null,
  );
}

static ObservationStatus _parseStatus(dynamic statusValue) {
  if (statusValue == null) return ObservationStatus.noIniciada;
  if (statusValue == 'resuelta') return ObservationStatus.resuelta;
  if (statusValue == 'en_progreso') return ObservationStatus.enProgreso;
  return ObservationStatus.noIniciada;
}

}
