class Product {
  final String id;
  final String name;
  final String description;
  final double price;
  final int stock;
  final String categoryId;
  final List<String> images;
  final String sellerId;
  final bool isActive;
  final int weightGrams;
  final double totalRating;
  final int ratingCount;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.stock,
    required this.categoryId,
    required this.images,
    required this.sellerId,
    required this.isActive,
    this.weightGrams = 0,
    this.totalRating = 0,
    this.ratingCount = 0,
  });


  Product copyWith({
    String? id,
    String? name,
    String? description,
    double? price,
    int? stock,
    String? categoryId,
    List<String>? images,
    String? sellerId,
    bool? isActive,
    int? weightGrams,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      stock: stock ?? this.stock,
      categoryId: categoryId ?? this.categoryId,
      images: images ?? this.images,
      sellerId: sellerId ?? this.sellerId,
      isActive: isActive ?? this.isActive,
      weightGrams: weightGrams ?? this.weightGrams,
    );
  }

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0,
      stock: json['stock'] as int? ?? 0,
      categoryId: json['category_id'] as String? ?? '',
      images: List<String>.from(json['images'] ?? []),
      sellerId: json['seller_id'] as String? ?? '',
      isActive: json['is_active'] as bool? ?? true,
      weightGrams: (json['weight_grams'] as num?)?.toInt() ?? 0,
      totalRating: (json['total_rating'] as num?)?.toDouble() ?? 0,
      ratingCount: (json['rating_count'] as num?)?.toInt() ?? 0,
    );
  }

   Map<String, dynamic> toJson() {
     return {
       if (id.isNotEmpty) 'id': id,
       'name': name,
       'description': description,
       'price': price,
       'stock': stock,
       'category_id': categoryId,
       'images': images,
       'seller_id': sellerId,
       'is_active': isActive,
       'weight_grams': weightGrams,
     };
   }
}