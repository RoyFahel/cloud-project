class Product {
  final String? id;
  final String productName;
  final String description;
  final String? categoryId;
  final String? categoryName; // For populated responses
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Product({
    this.id,
    required this.productName,
    required this.description,
    this.categoryId,
    this.categoryName,
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

    String? extractCategoryId() {
      final categoryField = json['category_id'];
      if (categoryField == null) return null;
      
      // Handle populated category object
      if (categoryField is Map<String, dynamic>) {
        final idField = categoryField['_id'] ?? categoryField['id'];
        if (idField is Map<String, dynamic> && idField.containsKey('\$oid')) {
          return idField['\$oid']?.toString();
        }
        return idField?.toString();
      }
      
      // Handle ObjectId format
      if (categoryField is Map<String, dynamic> && categoryField.containsKey('\$oid')) {
        return categoryField['\$oid']?.toString();
      }
      
      return categoryField.toString();
    }

    String? extractCategoryName() {
      final categoryField = json['category_id'];
      if (categoryField is Map<String, dynamic>) {
        return categoryField['categoryName']?.toString();
      }
      return null;
    }

    return Product(
      id: extractId(),
      productName: json['productName'] ?? '',
      description: json['description'] ?? '',
      categoryId: extractCategoryId(),
      categoryName: extractCategoryName(),
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
    
    if (categoryId != null) data['category_id'] = categoryId;
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
    String? categoryId,
    String? categoryName,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Product(
      id: id ?? this.id,
      productName: productName ?? this.productName,
      description: description ?? this.description,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'Product(id: $id, productName: $productName, categoryName: $categoryName)';
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