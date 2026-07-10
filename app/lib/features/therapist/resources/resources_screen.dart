import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/card_with_shadow.dart';

class TherapistResourcesScreen extends StatelessWidget {
  const TherapistResourcesScreen({super.key});

  final List<Map<String, dynamic>> _resources = const [
    {
      'title': 'CBT Worksheet Pack',
      'desc': 'Thought records, behavioral experiments, activity scheduling',
      'type': 'Worksheets',
      'icon': Icons.description_outlined,
      'color': Color(0xFF7F89E9),
    },
    {
      'title': 'Anxiety Assessment Tools',
      'desc': 'GAD-7, HAMA, and STAI assessment forms',
      'type': 'Assessments',
      'icon': Icons.assignment_outlined,
      'color': Color(0xFFA87CC7),
    },
    {
      'title': 'Psychoeducation Slides',
      'desc': 'Presentations to share with patients on common conditions',
      'type': 'Presentations',
      'icon': Icons.slideshow_outlined,
      'color': Color(0xFF5C7BD4),
    },
    {
      'title': 'Relaxation Scripts',
      'desc': 'Guided imagery, PMR, and body scan audio scripts',
      'type': 'Audio',
      'icon': Icons.headphones_outlined,
      'color': Color(0xFF658852),
    },
    {
      'title': 'Session Note Templates',
      'desc': 'SOAP notes, BIRP notes, and progress note templates',
      'type': 'Templates',
      'icon': Icons.note_add_outlined,
      'color': Color(0xFFE07B5A),
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(20, 56, 20, 24),
            decoration: const BoxDecoration(
              gradient: AppColors.headerGradient,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(32),
                bottomRight: Radius.circular(32),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Resources',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Clinical tools for your practice',
                  style: GoogleFonts.poppins(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: CardWithShadow(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.share_outlined,
                        color: Colors.white, size: 22),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Share with Patient',
                          style: GoogleFonts.poppins(
                            color: AppColors.black,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          'Send resources directly to your patients',
                          style: GoogleFonts.poppins(
                            color: AppColors.darkGray,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right_rounded,
                      color: AppColors.lightGray),
                ],
              ),
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: _resources.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (_, i) => _ResourceTile(data: _resources[i]),
            ),
          ),
        ],
      ),
    );
  }
}

class _ResourceTile extends StatelessWidget {
  final Map<String, dynamic> data;
  const _ResourceTile({required this.data});

  @override
  Widget build(BuildContext context) {
    return CardWithShadow(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: (data['color'] as Color).withOpacity(0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(data['icon'] as IconData,
                color: data['color'] as Color, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data['title'] as String,
                  style: GoogleFonts.poppins(
                    color: AppColors.black,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  data['desc'] as String,
                  style: GoogleFonts.poppins(
                    color: AppColors.darkGray,
                    fontSize: 11,
                    height: 1.4,
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 6),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: (data['color'] as Color).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    data['type'] as String,
                    style: GoogleFonts.poppins(
                      color: data['color'] as Color,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            children: [
              _IconAction(icon: Icons.file_download_outlined, color: AppColors.primary),
              const SizedBox(height: 8),
              _IconAction(icon: Icons.share_outlined, color: AppColors.secondary),
            ],
          ),
        ],
      ),
    );
  }
}

class _IconAction extends StatelessWidget {
  final IconData icon;
  final Color color;
  const _IconAction({required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, color: color, size: 15),
    );
  }
}
