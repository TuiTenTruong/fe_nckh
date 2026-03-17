import 'package:flutter/foundation.dart';

class ApiConfig {
  static const String _envBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: '',
  );

  static String get baseUrl {
    if (_envBaseUrl.isNotEmpty) {
      return _envBaseUrl;
    }

    if (kIsWeb) {
      return 'http://localhost:5000';
    }

    // Default for physical Android + adb reverse. Override with --dart-define API_BASE_URL.
    return 'http://127.0.0.1:5000';
  }

  static List<String> get candidateBaseUrls {
    final List<String> urls = <String>[
      baseUrl,
      'http://127.0.0.1:5000',
      'http://localhost:5000',
      'http://10.0.2.2:5000',
    ];

    final Set<String> seen = <String>{};
    return urls
        .where((String item) => item.isNotEmpty && seen.add(item))
        .toList();
  }

  static Uri buildUri(String base, String path, {Map<String, String>? query}) {
    return Uri.parse('$base$path').replace(queryParameters: query);
  }
}
