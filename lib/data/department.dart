// lib/models/department.dart

class Department {
  final String id;
  final int unitCode;
  final DateTime createdAt;
  final String planImageUrl;
  final String projectId;

  Department({
    required this.id,
    required this.unitCode,
    required this.createdAt,
    required this.planImageUrl,
    required this.projectId,
  });

  factory Department.fromJson(Map<String, dynamic> json) => Department(
    id: json['id'],
    unitCode: json['unit_code'],
    createdAt: DateTime.parse(json['created_at']),
    planImageUrl: json['plan_image_url'],
    projectId: json['project_id'],
  );

  Map<String, dynamic> toJson() => {
    'unit_code': unitCode,
    'created_at': createdAt.toIso8601String(),
    'plan_image_url': planImageUrl,
    'project_id': projectId,
  };
}

