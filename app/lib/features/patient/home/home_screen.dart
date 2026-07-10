import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/widgets/user_avatar.dart';
import '../../../services/app_state.dart';
import '../hub/hub_screen.dart'
    show HubResource, kHubBooks, kHubPodcasts, kHubTedTalks, openHubResource;

class HomeScreen extends StatefulWidget {
  final VoidCallback? onChatRequested;
  final VoidCallback? onProfileRequested;
  const HomeScreen({super.key, this.onChatRequested, this.onProfileRequested});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedMood    = -1;
  int _selectedTagIdx  = -1;
  bool _moodRecorded   = false;

  @override
  void initState() {
    super.initState();
    AppState.instance.addListener(_onStateChange);
  }

  void _onStateChange() { if (mounted) setState(() {}); }

  @override
  void dispose() {
    AppState.instance.removeListener(_onStateChange);
    super.dispose();
  }

  static const _moodTags = [
    'Grateful', 'Tired', 'Lonely', 'Motivated', 'Overwhelmed',
    'Confused', 'Stressed', 'Numb', 'Hopeful',
  ];

  static const _faceAssets = [
    'assets/images/mood_face_1.png',
    'assets/images/mood_face_2.png',
    'assets/images/mood_face_3.png',
    'assets/images/mood_face_4.png',
    'assets/images/mood_face_5.png',
  ];

  // Mood scale is 0=Angry, 1=Sad, 2=Neutral, 3=Happy, 4=Amazing (see
  // MoodResult.faceIndex / profile_screen.dart for the same mapping).
  static const _moodLabels = ['Angry', 'Sad', 'Neutral', 'Happy', 'Amazing'];

  // One pick per mood, sourced straight from Our Hub's own resource lists —
  // no separate recommendation content to maintain.
  static final Map<int, HubResource> _moodRecommendations = {
    0: kHubTedTalks[5], // How to Make Stress Your Friend — Kelly McGonigal
    1: kHubBooks[4],    // Lost Connections — Johann Hari
    2: kHubBooks[1],    // Practicing Mindfulness — Matthew Sockolov
    3: kHubPodcasts[5], // The Happiness Lab — Dr. Laurie Santos
    4: kHubBooks[5],    // Man's Search for Meaning — Viktor E. Frankl
  };

  // Live-selected face takes priority (updates the recommendation the
  // instant the user taps a different mood), falling back to today's
  // already-recorded mood, then a neutral default.
  int get _recommendationMoodIndex {
    if (_selectedMood >= 0) return _selectedMood;
    return AppState.instance.getMood(DateTime.now()) ?? 2;
  }

  void _onRecord() {
    if (_moodRecorded) return;
    setState(() => _moodRecorded = true);
    AppState.instance.logMood(
      DateTime.now(),
      _selectedMood >= 0 ? _selectedMood : 3,
      tag: _selectedTagIdx >= 0 ? _moodTags[_selectedTagIdx] : null,
    );
  }

