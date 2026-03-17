class RecipeItem {
  const RecipeItem({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.cookTimeMinutes,
    required this.difficulty,
    required this.isFeatured,
  });

  final String id;
  final String name;
  final String description;
  final String imageUrl;
  final int cookTimeMinutes;
  final String difficulty;
  final bool isFeatured;

  factory RecipeItem.fromJson(Map<String, dynamic> json) {
    final dynamic cookTimeRaw = json['cook_time_minutes'];

    return RecipeItem(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      imageUrl: (json['image_url'] ?? '').toString(),
      cookTimeMinutes: cookTimeRaw is num
          ? cookTimeRaw.toInt()
          : int.tryParse((cookTimeRaw ?? '').toString()) ?? 0,
      difficulty: (json['difficulty'] ?? '').toString(),
      isFeatured: json['is_featured'] == true,
    );
  }
}
