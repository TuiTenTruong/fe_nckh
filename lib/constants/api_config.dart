class ApiConfig {
  // Override with: flutter run --dart-define=API_BASE_URL=https://your-api-host
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:5000',
  );

  static const String recipesPath = '/api/recipes';
  static const String chatSessionsPath = '/api/chat/sessions';
  static const String chatMessagesSuffix = '/messages';
}
