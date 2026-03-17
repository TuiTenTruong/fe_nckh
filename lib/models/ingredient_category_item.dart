class IngredientCategoryItem {
  const IngredientCategoryItem({
    required this.id,
    required this.slug,
    required this.name,
    required this.icon,
    required this.sortOrder,
  });

  final String id;
  final String slug;
  final String name;
  final String icon;
  final int sortOrder;

  factory IngredientCategoryItem.fromJson(Map<String, dynamic> json) {
    final dynamic rawSortOrder = json['sort_order'];
    return IngredientCategoryItem(
      id: (json['id'] ?? '').toString(),
      slug: (json['slug'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      icon: (json['icon'] ?? '🥬').toString(),
      sortOrder: rawSortOrder is num
          ? rawSortOrder.toInt()
          : int.tryParse((rawSortOrder ?? '').toString()) ?? 0,
    );
  }
}
