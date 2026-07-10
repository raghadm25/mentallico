import 'dart:math' show pi;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/widgets/user_avatar.dart';
import '../../../services/app_state.dart';
import '../../../services/auth_service.dart';
import '../hub/hub_screen.dart'
    show kCommunityPosts, kHubHabits, CommunityPost, HubHabit;
import '../journal/journal_screen.dart';
import '../journal/journal_write_screen.dart';

class PatientProfileScreen extends StatefulWidget {
  const PatientProfileScreen({super.key});

  @override
  State<PatientProfileScreen> createState() => _PatientProfileScreenState();
}

class _PatientProfileScreenState extends State<PatientProfileScreen> {
  // ── Mood face assets (mirrors HomeScreen) ────────────────────────────────
  static const _faceAssets = [
    'assets/images/mood_face_1.png',
    'assets/images/mood_face_2.png',
    'assets/images/mood_face_3.png',
    'assets/images/mood_face_4.png',
    'assets/images/mood_face_5.png',
  ];
  static const _moodLabels = [
    'Angry',
    'Sad',
    'Neutral',
    'Happy',
    'Amazing',
  ];

  // ── Build ────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final s = MediaQuery.of(context).size.width / 430;
    return Scaffold(
      backgroundColor: const Color(0xFFF0F0F0),
      body: ListenableBuilder(
        listenable: AppState.instance,
        builder: (context, _) => _buildScroll(s),
      ),
    );
  }

  Widget _buildScroll(double s) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(s),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 35 * s),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 28 * s),
                _buildJournalTracker(s),
                SizedBox(height: 28 * s),
                _buildMoodTracker(s),
                SizedBox(height: 28 * s),
                _buildHabitsSection(s),
                SizedBox(height: 28 * s),
                _buildJournalEntries(s),
                SizedBox(height: 28 * s),
                _buildSavedSection(s),
                SizedBox(height: 28 * s),
                _buildLikedSection(s),
                SizedBox(height: 28 * s),
                _buildLogoutButton(s),
                SizedBox(height: 100 * s),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Header ───────────────────────────────────────────────────────────────
  Widget _buildHeader(double s) {
    final safeTop = MediaQuery.of(context).padding.top;
    return SizedBox(
      height: 320 * s + safeTop,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Gradient background
          Container(
            width: double.infinity,
            height: 187 * s + safeTop,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  Color(0xFF7F89E9),
                  Color(0xFFA87CC7),
                  Color(0xFF658852)
                ],
                stops: [0.059, 0.594, 1.0],
              ),
            ),
          ),
          // Decorative ellipses
          Positioned(
            right: -55 * s,
            top: safeTop + 10 * s,
            child: _Ellipse(219 * s, 209 * s,
                Colors.white.withValues(alpha: 0.08)),
          ),
          Positioned(
            left: -44 * s,
            top: safeTop,
            child: _Ellipse(
                191 * s, 198 * s, Colors.white.withValues(alpha: 0.06)),
          ),
          // Settings icon
          Positioned(
            right: 32 * s,
            top: safeTop + 26 * s,
            child: GestureDetector(
              onTap: () => _showEditProfile(s),
              child: Icon(Icons.settings_rounded,
                  color: Colors.white, size: 24 * s),
            ),
          ),
          // Avatar + name
          Positioned(
            left: 0,
            right: 0,
            top: safeTop + 28 * s,
            child: Column(
              children: [
                // Circle avatar
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF1A2E12).withValues(alpha: 0.18),
                        blurRadius: 16 * s,
                        offset: Offset(0, 6 * s),
                      ),
                    ],
                  ),
                  child: UserAvatar(
                    radius: 88 * s,
                    borderWidth: 8 * s,
                    borderColor: const Color(0xFF7F89E9),
                    backgroundColor: const Color(0xFFE8E9F8),
                    textColor: const Color(0xFF7F89E9),
                  ),
                ),
                SizedBox(height: 14 * s),
                Text(
                  AppState.instance.userName,
                  style: GoogleFonts.poppins(
                    fontSize: 28 * s,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF1A2E12),
                    letterSpacing: -1.4 * s,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Face sprite (shared with HomeScreen) ─────────────────────────────────
  Widget _buildFaceSprite(int i, double w, double s) {
    final h = w * (386.0 / 493.0);
    return SizedBox(
      width: w * s,
      height: h * s,
      child: Image.asset(
        _faceAssets[i],
        fit: BoxFit.contain,
        filterQuality: FilterQuality.high,
      ),
    );
  }

  // ── Journal Tracker ───────────────────────────────────────────────────────
  Widget _buildJournalTracker(double s) {
    final now = DateTime.now();
    final weekday = now.weekday; // 1=Mon … 7=Sun
    final monday = now.subtract(Duration(days: weekday - 1));
    final days = List.generate(7, (i) => monday.add(Duration(days: i)));
    const labels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Journal Tracker',
            style: GoogleFonts.poppins(
              fontSize: 20 * s,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF1A2E12),
              letterSpacing: -1 * s,
            )),
        SizedBox(height: 19 * s),
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(
              horizontal: 18 * s, vertical: 12 * s),
          decoration: BoxDecoration(
            color: const Color(0xFF1A2E12),
            borderRadius: BorderRadius.circular(100 * s),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: List.generate(7, (i) {
              final hasEntry = AppState.instance.hasEntryOn(days[i]);
              return _buildDayPill(labels[i], hasEntry, s);
            }),
          ),
        ),
      ],
    );
  }

  Widget _buildDayPill(String label, bool hasEntry, double s) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 30 * s,
          height: 56 * s,
          decoration: BoxDecoration(
            color: hasEntry
                ? const Color(0xFF7F89E9)
                : const Color(0xFFD2D5DE),
            borderRadius: BorderRadius.circular(40 * s),
          ),
          child: Padding(
            padding: EdgeInsets.only(top: 4 * s),
            child: Align(
              alignment: Alignment.topCenter,
              child: Container(
                width: 20 * s,
                height: 20 * s,
                decoration: BoxDecoration(
                  color: Colors.white
                      .withValues(alpha: hasEntry ? 0.92 : 0.55),
                  shape: BoxShape.circle,
                ),
                child: hasEntry
                    ? Icon(Icons.check_circle_rounded,
                        color: const Color(0xFF658852), size: 13 * s)
                    : null,
              ),
            ),
          ),
        ),
        SizedBox(height: 3 * s),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 8 * s,
            fontWeight: FontWeight.w300,
            color: const Color(0xFFF0F0F0),
            letterSpacing: -0.4 * s,
          ),
        ),
      ],
    );
  }

  // ── Mood Tracker ──────────────────────────────────────────────────────────
  Widget _buildMoodTracker(double s) {
    final now = DateTime.now();
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    // Flutter weekday: 1=Mon..7=Sun. We want 0=Sun for our header.
    final firstWeekday = DateTime(now.year, now.month, 1).weekday % 7;
    const headers = ['Su', 'Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa'];
    final totalWeeks = ((firstWeekday + daysInMonth) / 7).ceil();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Mood Tracker',
            style: GoogleFonts.poppins(
              fontSize: 20 * s,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF1A2E12),
              letterSpacing: -1 * s,
            )),
        SizedBox(height: 19 * s),
        Container(
          width: double.infinity,
          padding: EdgeInsets.fromLTRB(14 * s, 16 * s, 14 * s, 12 * s),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20 * s),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF1A2E12).withValues(alpha: 0.06),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              // Day headers
              Row(
                children: headers
                    .map((h) => Expanded(
                          child: Text(h,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.poppins(
                                fontSize: 11 * s,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFF595959),
                              )),
                        ))
                    .toList(),
              ),
              SizedBox(height: 4 * s),
              Container(height: 2, color: const Color(0xFFD2D5DE)),
              SizedBox(height: 6 * s),
              // Calendar grid
              for (int week = 0; week < totalWeeks; week++)
                Padding(
                  padding: EdgeInsets.only(bottom: 4 * s),
                  child: Row(
                    children: List.generate(7, (col) {
                      final cellIdx = week * 7 + col;
                      final dayNum = cellIdx - firstWeekday + 1;
                      if (dayNum < 1 || dayNum > daysInMonth) {
                        return Expanded(
                            child: SizedBox(height: 32 * s));
                      }
                      final date =
                          DateTime(now.year, now.month, dayNum);
                      final mood = AppState.instance.getMood(date);
                      final isFuture = date.isAfter(
                          DateTime(now.year, now.month, now.day));

                      return Expanded(
                        child: SizedBox(
                          height: 32 * s,
                          child: mood != null
                              ? Center(
                                  child: _buildFaceSprite(
                                      mood, 24.0, s),
                                )
                              : Center(
                                  child: Text('$dayNum',
                                      style: GoogleFonts.poppins(
                                        fontSize: 11 * s,
                                        color: isFuture
                                            ? const Color(0xFFD2D5DE)
                                            : const Color(0xFF595959),
                                      )),
                                ),
                        ),
                      );
                    }),
                  ),
                ),
              SizedBox(height: 6 * s),
              // Mood legend
              Wrap(
                spacing: 10 * s,
                runSpacing: 4 * s,
                alignment: WrapAlignment.center,
                children: List.generate(5, (i) => Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildFaceSprite(i, 16.0, s),
                    SizedBox(width: 3 * s),
                    Text(_moodLabels[i],
                        style: GoogleFonts.poppins(
                          fontSize: 9 * s,
                          color: const Color(0xFF595959),
                        )),
                  ],
                )),
              ),
              SizedBox(height: 8 * s),
              Text(
                'Your mood is 17.8% better than last month',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 10 * s,
                  color: const Color(0xFF595959),
                  letterSpacing: -0.3 * s,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── Habits Progress ───────────────────────────────────────────────────────
  Widget _buildHabitsSection(double s) {
    final progressMap = AppState.instance.habitProgress;
    final tracked =
        kHubHabits.where((h) => progressMap.containsKey(h.title)).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Your habits Progress',
            style: GoogleFonts.poppins(
              fontSize: 20 * s,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF1A2E12),
              letterSpacing: -1 * s,
            )),
        SizedBox(height: 22 * s),
        Wrap(
          spacing: 23 * s,
          runSpacing: 22 * s,
          children: [
            ...tracked.map((h) => GestureDetector(
                  onTap: () => _showHabitDetail(h, s),
                  child: _buildHabitCard(
                      h, progressMap[h.title] ?? 0.0, s),
                )),
            GestureDetector(
              onTap: () => _showAddHabit(s),
              child: _buildAddHabitCard(s),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildHabitCard(HubHabit habit, double progress, double s) {
    final size = 168 * s;
    return SizedBox(
      width: size,
      child: Column(
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: habit.bg,
              borderRadius: BorderRadius.circular(30 * s),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF1A2E12).withValues(alpha: 0.09),
                  blurRadius: 4 * s,
                  offset: Offset(0, 4 * s),
                ),
              ],
            ),
            child: Center(
              child: SizedBox(
                width: 95 * s,
                height: 95 * s,
                child: CustomPaint(
                  painter: _ProgressArcPainter(
                    progress: progress,
                    trackColor: habit.inner.withValues(alpha: 0.5),
                    arcColor: habit.iconColor,
                    strokeWidth: 7 * s,
                  ),
                  child: Center(
                    child: Icon(habit.icon,
                        color: habit.iconColor, size: 42 * s),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: 8 * s),
          Text(
            habit.title,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 12 * s,
              fontWeight: FontWeight.w500,
              color: habit.textColor,
              letterSpacing: -0.6 * s,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildAddHabitCard(double s) {
    final size = 168 * s;
    return SizedBox(
      width: size,
      child: Column(
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: const Color(0xFFC2C2C2),
              borderRadius: BorderRadius.circular(30 * s),
            ),
            child: Center(
              child: SizedBox(
                width: 95 * s,
                height: 95 * s,
                child: CustomPaint(
                  painter: _DashedCirclePainter(
                    color: Colors.white.withValues(alpha: 0.6),
                    strokeWidth: 2.5 * s,
                  ),
                  child: Center(
                    child: Icon(Icons.add_rounded,
                        color: Colors.white, size: 50 * s),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: 8 * s),
          Text(
            'Add Habit',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 12 * s,
              color: const Color(0xFF595959),
              letterSpacing: -0.6 * s,
            ),
          ),
        ],
      ),
    );
  }

  // ── Journal Entries ───────────────────────────────────────────────────────
  Widget _buildJournalEntries(double s) {
    final entries = AppState.instance.journalEntries;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('Journal Entries',
                style: GoogleFonts.poppins(
                  fontSize: 20 * s,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF1A2E12),
                  letterSpacing: -1 * s,
                )),
            const Spacer(),
            GestureDetector(
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                    builder: (_) => const JournalScreen()),
              ),
              child: Icon(Icons.arrow_forward_rounded,
                  color: const Color(0xFF1A2E12), size: 20 * s),
            ),
          ],
        ),
        SizedBox(height: 14 * s),
        // Write entry button
        GestureDetector(
          onTap: () => _showAddEntry(s),
          child: Container(
            width: double.infinity,
            height: 46 * s,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                  colors: [Color(0xFF7F89E9), Color(0xFFA87CC7)]),
              borderRadius: BorderRadius.circular(30 * s),
              boxShadow: [
                BoxShadow(
                  color:
                      const Color(0xFF7F89E9).withValues(alpha: 0.28),
                  blurRadius: 8 * s,
                  offset: Offset(0, 4 * s),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.edit_note_rounded,
                    color: Colors.white, size: 20 * s),
                SizedBox(width: 8 * s),
                Text("Write today's entry",
                    style: GoogleFonts.poppins(
                      fontSize: 14 * s,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                      letterSpacing: -0.5 * s,
                    )),
              ],
            ),
          ),
        ),
        SizedBox(height: 12 * s),
        if (entries.isEmpty)
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(20 * s),
            decoration: BoxDecoration(
              color: const Color(0xFFF7F7F7),
              borderRadius: BorderRadius.circular(20 * s),
            ),
            child: Text(
              'No entries yet. Tap the button above to start journalling!',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 13 * s,
                color: const Color(0xFF595959),
                height: 1.5,
              ),
            ),
          )
        else
          Column(
            children: entries.take(3).toList().asMap().entries.map((e) {
              return Padding(
                padding: EdgeInsets.only(bottom: 10 * s),
                child: GestureDetector(
                  onTap: () => _showEntryDetail(e.value, e.key, s),
                  child: _buildEntryCard(e.value, s),
                ),
              );
            }).toList(),
          ),
      ],
    );
  }

  Widget _buildEntryCard(JournalEntry entry, double s) {
    final d = entry.date;
    final dateStr = '${d.day}/${d.month}/${d.year}';
    return Container(
      width: double.infinity,
      padding:
          EdgeInsets.symmetric(horizontal: 18 * s, vertical: 12 * s),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7F7),
        borderRadius: BorderRadius.circular(20 * s),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1A2E12).withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(dateStr,
              style: GoogleFonts.poppins(
                fontSize: 10 * s,
                fontWeight: FontWeight.w200,
                color: const Color(0xFF595959),
                letterSpacing: -0.5 * s,
              )),
          SizedBox(height: 6 * s),
          Text(
            entry.content,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.poppins(
              fontSize: 12 * s,
              fontWeight: FontWeight.w300,
              color: const Color(0xFF292929),
              letterSpacing: -0.5 * s,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  // ── Saved posts ───────────────────────────────────────────────────────────
  Widget _buildSavedSection(double s) {
    final savedIdx = AppState.instance.savedPosts.toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.bookmark_rounded,
                color: const Color(0xFF7F89E9), size: 20 * s),
            SizedBox(width: 8 * s),
            Text('Saved Posts',
                style: GoogleFonts.poppins(
                  fontSize: 20 * s,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF1A2E12),
                  letterSpacing: -1 * s,
                )),
          ],
        ),
        SizedBox(height: 14 * s),
        if (savedIdx.isEmpty)
          _buildEmptyState(
              'No saved posts yet.\nSave posts from the Community tab!', s)
        else
          Column(
            children: savedIdx.map((idx) {
              if (idx >= kCommunityPosts.length) {
                return const SizedBox.shrink();
              }
              return Padding(
                padding: EdgeInsets.only(bottom: 10 * s),
                child: _buildCompactPostCard(
                    kCommunityPosts[idx],
                    Icons.bookmark_rounded,
                    s),
              );
            }).toList(),
          ),
      ],
    );
  }

  // ── Liked posts ───────────────────────────────────────────────────────────
  Widget _buildLikedSection(double s) {
    final likedIdx = AppState.instance.likedPosts.toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.thumb_up_alt_rounded,
                color: const Color(0xFF7F89E9), size: 20 * s),
            SizedBox(width: 8 * s),
            Text('Liked Posts',
                style: GoogleFonts.poppins(
                  fontSize: 20 * s,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF1A2E12),
                  letterSpacing: -1 * s,
                )),
          ],
        ),
        SizedBox(height: 14 * s),
        if (likedIdx.isEmpty)
          _buildEmptyState(
              'No liked posts yet.\nLike posts from the Community tab!', s)
        else
          Column(
            children: likedIdx.map((idx) {
              if (idx >= kCommunityPosts.length) {
                return const SizedBox.shrink();
              }
              return Padding(
                padding: EdgeInsets.only(bottom: 10 * s),
                child: _buildCompactPostCard(
                    kCommunityPosts[idx],
                    Icons.thumb_up_alt_rounded,
                    s),
              );
            }).toList(),
          ),
      ],
    );
  }

  Widget _buildCompactPostCard(
      CommunityPost post, IconData badge, double s) {
    return Container(
      width: double.infinity,
      padding:
          EdgeInsets.fromLTRB(14 * s, 12 * s, 14 * s, 12 * s),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7F7),
        borderRadius: BorderRadius.circular(18 * s),
        border: Border.all(
            color: const Color(0xFF7F89E9).withValues(alpha: 0.2),
            width: 1.5),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1A2E12).withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36 * s,
            height: 36 * s,
            decoration: BoxDecoration(
                color: post.avatarColor, shape: BoxShape.circle),
            child: Center(
              child: Text(post.initials,
                  style: GoogleFonts.poppins(
                    fontSize: 12 * s,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  )),
            ),
          ),
          SizedBox(width: 10 * s),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(post.author,
                    style: GoogleFonts.poppins(
                      fontSize: 13 * s,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF292929),
                      letterSpacing: -0.4 * s,
                    )),
                SizedBox(height: 3 * s),
                Text(post.content,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      fontSize: 11 * s,
                      color: const Color(0xFF595959),
                      height: 1.4,
                    )),
              ],
            ),
          ),
          SizedBox(width: 8 * s),
          Icon(badge, color: const Color(0xFF7F89E9), size: 16 * s),
        ],
      ),
    );
  }

  Widget _buildLogoutButton(double s) {
    return GestureDetector(
      onTap: () async {
        await AuthService.signOut();
        AppState.instance.clearState();
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/role-selection');
        }
      },
      child: Container(
        width: double.infinity,
        height: 50 * s,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16 * s),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF1A2E12).withValues(alpha: 0.08),
              blurRadius: 14 * s,
              offset: Offset(0, 4 * s),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.logout_rounded,
                color: const Color(0xFFD93333), size: 18 * s),
            SizedBox(width: 8 * s),
            Text(
              'Log Out',
              style: GoogleFonts.poppins(
                color: const Color(0xFFD93333),
                fontSize: 15 * s,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(String msg, double s) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20 * s),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7F7),
        borderRadius: BorderRadius.circular(18 * s),
      ),
      child: Text(msg,
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
            fontSize: 13 * s,
            color: const Color(0xFF595959),
            height: 1.5,
          )),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // Bottom sheets
  // ═══════════════════════════════════════════════════════════════════════════

  // ── Journal entry detail (read + edit) ───────────────────────────────────
  void _showEntryDetail(JournalEntry entry, int listIdx, double s) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => JournalWriteScreen(
        existingEntry: entry,
        existingIndex: listIdx,
      ),
    ));
  }


  // ── Add journal entry ─────────────────────────────────────────────────────
  void _showAddEntry(double s) {
    final ctrl = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setLocal) => Padding(
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
          child: Container(
            constraints: BoxConstraints(
                maxHeight: MediaQuery.of(ctx).size.height * 0.82),
            decoration: BoxDecoration(
              color: const Color(0xFFF0F0F0),
              borderRadius:
                  BorderRadius.vertical(top: Radius.circular(20 * s)),
            ),
            padding:
                EdgeInsets.fromLTRB(22 * s, 14 * s, 22 * s, 20 * s),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _SheetHandle(s: s),
                SizedBox(height: 14 * s),
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(ctx),
                      child: Icon(Icons.close_rounded,
                          size: 22 * s,
                          color: const Color(0xFF595959)),
                    ),
                    SizedBox(width: 12 * s),
                    Text("Today's Journal",
                        style: GoogleFonts.poppins(
                          fontSize: 17 * s,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF1A2E12),
                        )),
                    const Spacer(),
                    GestureDetector(
                      onTap: () {
                        final text = ctrl.text.trim();
                        if (text.isEmpty) return;
                        AppState.instance.addJournalEntry(
                            JournalEntry(
                                date: DateTime.now(), content: text));
                        Navigator.pop(ctx);
                      },
                      child: _gradientPill('Save', s),
                    ),
                  ],
                ),
                SizedBox(height: 12 * s),
                Divider(height: 1, color: const Color(0xFFD2D5DE)),
                Flexible(
                  child: SingleChildScrollView(
                    child: TextField(
                      controller: ctrl,
                      autofocus: true,
                      maxLines: null,
                      minLines: 6,
                      cursorColor: const Color(0xFF7F89E9),
                      style: GoogleFonts.poppins(
                          fontSize: 15 * s,
                          color: const Color(0xFF292929),
                          height: 1.6),
                      decoration: InputDecoration(
                        hintText: 'How are you feeling today?…',
                        hintStyle: GoogleFonts.poppins(
                            fontSize: 15 * s,
                            color: const Color(0xFF595959)
                                .withValues(alpha: 0.5),
                            height: 1.6),
                        border: InputBorder.none,
                        contentPadding:
                            EdgeInsets.symmetric(vertical: 14 * s),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Habit detail ──────────────────────────────────────────────────────────
  void _showHabitDetail(HubHabit habit, double s) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _HabitDetailSheet(habit: habit, s: s),
    );
  }

  // ── Add habit picker ──────────────────────────────────────────────────────
  void _showAddHabit(double s) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AddHabitSheet(s: s),
    );
  }

  // ── Edit profile ──────────────────────────────────────────────────────────
  void _showEditProfile(double s) {
    final nameCtrl =
        TextEditingController(text: AppState.instance.userName);
    final bioCtrl =
        TextEditingController(text: AppState.instance.userBio);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Padding(
        padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF0F0F0),
            borderRadius:
                BorderRadius.vertical(top: Radius.circular(20 * s)),
          ),
          padding:
              EdgeInsets.fromLTRB(22 * s, 14 * s, 22 * s, 24 * s),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _SheetHandle(s: s),
              SizedBox(height: 14 * s),
              Text('Edit Profile',
                  style: GoogleFonts.poppins(
                      fontSize: 18 * s,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1A2E12))),
              SizedBox(height: 18 * s),
              _LabeledField('Name', nameCtrl, s, maxLines: 1),
              SizedBox(height: 12 * s),
              _LabeledField('Bio', bioCtrl, s, maxLines: 4),
              SizedBox(height: 20 * s),
              GestureDetector(
                onTap: () {
                  AppState.instance.updateProfile(
                    name: nameCtrl.text.trim().isEmpty
                        ? null
                        : nameCtrl.text.trim(),
                    bio: bioCtrl.text.trim().isEmpty
                        ? null
                        : bioCtrl.text.trim(),
                  );
                  Navigator.pop(context);
                },
                child: Container(
                  width: double.infinity,
                  height: 50 * s,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                        colors: [Color(0xFF7F89E9), Color(0xFFA87CC7)]),
                    borderRadius: BorderRadius.circular(30 * s),
                  ),
                  child: Center(
                    child: Text('Save Changes',
                        style: GoogleFonts.poppins(
                            fontSize: 15 * s,
                            fontWeight: FontWeight.w600,
                            color: Colors.white)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Sub-widgets (bottom sheets as StatefulWidgets)
// ═══════════════════════════════════════════════════════════════════════════


// ── Habit detail ──────────────────────────────────────────────────────────
class _HabitDetailSheet extends StatefulWidget {
  final HubHabit habit;
  final double s;
  const _HabitDetailSheet({required this.habit, required this.s});

  @override
  State<_HabitDetailSheet> createState() => _HabitDetailSheetState();
}

class _HabitDetailSheetState extends State<_HabitDetailSheet> {
  late double _progress;

  @override
  void initState() {
    super.initState();
    _progress =
        AppState.instance.habitProgress[widget.habit.title] ?? 0.0;
  }

  void _adjust(double delta) {
    setState(() {
      _progress = (_progress + delta).clamp(0.0, 1.0);
    });
    AppState.instance.updateHabitProgress(widget.habit.title, _progress);
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.s;
    final habit = widget.habit;
    final pct = (_progress * 100).round();
    final cardSz = 200 * s;
    final arcSz = 120 * s;

    return Container(
      constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.82),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F0F0),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20 * s)),
      ),
      padding: EdgeInsets.fromLTRB(22 * s, 14 * s, 22 * s, 28 * s),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _SheetHandle(s: s),
          SizedBox(height: 16 * s),
          // Habit card enlarged
          Container(
            width: cardSz,
            height: cardSz,
            decoration: BoxDecoration(
              color: habit.bg,
              borderRadius: BorderRadius.circular(36 * s),
              boxShadow: [
                BoxShadow(
                    color: habit.bg.withValues(alpha: 0.35),
                    blurRadius: 16 * s,
                    offset: Offset(0, 6 * s)),
              ],
            ),
            child: Center(
              child: SizedBox(
                width: arcSz,
                height: arcSz,
                child: CustomPaint(
                  painter: _ProgressArcPainter(
                    progress: _progress,
                    trackColor: habit.inner.withValues(alpha: 0.45),
                    arcColor: habit.iconColor,
                    strokeWidth: 9 * s,
                  ),
                  child: Center(
                    child: Icon(habit.icon,
                        color: habit.iconColor, size: 52 * s),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: 16 * s),
          Text(habit.title,
              style: GoogleFonts.poppins(
                fontSize: 22 * s,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1A2E12),
                letterSpacing: -0.8 * s,
              )),
          SizedBox(height: 6 * s),
          Text('$pct% complete',
              style: GoogleFonts.poppins(
                fontSize: 14 * s,
                color: const Color(0xFF595959),
                letterSpacing: -0.4 * s,
              )),
          SizedBox(height: 18 * s),
          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(10 * s),
            child: LinearProgressIndicator(
              value: _progress,
              minHeight: 10 * s,
              backgroundColor: const Color(0xFFD2D5DE),
              valueColor:
                  AlwaysStoppedAnimation<Color>(habit.iconColor),
            ),
          ),
          SizedBox(height: 18 * s),
          // +/- controls
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _AdjustBtn(
                icon: Icons.remove_rounded,
                onTap: () => _adjust(-0.1),
                color: habit.iconColor,
                s: s,
              ),
              SizedBox(width: 20 * s),
              Column(
                children: [
                  Text('$pct%',
                      style: GoogleFonts.poppins(
                        fontSize: 32 * s,
                        fontWeight: FontWeight.w700,
                        color: habit.iconColor,
                        letterSpacing: -1.5 * s,
                      )),
                  Text('Progress',
                      style: GoogleFonts.poppins(
                        fontSize: 11 * s,
                        color: const Color(0xFF595959),
                      )),
                ],
              ),
              SizedBox(width: 20 * s),
              _AdjustBtn(
                icon: Icons.add_rounded,
                onTap: () => _adjust(0.1),
                color: habit.iconColor,
                s: s,
              ),
            ],
          ),
          SizedBox(height: 20 * s),
          // Remove habit button
          GestureDetector(
            onTap: () {
              AppState.instance.removeHabit(habit.title);
              Navigator.pop(context);
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.delete_outline_rounded,
                    size: 16 * s, color: const Color(0xFFD93333)),
                SizedBox(width: 6 * s),
                Text('Remove from my habits',
                    style: GoogleFonts.poppins(
                      fontSize: 13 * s,
                      color: const Color(0xFFD93333),
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Add habit picker ──────────────────────────────────────────────────────
class _AddHabitSheet extends StatelessWidget {
  final double s;
  const _AddHabitSheet({required this.s});

  @override
  Widget build(BuildContext context) {
    final available = kHubHabits
        .where((h) =>
            !AppState.instance.habitProgress.containsKey(h.title))
        .toList();

    return Container(
      constraints:
          BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.7),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F0F0),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20 * s)),
      ),
      padding: EdgeInsets.fromLTRB(22 * s, 14 * s, 22 * s, 24 * s),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _SheetHandle(s: s),
          SizedBox(height: 14 * s),
          Row(
            children: [
              Text('Add a Habit',
                  style: GoogleFonts.poppins(
                    fontSize: 18 * s,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1A2E12),
                  )),
              const Spacer(),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Icon(Icons.close_rounded,
                    size: 22 * s, color: const Color(0xFF595959)),
              ),
            ],
          ),
          SizedBox(height: 6 * s),
          if (available.isEmpty)
            Padding(
              padding: EdgeInsets.symmetric(vertical: 24 * s),
              child: Text(
                'You\'re already tracking all available habits! 🎉',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                    fontSize: 14 * s, color: const Color(0xFF595959)),
              ),
            )
          else
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                padding: EdgeInsets.only(top: 12 * s),
                itemCount: available.length,
                separatorBuilder: (ctx, i) => SizedBox(height: 10 * s),
                itemBuilder: (ctx, i) {
                  final h = available[i];
                  return GestureDetector(
                    onTap: () {
                      AppState.instance.addHabit(h.title);
                      Navigator.pop(context);
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 16 * s, vertical: 14 * s),
                      decoration: BoxDecoration(
                        color: h.bg.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(18 * s),
                        border: Border.all(
                            color: h.bg.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 44 * s,
                            height: 44 * s,
                            decoration: BoxDecoration(
                                color: h.bg,
                                borderRadius:
                                    BorderRadius.circular(12 * s)),
                            child: Icon(h.icon,
                                color: h.iconColor, size: 24 * s),
                          ),
                          SizedBox(width: 14 * s),
                          Expanded(
                            child: Text(h.title,
                                style: GoogleFonts.poppins(
                                  fontSize: 15 * s,
                                  fontWeight: FontWeight.w500,
                                  color: const Color(0xFF1A2E12),
                                  letterSpacing: -0.5 * s,
                                )),
                          ),
                          Icon(Icons.add_circle_outline_rounded,
                              color: h.iconColor, size: 22 * s),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Small reusable helpers
// ═══════════════════════════════════════════════════════════════════════════

class _SheetHandle extends StatelessWidget {
  final double s;
  const _SheetHandle({required this.s});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 40 * s,
        height: 4 * s,
        decoration: BoxDecoration(
            color: const Color(0xFFD2D5DE),
            borderRadius: BorderRadius.circular(2 * s)),
      ),
    );
  }
}

