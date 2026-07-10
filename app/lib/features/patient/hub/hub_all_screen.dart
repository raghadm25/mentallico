import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'hub_screen.dart';

enum _HubType { book, podcast, ted, habit }

class HubAllScreen extends StatelessWidget {
  final String title;
  final _HubType _type;
  final List<HubResource>? _resources;
  final List<HubHabit>? _habits;
  final void Function(HubResource)? _onTap;

  const HubAllScreen._({
    required this.title,
    required _HubType type,
    List<HubResource>? resources,
    List<HubHabit>? habits,
    void Function(HubResource)? onTap,
  })  : _type = type,
        _resources = resources,
        _habits = habits,
        _onTap = onTap;

  factory HubAllScreen.books({
    required List<HubResource> items,
    required void Function(HubResource) onTap,
  }) =>
      HubAllScreen._(
          title: 'Books', type: _HubType.book, resources: items, onTap: onTap);

  factory HubAllScreen.podcasts({
    required List<HubResource> items,
    required void Function(HubResource) onTap,
  }) =>
      HubAllScreen._(
          title: 'Podcasts',
          type: _HubType.podcast,
          resources: items,
          onTap: onTap);

  factory HubAllScreen.tedTalks({
    required List<HubResource> items,
    required void Function(HubResource) onTap,
  }) =>
      HubAllScreen._(
          title: 'TED Talks',
          type: _HubType.ted,
          resources: items,
          onTap: onTap);

  factory HubAllScreen.habits({required List<HubHabit> habits}) =>
      HubAllScreen._(
          title: 'Habits Lists', type: _HubType.habit, habits: habits);

  @override
  Widget build(BuildContext context) {
    final s = MediaQuery.of(context).size.width / 430;

    return Scaffold(
      backgroundColor: const Color(0xFFF0F0F0),
      body: SafeArea(
        child: Column(
          children: [
            // App bar
            Padding(
              padding: EdgeInsets.fromLTRB(20 * s, 12 * s, 20 * s, 0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Icon(Icons.arrow_back_ios_new_rounded,
                        size: 20 * s, color: const Color(0xFF1A2E12)),
                  ),
                  SizedBox(width: 16 * s),
                  Expanded(
                    child: Text(
                      title,
                      style: GoogleFonts.poppins(
                        fontSize: 20 * s,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF1A2E12),
                        letterSpacing: -1 * s,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 8 * s),
            Container(height: 1, color: const Color(0xFFD2D5DE)),
            SizedBox(height: 16 * s),
            Expanded(child: _buildGrid(s)),
          ],
        ),
      ),
    );
  }

  Widget _buildGrid(double s) {
    if (_type == _HubType.habit) {
      return _buildHabitsGrid(s);
    }
    return _buildResourceGrid(s);
  }

  Widget _buildResourceGrid(double s) {
    final items = _resources!;
    // 2-column grid: card width = (430 - 35*2 - 23) / 2 ≈ 168.5
    const crossCount = 2;
    const spacing = 23.0;
    final pad = 35.0;
    final cardW = (430 - pad * 2 - spacing) / crossCount; // ~168.5

    Widget buildCard(HubResource item) {
      switch (_type) {
        case _HubType.book:
          return _BookCardAll(item: item, s: s, cardW: cardW, onTap: () => _onTap?.call(item));
        case _HubType.podcast:
          return _PodcastCardAll(item: item, s: s, cardW: cardW, onTap: () => _onTap?.call(item));
        case _HubType.ted:
          return _TedCardAll(item: item, s: s, cardW: cardW, onTap: () => _onTap?.call(item));
        default:
          return const SizedBox.shrink();
      }
    }

    return GridView.builder(
      padding: EdgeInsets.fromLTRB(pad * s, 0, pad * s, 24 * s),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossCount,
        crossAxisSpacing: spacing * s,
        mainAxisSpacing: 20 * s,
        childAspectRatio: _type == _HubType.podcast
            ? (cardW / (160 + 14 + 30)) // card + gap + text height approx
            : (cardW / 215),
      ),
      itemCount: items.length,
      itemBuilder: (_, i) => buildCard(items[i]),
    );
  }

  Widget _buildHabitsGrid(double s) {
    final habits = _habits!;
    const crossCount = 2;
    const spacing = 23.0;
    final pad = 35.0;
    final cardW = (430 - pad * 2 - spacing) / crossCount;

    return GridView.builder(
      padding: EdgeInsets.fromLTRB(pad * s, 0, pad * s, 24 * s),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossCount,
        crossAxisSpacing: spacing * s,
        mainAxisSpacing: 20 * s,
        childAspectRatio: cardW / (cardW + 36), // card is square + text below
      ),
      itemCount: habits.length,
      itemBuilder: (_, i) {
        final h = habits[i];
        final cw = cardW * s;
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: cw,
              height: cw,
              decoration: BoxDecoration(
                color: h.bg,
                borderRadius: BorderRadius.circular(30 * s),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF1A2E12).withValues(alpha: 0.09),
                    blurRadius: 4 * s,
                    offset: Offset(0, 4 * s),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  Positioned(
                    left: cw * (23 / 168),
                    top: cw * (23 / 168),
                    child: Container(
                      width: cw * (122 / 168),
                      height: cw * (122 / 168),
                      decoration: BoxDecoration(
                        color: h.inner,
                        borderRadius: BorderRadius.circular(22 * s),
                      ),
                    ),
                  ),
                  Positioned(
                    left: cw * (46 / 168),
                    top: cw * (46 / 168),
                    child: Icon(h.icon,
                        size: cw * (76 / 168), color: h.iconColor),
                  ),
                ],
              ),
            ),
            SizedBox(height: 8 * s),
            Text(
              h.title,
              style: GoogleFonts.poppins(
                fontSize: 12 * s,
                fontWeight: FontWeight.w500,
                color: h.textColor,
                letterSpacing: -0.6 * s,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        );
      },
    );
  }
}