  void _onLetsChat() {
    setState(() => _moodRecorded = false);
    widget.onChatRequested?.call();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final s    = size.width / 430;

    return Scaffold(
      backgroundColor: const Color(0xFFF0F0F0),
      body: Stack(
        children: [
          Positioned(right: -60 * s, top:  40 * s, child: _Blob(207 * s, const Color(0xFFD4D7F5))),
          Positioned(left:  -60 * s, top: 328 * s, child: _Blob(191 * s, const Color(0xFFE0D4F0))),
          Positioned(right: -60 * s, top: 500 * s, child: _Blob(227 * s, const Color(0xFFD4EDD4))),
          Positioned(left:  -80 * s, top: 877 * s, child: _Blob(219 * s, const Color(0xFFE0D4F0))),

          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 26 * s),
                  _buildHeader(s),
                  SizedBox(height: 50 * s),
                  _buildReminderCard(s),
                  SizedBox(height: 39 * s),
                  _buildMoodChecker(s),
                  SizedBox(height: 34 * s),
                  _buildRecommendation(s),
                  SizedBox(height: 100 * s),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(double s) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 36 * s),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome Back,',
                  style: GoogleFonts.inter(
                    color: const Color(0xFF292929),
                    fontSize: 36 * s,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -1.8 * s,
                    height: 1.1,
                  ),
                ),
                ShaderMask(
                  shaderCallback: (b) => const LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      Color(0xFF7F89E9),
                      Color(0xFFA87CC7),
                      Color(0xFF658852),
                    ],
                    stops: [0.06, 0.59, 1.0],
                  ).createShader(b),
                  child: Text(
                    '${AppState.instance.userName.split(' ').first}!',
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 36 * s,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -1.8 * s,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 12 * s),
          GestureDetector(
            onTap: widget.onProfileRequested,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                UserAvatar(
                  radius: 26.5 * s,
                  borderWidth: 2 * s,
                  borderColor: const Color(0xFF7F89E9),
                ),
                Positioned(
                  right: 1 * s,
                  top:   1 * s,
                  child: Container(
                    width:  10 * s,
                    height: 10 * s,
                    decoration: const BoxDecoration(
                      color: Color(0xFFFF3B3B),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReminderCard(double s) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 35 * s),
      child: Container(
        width: 360 * s,
        height: 150 * s,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15 * s),
          color: const Color(0xFFD2D5DE),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15 * s),
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              stops: const [0.05968, 0.59393, 1.0],
              colors: [
                const Color(0xFF7F89E9).withValues(alpha: 0.24),
                const Color(0xFFA87CC7).withValues(alpha: 0.24),
                const Color(0xFF658852).withValues(alpha: 0.24),
              ],
            ),
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(29 * s, 19 * s, 105 * s, 16 * s),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "💡 Today's Reminder:",
                      style: GoogleFonts.poppins(
                        color: const Color(0xFF595959),
                        fontSize: 14 * s,
                        letterSpacing: -0.7 * s,
                      ),
                    ),
                    SizedBox(height: 8 * s),
                    Expanded(
                      child: Text(
                        '"Gently, you are doing enough. More than you give yourself credit for"',
                        style: GoogleFonts.inter(
                          color: const Color(0xFF1A2E12),
                          fontSize: 14 * s,
                          fontStyle: FontStyle.italic,
                          height: 1.35,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                right: -50 * s,
                bottom: -70 * s,
                child: Image.asset(
                  'assets/images/ReminderGraphicContainer.png',
                  width: 210 * s,
                  height: 282.3 * s,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => SizedBox(width: 210 * s, height: 282.3 * s),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMoodChecker(double s) {
    final shadow = [
      BoxShadow(
        color: const Color(0xFF1A2E12).withValues(alpha: 0.18),
        blurRadius: 4 * s,
        offset: Offset(0, 4 * s),
      ),
      BoxShadow(
        color: const Color(0xFF7F89E9).withValues(alpha: 0.43),
        blurRadius: 11.6 * s,
        offset: Offset(0, 4 * s),
      ),
    ];

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 35 * s),
      child: AnimatedSize(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
        child: Container(
          width: 360 * s,
          constraints: BoxConstraints(minHeight: 266 * s),
          decoration: BoxDecoration(
            color: const Color(0xFFF0F0F0),
            borderRadius: BorderRadius.circular(15 * s),
            boxShadow: shadow,
          ),
          padding: EdgeInsets.fromLTRB(16 * s, 20 * s, 16 * s, 20 * s),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (child, anim) => FadeTransition(opacity: anim, child: child),
            child: _moodRecorded ? _buildVariant2(s) : _buildMoodSelector(s),
          ),
        ),
      ),
    );
  }

  Widget _buildMoodSelector(double s) {
    return Column(
      key: const ValueKey('selector'),
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'How are you feeling today?',
            style: GoogleFonts.poppins(
              color: const Color(0xFF1A2E12),
              fontSize: 20 * s,
              fontWeight: FontWeight.w500,
              letterSpacing: -1.0 * s,
            ),
          ),
        ),
        SizedBox(height: 14 * s),
        _buildMoodFaceRow(s),
        SizedBox(height: 14 * s),
        Wrap(
          spacing: 6 * s,
          runSpacing: 6 * s,
          alignment: WrapAlignment.center,
          children: List.generate(
            _moodTags.length,
            (i) => GestureDetector(
              onTap: () => setState(() => _selectedTagIdx = _selectedTagIdx == i ? -1 : i),
              child: _MoodTag(label: _moodTags[i], s: s, selected: _selectedTagIdx == i),
            ),
          ),
        ),
        SizedBox(height: 18 * s),
        GestureDetector(
          onTap: _onRecord,
          child: _GradientButton(label: 'Record My Mood', width: 200 * s, height: 38 * s, s: s),
        ),
      ],
    );
  }

  Widget _buildMoodFaceRow(double s) {
    const boxSize = 60.0;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (i) {
        final sel = _selectedMood == i;
        return GestureDetector(
          onTap: () => setState(() => _selectedMood = i),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: EdgeInsets.symmetric(horizontal: 2 * s),
            width: boxSize * s,
            height: boxSize * s,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12 * s),
              color: sel ? const Color(0xFF9CA6F2).withValues(alpha: 0.20) : Colors.transparent,
              border: sel ? Border.all(color: const Color(0xFF7F89E9), width: 1.5 * s) : null,
              boxShadow: sel
                  ? [
                      BoxShadow(
                        color: const Color(0xFF7F89E9).withValues(alpha: 0.38),
                        blurRadius: 10 * s,
                        spreadRadius: 1 * s,
                        offset: Offset(0, 2 * s),
                      ),
                    ]
                  : null,
            ),
            child: Padding(
              padding: EdgeInsets.all(3 * s),
              child: Image.asset(
                _faceAssets[i],
                fit: BoxFit.contain,
                filterQuality: FilterQuality.high,
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildVariant2(double s) {
    final faceIdx = _selectedMood >= 0 ? _selectedMood : 3;
    final tagLabel = _selectedTagIdx >= 0 ? _moodTags[_selectedTagIdx] : 'Grateful';

    return Column(
      key: const ValueKey('v2'),
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(height: 16 * s),
        Center(
          child: SizedBox(
            width: 80 * s,
            height: 80 * s,
            child: Image.asset(_faceAssets[faceIdx], fit: BoxFit.contain, filterQuality: FilterQuality.high),
          ),
        ),
        SizedBox(height: 14 * s),
        Text(
          'Your mood has been recorded!',
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
            color: const Color(0xFF1A2E12),
            fontSize: 20 * s,
            fontWeight: FontWeight.w500,
            letterSpacing: -1.0 * s,
            height: 1.2,
          ),
        ),
        SizedBox(height: 10 * s),
        _MoodTag(label: tagLabel, s: s, selected: true),
        SizedBox(height: 18 * s),
        GestureDetector(
          onTap: _onLetsChat,
          child: _GradientButton(
            label: "Let's Chat",
            width: 200 * s,
            height: 38 * s,
            s: s,
          ),
        ),
        SizedBox(height: 8 * s),
      ],
    );
  }

  Widget _buildRecommendation(double s) {
    final moodIdx = _recommendationMoodIndex;
    final rec = _moodRecommendations[moodIdx]!;
    final moodLabel = _moodLabels[moodIdx].toLowerCase();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 35 * s),
          child: Text(
            "Today's Recommendation — because you're feeling $moodLabel",
            style: GoogleFonts.poppins(
              color: Colors.black,
              fontSize: 20 * s,
              fontWeight: FontWeight.w500,
              letterSpacing: -1.0 * s,
              height: 1.3,
            ),
          ),
        ),
        SizedBox(height: 23 * s),

        GestureDetector(
          onTap: () => openHubResource(context, rec),
          child: SizedBox(
            width: double.infinity,
            height: 327 * s,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned(
                  left: 55 * s,
                  top: 0,
                  child: Image.asset(
                    'assets/images/star_burst.png',
                    width: 127 * s,
                    height: 128 * s,
                    fit: BoxFit.contain,
                    errorBuilder: (_, _, _) => const SizedBox(),
                  ),
                ),
                Positioned(
                  right: 55 * s,
                  bottom: 0,
                  child: Image.asset(
                    'assets/images/star_burst.png',
                    width: 127 * s,
                    height: 128 * s,
                    fit: BoxFit.contain,
                    errorBuilder: (_, _, _) => const SizedBox(),
                  ),
                ),
                Container(
                  width: 234 * s,
                  height: 327 * s,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30 * s),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF7F89E9).withValues(alpha: 0.22),
                        blurRadius: 4 * s,
                        offset: Offset(0, 4 * s),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(30 * s),
                    child: Stack(
                      children: [
                        rec.imageUrl.isNotEmpty
                            ? Image.network(
                                rec.imageUrl,
                                width: 234 * s,
                                height: 327 * s,
                                fit: BoxFit.cover,
                                errorBuilder: (_, _, _) =>
                                    _recommendationFallback(rec, s),
                              )
                            : _recommendationFallback(rec, s),
                        // Scrim + title/platform so text stays legible over any cover.
                        Positioned(
                          left: 0,
                          right: 0,
                          bottom: 0,
                          child: Container(
                            padding: EdgeInsets.fromLTRB(
                                14 * s, 24 * s, 14 * s, 14 * s),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  Colors.black.withValues(alpha: 0.75),
                                ],
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  rec.platform,
                                  style: GoogleFonts.poppins(
                                    color: Colors.white.withValues(alpha: 0.75),
                                    fontSize: 10 * s,
                                    fontWeight: FontWeight.w500,
                                    letterSpacing: 0.5 * s,
                                  ),
                                ),
                                SizedBox(height: 2 * s),
                                Text(
                                  rec.title,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontSize: 14 * s,
                                    fontWeight: FontWeight.w600,
                                    height: 1.25,
                                  ),
                                ),
                                Text(
                                  rec.subtitle,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.poppins(
                                    color: Colors.white.withValues(alpha: 0.85),
                                    fontSize: 11 * s,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _recommendationFallback(HubResource rec, double s) => Container(
        color: rec.color,
        alignment: Alignment.center,
        padding: EdgeInsets.symmetric(horizontal: 16 * s),
        child: Text(
          rec.title,
          textAlign: TextAlign.center,
          maxLines: 4,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 18 * s,
            fontWeight: FontWeight.w700,
          ),
        ),
      );
}

class _Blob extends StatelessWidget {
  final double size;
  final Color color;
  const _Blob(this.size, this.color);

  @override
  Widget build(BuildContext context) => Container(
        width:  size,
        height: size,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.55),
          shape: BoxShape.circle,
        ),
      );
}