Widget _gradientPill(String label, double s) => Container(
      padding: EdgeInsets.symmetric(horizontal: 18 * s, vertical: 7 * s),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
            colors: [Color(0xFF7F89E9), Color(0xFFA87CC7)]),
        borderRadius: BorderRadius.circular(30 * s),
      ),
      child: Text(label,
          style: GoogleFonts.poppins(
              fontSize: 13 * s,
              fontWeight: FontWeight.w600,
              color: Colors.white)),
    );

class _LabeledField extends StatelessWidget {
  final String label;
  final TextEditingController ctrl;
  final double s;
  final int maxLines;
  const _LabeledField(this.label, this.ctrl, this.s, {this.maxLines = 1});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: GoogleFonts.poppins(
              fontSize: 12 * s,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF595959),
            )),
        SizedBox(height: 6 * s),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14 * s),
            border: Border.all(color: const Color(0xFFD2D5DE)),
          ),
          child: TextField(
            controller: ctrl,
            maxLines: maxLines,
            cursorColor: const Color(0xFF7F89E9),
            style: GoogleFonts.poppins(
                fontSize: 14 * s, color: const Color(0xFF292929)),
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                  horizontal: 14 * s, vertical: 10 * s),
            ),
          ),
        ),
      ],
    );
  }
}

