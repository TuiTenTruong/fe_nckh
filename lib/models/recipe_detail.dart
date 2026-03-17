import 'recipe.dart';

class RecipeIngredient {
  const RecipeIngredient({
    required this.id,
    required this.name,
    required this.amount,
    required this.isOptional,
    required this.sortOrder,
  });

  final String id;
  final String name;
  final String amount;
  final bool isOptional;
  final int sortOrder;

  factory RecipeIngredient.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> ingredientMap =
        json['ingredient'] is Map<String, dynamic>
        ? json['ingredient'] as Map<String, dynamic>
        : <String, dynamic>{};

    final String quantity = _asString(
      json['amount'] ?? json['quantity'] ?? json['qty'],
    );
    final String unit = _asString(
      json['unit'] ?? json['unit_name'] ?? json['measurement_unit'],
    );
    final String note = _asString(json['note'] ?? json['notes']);

    return RecipeIngredient(
      id: (json['id'] ?? json['recipe_ingredient_id'] ?? '').toString(),
      name: _asString(
        json['ingredient_name'] ??
            json['name'] ??
            ingredientMap['name'] ??
            ingredientMap['ingredient_name'],
      ),
      amount: _buildAmount(quantity: quantity, unit: unit, note: note),
      isOptional: _asBool(json['is_optional']),
      sortOrder: _asInt(json['sort_order']),
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

  static String _asString(dynamic value) {
    if (value == null) return '';
    return value.toString().trim();
  }

  static String _buildAmount({
    required String quantity,
    required String unit,
    required String note,
  }) {
    final List<String> parts = <String>[
      if (quantity.isNotEmpty) quantity,
      if (unit.isNotEmpty) unit,
    ];

    String amount = parts.join(' ').trim();
    if (note.isNotEmpty) {
      amount = amount.isEmpty ? note : '$amount ($note)';
    }

    return amount;
  }
}

class RecipeStep {
  const RecipeStep({
    required this.id,
    required this.stepNumber,
    required this.title,
    required this.description,
    this.durationMinutes,
    this.tip,
    this.imageUrl,
  });

  final String id;
  final int stepNumber;
  final String title;
  final String description;
  final int? durationMinutes;
  final String? tip;
  final String? imageUrl;

  factory RecipeStep.fromJson(Map<String, dynamic> json) {
    return RecipeStep(
      id: (json['id'] ?? json['step_id'] ?? '').toString(),
      stepNumber: _asInt(json['step_number']),
      title: (json['title'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      durationMinutes: _asNullableInt(json['duration_minutes']),
      tip: _asNullableString(json['tip']),
      imageUrl: _asNullableString(json['image_url']),
    );
  }

  static int _asInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static int? _asNullableInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString());
  }

  static String? _asNullableString(dynamic value) {
    if (value == null) return null;
    final String text = value.toString().trim();
    return text.isEmpty ? null : text;
  }
}

class RecipeDetail {
  const RecipeDetail({
    required this.recipe,
    required this.servings,
    required this.cuisineType,
    required this.dietTags,
    required this.ingredients,
    required this.steps,
  });

  final Recipe recipe;
  final int? servings;
  final String? cuisineType;
  final List<String> dietTags;
  final List<RecipeIngredient> ingredients;
  final List<RecipeStep> steps;

  factory RecipeDetail.fromJson(
    Map<String, dynamic> json, {
    List<RecipeIngredient>? ingredientsOverride,
    List<RecipeStep>? stepsOverride,
  }) {
    final List<RecipeIngredient> ingredients =
        ingredientsOverride ??
              _extractList(json, <String>['ingredients', 'recipe_ingredients'])
                  .whereType<Map<String, dynamic>>()
                  .map(RecipeIngredient.fromJson)
                  .toList()
          ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

    final List<RecipeStep> steps =
        stepsOverride ??
              _extractList(json, <String>['steps', 'recipe_steps'])
                  .whereType<Map<String, dynamic>>()
                  .map(RecipeStep.fromJson)
                  .toList()
          ..sort((a, b) {
            if (a.stepNumber == b.stepNumber) return 0;
            if (a.stepNumber == 0) return 1;
            if (b.stepNumber == 0) return -1;
            return a.stepNumber.compareTo(b.stepNumber);
          });

    return RecipeDetail(
      recipe: Recipe.fromJson(json),
      servings: _asNullableInt(json['servings']),
      cuisineType: _asNullableString(json['cuisine_type']),
      dietTags: _extractStringList(json['diet_tags']),
      ingredients: ingredients,
      steps: steps,
    );
  }

  static List<dynamic> _extractList(
    Map<String, dynamic> json,
    List<String> keys,
  ) {
    for (final String key in keys) {
      final dynamic value = json[key];
      if (value is List<dynamic>) return value;
      if (value is Map<String, dynamic>) {
        final dynamic nested = value['items'] ?? value['data'];
        if (nested is List<dynamic>) return nested;
      }
    }
    return <dynamic>[];
  }

  static List<String> _extractStringList(dynamic value) {
    if (value is List) {
      return value
          .map((dynamic item) => item.toString().trim())
          .where((String item) => item.isNotEmpty)
          .toList();
    }
    return <String>[];
  }

  static int? _asNullableInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString());
  }

  static String? _asNullableString(dynamic value) {
    if (value == null) return null;
    final String text = value.toString().trim();
    return text.isEmpty ? null : text;
  }
}