class _MoodTag extends StatelessWidget {
  final String label;
  final double s;
  final bool selected;

  const _MoodTag({required this.label, required this.s, this.selected = false});

  @override
  Widget build(BuildContext context) => Container(
        padding: EdgeInsets.symmetric(horizontal: 10 * s, vertical: 3 * s),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF5768D4) : const Color(0xFF7F89E9),
          borderRadius: BorderRadius.circular(30 * s),
        ),
        child: Text(
          label,
          style: GoogleFonts.poppins(
            color: const Color(0xFFF7F7F7),
            fontSize: 11 * s,
            fontWeight: FontWeight.w300,
            letterSpacing: -0.33 * s,
          ),
        ),
      );
}

class _GradientButton extends StatelessWidget {
  final String label;
  final double width;
  final double height;
  final double s;

  const _GradientButton({
    required this.label,
    required this.width,
    required this.height,
    required this.s,
  });

  @override
  Widget build(BuildContext context) => Container(
        width:  width,
        height: height,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.centerLeft,
            end:   Alignment.centerRight,
            colors: [Color(0xFF7F89E9), Color(0xFFA87CC7)],
          ),
          borderRadius: BorderRadius.circular(30 * s),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF7F89E9).withValues(alpha: 0.43),
              blurRadius: 11.6 * s,
              offset: Offset(0, 4 * s),
            ),
            BoxShadow(
              color: const Color(0xFF1A2E12).withValues(alpha: 0.10),
              blurRadius: 4 * s,
              offset: Offset(0, 4 * s),
            ),
          ],
        ),
        child: Center(
          child: Text(
            label,
            style: GoogleFonts.poppins(
              color: const Color(0xFFF0F0F0),
              fontSize: 14 * s,
              fontWeight: FontWeight.w500,
              letterSpacing: -0.7 * s,
            ),
          ),
        ),
      );
}
