import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';

class HubBooksTab extends StatelessWidget {
  const HubBooksTab({super.key});

  static const List<Map<String, dynamic>> _books = [
    {
      'title': 'This Book Will Change Your Mind About Mental Health',
      'author': 'Nathan Filer',
      'color': Color(0xFF7F89E9),
      'tag': 'Bestseller',
    },
    {
      'title': 'Where To Start',
      'author': 'Emma Gannon',
      'color': Color(0xFF5C9BD4),
      'tag': 'Featured',
    },
    {
      'title': 'What Happened To You?',
      'author': 'Bruce Perry',
      'color': Color(0xFF8B5E83),
      'tag': 'Popular',
    },
    {
      'title': 'Depression, Anxiety, & Other Things We Don\'t Want To Talk About',
      'author': 'Ryan Casey Waller',
      'color': Color(0xFF4A6B8A),
      'tag': 'New',
    },
    {
      'title': 'Practicing Mindfulness',
      'author': 'Matthew Sockolov',
      'color': Color(0xFF658852),
      'tag': 'Top Rated',
    },
    {
      'title': 'The Art and Science of Love',
      'author': 'John Gottman',
      'color': Color(0xFFD4785A),
      'tag': 'Classic',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final featured = _books[0];
    final spotlight = _books[1];
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Book of the week
          _SectionTitle('Book Of the Week'),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  (featured['color'] as Color).withValues(alpha: 0.2),
                  (featured['color'] as Color).withValues(alpha: 0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                _BookCover(
                  color: featured['color'] as Color,
                  title: featured['title'] as String,
                  width: 80,
                  height: 110,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: featured['color'] as Color,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          featured['tag'] as String,
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        featured['title'] as String,
                        style: GoogleFonts.poppins(
                          color: AppColors.black,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          height: 1.3,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        featured['author'] as String,
                        style: GoogleFonts.poppins(
                          color: AppColors.darkGray,
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 7),
                        decoration: BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'Get Book About Mental Health',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // Books that understand you
          _SectionTitle('Books That Understand You'),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 10,
                ),
              ],
            ),
            child: Row(
              children: [
                _BookCover(
                  color: spotlight['color'] as Color,
                  title: spotlight['title'] as String,
                  width: 90,
                  height: 120,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        spotlight['title'] as String,
                        style: GoogleFonts.poppins(
                          color: AppColors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        spotlight['author'] as String,
                        style: GoogleFonts.poppins(
                          color: AppColors.darkGray,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.star_rounded,
                              color: Color(0xFFFFC107), size: 14),
                          const SizedBox(width: 4),
                          Text('4.8',
                              style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600)),
                          const SizedBox(width: 8),
                          Text('(2.1k)',
                              style: GoogleFonts.poppins(
                                  color: AppColors.darkGray, fontSize: 11)),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          _SmallBtn('Get Now',
                              AppColors.primaryGradient, Colors.white),
                          const SizedBox(width: 8),
                          _SmallBtnOutline('Preview'),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // Book list grid
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _SectionTitle('Book List'),
              Text(
                'See All',
                style: GoogleFonts.poppins(
                    color: AppColors.primary,
                    fontSize: 12,
                    fontWeight: FontWeight.w500),
              ),
            ],
          ),
          const SizedBox(height: 10),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _books.length,
            gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 0.65,
            ),
            itemBuilder: (_, i) => Column(
              children: [
                Expanded(
                  child: _BookCover(
                    color: _books[i]['color'] as Color,
                    title: _books[i]['title'] as String,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _books[i]['title'] as String,
                  style: GoogleFonts.poppins(
                      fontSize: 9, color: AppColors.darkGray),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BookCover extends StatelessWidget {
  final Color color;
  final String title;
  final double? width;
  final double? height;

  const _BookCover(
      {required this.color, required this.title, this.width, this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: Text(
          title,
          style: const TextStyle(
              color: Colors.white, fontSize: 8, fontWeight: FontWeight.w600),
          maxLines: 4,
          overflow: TextOverflow.ellipsis,
        ),
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

class _SmallBtn extends StatelessWidget {
  final String label;
  final Gradient gradient;
  final Color textColor;
  const _SmallBtn(this.label, this.gradient, this.textColor);

  @override
  Widget build(BuildContext context) => Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(label,
            style: GoogleFonts.poppins(
                color: textColor,
                fontSize: 11,
                fontWeight: FontWeight.w600)),
      );
}

class _SmallBtnOutline extends StatelessWidget {
  final String label;
  const _SmallBtnOutline(this.label);

  @override
  Widget build(BuildContext context) => Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.primary),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(label,
            style: GoogleFonts.poppins(
                color: AppColors.primary,
                fontSize: 11,
                fontWeight: FontWeight.w600)),
      );
}
