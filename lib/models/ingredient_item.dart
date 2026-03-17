class IngredientItem {
  const IngredientItem({
    required this.id,
    required this.name,
    required this.icon,
    this.categoryId,
    this.imageUrl,
    this.categoryName,
  });

  final String id;
  final String name;
  final String icon;
  final String? categoryId;
  final String? imageUrl;
  final String? categoryName;

  factory IngredientItem.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic>? category =
        json['category'] is Map<String, dynamic>
        ? json['category'] as Map<String, dynamic>
        : null;

    return IngredientItem(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      icon: (json['icon'] ?? '🥬').toString(),
      categoryId: (json['category_id'] ?? '').toString(),
      imageUrl: (json['image_url'] ?? '').toString(),
      categoryName: category == null
          ? null
          : (category['name'] ?? '').toString(),
    );
  }
}
