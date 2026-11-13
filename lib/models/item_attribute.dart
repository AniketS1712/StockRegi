class ItemAttribute {
  final String id;
  final String itemId;
  final String attributeKeyId;
  final String value;
  final DateTime? createdAt;
  final String? attributeKeyName;

  ItemAttribute({
    required this.id,
    required this.itemId,
    required this.attributeKeyId,
    required this.value,
    this.createdAt,
    this.attributeKeyName,
  });

  factory ItemAttribute.fromJson(Map<String, dynamic> json) {
    String? keyName;
    if (json['attribute_keys'] != null && json['attribute_keys'] is Map) {
      keyName = json['attribute_keys']['key_name'] as String?;
    }
    return ItemAttribute(
      id: json['id'] as String,
      itemId: json['item_id'] as String,
      attributeKeyId: json['attribute_key_id'] as String,
      value: json['value'] as String,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      attributeKeyName: keyName,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'item_id': itemId,
      'attribute_key_id': attributeKeyId,
      'value': value,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
    };
  }
}