// ── Grid cards ────────────────────────────────────────────────────────────────

class _BookCardAll extends StatelessWidget {
  final HubResource item;
  final double s;
  final double cardW;
  final VoidCallback onTap;

  const _BookCardAll(
      {required this.item,
      required this.s,
      required this.cardW,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    final w = cardW * s;
    final h = 215 * s * (cardW / 168);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: w,
        height: h,
        decoration: BoxDecoration(
          color: const Color(0xFF7F89E9).withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(15 * s),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF7F89E9).withValues(alpha: 0.43),
              blurRadius: 11.6 * s,
              offset: Offset(0, 4 * s),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(15 * s),
          child: Stack(
            children: [
              Container(color: const Color(0xFF7F89E9).withValues(alpha: 0.3)),
              Positioned(
                left: w * (17 / 168),
                top: h * (19 / 215),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10 * s),
                  child: item.imageUrl.isNotEmpty
                      ? Image.network(
                          item.imageUrl,
                          width: w * (133 / 168),
                          height: h * (177 / 215),
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => _fallback(w, h),
                        )
                      : _fallback(w, h),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _fallback(double w, double h) => Container(
        width: w * (133 / 168),
        height: h * (177 / 215),
        color: item.color,
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(item.title,
                style: GoogleFonts.poppins(
                    fontSize: 9 * s,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    height: 1.3),
                textAlign: TextAlign.center,
                maxLines: 4,
                overflow: TextOverflow.ellipsis),
            const SizedBox(height: 4),
            Text(item.subtitle,
                style: GoogleFonts.poppins(
                    fontSize: 8 * s,
                    color: Colors.white.withValues(alpha: 0.8)),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis),
          ],
        ),
      );
}

class _PodcastCardAll extends StatelessWidget {
  final HubResource item;
  final double s;
  final double cardW;
  final VoidCallback onTap;

  const _PodcastCardAll(
      {required this.item,
      required this.s,
      required this.cardW,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    final w = cardW * s;
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: w,
            height: w, // square
            decoration: BoxDecoration(
              color: const Color(0xFF7F89E9).withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(24 * s),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF7F89E9).withValues(alpha: 0.33),
                  blurRadius: 11.6 * s,
                  offset: Offset(0, 4 * s),
                ),
              ],
            ),
            child: Center(
              child: Container(
                width: w * (117 / 160),
                height: w * (117 / 160),
                decoration: BoxDecoration(
                  color: item.color,
                  borderRadius: BorderRadius.circular(14 * s),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.podcasts_rounded,
                        size: w * 0.28,
                        color: Colors.white.withValues(alpha: 0.9)),
                    SizedBox(height: 4 * s),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 6 * s),
                      child: Text(
                        item.title,
                        style: GoogleFonts.poppins(
                            fontSize: 8 * s,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                            height: 1.3),
                        textAlign: TextAlign.center,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(height: 8 * s),
          Text(
            item.title,
            style: GoogleFonts.poppins(
              fontSize: 11 * s,
              color: const Color(0xFF1A2E12),
              letterSpacing: -0.55 * s,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _TedCardAll extends StatelessWidget {
  final HubResource item;
  final double s;
  final double cardW;
  final VoidCallback onTap;

  const _TedCardAll(
      {required this.item,
      required this.s,
      required this.cardW,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    final w = cardW * s;
    final h = 215 * s * (cardW / 168);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: w,
        height: h,
        decoration: BoxDecoration(
          color: const Color(0xFF7F89E9).withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(15 * s),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF7F89E9).withValues(alpha: 0.43),
              blurRadius: 11.6 * s,
              offset: Offset(0, 4 * s),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(15 * s),
          child: Stack(
            children: [
              Container(color: const Color(0xFF7F89E9).withValues(alpha: 0.3)),
              Positioned(
                left: w * (17 / 168),
                top: h * (19 / 215),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10 * s),
                  child: item.imageUrl.isNotEmpty
                      ? Image.network(
                          item.imageUrl,
                          width: w * (133 / 168),
                          height: h * (177 / 215),
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => _fallback(w, h),
                        )
                      : _fallback(w, h),
                ),
              ),
              Positioned(
                right: 8 * s,
                top: 8 * s,
                child: Container(
                  padding: EdgeInsets.symmetric(
                      horizontal: 5 * s, vertical: 2 * s),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE62B1E),
                    borderRadius: BorderRadius.circular(4 * s),
                  ),
                  child: Text('TED',
                      style: GoogleFonts.poppins(
                          fontSize: 8 * s,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: 0.4 * s)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _fallback(double w, double h) => Container(
        width: w * (133 / 168),
        height: h * (177 / 215),
        color: const Color(0xFFE62B1E),
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.play_circle_outline_rounded,
                size: w * 0.22, color: Colors.white),
            const SizedBox(height: 8),
            Text(item.title,
                style: GoogleFonts.poppins(
                    fontSize: 9 * s,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    height: 1.3),
                textAlign: TextAlign.center,
                maxLines: 3,
                overflow: TextOverflow.ellipsis),
            const SizedBox(height: 4),
            Text(item.subtitle,
                style: GoogleFonts.poppins(
                    fontSize: 8 * s,
                    color: Colors.white.withValues(alpha: 0.8)),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
          ],
        ),
      );
}
