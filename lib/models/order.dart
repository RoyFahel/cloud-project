class Order {
  final String? id;
  final String customerId;
  final String groupId;
  final String productId;
  final DateTime date;
 
  final DateTime? createdAt;
  final DateTime? updatedAt;
  
 
  final Map<String, dynamic>? customer;
  final Map<String, dynamic>? group;
  final Map<String, dynamic>? product;

  Order({
    this.id,
    required this.customerId,
    required this.groupId,
    required this.productId,
    required this.date,
    this.createdAt,
    this.updatedAt,
    this.customer,
    this.group,
    this.product,
  });

  // Convert from JSON (MongoDB response)
  factory Order.fromJson(Map<String, dynamic> json) {
    String? extractId() {
      final idField = json['_id'] ?? json['id'];
      if (idField == null) return null;
      
      if (idField is Map<String, dynamic> && idField.containsKey('\$oid')) {
        return idField['\$oid']?.toString();
      }
      
      return idField.toString();
    }

    return Order(
      id: extractId(),
      customerId: json['customer_id']?.toString() ?? '',
      groupId: json['group_id']?.toString() ?? '',
      productId: json['product_id']?.toString() ?? '',
      date: json['date'] != null 
          ? DateTime.parse(json['date'])
          : DateTime.now(),
     
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt'])
          : null,
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt'])
          : null,
      customer: json['customer_id'] is Map<String, dynamic> 
          ? Map<String, dynamic>.from(json['customer_id'])
          : null,
      group: json['group_id'] is Map<String, dynamic> 
          ? Map<String, dynamic>.from(json['group_id'])
          : null,
      product: json['product_id'] is Map<String, dynamic> 
          ? Map<String, dynamic>.from(json['product_id'])
          : null,
    );
  }

  // Convert to JSON (for MongoDB request)
  Map<String, dynamic> toJson() {
    return {
      'customer_id': customerId,
      'group_id': groupId,
      'product_id': productId,
      'date': date.toIso8601String(),
    
    };
  }

  @override
  String toString() {
    return 'Order(id: $id, customerId: $customerId, groupId: $groupId, productId: $productId, date: $date)';
  }
}