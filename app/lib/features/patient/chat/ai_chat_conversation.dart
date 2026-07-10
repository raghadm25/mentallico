import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../services/firestore_service.dart';
import '../../../services/mentallico_api_service.dart';
import 'chat_menu_drawer.dart';

class AiChatConversation extends StatefulWidget {
  final String title;
  /// Existing chat to load & continue. Null means a brand-new, unsaved chat —
  /// it's created in Firestore (and auto-titled) on the first message sent.
  final String? chatId;
  final VoidCallback? onBack;
  const AiChatConversation({
    super.key,
    this.title = 'New Chat',
    this.chatId,
    this.onBack,
  });

  @override
  State<AiChatConversation> createState() => _AiChatConversationState();
}

class _AiChatConversationState extends State<AiChatConversation> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _controller = TextEditingController();
  final _scrollCtrl = ScrollController();
  bool _typing = false;

  final List<_Msg> _messages = [];
  String? _chatId;
  String? _sessionId; // Mentallico API session — reused for the whole conversation
  late String _title;

  static const List<String> _suggestions = [
    'Try A Breathing Exercise',
    'I Just Need To Vent',
    'I Want To Learn How To Say No.',
    'Help Me Understand My Mood',
    'I Feel Anxious And Want To Calm Down',
  ];

  @override
  void initState() {
    super.initState();
    _chatId = widget.chatId;
    _title = widget.title;
    if (widget.chatId != null) _loadExisting(widget.chatId!);
  }

  Future<void> _loadExisting(String chatId) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    final saved = await FirestoreService.loadAiChatMessages(uid, chatId);
    if (!mounted) return;
    setState(() {
      _messages.addAll(
          saved.map((m) => _Msg(m.text, isAi: m.isAi)));
    });
    _scrollToBottom();
  }

  // Auto-names a new chat from its first message, e.g. "I'm feeling anxious
  // about work" → "I'm feeling anxious about work".
  String _titleFromContent(String text) {
    final cleaned = text.trim().replaceAll(RegExp(r'\s+'), ' ');
    if (cleaned.isEmpty) return 'New Chat';
    const maxLen = 42;
    final capped = cleaned.length > maxLen
        ? '${cleaned.substring(0, maxLen).trimRight()}…'
        : cleaned;
    return capped[0].toUpperCase() + capped.substring(1);
  }

  Future<void> _persist(String text, {required bool isAi}) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    if (_chatId == null) {
      final title = _titleFromContent(text);
      _chatId = await FirestoreService.createAiChat(uid, title);
      if (mounted) setState(() => _title = title);
    }
    await FirestoreService.addAiChatMessage(uid, _chatId!,
        text: text, isAi: isAi);
  }

  Future<void> _send([String? text]) async {
    final msg = (text ?? _controller.text).trim();
    if (msg.isEmpty) return;
    setState(() {
      _messages.add(_Msg(msg, isAi: false));
      _controller.clear();
      _typing = true;
    });
    _scrollToBottom();
    _persist(msg, isAi: false);

    try {
      _sessionId ??= await MentallicoApiService.createSession();
      final result =
          await MentallicoApiService.sendSessionMessage(_sessionId!, msg);
      if (!mounted) return;
      setState(() {
        _typing = false;
        _messages.add(_Msg(result.response, isAi: true));
      });
      _scrollToBottom();
      _persist(result.response, isAi: true);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _typing = false;
        _messages.add(_Msg(
          "Sorry, I couldn't reach the server right now. Please try again in a moment.",
          isAi: true,
        ));
      });
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isEmpty = _messages.isEmpty;
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.background,
      drawer: const ChatMenuDrawer(isAiChatActive: true, isInsideConversation: true),
      body: SafeArea(
        child: Column(
          children: [
            // Top bar
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: widget.onBack ?? () => Navigator.pop(context),
                    child: const Icon(Icons.arrow_back_ios_new_rounded,
                        size: 20, color: AppColors.black),
                  ),
                  Expanded(
                    child: Text(
                      _title,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: AppColors.black,
                        letterSpacing: -0.6,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () =>
                        _scaffoldKey.currentState?.openDrawer(),
                    child: const Icon(Icons.menu_rounded,
                        size: 26, color: AppColors.black),
                  ),
                ],
              ),
            ),
            // Empty state
            if (isEmpty) ...[
              const Spacer(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  "I'm Here To Listen And Help You Make Sense Of What's On Your Mind.",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.black,
                    height: 1.4,
                  ),
                ),
              ),
              const SizedBox(height: 28),
              _buildInputField(),
              const SizedBox(height: 24),
              _buildSuggestions(),
              const Spacer(),
            ] else ...[
              // Messages
              Expanded(
                child: ListView.builder(
                  controller: _scrollCtrl,
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
                  itemCount: _messages.length + (_typing ? 1 : 0),
                  itemBuilder: (_, i) {
                    if (i == _messages.length) return _buildTyping();
                    return _buildBubble(_messages[i]);
                  },
                ),
              ),
              _buildInputField(),
              const SizedBox(height: 8),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildBubble(_Msg msg) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment:
            msg.isAi ? MainAxisAlignment.start : MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (msg.isAi) ...[
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.smart_toy_outlined,
                  color: AppColors.primary, size: 18),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              decoration: BoxDecoration(
                color: msg.isAi ? Colors.white : AppColors.primary,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(18),
                  topRight: const Radius.circular(18),
                  bottomLeft: Radius.circular(msg.isAi ? 4 : 18),
                  bottomRight: Radius.circular(msg.isAi ? 18 : 4),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                msg.text,
                style: GoogleFonts.poppins(
                  color: msg.isAi ? AppColors.black : Colors.white,
                  fontSize: 13,
                  height: 1.5,
                ),
              ),
            ),
          ),
          if (!msg.isAi) ...[
            const SizedBox(width: 8),
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: AppColors.lightGray.withValues(alpha: 0.4),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.person_outline,
                  color: AppColors.darkGray, size: 18),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTyping() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.smart_toy_outlined,
                color: AppColors.primary, size: 18),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(18),
                topRight: Radius.circular(18),
                bottomRight: Radius.circular(18),
                bottomLeft: Radius.circular(4),
              ),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06), blurRadius: 8)
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(
                3,
                (i) => _Dot(delay: i * 200),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 52,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 12,
                  ),
                ],
              ),
              child: TextField(
                controller: _controller,
                style: GoogleFonts.poppins(fontSize: 14, color: AppColors.black),
                decoration: InputDecoration(
                  hintText: 'Type Your Message Here',
                  hintStyle: GoogleFonts.poppins(
                      color: AppColors.lightGray, fontSize: 14),
                  border: InputBorder.none,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
                ),
                onSubmitted: (_) => _send(),
              ),
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: () => _send(),
            child: Container(
              width: 48,
              height: 48,
              decoration: const BoxDecoration(
                gradient: AppColors.primaryGradient,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.send_rounded,
                  color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestions() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        alignment: WrapAlignment.center,
        children: _suggestions
            .map(
              (s) => GestureDetector(
                onTap: () => _send(s),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 18, vertical: 12),
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Text(
                    s,
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}

class _Dot extends StatefulWidget {
  final int delay;
  const _Dot({required this.delay});

  @override
  State<_Dot> createState() => _DotState();
}

class _DotState extends State<_Dot> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat(reverse: true);
    _anim = Tween<double>(begin: 0, end: -6).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: Interval(widget.delay / 1000, 1.0, curve: Curves.easeInOut),
      ),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => Transform.translate(
        offset: Offset(0, _anim.value),
        child: Container(
          width: 8,
          height: 8,
          margin: const EdgeInsets.symmetric(horizontal: 3),
          decoration: const BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}

class _Msg {
  final String text;
  final bool isAi;
  _Msg(this.text, {required this.isAi});
}
