import 'dart:math' show pi;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../services/app_state.dart';
import 'journal_write_screen.dart';

class JournalScreen extends StatelessWidget {
  const JournalScreen({super.key});

  // Mood face assets (same as HomeScreen)
  static const _faceAssets = [
    'assets/images/mood_face_1.png',
    'assets/images/mood_face_2.png',
    'assets/images/mood_face_3.png',
    'assets/images/mood_face_4.png',
    'assets/images/mood_face_5.png',
  ];

  // Decorative cloud placements (Figma 430-canvas)
  // moodIdx 0-4, side -1=left 1=right, absTop from screen top
  static const _decos = [
    _Deco(moodIdx: 0, side:  1, absTop:  36, w: 78, h: 66, deg:  21.0),
    _Deco(moodIdx: 1, side: -1, absTop:  74, w: 50, h: 44, deg: -11.0),
    _Deco(moodIdx: 2, side: -1, absTop: 241, w: 40, h: 35, deg:  19.0),
    _Deco(moodIdx: 3, side:  1, absTop: 378, w: 50, h: 44, deg: -11.0),
    _Deco(moodIdx: 4, side: -1, absTop: 466, w: 38, h: 33, deg:   9.7),
    _Deco(moodIdx: 0, side:  1, absTop: 632, w: 48, h: 42, deg:  -7.25),
    _Deco(moodIdx: 2, side: -1, absTop: 820, w: 50, h: 43, deg:   9.7),
    _Deco(moodIdx: 1, side:  1, absTop: 815, w: 44, h: 38, deg:   9.7),
  ];

  @override
  Widget build(BuildContext context) {
    final s = MediaQuery.of(context).size.width / 430;
    final safeTop = MediaQuery.of(context).padding.top;
    return Scaffold(
      backgroundColor: const Color(0xFFC9CDEB),
      body: ListenableBuilder(
        listenable: AppState.instance,
        builder: (ctx, _) => _buildBody(ctx, s, safeTop),
      ),
    );
  }

  Widget _buildBody(BuildContext context, double s, double safeTop) {
    final entries = AppState.instance.journalEntries;
    final minH = 900 * s + safeTop;

    return Stack(
      children: [
        // ── Scrollable content ─────────────────────────────────────────────
        SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: minH),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: safeTop + 49 * s),
                Text(
                  'My Journal',
                  style: GoogleFonts.poppins(
                    fontSize: 20 * s,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF1A2E12),
                    letterSpacing: -0.6 * s,
                  ),
                ),
                SizedBox(height: 55 * s),
                _buildAddButton(context, s),
                SizedBox(height: 16 * s),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 37 * s),
                  child: Column(
                    children: [
                      if (entries.isEmpty)
                        Padding(
                          padding: EdgeInsets.only(top: 40 * s),
                          child: Text(
                            'No journal entries yet.\nTap "Add a new entry" to start!',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              fontSize: 14 * s,
                              color: const Color(0xFF595959),
                              height: 1.6,
                            ),
                          ),
                        )
                      else
                        ...entries.asMap().entries.map((e) => Padding(
                              padding: EdgeInsets.only(bottom: 20 * s),
                              child: GestureDetector(
                                onTap: () => Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => JournalWriteScreen(
                                      existingEntry: e.value,
                                      existingIndex: e.key,
                                    ),
                                  ),
                                ),
                                child: _buildEntryCard(e.value, s),
                              ),
                            )),
                    ],
                  ),
                ),
                SizedBox(height: 100 * s),
              ],
            ),
          ),
        ),
        // ── Decorative clouds ──────────────────────────────────────────────
        ..._decos.map((d) => _buildCloud(d, s, safeTop)),
      ],
    );
  }

  Widget _buildAddButton(BuildContext context, double s) {
    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const JournalWriteScreen()),
      ),
      child: Container(
        width: 359 * s,
        height: 45 * s,
        decoration: BoxDecoration(
          color: const Color(0xFFC6C6C6),
          borderRadius: BorderRadius.circular(30 * s),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add, color: const Color(0xFF7E7E7E), size: 18 * s),
            SizedBox(width: 10 * s),
            Text(
              'Add a new entry',
              style: GoogleFonts.poppins(
                fontSize: 15 * s,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF7E7E7E),
                letterSpacing: -0.75 * s,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEntryCard(JournalEntry entry, double s) {
    final d = entry.date;
    final dateStr = '${d.day}/${d.month}/${d.year}';
    return Container(
      width: double.infinity,
      constraints: BoxConstraints(minHeight: 68 * s),
      padding: EdgeInsets.symmetric(horizontal: 20 * s, vertical: 10 * s),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7F7),
        borderRadius: BorderRadius.circular(30 * s),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            dateStr,
            style: GoogleFonts.poppins(
              fontSize: 10 * s,
              fontWeight: FontWeight.w200,
              color: const Color(0xFF595959),
              letterSpacing: -0.5 * s,
            ),
          ),
          SizedBox(height: 6 * s),
          if (entry.title.isNotEmpty)
            Text(
              entry.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.poppins(
                fontSize: 13 * s,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF1A2E12),
                letterSpacing: -0.5 * s,
              ),
            ),
          if (entry.title.isNotEmpty) SizedBox(height: 2 * s),
          Text(
            entry.content,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.poppins(
              fontSize: 12 * s,
              fontWeight: FontWeight.w300,
              color: const Color(0xFF292929),
              letterSpacing: -0.6 * s,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }

  // ── Cloud widget using OverflowBox for guaranteed face centering ───────────
  Widget _buildCloud(_Deco d, double s, double safeTop) {
    final faceW = d.w * 0.58;
    final faceH = faceW * (386.0 / 493.0);

    final face = SizedBox(
      width: faceW * s,
      height: faceH * s,
      child: Image.asset(
        _faceAssets[d.moodIdx],
        fit: BoxFit.contain,
        filterQuality: FilterQuality.high,
      ),
    );

    final cloud = Transform.rotate(
      angle: d.deg * pi / 180,
      child: Container(
        width: d.w * s,
        height: d.h * s,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.78),
          borderRadius: BorderRadius.circular(d.h * 0.46 * s),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF7B80C2).withValues(alpha: 0.17),
              blurRadius: 5 * s,
              offset: Offset(0, 3 * s),
            ),
          ],
        ),
        child: Center(child: face),
      ),
    );

    final top = (d.absTop + safeTop) * s;
    return d.side < 0
        ? Positioned(left: 6 * s, top: top, child: cloud)
        : Positioned(right: 6 * s, top: top, child: cloud);
  }
}

// ── Data class ────────────────────────────────────────────────────────────────
class _Deco {
  final int moodIdx;
  final int side; // -1 = left, 1 = right
  final double absTop;
  final double w, h, deg;
  const _Deco({
    required this.moodIdx,
    required this.side,
    required this.absTop,
    required this.w,
    required this.h,
    required this.deg,
  });
}
