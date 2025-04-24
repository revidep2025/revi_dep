// lib/data/proyecto_model.dart

class Project {
  final String id;
  final DateTime createdAt;
  final String name;
  final String imageUrl;
  final String description;
  final String location;
  final String realEstateCompanyId;

  Project({
    required this.id,
    required this.createdAt,
    required this.name,
    required this.imageUrl,
    required this.description,
    required this.location,
    required this.realEstateCompanyId
  });

  /// Crea una instancia de [Project] a partir del JSON que retorna Supabase.
  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      id: json['id']?.toString() ?? '',
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      name: json['name'] ?? 'Sin nombre',
      imageUrl: json['image_url'] ?? '',
      description: json['description'] ?? 'Sin descripción',
      location: json['location'] ?? 'Sin ubicación',
      realEstateCompanyId: json['real_estate_company_id'] ?? '',
    );
  }

  /// Convierte este [Project] de nuevo a un mapa que puedes enviar a Supabase.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'created_at': createdAt.toIso8601String(),
      'name': name,
      'image_url': imageUrl,
      'description': description,
      'location': location,
      'real_estate_company_id': realEstateCompanyId,
    };
  }
}
