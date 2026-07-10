import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/widgets/user_avatar.dart';
import '../../../services/app_state.dart';
import '../../../services/auth_service.dart';
import '../../../services/firestore_service.dart';
import 'ai_chat_conversation.dart';

class _HistoryEntry {
  final String? id; // null = "New Chat" pseudo-entry, or a mock therapist row
  final String title;
  const _HistoryEntry({this.id, required this.title});
}

class ChatMenuDrawer extends StatefulWidget {
  final bool isAiChatActive;
  /// True when the drawer is opened from inside a chat conversation screen
  /// (not from the main chat list). Controls whether history taps use
  /// pushReplacement (to avoid stacking conversations) or push.
  final bool isInsideConversation;
  const ChatMenuDrawer({
    super.key,
    this.isAiChatActive = true,
    this.isInsideConversation = false,
  });

  @override
  State<ChatMenuDrawer> createState() => _ChatMenuDrawerState();
}

class _ChatMenuDrawerState extends State<ChatMenuDrawer> {
  late int _tab;
  final TextEditingController _searchCtrl = TextEditingController();

  static const String newChatLabel = 'New Chat';

  List<AiChatSummary> _aiChats = [];
  StreamSubscription<List<AiChatSummary>>? _aiChatsSub;

  static const _therapistHistory = [
    'Session with Dr. Ali Samir',
    'Follow-up with Dr. Sara Hany',
    'Session with Dr. Mariah Holland',
    'Initial consultation — Dr. Xavier Roberto',
    'Session with Dr. Kareem El-Hadidy',
    'Follow-up with Dr. Monica Hernandez',
    'Session with Dr. Hager Osama',
  ];

