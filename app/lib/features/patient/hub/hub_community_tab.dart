import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';

class HubCommunityTab extends StatelessWidget {
  const HubCommunityTab({super.key});

  static const List<Map<String, dynamic>> _posts = [
    {
      'name': 'Anna B.',
      'initials': 'AB',
      'date': '5th Nov 2025',
      'content':
          "Proud of Myself\nI went for a short walk this morning even though I didn't feel motivated. It wasn't long, but it helped clear my mind.\nWhat are you proud of today?",
      'likes': 24,
      'comments': 8,
      'color': Color(0xFF7F89E9),
    },
    {
      'name': 'Anonymous',
      'initials': '?',
      'date': '5th Nov 2025',
      'content':
          "University has been overwhelming lately.\nI'm exhausted and scared I'm falling behind.\nAny gentle advice from people who've been through this?",
      'likes': 31,
      'comments': 12,
      'color': Color(0xFF9B9B9B),
    },
    {
      'name': 'Albert G.',
      'initials': 'AG',
      'date': '5th Nov 2025',
      'content':
          "I'm trying to build a consistent morning routine.\nEven simple things feel hard sometimes.\nWhat's one small habit that made your mornings better?",
      'likes': 18,
      'comments': 6,
      'color': Color(0xFF658852),
    },
    {
      'name': 'Yara S.',
      'initials': 'YS',
      'date': '4th Nov 2025',
      'content':
          "Mini Declutter Challenge — Day 3\nPick one tiny thing to tidy today.\nYour desk, your bag, your photo gallery... anything.\nShare your before/after or describe the moment.",
      'likes': 42,
      'comments': 15,
      'color': Color(0xFFA87CC7),
    },
    {
      'name': 'Zayn M.',
      'initials': 'ZM',
      'date': '13th Nov 2025',
      'content':
          "Write one sentence to yourself 6 months from now.\nNot advice — but a promise.\nI'll start: I promise to rest when I need to, not only when I break.",
      'likes': 56,
      'comments': 20,
      'color': Color(0xFF5C7BD4),
    },
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: 'Welcome to ',
                  style: GoogleFonts.poppins(
                    color: AppColors.black,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                TextSpan(
                  text: 'Mentallico\nCommunity!',
                  style: GoogleFonts.poppins(
                    color: AppColors.primary,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Here you can be yourself and share every little achievement.\nFind thousands of inspiring journeys and connect with people\nwith the same experience!',
            style: GoogleFonts.poppins(
              color: AppColors.darkGray,
              fontSize: 11,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          // Post input
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 6,
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Share an experience to inspire others or ask for advice...',
                    style: GoogleFonts.poppins(
                        color: AppColors.lightGray, fontSize: 12),
                  ),
                ),
                const Icon(Icons.attach_file_rounded,
                    color: AppColors.lightGray, size: 18),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Posts
          ...(_posts.map((p) => _PostCard(data: p))),
        ],
      ),
    );
  }
}

class _PostCard extends StatelessWidget {
  final Map<String, dynamic> data;
  const _PostCard({required this.data});

  @override
  Widget build(BuildContext context) {
    final color = data['color'] as Color;
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: color.withValues(alpha: 0.2),
                child: Text(
                  data['initials'] as String,
                  style: GoogleFonts.poppins(
                    color: color,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data['name'] as String,
                      style: GoogleFonts.poppins(
                        color: AppColors.black,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      data['date'] as String,
                      style: GoogleFonts.poppins(
                        color: AppColors.darkGray,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.more_vert_rounded,
                  color: AppColors.lightGray, size: 18),
            ],
          ),
          const SizedBox(height: 10),
          // Content
          Text(
            data['content'] as String,
            style: GoogleFonts.poppins(
              color: AppColors.black,
              fontSize: 12,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          // Actions
          Row(
            children: [
              _ActionBtn(
                  icon: Icons.thumb_up_outlined,
                  count: data['likes'] as int),
              const SizedBox(width: 16),
              _ActionBtn(
                  icon: Icons.chat_bubble_outline_rounded,
                  count: data['comments'] as int),
              const Spacer(),
              const Icon(Icons.bookmark_border_rounded,
                  color: AppColors.darkGray, size: 20),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final int count;
  const _ActionBtn({required this.icon, required this.count});

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Icon(icon, color: AppColors.darkGray, size: 18),
          const SizedBox(width: 4),
          Text(
            '$count',
            style: GoogleFonts.poppins(
                color: AppColors.darkGray, fontSize: 12),
          ),
        ],
      );
}
