import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';

class HubTedTab extends StatelessWidget {
  const HubTedTab({super.key});

  static const List<Map<String, dynamic>> _talks = [
    {
      'title': 'How to manage your mental health | Leon Taylor | TEDxClapham',
      'speaker': 'Leon Taylor',
      'duration': '12:34',
      'color': Color(0xFFD4452A),
    },
    {
      'title': 'How to talk to the worst parts of yourself | Karen Faith | TEDxKC',
      'speaker': 'Karen Faith',
      'duration': '14:22',
      'color': Color(0xFF7F89E9),
    },
    {
      'title': 'The Power of Vulnerability | Brené Brown',
      'speaker': 'Brené Brown',
      'duration': '20:19',
      'color': Color(0xFF4A6B8A),
    },
  ];

  static const _featured = {
    'title':
        'How To Protect Your Brain From Stress | Niki Korteweg | TEDxAmsterdamWomen',
    'speaker': 'Niki Korteweg',
    'duration': '15:42',
    'color': Color(0xFF9095D9),
  };

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle('TED Talk Of the Week'),
          const SizedBox(height: 12),
          // Featured TED
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.07),
                  blurRadius: 10,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    Container(
                      height: 160,
                      decoration: BoxDecoration(
                        color: _featured['color'] as Color,
                        borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(16)),
                      ),
                      child: const Center(
                        child: Icon(Icons.play_circle_fill_rounded,
                            color: Colors.white, size: 56),
                      ),
                    ),
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFD4452A),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'TED',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        color: Colors.black54,
                        child: Text(
                          _featured['duration'] as String,
                          style: GoogleFonts.poppins(
                              color: Colors.white, fontSize: 11),
                        ),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(14),
                  child: Text(
                    _featured['title'] as String,
                    style: GoogleFonts.poppins(
                      color: AppColors.black,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _SectionTitle('Top TED Talks'),
              Text(
                'See All',
                style: GoogleFonts.poppins(
                    color: AppColors.primary,
                    fontSize: 12,
                    fontWeight: FontWeight.w500),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...(_talks.map((t) => _TedCard(data: t))),
        ],
      ),
    );
  }
}

class _TedCard extends StatelessWidget {
  final Map<String, dynamic> data;
  const _TedCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
      child: Row(
        children: [
          Container(
            width: 90,
            height: 70,
            decoration: BoxDecoration(
              color: data['color'] as Color,
              borderRadius: const BorderRadius.horizontal(
                  left: Radius.circular(14)),
            ),
            child: const Center(
              child: Icon(Icons.play_circle_outline_rounded,
                  color: Colors.white, size: 32),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data['title'] as String,
                    style: GoogleFonts.poppins(
                      color: AppColors.black,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${data['speaker']} · ${data['duration']}',
                    style: GoogleFonts.poppins(
                        color: AppColors.darkGray, fontSize: 10),
                  ),
                ],
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(right: 10),
            child: Icon(Icons.chevron_right_rounded,
                color: AppColors.lightGray),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: GoogleFonts.poppins(
          color: AppColors.black,
          fontSize: 15,
          fontWeight: FontWeight.w700,
        ),
      );
}
