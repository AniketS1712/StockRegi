class Category {
  final String id;
  final String businessId;
  final String name;
  final DateTime? createdAt;

  Category({
    required this.id,
    required this.businessId,
    required this.name,
    this.createdAt,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] as String,
      businessId: json['business_id'] as String,
      name: json['name'] as String,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'business_id': businessId,
      'name': name,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
    };
  }
}
