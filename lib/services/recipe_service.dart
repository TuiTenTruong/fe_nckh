import 'dart:convert';

import 'package:http/http.dart' as http;

import '../constants/constants.dart';
import '../models/models.dart';

class RecipePage {
  const RecipePage({
    required this.items,
    required this.page,
    required this.perPage,
    required this.total,
    required this.hasNextPage,
  });

  final List<Recipe> items;
  final int page;
  final int perPage;
  final int total;
  final bool hasNextPage;
}

class RecipeService {
  const RecipeService();

  Future<RecipePage> fetchRecipes({
    int page = 1,
    int perPage = 10,
    String? search,
    String? difficulty,
    bool? isFeatured,
  }) async {
    final Map<String, String> query = <String, String>{
      'page': '$page',
      'per_page': '$perPage',
    };

    if (search != null && search.trim().isNotEmpty) {
      query['search'] = search.trim();
    }

    if (difficulty != null && difficulty.trim().isNotEmpty) {
      query['difficulty'] = difficulty.trim();
    }

    if (isFeatured != null) {
      query['is_featured'] = isFeatured.toString();
    }

    final Uri uri = Uri.parse(
      '${ApiConfig.baseUrl}${ApiConfig.recipesPath}',
    ).replace(queryParameters: query);

    final http.Response response = await http.get(uri);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Cannot load recipes (${response.statusCode}).');
    }

    final dynamic decoded = jsonDecode(response.body);
    final Map<String, dynamic> root = decoded is Map<String, dynamic>
        ? decoded
        : <String, dynamic>{};

    final List<dynamic> rawItems = _extractItems(root, decoded);
    final List<Recipe> items = rawItems
        .whereType<Map<String, dynamic>>()
        .map(Recipe.fromJson)
        .toList();

    final int serverPage = _asInt(root['page'], fallback: page);
    final int serverPerPage = _asInt(root['per_page'], fallback: perPage);
    final int total = _extractTotal(
      root,
      items.length,
      serverPage,
      serverPerPage,
    );
    final bool hasNextPage = (serverPage * serverPerPage) < total;

    return RecipePage(
      items: items,
      page: serverPage,
      perPage: serverPerPage,
      total: total,
      hasNextPage: hasNextPage,
    );
  }

  Future<RecipeDetail> fetchRecipeDetail(String recipeId) async {
    final String encodedId = Uri.encodeComponent(recipeId);
    final Uri detailUri =
        Uri.parse(
          '${ApiConfig.baseUrl}${ApiConfig.recipesPath}/$encodedId',
        ).replace(
          queryParameters: const <String, String>{
            'include_ingredients': 'true',
            'include_steps': 'true',
          },
        );

    final Map<String, dynamic> detailMap = await _getAsMap(detailUri);

    List<RecipeIngredient> ingredients = _extractIngredients(detailMap);
    List<RecipeStep> steps = _extractSteps(detailMap);

    if (ingredients.isEmpty) {
      ingredients = await _fetchIngredientsFallback(encodedId);
    }

    if (steps.isEmpty) {
      steps = await _fetchStepsFallback(encodedId);
    }

    return RecipeDetail.fromJson(
      detailMap,
      ingredientsOverride: ingredients,
      stepsOverride: steps,
    );
  }

  Future<List<RecipeIngredient>> _fetchIngredientsFallback(
    String encodedId,
  ) async {
    final Uri uri = Uri.parse(
      '${ApiConfig.baseUrl}${ApiConfig.recipesPath}/$encodedId/ingredients',
    );

    final Map<String, dynamic> map = await _getAsMap(uri);
    return _extractIngredients(map);
  }

  Future<List<RecipeStep>> _fetchStepsFallback(String encodedId) async {
    final Uri uri = Uri.parse(
      '${ApiConfig.baseUrl}${ApiConfig.recipesPath}/$encodedId/steps',
    );

    final Map<String, dynamic> map = await _getAsMap(uri);
    return _extractSteps(map);
  }

  Future<Map<String, dynamic>> _getAsMap(Uri uri) async {
    final http.Response response = await http.get(uri);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Cannot load data (${response.statusCode}) from $uri');
    }

    final dynamic decoded = jsonDecode(response.body);
    if (decoded is Map<String, dynamic>) {
      final dynamic data = decoded['data'];
      if (data is Map<String, dynamic>) return data;
      return decoded;
    }

    throw Exception('Invalid response format from $uri');
  }

  List<RecipeIngredient> _extractIngredients(Map<String, dynamic> map) {
    final List<dynamic> raw = _extractItemsByKeys(map, const <String>[
      'ingredients',
      'recipe_ingredients',
    ]);

    return raw
        .whereType<Map<String, dynamic>>()
        .map(RecipeIngredient.fromJson)
        .toList()
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
  }

  List<RecipeStep> _extractSteps(Map<String, dynamic> map) {
    final List<dynamic> raw = _extractItemsByKeys(map, const <String>[
      'steps',
      'recipe_steps',
    ]);

    return raw
        .whereType<Map<String, dynamic>>()
        .map(RecipeStep.fromJson)
        .toList()
      ..sort((a, b) {
        if (a.stepNumber == b.stepNumber) return 0;
        if (a.stepNumber == 0) return 1;
        if (b.stepNumber == 0) return -1;
        return a.stepNumber.compareTo(b.stepNumber);
      });
  }

  List<dynamic> _extractItemsByKeys(
    Map<String, dynamic> map,
    List<String> keys,
  ) {
    for (final String key in keys) {
      final dynamic value = map[key];
      if (value is List<dynamic>) return value;
      if (value is Map<String, dynamic>) {
        final dynamic nested =
            value['items'] ?? value['results'] ?? value['data'];
        if (nested is List<dynamic>) return nested;
      }
    }

    final dynamic data = map['data'];
    if (data is List<dynamic>) return data;
    if (data is Map<String, dynamic>) {
      final dynamic nested =
          data['items'] ??
          data['results'] ??
          data['ingredients'] ??
          data['steps'];
      if (nested is List<dynamic>) return nested;
    }

    final dynamic nestedItems = map['items'];
    if (nestedItems is List<dynamic>) return nestedItems;

    final dynamic nestedResults = map['results'];
    if (nestedResults is List<dynamic>) return nestedResults;

    return <dynamic>[];
  }

  List<dynamic> _extractItems(Map<String, dynamic> root, dynamic decoded) {
    if (decoded is List<dynamic>) return decoded;

    final dynamic data = root['data'];
    if (data is List<dynamic>) return data;

    if (data is Map<String, dynamic>) {
      final dynamic nested =
          data['items'] ?? data['results'] ?? data['recipes'];
      if (nested is List<dynamic>) return nested;
    }

    final dynamic direct = root['items'] ?? root['results'] ?? root['recipes'];
    if (direct is List<dynamic>) return direct;

    return <dynamic>[];
  }

  int _extractTotal(
    Map<String, dynamic> root,
    int currentLength,
    int page,
    int perPage,
  ) {
    final int direct = _asInt(root['total'], fallback: -1);
    if (direct >= 0) return direct;

    final dynamic data = root['data'];
    if (data is Map<String, dynamic>) {
      final int nested = _asInt(data['total'], fallback: -1);
      if (nested >= 0) return nested;
    }

    // Fallback when backend does not return total.
    return ((page - 1) * perPage) + currentLength;
  }

  int _asInt(dynamic value, {required int fallback}) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? fallback;
  }
}
