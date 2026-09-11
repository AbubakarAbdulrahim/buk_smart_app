import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/theme/app_colors.dart';
import '../../config/gemini_config.dart';
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
  Stream<List<ChatMessage>>? _messagesStream;
  bool _isTyping = false;
  String _streamingText = '';
  String? _savingMessageText;
  String? _optimisticUserMessage;
  List<ChatMessage> _lastKnownMessages = [];
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
    'Is the registration portal still open?',
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
      _messagesStream = null;
      _streamingText = '';
      _isTyping = false;
      _optimisticUserMessage = null;
      _savingMessageText = null;
      _lastKnownMessages = [];
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
          _messagesStream = null;
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
    final messageContent = text.trim();
    if (messageContent.isEmpty) return;

    // Trigger soft haptic feedback
    HapticFeedback.lightImpact();

    _inputController.clear();
    _focusNode.unfocus();

    // 1. Immediately determine or generate session ID synchronously
    final bool isNewSession = (_currentSessionId == null || _currentSessionId!.isEmpty);
    final String sessionId = isNewSession ? repository.generateSessionId(uid) : _currentSessionId!;

    // 2. Prepare conversation history for prompt context
    final historyList = _lastKnownMessages.map((m) => {
      'role': m.role,
      'content': m.content,
    }).toList();
    historyList.add({
      'role': 'user',
      'content': messageContent,
    });

    // 3. Immediately transition UI to active chat state with user message & typing indicator (0ms latency)
    setState(() {
      _currentSessionId = sessionId;
      _messagesStream = repository.getMessages(uid, sessionId);
      _optimisticUserMessage = messageContent;
      _isTyping = true;
      _streamingText = '';
      _savingMessageText = null;
    });
    _scrollToBottom();

    // 4. Persist session and user message in Firestore asynchronously (unblocked)
    if (isNewSession) {
      unawaited(repository.saveSession(uid, sessionId, messageContent));
    }
    unawaited(repository.addMessage(uid, sessionId, 'user', messageContent));

    // 5. Call API immediately
    try {
      _streamingSubscription?.cancel();
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
            final savedText = _streamingText;
            setState(() {
              _isTyping = false;
              _streamingText = '';
              _savingMessageText = savedText;
              _optimisticUserMessage = null;
            });
            await repository.addMessage(uid, sessionId, 'model', savedText);
            if (mounted) {
              setState(() {
                _savingMessageText = null;
              });
            }
          } else {
            setState(() {
              _isTyping = false;
              _optimisticUserMessage = null;
            });
          }
          _scrollToBottom();
        },
        cancelOnError: true,
      );
    } catch (e) {
      _handleError(uid, sessionId, e, repository);
    }
  }

  void _handleError(String uid, String sessionId, Object err, SmartAiRepository repository) async {
    debugPrint('Smart AI API Error: $err');
    
    String friendlyError = 'An unexpected error occurred. Please try again later.';
    final errMsg = err.toString().toLowerCase();

    if (errMsg.contains('not configured') || (errMsg.contains('api key') && GeminiConfig.apiKey.isEmpty)) {
      friendlyError = 'AI service configuration error: API key is not loaded. Please fully stop and rebuild the app (e.g. flutter run) to bundle the configuration.';
    } else if (errMsg.contains('api key not valid') || errMsg.contains('api_key_invalid')) {
      friendlyError = 'API key is invalid. Please check your GEMINI_API_KEY in .env.';
    } else if (errMsg.contains('api key')) {
      friendlyError = 'AI service configuration error. Please try again later.';
    } else if (errMsg.contains('quota') || errMsg.contains('429') || errMsg.contains('exhausted') || errMsg.contains('resource_exhausted')) {
      friendlyError = 'Service is temporarily busy. Please wait a moment and try again.';
    } else if (errMsg.contains('failed to fetch') || 
               errMsg.contains('clientexception') || 
               errMsg.contains('socketexception') || 
               errMsg.contains('network') || 
               errMsg.contains('failed to connect') || 
               errMsg.contains('connection refused') || 
               errMsg.contains('handshake') || 
               errMsg.contains('no internet')) {
      friendlyError = 'No internet connection, please try again later.';
    }

    await repository.addMessage(uid, sessionId, 'model', friendlyError);
    if (mounted) {
      setState(() {
        _isTyping = false;
        _streamingText = '';
        _optimisticUserMessage = null;
      });
      _scrollToBottom();
    }
  }

  Widget _buildMarkdown(String content, bool isDarkText) {
    // Custom light markdown formatter: handles headers, bold text, listing items
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
            child: _buildRichText(
              headerMatch.group(1)!,
              isDarkText,
              customStyle: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14.5,
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
                    color: isDarkText 
                        ? (Theme.of(context).brightness == Brightness.dark ? Colors.white : const Color(AppColors.textPrimary))
                        : Colors.white,
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

  Widget _buildRichText(String text, bool isDarkText, {TextStyle? customStyle}) {
    // Self-close unmatched bold markers if odd count
    var processedText = text;
    final occurrences = RegExp(r'\*\*').allMatches(text).length;
    if (occurrences.isOdd) {
      processedText += '**';
    }

    // Basic inline bold formatting checker (**text**)
    final boldRegex = RegExp(r'\*\*(.*?)\*\*');
    final spans = <TextSpan>[];
    
    int start = 0;
    for (final match in boldRegex.allMatches(processedText)) {
      if (match.start > start) {
        spans.add(TextSpan(text: processedText.substring(start, match.start)));
      }
      spans.add(
        TextSpan(
          text: match.group(1),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      );
      start = match.end;
    }
    
    if (start < processedText.length) {
      spans.add(TextSpan(text: processedText.substring(start)));
    }

    final defaultStyle = TextStyle(
      fontSize: 13.5,
      color: isDarkText 
          ? (Theme.of(context).brightness == Brightness.dark ? Colors.white : const Color(AppColors.textPrimary))
          : Colors.white,
      height: 1.4,
    );

    return Text.rich(
      TextSpan(
        children: spans,
        style: defaultStyle.merge(customStyle),
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
                  Text(
                    'Chat Sessions',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white
                          : const Color(AppColors.textPrimary),
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
        color: isSelected ? const Color(AppColors.primaryDeeper).withValues(alpha: 0.06) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () {
            _streamingSubscription?.cancel();
            setState(() {
              _currentSessionId = session.id;
              _messagesStream = repository.getMessages(uid, session.id);
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
                      color: isSelected
                          ? const Color(AppColors.primaryDeeper)
                          : (Theme.of(context).brightness == Brightness.dark ? Colors.white70 : const Color(AppColors.textPrimary)),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
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
              ),
            ),
            const SizedBox(height: 32),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: _currentSuggestions.map((s) {
                return Material(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(20),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: () => _sendMessage(s, uid, repository, gemini),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isDark ? const Color(0xFF1E293B) : const Color(AppColors.border),
                        ),
                      ),
                      child: Text(
                        s,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12.5,
                          color: isDark ? Colors.white70 : const Color(AppColors.textPrimary),
                          fontWeight: FontWeight.normal,
                        ),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(AppColors.primaryDeeper).withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(PhosphorIconsFill.sparkle, size: 16, color: Color(AppColors.primaryDeeper)),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(16),
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
              border: Border.all(
                color: isDark ? const Color(0xFF1E293B) : const Color(AppColors.border),
              ),
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
    _lastKnownMessages = messages;
    final displayMessages = List<ChatMessage>.from(messages);

    // Render optimistic user message immediately if not yet synced from Firestore
    if (_optimisticUserMessage != null) {
      final alreadyPresent = messages.isNotEmpty &&
          messages.last.role == 'user' &&
          messages.last.content == _optimisticUserMessage;
      if (!alreadyPresent) {
        displayMessages.add(ChatMessage(
          id: 'temp_user',
          role: 'user',
          content: _optimisticUserMessage!,
          createdAt: DateTime.now(),
        ));
      }
    }

    if (_savingMessageText != null) {
      final alreadySaved = messages.isNotEmpty &&
          messages.last.role == 'model' &&
          messages.last.content == _savingMessageText;
      if (!alreadySaved) {
        displayMessages.add(ChatMessage(
          id: 'temp_save',
          role: 'model',
          content: _savingMessageText!,
          createdAt: DateTime.now(),
        ));
      }
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(vertical: 16),
      itemCount: displayMessages.length + (_isTyping ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == displayMessages.length && _isTyping) {
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

        final m = displayMessages[index];
        final timeStr = m.id == 'temp_save'
            ? 'Saving...'
            : DateFormat('h:mm a').format(m.createdAt);

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
                  color: const Color(AppColors.primaryDeeper).withValues(alpha: 0.08),
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
                  color: isMe ? const Color(AppColors.primaryDeeper) : Theme.of(context).cardColor,
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(16),
                    topRight: const Radius.circular(16),
                    bottomLeft: isMe ? const Radius.circular(16) : Radius.zero,
                    bottomRight: isMe ? Radius.zero : const Radius.circular(16),
                  ),
                  border: isMe
                      ? null
                      : Border.all(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? const Color(0xFF1E293B)
                              : const Color(AppColors.border),
                        ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildMarkdown(content, !isMe),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          time,
                          style: TextStyle(
                            fontSize: 9.5,
                            color: isMe ? Colors.white.withValues(alpha: 0.7) : const Color(AppColors.textSecondary),
                          ),
                        ),
                      ],
                    ),
                    if (!isMe && time != 'Generating...') ...[
                      const SizedBox(height: 8),
                      Divider(
                        height: 1,
                        thickness: 0.5,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? const Color(0xFF1E293B)
                            : null,
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(4),
                              onTap: () {
                                Clipboard.setData(ClipboardData(text: content));
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Copied to clipboard'),
                                    duration: Duration(seconds: 2),
                                  ),
                                );
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      PhosphorIconsRegular.copy,
                                      size: 12,
                                      color: Theme.of(context).brightness == Brightness.dark
                                          ? Colors.white60
                                          : const Color(AppColors.textSecondary),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Copy',
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: Theme.of(context).brightness == Brightness.dark
                                            ? Colors.white60
                                            : const Color(AppColors.textSecondary),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          if (() {
                            final urlRegex = RegExp(r'(https?://[^\s\)]+)');
                            return urlRegex.hasMatch(content);
                          }()) ...[
                            const SizedBox(width: 12),
                            Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(4),
                                onTap: () async {
                                  final urlRegex = RegExp(r'(https?://[^\s\)]+)');
                                  final match = urlRegex.firstMatch(content);
                                  if (match != null) {
                                    final uri = Uri.parse(match.group(1)!);
                                    if (await canLaunchUrl(uri)) {
                                      await launchUrl(uri);
                                    }
                                  }
                                },
                                child: const Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(PhosphorIconsRegular.arrowSquareOut, size: 12, color: Color(AppColors.primaryDeeper)),
                                      SizedBox(width: 4),
                                      Text(
                                        'Open Link',
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: Color(AppColors.primaryDeeper),
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputBar(String uid, SmartAiRepository repository, GeminiService gemini) {
    final canSend = _inputController.text.trim().isNotEmpty && !_isTyping;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border(
          top: BorderSide(
            color: isDark ? const Color(0xFF1E293B) : const Color(AppColors.border),
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: isDark ? const Color(AppColors.darkBackground) : const Color(AppColors.background),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: _focusNode.hasFocus
                      ? const Color(AppColors.primaryDeeper)
                      : (isDark ? const Color(AppColors.darkBorder) : const Color(AppColors.border)),
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
              backgroundColor: canSend ? const Color(AppColors.primaryDeeper) : (isDark ? const Color(0xFF1E293B) : const Color(AppColors.border)),
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
        drawer: _buildSidebar(uid, repository),
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(PhosphorIconsRegular.list),
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
                  fontWeight: FontWeight.bold,
                  fontSize: 16.5,
                ),
              ),
            ],
          ),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(PhosphorIconsRegular.notePencil),
              tooltip: 'New Chat',
              onPressed: () => _startNewChat(uid, repository),
            ),
          ],
        ),
        body: Column(
          children: [
            Expanded(
              child: () {
                if (_currentSessionId != null && _messagesStream == null) {
                  _messagesStream = repository.getMessages(uid, _currentSessionId!);
                }
                return (_currentSessionId == null && _optimisticUserMessage == null)
                    ? _buildEmptyState(uid, repository, gemini)
                    : StreamBuilder<List<ChatMessage>>(
                        stream: _messagesStream,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData && _optimisticUserMessage == null) {
                            return const Center(child: CircularProgressIndicator());
                          }
        
                          final messages = snapshot.data ?? [];
                          if (messages.isEmpty && !_isTyping && _optimisticUserMessage == null) {
                            return _buildEmptyState(uid, repository, gemini);
                          }
        
                          return _buildMessageList(messages);
                        },
                      );
              }(),
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
