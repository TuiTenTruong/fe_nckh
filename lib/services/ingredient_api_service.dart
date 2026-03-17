import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/ingredient_category_item.dart';
import '../models/ingredient_item.dart';
import 'api_config.dart';

class IngredientApiService {
  static Future<http.Response> _getWithFallback(
    String path,
    Map<String, String> query,
  ) async {
    Object? lastError;
    int? lastStatusCode;

    for (final String base in ApiConfig.candidateBaseUrls) {
      final Uri uri = ApiConfig.buildUri(base, path, query: query);
      debugPrint('[IngredientApi] GET $uri');

      try {
        final http.Response response = await http
            .get(uri)
            .timeout(const Duration(seconds: 5));
        if (response.statusCode >= 200 && response.statusCode < 300) {
          debugPrint('[IngredientApi] SUCCESS $uri (${response.statusCode})');
          return response;
        }

        lastStatusCode = response.statusCode;
        debugPrint('[IngredientApi] FAIL $uri (${response.statusCode})');
      } catch (e) {
        lastError = e;
        debugPrint('[IngredientApi] ERROR $uri -> $e');
      }
    }

    if (lastStatusCode != null) {
      throw Exception(
        'Không tải được dữ liệu nguyên liệu (HTTP $lastStatusCode)',
      );
    }
    throw Exception('Không kết nối được API nguyên liệu: $lastError');
  }

  static Future<List<IngredientItem>> getRandomIngredients({
    int limit = 12,
    String? categoryId,
  }) async {
    final Map<String, String> query = <String, String>{'limit': '$limit'};
    if (categoryId != null && categoryId.isNotEmpty) {
      query['category_id'] = categoryId;
    }

    final http.Response response = await _getWithFallback(
      '/api/ingredients/random',
      query,
    );

    final Map<String, dynamic> body =
        jsonDecode(response.body) as Map<String, dynamic>;
    final List<dynamic> data = (body['data'] as List<dynamic>?) ?? <dynamic>[];

    return data
        .whereType<Map<String, dynamic>>()
        .map(IngredientItem.fromJson)
        .toList();
  }

  static Future<List<IngredientItem>> getPopularIngredients({
    int limit = 8,
  }) async {
    final http.Response response = await _getWithFallback(
      '/api/ingredients/popular',
      <String, String>{'limit': '$limit'},
    );

    final Map<String, dynamic> body =
        jsonDecode(response.body) as Map<String, dynamic>;
    final List<dynamic> data = (body['data'] as List<dynamic>?) ?? <dynamic>[];

    return data
        .whereType<Map<String, dynamic>>()
        .map(IngredientItem.fromJson)
        .toList();
  }

  static Future<List<IngredientCategoryItem>> getCategories() async {
    final http.Response response = await _getWithFallback(
      '/api/categories',
      const <String, String>{},
    );

    final Map<String, dynamic> body =
        jsonDecode(response.body) as Map<String, dynamic>;
    final List<dynamic> data = (body['data'] as List<dynamic>?) ?? <dynamic>[];

    return data
        .whereType<Map<String, dynamic>>()
        .map(IngredientCategoryItem.fromJson)
        .toList();
  }

  static Future<List<IngredientItem>> getIngredientsByCategory({
    required String categoryId,
    int limit = 50,
  }) async {
    final http.Response response = await _getWithFallback(
      '/api/ingredients/category/$categoryId',
      <String, String>{'limit': '$limit'},
    );

    final Map<String, dynamic> body =
        jsonDecode(response.body) as Map<String, dynamic>;
    final List<dynamic> data = (body['data'] as List<dynamic>?) ?? <dynamic>[];

    return data
        .whereType<Map<String, dynamic>>()
        .map(IngredientItem.fromJson)
        .toList();
  }
}
