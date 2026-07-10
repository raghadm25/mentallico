import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/widgets/user_avatar.dart';
import '../../../services/app_state.dart';
import '../../../services/auth_service.dart';
import 'ai_chat_tab.dart';
import 'therapist_chat_tab.dart';
import 'chat_menu_drawer.dart';

class ChatScreen extends StatefulWidget {
  final VoidCallback? onBack;
  const ChatScreen({super.key, this.onBack});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  int _tab = 0;
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: ChatMenuDrawer(isAiChatActive: _tab == 0),
      body: Container(
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
              const SizedBox(height: 35),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: widget.onBack,
                      child: const Padding(
                        padding: EdgeInsets.only(right: 8),
                        child: Icon(Icons.arrow_back_ios_new_rounded,
                            color: Colors.white, size: 22),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        'Mentallico',
                        style: GoogleFonts.poppins(
                          fontSize: 48,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                          letterSpacing: -4.8,
                          height: 1,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () =>
                          _scaffoldKey.currentState?.openDrawer(),
                      child: const Icon(Icons.menu_rounded,
                          color: Colors.white, size: 36),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Container(height: 1, color: const Color(0xFFD2D5DE)),
              const SizedBox(height: 18),
              Padding(
                padding: const EdgeInsets.only(left: 33),
                child: Row(
                  children: [
                    _TabPill(
                      label: 'AI Chat',
                      active: _tab == 0,
                      onTap: () => setState(() => _tab = 0),
                    ),
                    const SizedBox(width: 8),
                    _TabPill(
                      label: 'Therapist Chat',
                      active: _tab == 1,
                      onTap: () => setState(() => _tab = 1),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 33),
                child: Container(
                  height: 45,
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xFFD2D5DE)),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Row(
                    children: [
                      const SizedBox(width: 20),
                      const Icon(Icons.search_rounded,
                          color: Colors.white, size: 26),
                      const SizedBox(width: 17),
                      Text(
                        'Chat History',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          color: Colors.white,
                          letterSpacing: -0.8,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: _tab == 0
                    ? const AiChatTab()
                    : const TherapistChatTab(),
              ),
              const _UserCard(),
            ],
          ),
        ),
      ),
    );
  }
}

class _TabPill extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _TabPill(
      {required this.label, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 154,
        height: 43,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: active
              ? Colors.white
              : Colors.white.withValues(alpha: 0.32),
          borderRadius: BorderRadius.circular(22.564),
          boxShadow: active
              ? [
                  BoxShadow(
                    color: const Color(0xFFA87CC7).withValues(alpha: 0.42),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 14.667,
            fontWeight: FontWeight.w600,
            color: active
                ? const Color(0xFF7F89E9)
                : Colors.white,
          ),
        ),
      ),
    );
  }
}

class _UserCard extends StatelessWidget {
  const _UserCard();

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).padding.bottom;
    return Container(
      width: double.infinity,
      color: const Color(0xFF1A2E12),
      padding: EdgeInsets.fromLTRB(0, 20, 0, 20 + bottomPad),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const UserAvatar(radius: 26.5, borderWidth: 2),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                AppState.instance.userName,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                  letterSpacing: -0.8,
                ),
              ),
              Text(
                AuthService.currentUser?.email ?? '',
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  fontWeight: FontWeight.w300,
                  color: const Color(0xFFA4A4A4),
                  letterSpacing: -0.55,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
