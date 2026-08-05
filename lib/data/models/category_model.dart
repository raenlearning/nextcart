class Category {
  final String id;        
  final String name;         
  final String? iconUrl;     
  final String? parentId;    
  final DateTime createdAt;  

  Category({
    required this.id,
    required this.name,
    this.iconUrl,
    this.parentId,
    required this.createdAt,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] as String,
      name: json['name'] as String,
      iconUrl: json['icon_url'] as String?,
      parentId: json['parent_id'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'icon_url': iconUrl,
      'parent_id': parentId,
      'created_at': createdAt.toIso8601String(),
    };
  }

}