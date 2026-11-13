class Business {
  final String id;
  final String ownerId;
  final String name;
  final String role; // 'seller' | 'producer'
  final DateTime? createdAt;

  Business({
    required this.id,
    required this.ownerId,
    required this.name,
    required this.role,
    this.createdAt,
  });

  factory Business.fromJson(Map<String, dynamic> json) {
    return Business(
      id: json['id'] as String,
      ownerId: json['owner_id'] as String,
      name: json['name'] as String,
      role: json['role'] as String,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'owner_id': ownerId,
      'name': name,
      'role': role,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
    };
  }
}
