import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/scan_result.dart';
import 'api_config.dart';

class ScanApiService {
  static Future<ScanResult> _sendScanMultipart({
    required String userId,
    required Uint8List imageBytes,
    required String fileName,
  }) async {
    Object? lastError;
    int? lastStatusCode;
    String? lastMessage;

    for (final String base in ApiConfig.candidateBaseUrls) {
      final Uri uri = ApiConfig.buildUri(base, '/api/scan');
      debugPrint('[ScanApi] POST $uri');

      final http.MultipartRequest request = http.MultipartRequest('POST', uri);
      request.headers['X-User-Id'] = userId;
      request.files.add(
        http.MultipartFile.fromBytes('image', imageBytes, filename: fileName),
      );

      try {
        final http.StreamedResponse streamed = await request.send().timeout(
          const Duration(seconds: 12),
        );
        final String bodyText = await streamed.stream.bytesToString();

        if (streamed.statusCode >= 200 && streamed.statusCode < 300) {
          debugPrint('[ScanApi] SUCCESS $uri (${streamed.statusCode})');
          final Map<String, dynamic> body =
              jsonDecode(bodyText) as Map<String, dynamic>;
          final Map<String, dynamic> data =
              (body['data'] as Map<String, dynamic>?) ?? <String, dynamic>{};
          return ScanResult.fromJson(data);
        }

        lastStatusCode = streamed.statusCode;
        debugPrint('[ScanApi] FAIL $uri (${streamed.statusCode})');

        try {
          final Map<String, dynamic> body =
              jsonDecode(bodyText) as Map<String, dynamic>;
          lastMessage = (body['message'] ?? body['error'] ?? '').toString();
        } catch (_) {
          // Ignore malformed error body, use status code fallback message.
        }
      } catch (e) {
        lastError = e;
        debugPrint('[ScanApi] ERROR $uri -> $e');
      }
    }

    if (lastStatusCode != null) {
      final String detail = (lastMessage != null && lastMessage.isNotEmpty)
          ? ': $lastMessage'
          : '';
      throw Exception('Quét thất bại (HTTP $lastStatusCode)$detail');
    }

    throw Exception('Không kết nối được API quét: $lastError');
  }

  static Future<ScanResult> scanImageBytes({
    required String userId,
    required Uint8List imageBytes,
    String fileName = 'capture.jpg',
  }) async {
    return _sendScanMultipart(
      userId: userId,
      imageBytes: imageBytes,
      fileName: fileName,
    );
  }

  static Future<ScanResult> scanDemo({required String userId}) async {
    return _sendScanMultipart(
      userId: userId,
      imageBytes: Uint8List.fromList(utf8.encode('demo-image-bytes')),
      fileName: 'demo.jpg',
    );
  }
}
