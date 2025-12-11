class Product {
  final String? id;
  final String productName;
  final String description;
  final String? groupId;
  final String? groupName; // For populated responses
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Product({
    this.id,
    required this.productName,
    required this.description,
    this.groupId,
    this.groupName,
    this.createdAt,
    this.updatedAt,
  });

  // Convert from JSON (MongoDB response)
  factory Product.fromJson(Map<String, dynamic> json) {
    String? extractId() {
      final idField = json['_id'] ?? json['id'];
      if (idField == null) return null;
      
      // Handle MongoDB ObjectId format: {"$oid": "..."}
      if (idField is Map<String, dynamic> && idField.containsKey('\$oid')) {
        return idField['\$oid']?.toString();
      }
      
      // Handle simple string ID
      return idField.toString();
    }

    String? extractGroupId() {
      final groupField = json['group_id'];
      if (groupField == null) return null;
      
      // Handle populated group object
      if (groupField is Map<String, dynamic>) {
        final idField = groupField['_id'] ?? groupField['id'];
        if (idField is Map<String, dynamic> && idField.containsKey('\$oid')) {
          return idField['\$oid']?.toString();
        }
        return idField?.toString();
      }
      
      // Handle ObjectId format
      if (groupField is Map<String, dynamic> && groupField.containsKey('\$oid')) {
        return groupField['\$oid']?.toString();
      }
      
      return groupField.toString();
    }

    String? extractGroupName() {
      final groupField = json['group_id'];
      if (groupField is Map<String, dynamic>) {
        return groupField['groupName']?.toString();
      }
      return null;
    }

    return Product(
      id: extractId(),
      productName: json['productName'] ?? '',
      description: json['description'] ?? '',
      groupId: extractGroupId(),
      groupName: extractGroupName(),
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt'])
          : null,
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt'])
          : null,
    );
  }

  // Convert to JSON (for MongoDB request)
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'productName': productName,
      'description': description,
    };
    
    if (groupId != null) data['group_id'] = groupId;
    if (id != null) data['_id'] = id;
    if (createdAt != null) data['createdAt'] = createdAt!.toIso8601String();
    if (updatedAt != null) data['updatedAt'] = updatedAt!.toIso8601String();
    
    return data;
  }

  // Copy with method for immutable updates
  Product copyWith({
    String? id,
    String? productName,
    String? description,
    String? groupId,
    String? groupName,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Product(
      id: id ?? this.id,
      productName: productName ?? this.productName,
      description: description ?? this.description,
      groupId: groupId ?? this.groupId,
      groupName: groupName ?? this.groupName,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'Product(id: $id, productName: $productName, groupName: $groupName)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Product && other.id == id;
  }

  @override
  int get hashCode {
    return id.hashCode;
  }
}