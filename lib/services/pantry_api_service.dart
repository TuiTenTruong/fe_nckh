import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/pantry_item.dart';
import 'api_config.dart';

class PantryApiService {
  static Future<http.Response> _getWithFallback({
    required String path,
    required String userId,
  }) async {
    Object? lastError;
    int? lastStatusCode;

    for (final String base in ApiConfig.candidateBaseUrls) {
      final Uri uri = ApiConfig.buildUri(base, path);
      debugPrint('[PantryApi] GET $uri');

      try {
        final http.Response response = await http
            .get(uri, headers: <String, String>{'X-User-Id': userId})
            .timeout(const Duration(seconds: 5));
        if (response.statusCode >= 200 && response.statusCode < 300) {
          debugPrint('[PantryApi] SUCCESS $uri (${response.statusCode})');
          return response;
        }

        lastStatusCode = response.statusCode;
      } catch (e) {
        lastError = e;
      }
    }

    if (lastStatusCode != null) {
      throw Exception('Không tải được kho nguyên liệu (HTTP $lastStatusCode)');
    }
    throw Exception('Không kết nối được API kho nguyên liệu: $lastError');
  }

  static Future<http.Response> _sendWithFallback({
    required String path,
    required String method,
    required String userId,
    Map<String, dynamic>? body,
  }) async {
    Object? lastError;
    int? lastStatusCode;

    for (final String base in ApiConfig.candidateBaseUrls) {
      final Uri uri = ApiConfig.buildUri(base, path);

      try {
        late final http.Response response;
        if (method == 'POST') {
          response = await http
              .post(
                uri,
                headers: <String, String>{
                  'Content-Type': 'application/json',
                  'X-User-Id': userId,
                },
                body: jsonEncode(body ?? <String, dynamic>{}),
              )
              .timeout(const Duration(seconds: 5));
        } else {
          response = await http
              .delete(uri, headers: <String, String>{'X-User-Id': userId})
              .timeout(const Duration(seconds: 5));
        }

        if (response.statusCode >= 200 && response.statusCode < 300) {
          return response;
        }
        lastStatusCode = response.statusCode;
      } catch (e) {
        lastError = e;
      }
    }

    if (lastStatusCode != null) {
      throw Exception(
        'Yeu cau kho nguyen lieu that bai (HTTP $lastStatusCode)',
      );
    }
    throw Exception('Khong ket noi duoc API kho nguyen lieu: $lastError');
  }

  static Future<void> saveIngredient({
    required String userId,
    required String ingredientId,
    String quantity = '1',
  }) async {
    final http.Response response = await _sendWithFallback(
      path: '/api/pantry',
      method: 'POST',
      userId: userId,
      body: <String, dynamic>{
        'ingredient_id': ingredientId,
        'quantity': quantity,
      },
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Lưu vào kho thất bại (${response.statusCode})');
    }
  }

  static Future<List<PantryItem>> getPantry({required String userId}) async {
    final http.Response response = await _getWithFallback(
      path: '/api/pantry',
      userId: userId,
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(
        'Không tải được kho nguyên liệu (${response.statusCode})',
      );
    }

    final Map<String, dynamic> body =
        jsonDecode(response.body) as Map<String, dynamic>;
    final List<dynamic> data = (body['data'] as List<dynamic>?) ?? <dynamic>[];

    return data
        .whereType<Map<String, dynamic>>()
        .map(PantryItem.fromJson)
        .toList();
  }

  static Future<void> deletePantryItem({
    required String userId,
    required String pantryItemId,
  }) async {
    final http.Response response = await _sendWithFallback(
      path: '/api/pantry/$pantryItemId',
      method: 'DELETE',
      userId: userId,
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Xóa nguyên liệu thất bại (${response.statusCode})');
    }
  }
}
