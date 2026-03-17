class ChatSession {
  const ChatSession({
    required this.id,
    required this.title,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String title;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory ChatSession.fromJson(Map<String, dynamic> json) {
    return ChatSession(
      id: _asString(
        json['id'] ?? json['session_id'] ?? json['uuid'] ?? json['_id'],
      ),
      title: _asString(
        json['title'] ?? json['name'] ?? json['label'],
        fallback: 'Cuộc trò chuyện',
      ),
      createdAt: _asDateTime(json['created_at'] ?? json['createdAt']),
      updatedAt: _asDateTime(json['updated_at'] ?? json['updatedAt']),
    );
  }
}

enum ChatRole { user, assistant, system }

class ChatMessage {
  const ChatMessage({
    required this.id,
    required this.sessionId,
    required this.role,
    required this.content,
    this.createdAt,
  });

  final String id;
  final String sessionId;
  final ChatRole role;
  final String content;
  final DateTime? createdAt;

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    final String roleRaw = _asString(
      json['role'] ?? json['sender'] ?? json['type'],
      fallback: 'assistant',
    ).toLowerCase();

    return ChatMessage(
      id: _asString(json['id'] ?? json['message_id'] ?? json['uuid'] ?? ''),
      sessionId: _asString(
        json['session_id'] ??
            json['sessionId'] ??
            json['chat_session_id'] ??
            '',
      ),
      role: _roleFromString(roleRaw),
      content: _asString(json['content'] ?? json['message'] ?? json['text']),
      createdAt: _asDateTime(json['created_at'] ?? json['createdAt']),
    );
  }

  bool get isUser => role == ChatRole.user;
}

ChatRole _roleFromString(String value) {
  if (value == 'user' || value == 'human') return ChatRole.user;
  if (value == 'system') return ChatRole.system;
  return ChatRole.assistant;
}

String _asString(dynamic value, {String fallback = ''}) {
  if (value == null) return fallback;
  final String text = value.toString().trim();
  return text.isEmpty ? fallback : text;
}

DateTime? _asDateTime(dynamic value) {
  if (value == null) return null;
  if (value is DateTime) return value;
  return DateTime.tryParse(value.toString());
}
