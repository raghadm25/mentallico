import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';

class HubPodcastsTab extends StatelessWidget {
  const HubPodcastsTab({super.key});

  static const List<Map<String, dynamic>> _podcasts = [
    {
      'title': 'The Psychology Podcast',
      'host': 'Dr. Scott Barry Kaufman',
      'color': Color(0xFF7F89E9),
      'episodes': '320 episodes',
    },
    {
      'title': 'Mental Illness Happy Hour',
      'host': 'Paul Gilmartin',
      'color': Color(0xFFA87CC7),
      'episodes': '500+ episodes',
    },
    {
      'title': 'The Psychology Of Your 20s',
      'host': 'Jemma Sbeg',
      'color': Color(0xFF658852),
      'episodes': '200 episodes',
    },
    {
      'title': 'What Your Therapist Thinks',
      'host': 'Various therapists',
      'color': Color(0xFF5C7BD4),
      'episodes': '150 episodes',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final podOfWeek = {
      'title': 'Psychology Unplugged',
      'host': 'Dr. Thad Williams',
      'color': const Color(0xFF9095D9),
    };

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Podcast of the week
          _SectionTitle('Podcast Of the Week'),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  (podOfWeek['color'] as Color).withValues(alpha: 0.3),
                  (podOfWeek['color'] as Color).withValues(alpha: 0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: podOfWeek['color'] as Color,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.headphones_rounded,
                      color: Colors.white, size: 56),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    podOfWeek['title'] as String,
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // Top podcasts
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _SectionTitle('Top Podcasts'),
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
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _podcasts.length,
            gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.0,
            ),
            itemBuilder: (_, i) {
              final p = _podcasts[i];
              return Container(
                decoration: BoxDecoration(
                  color: (p['color'] as Color).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: p['color'] as Color,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.mic_rounded,
                          color: Colors.white, size: 28),
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Text(
                        p['title'] as String,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          color: AppColors.black,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      p['host'] as String,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        color: AppColors.darkGray,
                        fontSize: 9,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              );
            },
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
