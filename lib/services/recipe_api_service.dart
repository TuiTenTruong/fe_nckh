import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/recipe_item.dart';
import 'api_config.dart';

class RecipeApiService {
  static Future<http.Response> _getWithFallback(
    String path,
    Map<String, String> query,
  ) async {
    Object? lastError;
    int? lastStatusCode;

    for (final String base in ApiConfig.candidateBaseUrls) {
      final Uri uri = ApiConfig.buildUri(base, path, query: query);
      debugPrint('[RecipeApi] GET $uri');

      try {
        final http.Response response = await http
            .get(uri)
            .timeout(const Duration(seconds: 5));
        if (response.statusCode >= 200 && response.statusCode < 300) {
          debugPrint('[RecipeApi] SUCCESS $uri (${response.statusCode})');
          return response;
        }

        lastStatusCode = response.statusCode;
        debugPrint('[RecipeApi] FAIL $uri (${response.statusCode})');
      } catch (e) {
        lastError = e;
        debugPrint('[RecipeApi] ERROR $uri -> $e');
      }
    }

    if (lastStatusCode != null) {
      throw Exception('Không tải được công thức (HTTP $lastStatusCode)');
    }
    throw Exception('Không kết nối được API công thức: $lastError');
  }

  static Future<List<RecipeItem>> getRandomRecipes({int limit = 4}) async {
    final http.Response response = await _getWithFallback(
      '/api/recipes/random',
      <String, String>{'limit': '$limit'},
    );

    final Map<String, dynamic> body =
        jsonDecode(response.body) as Map<String, dynamic>;
    final List<dynamic> data = (body['data'] as List<dynamic>?) ?? <dynamic>[];

    return data
        .whereType<Map<String, dynamic>>()
        .map(RecipeItem.fromJson)
        .toList();
  }
}
