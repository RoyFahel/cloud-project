class Group {
  final String? id;
  final String groupName;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Group({
    this.id,
    required this.groupName,
    this.createdAt,
    this.updatedAt,
  });

  // Convert from JSON (MongoDB response)
  factory Group.fromJson(Map<String, dynamic> json) {
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

    return Group(
      id: extractId(),
      groupName: json['groupName'] ?? '',
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
      'groupName': groupName,
      
    };
    
    if (id != null) data['_id'] = id;
    if (createdAt != null) data['createdAt'] = createdAt!.toIso8601String();
    if (updatedAt != null) data['updatedAt'] = updatedAt!.toIso8601String();
    
    return data;
  }

  // Copy with method for immutable updates
  Group copyWith({
    String? id,
    String? groupName,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Group(
      id: id ?? this.id,
      groupName: groupName ?? this.groupName,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'Group(id: $id, groupName: $groupName)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Group && other.id == id;
  }

  @override
  int get hashCode {
    return id.hashCode;
  }
}