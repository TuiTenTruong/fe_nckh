import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/models.dart';
import '../services/services.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ChatService _chatService = ChatService();
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _messageScrollController = ScrollController();

  List<ChatSession> _sessions = <ChatSession>[];
  List<ChatMessage> _messages = <ChatMessage>[];

  String? _currentSessionId;
  bool _isLoadingSessions = true;
  bool _isLoadingMessages = false;
  bool _isSending = false;
  String? _sessionError;
  String? _messageError;

  @override
  void initState() {
    super.initState();
    _loadSessions();
  }

  @override
  void dispose() {
    _inputController.dispose();
    _messageScrollController.dispose();
    super.dispose();
  }

  Future<void> _loadSessions() async {
    setState(() {
      _isLoadingSessions = true;
      _sessionError = null;
    });

    try {
      final List<ChatSession> sessions = await _chatService.fetchSessions();

      if (!mounted) return;

      if (sessions.isEmpty) {
        final ChatSession newSession = await _chatService.createSession(
          title: 'Chat mới',
        );
        if (!mounted) return;
        _sessions = <ChatSession>[newSession];
        _currentSessionId = newSession.id;
      } else {
        _sessions = sessions;
        _currentSessionId ??= sessions.first.id;
      }

      setState(() {
        _isLoadingSessions = false;
      });

      if (_currentSessionId != null) {
        await _loadMessages(_currentSessionId!);
      }
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _isLoadingSessions = false;
        _sessionError = 'Không thể tải danh sách chat';
      });
    }
  }

  Future<void> _loadMessages(String sessionId) async {
    setState(() {
      _isLoadingMessages = true;
      _messageError = null;
      _currentSessionId = sessionId;
    });

    try {
      final List<ChatMessage> messages = await _chatService.fetchMessages(
        sessionId,
      );

      if (!mounted) return;

      setState(() {
        _messages = messages;
        _isLoadingMessages = false;
      });

      _scrollToBottom();
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isLoadingMessages = false;
        _messageError = 'Không thể tải tin nhắn';
      });
    }
  }

  Future<void> _createSession() async {
    try {
      final ChatSession session = await _chatService.createSession(
        title: 'Chat mới',
      );

      if (!mounted) return;

      setState(() {
        _sessions = <ChatSession>[session, ..._sessions];
        _currentSessionId = session.id;
        _messages = <ChatMessage>[];
      });
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Không tạo được phiên chat mới')),
      );
    }
  }

  Future<void> _deleteCurrentSession() async {
    final String? sessionId = _currentSessionId;
    if (sessionId == null) return;

    try {
      await _chatService.deleteSession(sessionId);

      if (!mounted) return;

      final List<ChatSession> remaining = _sessions
          .where((ChatSession item) => item.id != sessionId)
          .toList();

      if (remaining.isEmpty) {
        final ChatSession fallback = await _chatService.createSession(
          title: 'Chat mới',
        );
        if (!mounted) return;
        setState(() {
          _sessions = <ChatSession>[fallback];
          _currentSessionId = fallback.id;
          _messages = <ChatMessage>[];
        });
      } else {
        setState(() {
          _sessions = remaining;
          _currentSessionId = remaining.first.id;
          _messages = <ChatMessage>[];
        });
        await _loadMessages(_currentSessionId!);
      }
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Không xóa được phiên chat')),
      );
    }
  }

  Future<void> _sendMessage() async {
    final String content = _inputController.text.trim();
    if (content.isEmpty || _isSending) return;

    String? sessionId = _currentSessionId;
    if (sessionId == null) {
      await _createSession();
      sessionId = _currentSessionId;
    }

    if (sessionId == null) return;

    final ChatMessage userMessage = ChatMessage(
      id: 'local-${DateTime.now().microsecondsSinceEpoch}',
      sessionId: sessionId,
      role: ChatRole.user,
      content: content,
      createdAt: DateTime.now(),
    );

    _inputController.clear();

    setState(() {
      _messages = <ChatMessage>[..._messages, userMessage];
      _isSending = true;
      _messageError = null;
    });

    _scrollToBottom();

    try {
      final List<ChatMessage> responseMessages = await _chatService.sendMessage(
        sessionId: sessionId,
        content: content,
      );

      if (!mounted) return;

      final List<ChatMessage> assistantMessages = responseMessages
          .where((ChatMessage message) => message.role != ChatRole.user)
          .toList();

      setState(() {
        _messages = <ChatMessage>[..._messages, ...assistantMessages];
        _isSending = false;
      });

      _scrollToBottom();
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isSending = false;
        _messageError = 'Gửi tin nhắn thất bại';
      });
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_messageScrollController.hasClients) return;
      _messageScrollController.animateTo(
        _messageScrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        _buildSessionBar(),
        Expanded(child: _buildMessageArea()),
        _buildComposer(),
      ],
    );
  }

  Widget _buildSessionBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Text(
                'Phiên chat',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1F2937),
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: _createSession,
                icon: const Icon(Icons.add_circle_outline),
                tooltip: 'Tạo phiên mới',
              ),
              IconButton(
                onPressed: _currentSessionId == null
                    ? null
                    : _deleteCurrentSession,
                icon: const Icon(Icons.delete_outline),
                tooltip: 'Xóa phiên hiện tại',
              ),
            ],
          ),
          if (_isLoadingSessions)
            const LinearProgressIndicator(minHeight: 2)
          else if (_sessionError != null)
            Text(
              _sessionError!,
              style: GoogleFonts.inter(
                color: Colors.red.shade600,
                fontSize: 12,
              ),
            )
          else
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _sessions.map((ChatSession session) {
                  final bool selected = _currentSessionId == session.id;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      selected: selected,
                      label: Text(
                        session.title,
                        style: GoogleFonts.inter(fontSize: 12),
                      ),
                      onSelected: (_) => _loadMessages(session.id),
                    ),
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMessageArea() {
    if (_isLoadingMessages) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_messageError != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              _messageError!,
              style: GoogleFonts.inter(
                color: Colors.red.shade700,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: _currentSessionId == null
                  ? null
                  : () => _loadMessages(_currentSessionId!),
              child: const Text('Thử lại'),
            ),
          ],
        ),
      );
    }

    if (_messages.isEmpty) {
      return Center(
        child: Text(
          'Hãy gửi tin nhắn đầu tiên để bắt đầu',
          style: GoogleFonts.inter(
            color: const Color(0xFF6B7280),
            fontSize: 14,
          ),
        ),
      );
    }

    return ListView.builder(
      controller: _messageScrollController,
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
      itemCount: _messages.length + (_isSending ? 1 : 0),
      itemBuilder: (BuildContext context, int index) {
        if (_isSending && index == _messages.length) {
          return Align(
            alignment: Alignment.centerLeft,
            child: Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFDCFCE7),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(
                'Đang trả lời...',
                style: GoogleFonts.inter(color: const Color(0xFF166534)),
              ),
            ),
          );
        }

        final ChatMessage message = _messages[index];
        final bool isUser = message.isUser;

        return Align(
          alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            margin: const EdgeInsets.only(bottom: 10),
            constraints: const BoxConstraints(maxWidth: 320),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isUser ? const Color(0xFF22C55E) : const Color(0xFFDCFCE7),
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(14),
                topRight: const Radius.circular(14),
                bottomLeft: Radius.circular(isUser ? 14 : 4),
                bottomRight: Radius.circular(isUser ? 4 : 14),
              ),
            ),
            child: Text(
              message.content,
              style: GoogleFonts.inter(
                color: isUser ? Colors.white : const Color(0xFF166534),
                fontSize: 15,
                height: 1.45,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildComposer() {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Colors.grey.shade200)),
        ),
        child: Row(
          children: <Widget>[
            Expanded(
              child: TextField(
                controller: _inputController,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _sendMessage(),
                minLines: 1,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Nhập câu hỏi của bạn...',
                  hintStyle: GoogleFonts.inter(color: const Color(0xFF9CA3AF)),
                  filled: true,
                  fillColor: const Color(0xFFF3F4F6),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            SizedBox(
              width: 48,
              height: 48,
              child: ElevatedButton(
                onPressed: _isSending ? null : _sendMessage,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF22C55E),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: _isSending
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.send_rounded, size: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
