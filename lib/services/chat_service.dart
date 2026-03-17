import 'dart:convert';

import 'package:http/http.dart' as http;

import '../constants/constants.dart';
import '../models/models.dart';

class ChatService {
  ChatService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Uri get _sessionsUri =>
      Uri.parse('${ApiConfig.baseUrl}${ApiConfig.chatSessionsPath}');

  Future<List<ChatSession>> fetchSessions() async {
    final http.Response response = await _client.get(_sessionsUri);
    final dynamic decoded = _decodeResponse(response, expected: 200);

    return _extractList(decoded)
        .whereType<Map<String, dynamic>>()
        .map(ChatSession.fromJson)
        .where((ChatSession session) => session.id.isNotEmpty)
        .toList();
  }

  Future<ChatSession> createSession({String? title}) async {
    final Map<String, dynamic> payload = <String, dynamic>{};
    if (title != null && title.trim().isNotEmpty) {
      payload['title'] = title.trim();
    }

    final http.Response response = await _client.post(
      _sessionsUri,
      headers: const <String, String>{'Content-Type': 'application/json'},
      body: jsonEncode(payload),
    );

    final dynamic decoded = _decodeResponse(response, expected: 201);
    final Map<String, dynamic> map = _extractFirstMap(decoded);

    final ChatSession session = ChatSession.fromJson(map);
    if (session.id.isEmpty) {
      throw Exception('Session was created but missing id.');
    }

    return session;
  }

  Future<void> deleteSession(String sessionId) async {
    final Uri uri = Uri.parse(
      '${ApiConfig.baseUrl}${ApiConfig.chatSessionsPath}/${Uri.encodeComponent(sessionId)}',
    );

    final http.Response response = await _client.delete(uri);
    if (response.statusCode != 200) {
      throw Exception('Cannot delete session (${response.statusCode}).');
    }
  }

  Future<List<ChatMessage>> fetchMessages(String sessionId) async {
    final Uri uri = Uri.parse(
      '${ApiConfig.baseUrl}${ApiConfig.chatSessionsPath}/${Uri.encodeComponent(sessionId)}${ApiConfig.chatMessagesSuffix}',
    );

    final http.Response response = await _client.get(uri);
    final dynamic decoded = _decodeResponse(response, expected: 200);

    return _extractList(decoded)
        .whereType<Map<String, dynamic>>()
        .map(ChatMessage.fromJson)
        .where((ChatMessage message) => message.content.isNotEmpty)
        .toList();
  }

  Future<List<ChatMessage>> sendMessage({
    required String sessionId,
    required String content,
  }) async {
    final Uri uri = Uri.parse(
      '${ApiConfig.baseUrl}${ApiConfig.chatSessionsPath}/${Uri.encodeComponent(sessionId)}${ApiConfig.chatMessagesSuffix}',
    );

    final http.Response response = await _client.post(
      uri,
      headers: const <String, String>{'Content-Type': 'application/json'},
      body: jsonEncode(<String, String>{'content': content}),
    );

    final dynamic decoded = _decodeResponse(response, expected: 200);

    final List<ChatMessage> fromList = _extractList(decoded)
        .whereType<Map<String, dynamic>>()
        .map(ChatMessage.fromJson)
        .where((ChatMessage message) => message.content.isNotEmpty)
        .toList();

    if (fromList.isNotEmpty) {
      return fromList;
    }

    final List<ChatMessage> fallback = <ChatMessage>[];
    final Map<String, dynamic> root = _extractFirstMap(decoded);
    final List<String> singleKeys = <String>[
      'user_message',
      'assistant_message',
      'message',
      'reply',
    ];

    for (final String key in singleKeys) {
      final dynamic value = root[key];
      if (value is Map<String, dynamic>) {
        final ChatMessage message = ChatMessage.fromJson(value);
        if (message.content.isNotEmpty) fallback.add(message);
      }
    }

    return fallback;
  }

  dynamic _decodeResponse(http.Response response, {required int expected}) {
    if (response.statusCode != expected) {
      throw Exception(
        'Request failed (${response.statusCode}): ${response.body}',
      );
    }

    if (response.body.trim().isEmpty) {
      return <String, dynamic>{};
    }

    return jsonDecode(response.body);
  }

  List<dynamic> _extractList(dynamic decoded) {
    if (decoded is List<dynamic>) return decoded;

    if (decoded is Map<String, dynamic>) {
      final dynamic data = decoded['data'];
      if (data is List<dynamic>) return data;
      if (data is Map<String, dynamic>) {
        final dynamic nested =
            data['items'] ??
            data['results'] ??
            data['messages'] ??
            data['sessions'];
        if (nested is List<dynamic>) return nested;
      }

      final dynamic direct =
          decoded['items'] ??
          decoded['results'] ??
          decoded['messages'] ??
          decoded['sessions'];
      if (direct is List<dynamic>) return direct;
    }

    return <dynamic>[];
  }

  Map<String, dynamic> _extractFirstMap(dynamic decoded) {
    if (decoded is Map<String, dynamic>) {
      final dynamic data = decoded['data'];
      if (data is Map<String, dynamic>) return data;
      return decoded;
    }

    if (decoded is List<dynamic>) {
      for (final dynamic item in decoded) {
        if (item is Map<String, dynamic>) return item;
      }
    }

    return <String, dynamic>{};
  }
}