  @override
  void initState() {
    super.initState();
    _tab = widget.isAiChatActive ? 0 : 1;
    _searchCtrl.addListener(() => setState(() {}));
    _aiChatsSub = FirestoreService.aiChatsStream().listen((chats) {
      if (mounted) setState(() => _aiChats = chats);
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _aiChatsSub?.cancel();
    super.dispose();
  }

  List<_HistoryEntry> get _filteredHistory {
    final q = _searchCtrl.text.trim().toLowerCase();
    if (_tab == 0) {
      final filtered = q.isEmpty
          ? _aiChats
          : _aiChats.where((c) => c.title.toLowerCase().contains(q)).toList();
      final entries =
          filtered.map((c) => _HistoryEntry(id: c.id, title: c.title));
      // "New Chat" always leads the AI history, but only while not searching.
      if (q.isEmpty) {
        return [const _HistoryEntry(title: newChatLabel), ...entries];
      }
      return entries.toList();
    }
    final filtered = q.isEmpty
        ? _therapistHistory
        : _therapistHistory.where((h) => h.toLowerCase().contains(q));
    return filtered.map((t) => _HistoryEntry(title: t)).toList();
  }

  @override
  Widget build(BuildContext context) {
    final s = MediaQuery.of(context).size.width / 430;
    final items = _filteredHistory;

    return Drawer(
      width: 386 * s,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      child: Column(
        children: [
          // ── Gradient header ──────────────────────────────────────────────
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [Color(0xFF7F89E9), Color(0xFFA87CC7)],
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title row
                  Padding(
                    padding: EdgeInsets.fromLTRB(35 * s, 35 * s, 10 * s, 0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Mentallico',
                            style: GoogleFonts.poppins(
                              fontSize: 48 * s,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                              letterSpacing: -4.8 * s,
                              height: 1.208,
                            ),
                          ),
                        ),
                        // Close drawer button
                        GestureDetector(
                          onTap: () => Navigator.of(context).pop(),
                          child: Padding(
                            padding: EdgeInsets.all(8 * s),
                            child: Icon(
                              Icons.menu_rounded,
                              color: Colors.white,
                              size: 36 * s,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Divider
                  SizedBox(height: 16 * s),
                  Container(
                    height: 1,
                    color: const Color(0xFFD2D5DE).withValues(alpha: 0.7),
                  ),
                  SizedBox(height: 16 * s),

                  // AI Chat / Therapist Chat tabs
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 33 * s),
                    child: Row(
                      children: [
                        _TabPill(
                          label: 'AI Chat',
                          active: _tab == 0,
                          s: s,
                          onTap: () => setState(() => _tab = 0),
                        ),
                        SizedBox(width: 8 * s),
                        _TabPill(
                          label: 'Therapist Chat',
                          active: _tab == 1,
                          s: s,
                          onTap: () => setState(() => _tab = 1),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 16 * s),

                  // Search bar
                  Padding(
                    padding: EdgeInsets.fromLTRB(33 * s, 0, 33 * s, 20 * s),
                    child: Container(
                      height: 45 * s,
                      decoration: BoxDecoration(
                        border: Border.all(
                            color: const Color(0xFFD2D5DE)),
                        borderRadius: BorderRadius.circular(30 * s),
                      ),
                      child: TextField(
                        controller: _searchCtrl,
                        cursorColor: Colors.white,
                        style: GoogleFonts.poppins(
                          fontSize: 15 * s,
                          color: Colors.white,
                          letterSpacing: -0.8 * s,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Chat History',
                          hintStyle: GoogleFonts.poppins(
                            fontSize: 15 * s,
                            color: Colors.white.withValues(alpha: 0.65),
                            letterSpacing: -0.8 * s,
                          ),
                          filled: true,
                          fillColor: Colors.transparent,
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding:
                              EdgeInsets.symmetric(vertical: 13 * s),
                          prefixIcon: Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 14 * s),
                            child: Icon(
                              Icons.search_rounded,
                              color: Colors.white,
                              size: 26 * s,
                            ),
                          ),
                          prefixIconConstraints: const BoxConstraints(),
                          suffixIcon: _searchCtrl.text.isNotEmpty
                              ? IconButton(
                                  icon: Icon(Icons.close_rounded,
                                      color: Colors.white,
                                      size: 18 * s),
                                  onPressed: () => _searchCtrl.clear(),
                                  padding: EdgeInsets.zero,
                                )
                              : null,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Chat history list ────────────────────────────────────────────
          Expanded(
            child: items.isEmpty
                ? _buildEmpty(s)
                : ListView.separated(
                    padding: EdgeInsets.zero,
                    itemCount: items.length,
                    separatorBuilder: (_, _) => Container(
                      height: 1,
                      color: const Color(0xFFD2D5DE).withValues(alpha: 0.5),
                    ),
                    itemBuilder: (ctx, i) => _HistoryItem(
                      title: items[i].title,
                      chatId: items[i].id,
                      tab: _tab,
                      s: s,
                      isNewChat: _tab == 0 &&
                          items[i].id == null &&
                          items[i].title == newChatLabel,
                      isInsideConversation:
                          widget.isInsideConversation,
                    ),
                  ),
          ),

          // ── User footer ──────────────────────────────────────────────────
          _buildUserCard(s),
        ],
      ),
    );
  }

  Widget _buildEmpty(double s) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.search_off_rounded,
              size: 40 * s,
              color: const Color(0xFF7F89E9).withValues(alpha: 0.4)),
          SizedBox(height: 8 * s),
          Text(
            'No chats found',
            style: GoogleFonts.poppins(
              fontSize: 14 * s,
              color: const Color(0xFF595959),
              letterSpacing: -0.4 * s,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserCard(double s) {
    return Container(
      width: double.infinity,
      color: const Color(0xFF1A2E12),
      padding: EdgeInsets.symmetric(vertical: 24 * s),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          UserAvatar(radius: 26.5 * s, borderWidth: 2 * s),
          SizedBox(width: 16 * s),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                AppState.instance.userName,
                style: GoogleFonts.poppins(
                  fontSize: 16 * s,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                  letterSpacing: -0.8 * s,
                ),
              ),
              Text(
                AuthService.currentUser?.email ?? '',
                style: GoogleFonts.poppins(
                  fontSize: 11 * s,
                  fontWeight: FontWeight.w300,
                  color: const Color(0xFFA4A4A4),
                  letterSpacing: -0.55 * s,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── History row item ──────────────────────────────────────────────────────────

class _HistoryItem extends StatelessWidget {
  final String title;
  final String? chatId;
  final int tab;
  final double s;
  final bool isNewChat;
  final bool isInsideConversation;

  const _HistoryItem({
    required this.title,
    this.chatId,
    required this.tab,
    required this.s,
    this.isNewChat = false,
    this.isInsideConversation = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Close the drawer without touching the Navigator stack
        Scaffold.of(context).closeDrawer();
        if (tab == 0) {
          final conversation = isNewChat
              ? const AiChatConversation()
              : AiChatConversation(title: title, chatId: chatId);
          // When already inside a conversation, replace it so back-button
          // returns to the chat list — not to the previous conversation.
          if (isInsideConversation) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => conversation),
            );
          } else {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => conversation),
            );
          }
        }
        // Therapist history items: just close drawer for now
        // (opening a specific session requires a backend session ID)
      },
      child: Container(
        width: double.infinity,
        height: 64.785 * s,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [Color(0xFF7F89E9), Color(0xFFA87CC7)],
          ),
        ),
        alignment: Alignment.center,
        padding: EdgeInsets.symmetric(horizontal: 20 * s),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isNewChat) ...[
              Icon(Icons.add_circle_outline_rounded,
                  color: Colors.white, size: 18 * s),
              SizedBox(width: 8 * s),
            ],
            Flexible(
              child: Text(
                title,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.poppins(
                  fontSize: 15 * s,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                  letterSpacing: -0.75 * s,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Tab pill (reused from chat_screen) ───────────────────────────────────────

class _TabPill extends StatelessWidget {
  final String label;
  final bool active;
  final double s;
  final VoidCallback onTap;

  const _TabPill(
      {required this.label,
      required this.active,
      required this.s,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 154 * s,
        height: 43 * s,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: active
              ? Colors.white
              : Colors.white.withValues(alpha: 0.22),
          borderRadius: BorderRadius.circular(22.564 * s),
          boxShadow: active
              ? [
                  BoxShadow(
                    color: const Color(0xFFA87CC7).withValues(alpha: 0.42),
                    blurRadius: 5 * s,
                    offset: Offset(0, 2 * s),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 14.667 * s,
            fontWeight: FontWeight.w600,
            color: active ? const Color(0xFF7F89E9) : Colors.white,
            letterSpacing: -0.73 * s,
          ),
        ),
      ),
    );
  }
}
