class AttributeKey {
  final String id;
  final String categoryId;
  final String keyName;
  final DateTime? createdAt;

  AttributeKey({
    required this.id,
    required this.categoryId,
    required this.keyName,
    this.createdAt,
  });

  factory AttributeKey.fromJson(Map<String, dynamic> json) {
    return AttributeKey(
      id: json['id'] as String,
      categoryId: json['category_id'] as String,
      keyName: json['key_name'] as String,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category_id': categoryId,
      'key_name': keyName,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
    };
  }
}
