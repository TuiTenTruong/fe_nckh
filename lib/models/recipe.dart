class Recipe {
  const Recipe({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.difficulty,
    required this.cookTimeMinutes,
    required this.isFeatured,
    this.rating,
  });

  final String id;
  final String name;
  final String description;
  final String imageUrl;
  final String difficulty;
  final int cookTimeMinutes;
  final bool isFeatured;
  final double? rating;

  factory Recipe.fromJson(Map<String, dynamic> json) {
    return Recipe(
      id: (json['id'] ?? json['recipe_id'] ?? '').toString(),
      name: (json['name'] ?? 'Unknown recipe').toString(),
      description: (json['description'] ?? '').toString(),
      imageUrl: (json['image_url'] ?? '').toString(),
      difficulty: (json['difficulty'] ?? 'Medium').toString(),
      cookTimeMinutes: _asInt(json['cook_time_minutes']),
      isFeatured: _asBool(json['is_featured']),
      rating: _asDoubleOrNull(json['rating']),
    );
  }

  static int _asInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static bool _asBool(dynamic value) {
    if (value is bool) return value;
    if (value is num) return value != 0;
    final String text = (value ?? '').toString().toLowerCase();
    return text == 'true' || text == '1' || text == 'yes';
  }

  static double? _asDoubleOrNull(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString());
  }
}
