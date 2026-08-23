import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_colors.dart';
import '../../services/auth_service.dart';
import '../../services/gemini_service.dart';
import '../../services/smart_ai_repository.dart';

class SmartAiPage extends StatefulWidget {
  const SmartAiPage({super.key});

  @override
  State<SmartAiPage> createState() => _SmartAiPageState();
}

class _SmartAiPageState extends State<SmartAiPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();

  String? _currentSessionId;
  bool _isTyping = false;
  String _streamingText = '';
  StreamSubscription? _streamingSubscription;

  final List<String> _suggestionPool = const [
    'How do I check my results?',
    'How do I update my profile?',
    'How do I report an incident?',
    'Who can I call in case of emergency?',
    'What are SIWES guidelines?',
    'How do I format my FYP template?',
    'Where is the student handbook?',
    'Where is the CITS building?',
    'Is the registration portal still open?'
    'Where is the senate building?',
  ];

  List<String> _currentSuggestions = [];

  @override
  void initState() {
    super.initState();
    _inputController.addListener(_onInputChanged);
    _randomizeSuggestions();
  }

  void _randomizeSuggestions() {
    final pool = List<String>.from(_suggestionPool)..shuffle();
    _currentSuggestions = pool.take(4).toList();
  }

  @override
  void dispose() {
    _inputController.removeListener(_onInputChanged);
    _inputController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    _streamingSubscription?.cancel();
    super.dispose();
  }

  void _onInputChanged() {
    setState(() {});
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _startNewChat(String uid, SmartAiRepository repository) async {
    _streamingSubscription?.cancel();
    setState(() {
      _currentSessionId = null;
      _streamingText = '';
      _isTyping = false;
      _randomizeSuggestions();
    });
    _inputController.clear();
  }

  Future<void> _deleteSession(String uid, String sessionId, SmartAiRepository repository) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Chat'),
        content: const Text('Are you sure you want to delete this chat session? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel', style: TextStyle(color: Color(AppColors.textSecondary))),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Color(AppColors.danger), fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await repository.deleteSession(uid, sessionId);
      if (_currentSessionId == sessionId) {
        setState(() {
          _currentSessionId = null;
          _streamingText = '';
          _isTyping = false;
        });
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Chat session deleted')),
        );
      }
    }
  }

  Future<void> _renameSession(String uid, String sessionId, String oldTitle, SmartAiRepository repository) async {
    final textController = TextEditingController(text: oldTitle);
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rename Session'),
        content: TextField(
          controller: textController,
          decoration: const InputDecoration(
            hintText: 'Enter new title',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
          textCapitalization: TextCapitalization.sentences,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel', style: TextStyle(color: Color(AppColors.textSecondary))),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Save', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirm == true && textController.text.trim().isNotEmpty) {
      await repository.updateSessionTitle(uid, sessionId, textController.text.trim());
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Chat session renamed')),
        );
      }
    }
  }

  Future<void> _sendMessage(String text, String uid, SmartAiRepository repository, GeminiService gemini) async {
    if (text.trim().isEmpty) return;

    // Trigger soft haptic feedback
    HapticFeedback.lightImpact();

    final messageContent = text.trim();
    _inputController.clear();
    _focusNode.unfocus();

    // 1. Ensure user session exists
    String sessionId = _currentSessionId ?? '';
    if (sessionId.isEmpty) {
      sessionId = await repository.createSession(uid, messageContent);
      setState(() {
        _currentSessionId = sessionId;
      });
    }

    // 2. Save user message in Firestore
    await repository.addMessage(uid, sessionId, 'user', messageContent);
    _scrollToBottom();

    // 3. Initiate typing state
    setState(() {
      _isTyping = true;
      _streamingText = '';
    });

    // 4. Fetch session dialogue history for model context
    final messagesSnapshot = await repository.getMessages(uid, sessionId).first;
    final historyList = messagesSnapshot.map((m) => {
      'role': m.role,
      'content': m.content,
    }).toList();

    // 5. Call API
    try {
      _streamingSubscription = gemini.generateContentStream(historyList).listen(
        (chunk) {
          setState(() {
            _streamingText += chunk;
          });
          _scrollToBottom();
        },
        onError: (err) async {
          _handleError(uid, sessionId, err, repository);
        },
        onDone: () async {
          if (_streamingText.trim().isNotEmpty) {
            await repository.addMessage(uid, sessionId, 'model', _streamingText);
          }
          setState(() {
            _isTyping = false;
            _streamingText = '';
          });
          _scrollToBottom();
        },
        cancelOnError: true,
      );
    } catch (e) {
      _handleError(uid, sessionId, e, repository);
    }
  }

  void _handleError(String uid, String sessionId, Object err, SmartAiRepository repository) async {
    String friendlyError = 'Smart AI is a bit busy right now. Please try again in a moment.';
    final errMsg = err.toString().toLowerCase();

    if (errMsg.contains('quota_exceeded') || errMsg.contains('429')) {
      friendlyError = 'Smart AI free quota exceeded. Please wait a moment before trying again.';
    } else if (errMsg.contains('network') || errMsg.contains('failed to connect')) {
      friendlyError = 'Network error. Please check your internet connection.';
    }

    await repository.addMessage(uid, sessionId, 'model', friendlyError);
    if (mounted) {
      setState(() {
        _isTyping = false;
        _streamingText = '';
      });
      _scrollToBottom();
    }
  }

  Widget _buildMarkdown(String content, bool isDarkText) {
    // Custom light markdown formatter: handles headers, bold text, listing items
    final boldRegex = RegExp(r'\*\*(.*?)\*\*');
    final headerRegex = RegExp(r'^###\s*(.*)$');
    final bulletRegex = RegExp(r'^\s*[\-\*]\s+(.*)$');

    final lines = content.split('\n');
    final children = <Widget>[];

    for (var line in lines) {
      if (line.trim().isEmpty) continue;

      // Check header
      final headerMatch = headerRegex.firstMatch(line.trim());
      if (headerMatch != null) {
        children.add(
          Padding(
            padding: const EdgeInsets.only(top: 8, bottom: 4),
            child: Text(
              headerMatch.group(1)!,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14.5,
                color: isDarkText ? const Color(AppColors.textPrimary) : Colors.white,
              ),
            ),
          ),
        );
        continue;
      }

      // Check bullet list item
      final bulletMatch = bulletRegex.firstMatch(line.trim());
      if (bulletMatch != null) {
        children.add(
          Padding(
            padding: const EdgeInsets.only(left: 12, top: 2, bottom: 2),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '• ',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isDarkText ? const Color(AppColors.textPrimary) : Colors.white,
                  ),
                ),
                Expanded(
                  child: _buildRichText(bulletMatch.group(1)!, isDarkText),
                ),
              ],
            ),
          ),
        );
        continue;
      }

      // Regular line
      children.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: _buildRichText(line, isDarkText),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    );
  }

  Widget _buildRichText(String text, bool isDarkText) {
    // Basic inline bold formatting checker (**text**)
    final boldRegex = RegExp(r'\*\*(.*?)\*\*');
    final spans = <TextSpan>[];
    
    int start = 0;
    for (final match in boldRegex.allMatches(text)) {
      if (match.start > start) {
        spans.add(TextSpan(text: text.substring(start, match.start)));
      }
      spans.add(
        TextSpan(
          text: match.group(1),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      );
      start = match.end;
    }
    
    if (start < text.length) {
      spans.add(TextSpan(text: text.substring(start)));
    }

    return Text.rich(
      TextSpan(
        children: spans,
        style: TextStyle(
          fontSize: 13.5,
          color: isDarkText ? const Color(AppColors.textPrimary) : Colors.white,
          height: 1.4,
        ),
      ),
    );
  }

  Widget _buildSidebar(String uid, SmartAiRepository repository) {
    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
              alignment: Alignment.centerLeft,
              child: Row(
                children: [
                  const Icon(PhosphorIconsFill.sparkle, color: Color(AppColors.primaryDeeper), size: 24),
                  const SizedBox(width: 10),
                  const Text(
                    'Chat Sessions',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(AppColors.textPrimary),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: StreamBuilder<List<ChatSession>>(
                stream: repository.getSessions(uid),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final sessions = snapshot.data ?? [];
                  if (sessions.isEmpty) {
                    return const Center(
                      child: Text(
                        'No history sessions yet.',
                        style: TextStyle(color: Color(AppColors.textSecondary)),
                      ),
                    );
                  }

                  // Group elements (Today, Yesterday, Older)
                  final now = DateTime.now();
                  final todaySessions = <ChatSession>[];
                  final yesterdaySessions = <ChatSession>[];
                  final olderSessions = <ChatSession>[];

                  for (final session in sessions) {
                    final diffDays = now.difference(session.updatedAt).inDays;
                    if (diffDays == 0 && now.day == session.updatedAt.day) {
                      todaySessions.add(session);
                    } else if (diffDays <= 1) {
                      yesterdaySessions.add(session);
                    } else {
                      olderSessions.add(session);
                    }
                  }

                  return ListView(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    children: [
                      if (todaySessions.isNotEmpty) ...[
                        _buildGroupHeader('Today'),
                        ...todaySessions.map((s) => _buildSessionTile(uid, s, repository)),
                      ],
                      if (yesterdaySessions.isNotEmpty) ...[
                        _buildGroupHeader('Yesterday'),
                        ...yesterdaySessions.map((s) => _buildSessionTile(uid, s, repository)),
                      ],
                      if (olderSessions.isNotEmpty) ...[
                        _buildGroupHeader('Previous Days'),
                        ...olderSessions.map((s) => _buildSessionTile(uid, s, repository)),
                      ],
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGroupHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: Color(AppColors.textSecondary),
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  Widget _buildSessionTile(String uid, ChatSession session, SmartAiRepository repository) {
    final isSelected = _currentSessionId == session.id;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      child: Material(
        color: isSelected ? const Color(AppColors.primaryDeeper).withOpacity(0.06) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () {
            _streamingSubscription?.cancel();
            setState(() {
              _currentSessionId = session.id;
              _streamingText = '';
              _isTyping = false;
            });
            Navigator.pop(context); // Close Drawer
            _scrollToBottom();
          },
          onLongPress: () {
            // Edit or Delete bottom actions
            showModalBottomSheet(
              context: context,
              builder: (context) => SafeArea(
                child: Wrap(
                  children: [
                    ListTile(
                      leading: const Icon(PhosphorIconsRegular.pencilSimple),
                      title: const Text('Rename Session'),
                      onTap: () {
                        Navigator.pop(context);
                        _renameSession(uid, session.id, session.title, repository);
                      },
                    ),
                    ListTile(
                      leading: const Icon(PhosphorIconsRegular.trash, color: Color(AppColors.danger)),
                      title: const Text('Delete Session', style: TextStyle(color: Color(AppColors.danger))),
                      onTap: () {
                        Navigator.pop(context);
                        _deleteSession(uid, session.id, repository);
                      },
                    ),
                  ],
                ),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                Icon(
                  PhosphorIconsRegular.chatCircle,
                  size: 18,
                  color: isSelected ? const Color(AppColors.primaryDeeper) : const Color(AppColors.textSecondary),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    session.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected ? const Color(AppColors.primaryDeeper) : const Color(AppColors.textPrimary),
                    ),
                  ),
                ),
                if (isSelected)
                  const Icon(PhosphorIconsFill.circle, size: 6, color: Color(AppColors.primaryDeeper)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(String uid, SmartAiRepository repository, GeminiService gemini) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Icon(
              PhosphorIconsFill.sparkle,
              size: 40,
              color: Color(AppColors.primaryDeeper),
            ),
            const SizedBox(height: 16),
            const Text(
              'How can I help you today?',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(AppColors.textPrimary),
              ),
            ),
            const SizedBox(height: 32),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: _currentSuggestions.map((s) {
                return Material(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: () => _sendMessage(s, uid, repository, gemini),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(AppColors.border)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(PhosphorIconsRegular.question, size: 14, color: Color(AppColors.primaryDeeper)),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              s,
                              style: const TextStyle(
                                fontSize: 12.5,
                                color: Color(AppColors.textPrimary),
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThinkingBubble() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(AppColors.primaryDeeper).withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(PhosphorIconsFill.sparkle, size: 16, color: Color(AppColors.primaryDeeper)),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(16),
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
              border: Border.all(color: const Color(AppColors.border)),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _PulsingBubbleDot(delay: 0),
                SizedBox(width: 4),
                _PulsingBubbleDot(delay: 150),
                SizedBox(width: 4),
                _PulsingBubbleDot(delay: 300),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageList(List<ChatMessage> messages) {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(vertical: 16),
      itemCount: messages.length + (_isTyping ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == messages.length && _isTyping) {
          if (_streamingText.trim().isNotEmpty) {
            // Render streaming content block
            return _buildSpeechBubble(
              role: 'model',
              content: _streamingText,
              time: 'Generating...',
            );
          }
          return _buildThinkingBubble();
        }

        final m = messages[index];
        final timeStr = DateFormat('h:mm a').format(m.createdAt);

        return _buildSpeechBubble(
          role: m.role,
          content: m.content,
          time: timeStr,
        );
      },
    );
  }

  Widget _buildSpeechBubble({required String role, required String content, required String time}) {
    final isMe = role == 'user';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Align(
        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!isMe) ...[
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(AppColors.primaryDeeper).withOpacity(0.08),
                  shape: BoxShape.circle,
                ),
                child: const Icon(PhosphorIconsFill.sparkle, size: 16, color: Color(AppColors.primaryDeeper)),
              ),
              const SizedBox(width: 8),
            ],
            Flexible(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: isMe ? const Color(AppColors.primaryDeeper) : Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(16),
                    topRight: const Radius.circular(16),
                    bottomLeft: isMe ? const Radius.circular(16) : Radius.zero,
                    bottomRight: isMe ? Radius.zero : const Radius.circular(16),
                  ),
                  border: isMe ? null : Border.all(color: const Color(AppColors.border)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildMarkdown(content, !isMe),
                    const SizedBox(height: 4),
                    Text(
                      time,
                      style: TextStyle(
                        fontSize: 9.5,
                        color: isMe ? Colors.white.withOpacity(0.7) : const Color(AppColors.textSecondary),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget _buildInputBar(String uid, SmartAiRepository repository, GeminiService gemini) {
    final canSend = _inputController.text.trim().isNotEmpty && !_isTyping;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: const Color(AppColors.border))),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: const Color(AppColors.background),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: _focusNode.hasFocus ? const Color(AppColors.primaryDeeper) : const Color(AppColors.border),
                  width: _focusNode.hasFocus ? 1.5 : 1,
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Scrollbar(
                child: TextField(
                  controller: _inputController,
                  focusNode: _focusNode,
                  maxLines: 4,
                  minLines: 1,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    hintText: 'Type your message...',
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    disabledBorder: InputBorder.none,
                    errorBorder: InputBorder.none,
                    focusedErrorBorder: InputBorder.none,
                    filled: false,
                    contentPadding: EdgeInsets.symmetric(vertical: 8),
                  ),
                  style: const TextStyle(fontSize: 14),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            style: IconButton.styleFrom(
              backgroundColor: canSend ? const Color(AppColors.primaryDeeper) : const Color(AppColors.border),
              foregroundColor: Colors.white,
              shape: const CircleBorder(),
              padding: const EdgeInsets.all(12),
            ),
            onPressed: canSend
                ? () {
                    final text = _inputController.text;
                    _sendMessage(text, uid, repository, gemini);
                  }
                : null,
            icon: const Icon(PhosphorIconsBold.paperPlaneRight, size: 18),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthService>(context, listen: false);
    final repository = Provider.of<SmartAiRepository>(context, listen: false);
    final gemini = Provider.of<GeminiService>(context, listen: false);
    final uid = auth.currentUser?.uid ?? 'guest';

    return FocusScope(
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: const Color(AppColors.background),
        drawer: _buildSidebar(uid, repository),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(PhosphorIconsRegular.list, color: Color(AppColors.textPrimary)),
            onPressed: () {
              _scaffoldKey.currentState?.openDrawer();
            },
          ),
          title: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(PhosphorIconsFill.sparkle, color: Color(AppColors.primaryDeeper), size: 18),
              SizedBox(width: 8),
              Text(
                'Smart AI',
                style: TextStyle(
                  color: Color(AppColors.textPrimary),
                  fontWeight: FontWeight.bold,
                  fontSize: 16.5,
                ),
              ),
            ],
          ),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(PhosphorIconsRegular.notePencil, color: Color(AppColors.textPrimary)),
              onPressed: () => _startNewChat(uid, repository),
            ),
          ],
        ),
        body: Column(
          children: [
            Expanded(
              child: _currentSessionId == null
                  ? _buildEmptyState(uid, repository, gemini)
                  : StreamBuilder<List<ChatMessage>>(
                      stream: repository.getMessages(uid, _currentSessionId!),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }
      
                        final messages = snapshot.data ?? [];
                        if (messages.isEmpty && !_isTyping) {
                          return _buildEmptyState(uid, repository, gemini);
                        }
      
                        return _buildMessageList(messages);
                      },
                    ),
            ),
            _buildInputBar(uid, repository, gemini),
          ],
        ),
      ),
    );
  }
}

class _PulsingBubbleDot extends StatefulWidget {
  final int delay;
  const _PulsingBubbleDot({required this.delay});

  @override
  State<_PulsingBubbleDot> createState() => _PulsingBubbleDotState();
}

class _PulsingBubbleDotState extends State<_PulsingBubbleDot> with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _scaleAnimation = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );

    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) {
        _animController.repeat(reverse: true);
      }
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Container(
        width: 6,
        height: 6,
        decoration: const BoxDecoration(
          color: Color(AppColors.primaryDeeper),
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
