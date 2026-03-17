class PantryItem {
  const PantryItem({
    required this.id,
    required this.userId,
    required this.ingredientId,
    required this.quantity,
    required this.ingredientName,
    required this.ingredientIcon,
  });

  final String id;
  final String userId;
  final String ingredientId;
  final String quantity;
  final String ingredientName;
  final String ingredientIcon;

  factory PantryItem.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> ingredient =
        (json['ingredient'] as Map<String, dynamic>?) ?? <String, dynamic>{};

    return PantryItem(
      id: (json['id'] ?? '').toString(),
      userId: (json['user_id'] ?? '').toString(),
      ingredientId: (json['ingredient_id'] ?? '').toString(),
      quantity: (json['quantity'] ?? '').toString(),
      ingredientName: (ingredient['name'] ?? '').toString(),
      ingredientIcon: (ingredient['icon'] ?? '🥬').toString(),
    );
  }

  factory PantryItem.fromCacheJson(Map<String, dynamic> json) {
    return PantryItem(
      id: (json['id'] ?? '').toString(),
      userId: (json['user_id'] ?? '').toString(),
      ingredientId: (json['ingredient_id'] ?? '').toString(),
      quantity: (json['quantity'] ?? '').toString(),
      ingredientName: (json['ingredient_name'] ?? '').toString(),
      ingredientIcon: (json['ingredient_icon'] ?? '🥬').toString(),
    );
  }

  Map<String, dynamic> toCacheJson() {
    return <String, dynamic>{
      'id': id,
      'user_id': userId,
      'ingredient_id': ingredientId,
      'quantity': quantity,
      'ingredient_name': ingredientName,
      'ingredient_icon': ingredientIcon,
    };
  }
}
