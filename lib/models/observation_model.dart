import 'package:flutter/material.dart';

enum ObservationStatus {
  noIniciada,
  enProgreso,
  resuelta,
}

ObservationStatus parseStatus(String value) {
  switch (value.toLowerCase()) {
    case 'en_progreso':
      return ObservationStatus.enProgreso;
    case 'resuelta':
      return ObservationStatus.resuelta;
    case 'no_iniciada':
    default:
      return ObservationStatus.noIniciada;
  }
}

String statusToString(ObservationStatus status) {
  switch (status) {
    case ObservationStatus.noIniciada:
      return 'no_iniciada';
    case ObservationStatus.enProgreso:
      return 'en_progreso';
    case ObservationStatus.resuelta:
      return 'resuelta';
  }
}

class Observation {
  final String id;
  final String departmentId;
  final double x; // 0.0 - 1.0
  final double y;
  final String description;
  final String? imageUrl;
  final ObservationStatus status;
  final DateTime createdAt;

  Observation({
    required this.id,
    required this.departmentId,
    required this.x,
    required this.y,
    required this.description,
    this.imageUrl,
    required this.status,
    required this.createdAt,
  });

  /// Usado para posicionar en Stack con dimensiones de la imagen
  Offset get position => Offset(x, y);

  factory Observation.fromJson(Map<String, dynamic> json) {
    return Observation(
      id: json['id'] ?? '',
      departmentId: json['department_id'] ?? '',
      x: (json['x'] as num).toDouble(),
      y: (json['y'] as num).toDouble(),
      description: json['description'] ?? '',
      imageUrl: json['image_url'],
      status: parseStatus(json['status'] ?? 'no_iniciada'),
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'department_id': departmentId,
      'x': x,
      'y': y,
      'description': description,
      'image_url': imageUrl,
      'status': statusToString(status),
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// Para crear una nueva observación desde UI
  static Observation createNew({
    required String departmentId,
    required Offset position,
    required String description,
    required ObservationStatus status,
    String? imageUrl,
  }) {
    return Observation(
      id: '', // se asignará en Supabase
      departmentId: departmentId,
      x: position.dx,
      y: position.dy,
      description: description,
      status: status,
      imageUrl: imageUrl,
      createdAt: DateTime.now(),
    );
  }
}