class _AdjustBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color color;
  final double s;
  const _AdjustBtn(
      {required this.icon,
      required this.onTap,
      required this.color,
      required this.s});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48 * s,
        height: 48 * s,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          shape: BoxShape.circle,
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Icon(icon, color: color, size: 24 * s),
      ),
    );
  }
}

class _Ellipse extends StatelessWidget {
  final double w, h;
  final Color color;
  const _Ellipse(this.w, this.h, this.color);

  @override
  Widget build(BuildContext context) => Container(
      width: w,
      height: h,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle));
}

// ═══════════════════════════════════════════════════════════════════════════
// CustomPainters
// ═══════════════════════════════════════════════════════════════════════════

class _ProgressArcPainter extends CustomPainter {
  final double progress;
  final Color trackColor;
  final Color arcColor;
  final double strokeWidth;

  const _ProgressArcPainter({
    required this.progress,
    required this.trackColor,
    required this.arcColor,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.shortestSide - strokeWidth) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = trackColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round,
    );
    if (progress > 0) {
      canvas.drawArc(
        rect,
        -pi / 2,
        2 * pi * progress,
        false,
        Paint()
          ..color = arcColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  @override
  bool shouldRepaint(_ProgressArcPainter old) =>
      old.progress != progress ||
      old.arcColor != arcColor ||
      old.strokeWidth != strokeWidth;
}

class _DashedCirclePainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  const _DashedCirclePainter(
      {required this.color, required this.strokeWidth});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.shortestSide - strokeWidth) / 2;
    const dashCount = 18;
    final dashAngle = (2 * pi / dashCount) * 0.55;
    final gapAngle = (2 * pi / dashCount) * 0.45;
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    double angle = -pi / 2;
    for (int i = 0; i < dashCount; i++) {
      canvas.drawArc(
          Rect.fromCircle(center: center, radius: radius),
          angle,
          dashAngle,
          false,
          paint);
      angle += dashAngle + gapAngle;
    }
  }

  @override
  bool shouldRepaint(_DashedCirclePainter old) => old.color != color;
}
