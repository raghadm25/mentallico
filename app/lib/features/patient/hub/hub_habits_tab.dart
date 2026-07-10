import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';

class HubHabitsTab extends StatelessWidget {
  const HubHabitsTab({super.key});

  static const List<Map<String, dynamic>> _goodHabits = [
    {
      'label': 'Meditate',
      'icon': Icons.self_improvement,
      'color': Color(0xFF9B7FC7),
      'bg': Color(0xFFE8DEFF),
    },
    {
      'label': 'Practice Gratitude',
      'icon': Icons.favorite_outline,
      'color': Color(0xFF658852),
      'bg': Color(0xFFDDEFD1),
    },
    {
      'label': 'Workout',
      'icon': Icons.fitness_center,
      'color': Color(0xFF4A7B8A),
      'bg': Color(0xFFCDE6EE),
    },
    {
      'label': 'Declutter',
      'icon': Icons.auto_fix_high_rounded,
      'color': Color(0xFFC75A7C),
      'bg': Color(0xFFF5D0DC),
    },
  ];

  static const List<Map<String, dynamic>> _badHabits = [
    {
      'label': 'Quit Smoking',
      'icon': Icons.smoke_free_rounded,
      'color': Color(0xFF4A6B3A),
      'bg': Color(0xFFD1E8C2),
    },
    {
      'label': 'Quit Skipping Meals',
      'icon': Icons.no_meals_rounded,
      'color': Color(0xFF5A4BA0),
      'bg': Color(0xFFDDD9F5),
    },
    {
      'label': 'Quit Staying up late',
      'icon': Icons.nightlight_round,
      'color': Color(0xFF8B3A5A),
      'bg': Color(0xFFF5D0DC),
    },
    {
      'label': 'Quit negative self talk',
      'icon': Icons.heart_broken_rounded,
      'color': Color(0xFF6B5A2A),
      'bg': Color(0xFFF0E8CA),
    },
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle('Start new good habits'),
          const SizedBox(height: 12),
          _HabitGrid(habits: _goodHabits),
          const SizedBox(height: 20),
          _SectionTitle('Quit bad habits'),
          const SizedBox(height: 12),
          _HabitGrid(habits: _badHabits),
        ],
      ),
    );
  }
}

class _HabitGrid extends StatelessWidget {
  final List<Map<String, dynamic>> habits;
  const _HabitGrid({required this.habits});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: habits.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.0,
      ),
      itemBuilder: (_, i) {
        final h = habits[i];
        return GestureDetector(
          onTap: () {},
          child: Container(
            decoration: BoxDecoration(
              color: h['bg'] as Color,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  h['icon'] as IconData,
                  color: h['color'] as Color,
                  size: 52,
                ),
                const SizedBox(height: 10),
                Text(
                  h['label'] as String,
                  style: GoogleFonts.poppins(
                    color: h['color'] as Color,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
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
