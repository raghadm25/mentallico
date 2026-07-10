import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'ai_chat_conversation.dart';

class AiChatTab extends StatelessWidget {
  const AiChatTab({super.key});

  static const List<String> _history = [
    'How To Get Over The Feeling Of Guilt?',
    'Best Books To Read About Personal Growth',
    'Daily Fights With Overthinking',
    'Feeling Misunderstood',
    'Overwhelming Day',
    'How To Get Over The Feeling Of Guilt?',
    'Best Books To Read About Personal Growth',
    'Daily Fights With Overthinking',
    'Feeling Misunderstood',
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: EdgeInsets.zero,
      itemCount: _history.length,
      separatorBuilder: (_, __) => Container(
        height: 1,
        color: const Color(0xFFD2D5DE),
      ),
      itemBuilder: (ctx, i) => GestureDetector(
        onTap: () => Navigator.push(
          ctx,
          MaterialPageRoute(
            builder: (_) => AiChatConversation(title: _history[i]),
          ),
        ),
        child: Container(
          width: double.infinity,
          height: 64.785,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [Color(0xFF7F89E9), Color(0xFFA87CC7)],
            ),
          ),
          child: Center(
            child: Text(
              _history[i],
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.white,
                letterSpacing: -0.8,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
