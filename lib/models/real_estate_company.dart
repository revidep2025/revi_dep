class RealEstateCompany {
  final String id;
  final String name;
  final String logoImageUrl;
  final DateTime createdAt;

  RealEstateCompany({
    required this.id,
    required this.name,
    required this.logoImageUrl,
    required this.createdAt,
  });

  factory RealEstateCompany.fromJson(Map<String, dynamic> json) {
    return RealEstateCompany(
      id: json['id'],
      name: json['name'],
      logoImageUrl: json['logo_image_url'] ?? '',
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'logo_image_url': logoImageUrl,
        'created_at': createdAt.toIso8601String(),
      };
}
