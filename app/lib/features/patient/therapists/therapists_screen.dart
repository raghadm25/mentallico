import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'doctor.dart';
import 'doctor_profile_screen.dart';
import 'all_doctors_screen.dart';
import 'book_session_screen.dart';
import '../../../services/session_service.dart';
import '../../../services/app_state.dart';
import '../vr/active_vr_session_screen.dart';

class TherapistsScreen extends StatefulWidget {
  const TherapistsScreen({super.key});

  @override
  State<TherapistsScreen> createState() => _TherapistsScreenState();
}

class _TherapistsScreenState extends State<TherapistsScreen> {
  String _activeFilter = 'General';
  String _sortBy = 'Recommended';
  int _featuredPage = 0;
  late final PageController _pageController;
  final TextEditingController _searchCtrl = TextEditingController();

  // Top 4 carousel doctors
  static final _topDoctors =
      kAllDoctors.where((d) => d.isTopDoctor).toList();

  // First 4 non-top doctors shown in the main grid
  static final _mainGridBase =
      kAllDoctors.where((d) => !d.isTopDoctor).take(4).toList();

  static const _categories = [
    'General',
    'Depression',
    'Anxiety',
    'Eating Disorder',
  ];
  static const _sortOptions = [
    'Recommended',
    'Highest Rated',
    'Most Experience',
    'Price: Low to High',
    'Price: High to Low',
  ];

  List<Doctor> get _filteredGrid {
    final q = _searchCtrl.text.trim().toLowerCase();
    var docs = _mainGridBase.where((d) {
      final matchesCat =
          _activeFilter == 'General' || d.categories.contains(_activeFilter);
      final matchesQ = q.isEmpty ||
          d.name.toLowerCase().contains(q) ||
          d.specialty.toLowerCase().contains(q) ||
          d.categories.any((c) => c.toLowerCase().contains(q));
      return matchesCat && matchesQ;
    }).toList();

    switch (_sortBy) {
      case 'Highest Rated':
        docs.sort((a, b) => b.rating.compareTo(a.rating));
      case 'Most Experience':
        docs.sort((a, b) => b.yearsExperience.compareTo(a.yearsExperience));
      case 'Price: Low to High':
        docs.sort((a, b) => a.pricePerSession.compareTo(b.pricePerSession));
      case 'Price: High to Low':
        docs.sort((a, b) => b.pricePerSession.compareTo(a.pricePerSession));
    }
    return docs;
  }

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _searchCtrl.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _pageController.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = MediaQuery.of(context).size.width / 430;
    final gridDocs = _filteredGrid;

    return Scaffold(
      backgroundColor: const Color(0xFFF0F0F0),
      body: Stack(
        children: [
          // Background blobs (Figma node 1390:1325 positions)
          Positioned(
            left: 260 * s,
            top: 14 * s,
            child: _Blob(
                color: const Color(0xFF7F89E9).withValues(alpha: 0.18),
                size: 219 * s),
          ),
          Positioned(
            left: -84 * s,
            top: 723 * s,
            child: _Blob(
                color: const Color(0xFF7F89E9).withValues(alpha: 0.18),
                size: 219 * s),
          ),
          Positioned(
            left: 251 * s,
            top: 568 * s,
            child: _Blob(
                color: const Color(0xFFA87CC7).withValues(alpha: 0.18),
                size: 227 * s),
          ),
          Positioned(
            left: -49 * s,
            top: 200 * s,
            child: _Blob(
                color: const Color(0xFF658852).withValues(alpha: 0.15),
                size: 191 * s),
          ),

          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Header ────────────────────────────────────────────────
                  SizedBox(height: 14 * s),
                  Padding(
                    padding: EdgeInsets.fromLTRB(35 * s, 0, 20 * s, 0),
                    child: Row(
                      children: [
                        SizedBox(width: 36 * s),
                        Expanded(
                          child: Text(
                            'Therapists',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              fontSize: 20 * s,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF1A2E12),
                              letterSpacing: -0.6 * s,
                            ),
                          ),
                        ),
                        SizedBox(width: 36 * s),
                      ],
                    ),
                  ),
                  SizedBox(height: 14 * s),
                  Container(
                    height: 2,
                    margin: EdgeInsets.symmetric(horizontal: 35 * s),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFF7F89E9).withValues(alpha: 0.4),
                          const Color(0xFF658852).withValues(alpha: 0.4),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 18 * s),

                  // ── Intro ─────────────────────────────────────────────────
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 35 * s),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _GradientHeading(s: s),
                        SizedBox(height: 5 * s),
                        Text(
                          "When it's time to talk to a real person, our therapists step in to provide personalised care, therapy sessions, and professional support.",
                          style: GoogleFonts.poppins(
                            color: const Color(0xFF595959),
                            fontSize: 13 * s,
                            fontWeight: FontWeight.w300,
                            height: 1.189,
                            letterSpacing: -0.65 * s,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 18 * s),

                  // ── AI VR Session ─────────────────────────────────────────
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 35 * s),
                    child: _AiVrSessionBanner(s: s),
                  ),
                  SizedBox(height: 18 * s),

                  // ── Search + Filter ──────────────────────────────────────
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 35 * s),
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 38 * s,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1EFEF),
                              borderRadius: BorderRadius.circular(30 * s),
                              border: Border.all(
                                  color: const Color(0xFF7F89E9)),
                            ),
                            child: TextField(
                              controller: _searchCtrl,
                              style: GoogleFonts.poppins(
                                fontSize: 11 * s,
                                color: const Color(0xFF292929),
                                letterSpacing: -0.4 * s,
                              ),
                              decoration: InputDecoration(
                                hintText: 'Search Therapists',
                                hintStyle: GoogleFonts.poppins(
                                  fontSize: 11 * s,
                                  color: const Color(0xFF7F89E9),
                                  letterSpacing: -0.55 * s,
                                ),
                                border: InputBorder.none,
                                isDense: true,
                                contentPadding:
                                    EdgeInsets.symmetric(vertical: 11 * s),
                                prefixIcon: Padding(
                                  padding: EdgeInsets.only(
                                      left: 20 * s, right: 8 * s),
                                  child: Icon(Icons.search_rounded,
                                      color: const Color(0xFF7F89E9),
                                      size: 18 * s),
                                ),
                                prefixIconConstraints:
                                    const BoxConstraints(),
                                suffixIcon: _searchCtrl.text.isNotEmpty
                                    ? IconButton(
                                        icon: Icon(Icons.close_rounded,
                                            size: 16 * s,
                                            color: const Color(0xFF7F89E9)),
                                        onPressed: () =>
                                            _searchCtrl.clear(),
                                        padding: EdgeInsets.zero,
                                      )
                                    : null,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 8 * s),
                        // Filter / Sort button
                        GestureDetector(
                          onTap: () => _showSortSheet(context, s),
                          child: Container(
                            width: 79 * s,
                            height: 38 * s,
                            decoration: BoxDecoration(
                              color: const Color(0xFF7F89E9),
                              borderRadius: BorderRadius.circular(30 * s),
                            ),
                            child: Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.center,
                              children: [
                                Icon(Icons.filter_list_rounded,
                                    color: Colors.white,
                                    size: 14 * s),
                                SizedBox(width: 4 * s),
                                Text(
                                  'Filter by',
                                  style: GoogleFonts.poppins(
                                    fontSize: 11 * s,
                                    color: Colors.white,
                                    letterSpacing: -0.55 * s,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20 * s),

                  // ── Registered / live therapists from Firestore ───────────
                  _RegisteredTherapistsBanner(s: s),

                  // ── Top Therapists ────────────────────────────────────────
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 35 * s),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Top Therapists',
                          style: GoogleFonts.poppins(
                            color: const Color(0xFF292929),
                            fontSize: 20 * s,
                            fontWeight: FontWeight.w500,
                            letterSpacing: -1 * s,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const AllDoctorsScreen(),
                            ),
                          ),
                          child: Text(
                            'See All',
                            style: GoogleFonts.poppins(
                              color: const Color(0xFF7F89E9),
                              fontSize: 11 * s,
                              fontWeight: FontWeight.w600,
                              letterSpacing: -0.55 * s,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 12 * s),

                  // Carousel (cards fill the 360px content width)
                  SizedBox(
                    height: 181 * s,
                    child: Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 35 * s),
                      child: PageView.builder(
                        controller: _pageController,
                        itemCount: _topDoctors.length,
                        onPageChanged: (i) =>
                            setState(() => _featuredPage = i),
                        itemBuilder: (_, i) =>
                            _FeaturedCard(doctor: _topDoctors[i], s: s),
                      ),
                    ),
                  ),
                  SizedBox(height: 12 * s),

                  // Pagination dots
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _topDoctors.length,
                      (i) => AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        margin: EdgeInsets.symmetric(horizontal: 4 * s),
                        width:
                            i == _featuredPage ? 64 * s : 6 * s,
                        height: 6 * s,
                        decoration: BoxDecoration(
                          color: i == _featuredPage
                              ? const Color(0xFF7F89E9)
                              : const Color(0xFFD2D5DE),
                          borderRadius:
                              BorderRadius.circular(30 * s),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 16 * s),

                  // ── Therapists List ───────────────────────────────────────
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 35 * s),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Therapists List',
                          style: GoogleFonts.poppins(
                            color: const Color(0xFF292929),
                            fontSize: 20 * s,
                            fontWeight: FontWeight.w500,
                            letterSpacing: -1 * s,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => AllDoctorsScreen(
                                  initialCategory: _activeFilter),
                            ),
                          ),
                          child: Text(
                            'See All',
                            style: GoogleFonts.poppins(
                              color: const Color(0xFF7F89E9),
                              fontSize: 11 * s,
                              fontWeight: FontWeight.w600,
                              letterSpacing: -0.55 * s,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 10 * s),

                  // Horizontally scrollable category chips
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding:
                        EdgeInsets.symmetric(horizontal: 35 * s),
                    child: Row(
                      children: _categories.asMap().entries.map((e) {
                        final active = _activeFilter == e.value;
                        return GestureDetector(
                          onTap: () => setState(
                              () => _activeFilter = e.value),
                          child: Container(
                            margin: EdgeInsets.only(
                                right: e.key < _categories.length - 1
                                    ? 10 * s
                                    : 0),
                            height: 24 * s,
                            padding: EdgeInsets.symmetric(
                                horizontal: 10 * s),
                            decoration: BoxDecoration(
                              color: active
                                  ? const Color(0xFF1A2E12)
                                  : const Color(0xFFF0F0F0),
                              borderRadius:
                                  BorderRadius.circular(30 * s),
                              boxShadow: active
                                  ? [
                                      BoxShadow(
                                        color: const Color(0xFF7F89E9)
                                            .withValues(alpha: 0.52),
                                        blurRadius: 14.4 * s,
                                      ),
                                    ]
                                  : null,
                            ),
                            child: Center(
                              child: Text(
                                e.value,
                                style: GoogleFonts.inter(
                                  fontSize: 12 * s,
                                  color: active
                                      ? Colors.white
                                      : const Color(0xFF7F89E9),
                                  letterSpacing: -0.6 * s,
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  SizedBox(height: 14 * s),

                  // 2-column grid or empty state
                  if (gridDocs.isEmpty)
                    _buildEmptyGrid(s)
                  else
                    Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 35 * s),
                      child: GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: gridDocs.length,
                        gridDelegate:
                            SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 23 * s,
                          mainAxisSpacing: 23 * s,
                          childAspectRatio: 168 / 159,
                        ),
                        itemBuilder: (ctx, i) => _TherapistGridCard(
                          doctor: gridDocs[i],
                          s: s,
                          onProfile: () => Navigator.push(
                            ctx,
                            MaterialPageRoute(
                              builder: (_) => DoctorProfileScreen(
                                  doctor: gridDocs[i]),
                            ),
                          ),
                          onBook: () => Navigator.push(
                            ctx,
                            MaterialPageRoute(
                              builder: (_) => BookSessionScreen(
                                doctorName: gridDocs[i].name,
                                doctorSpecialty: gridDocs[i].specialty,
                                doctorImage: gridDocs[i].image,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  SizedBox(height: 24 * s),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyGrid(double s) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 35 * s, vertical: 24 * s),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.search_off_rounded,
                size: 48 * s,
                color: const Color(0xFF7F89E9).withValues(alpha: 0.4)),
            SizedBox(height: 8 * s),
            Text(
              'No therapists match this filter',
              style: GoogleFonts.poppins(
                fontSize: 14 * s,
                color: const Color(0xFF595959),
                letterSpacing: -0.4 * s,
              ),
            ),
            SizedBox(height: 4 * s),
            GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      AllDoctorsScreen(initialCategory: _activeFilter),
                ),
              ),
              child: Text(
                'See all therapists →',
                style: GoogleFonts.poppins(
                  fontSize: 13 * s,
                  color: const Color(0xFF7F89E9),
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.4 * s,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSortSheet(BuildContext context, double s) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFFF0F0F0),
      shape: RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(20 * s)),
      ),
      builder: (ctx) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: 8 * s),
          Container(
            width: 40 * s,
            height: 4 * s,
            decoration: BoxDecoration(
              color: const Color(0xFFD2D5DE),
              borderRadius: BorderRadius.circular(4 * s),
            ),
          ),
          SizedBox(height: 16 * s),
          Text(
            'Sort Therapists',
            style: GoogleFonts.poppins(
              fontSize: 16 * s,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1A2E12),
              letterSpacing: -0.5 * s,
            ),
          ),
          SizedBox(height: 8 * s),
          ..._sortOptions.map((opt) => ListTile(
                title: Text(
                  opt,
                  style: GoogleFonts.poppins(
                    fontSize: 14 * s,
                    color: const Color(0xFF292929),
                    letterSpacing: -0.4 * s,
                    fontWeight: _sortBy == opt
                        ? FontWeight.w600
                        : FontWeight.w400,
                  ),
                ),
                trailing: _sortBy == opt
                    ? Icon(Icons.check_rounded,
                        color: const Color(0xFF7F89E9),
                        size: 20 * s)
                    : null,
                onTap: () {
                  setState(() => _sortBy = opt);
                  Navigator.pop(ctx);
                },
              )),
          SizedBox(height: 24 * s),
        ],
      ),
    );
  }
}

// ── AI VR session banner ──────────────────────────────────────────────────────

class _AiVrSessionBanner extends StatelessWidget {
  final double s;
  const _AiVrSessionBanner({required this.s});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        final sessionId = DateTime.now().millisecondsSinceEpoch.toString();
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ActiveVrSessionScreen(
              sessionId: sessionId,
              therapistName: 'AI Therapist',
              sessionType: 'ai',
            ),
          ),
        );
      },
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(18 * s),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF7F89E9), Color(0xFFA87CC7)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(18 * s),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF7F89E9).withValues(alpha: 0.4),
              blurRadius: 16 * s,
              offset: Offset(0, 6 * s),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 52 * s,
              height: 52 * s,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(14 * s),
              ),
              child: Icon(
                Icons.view_in_ar_rounded,
                color: Colors.white,
                size: 28 * s,
              ),
            ),
            SizedBox(width: 14 * s),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'AI Therapy Session',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 16 * s,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.5 * s,
                    ),
                  ),
                  SizedBox(height: 2 * s),
                  Text(
                    'Talk to Dr. Sarah in VR — available anytime',
                    style: GoogleFonts.poppins(
                      color: Colors.white.withValues(alpha: 0.85),
                      fontSize: 12 * s,
                      fontWeight: FontWeight.w300,
                      letterSpacing: -0.4 * s,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 10 * s),
            Container(
              padding: EdgeInsets.symmetric(
                  horizontal: 14 * s, vertical: 8 * s),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30 * s),
              ),
              child: Text(
                'Enter VR',
                style: GoogleFonts.poppins(
                  color: const Color(0xFF7F89E9),
                  fontSize: 12 * s,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.4 * s,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Gradient heading ──────────────────────────────────────────────────────────

class _GradientHeading extends StatelessWidget {
  final double s;
  const _GradientHeading({required this.s});

  @override
  Widget build(BuildContext context) {
    final style = GoogleFonts.poppins(
      fontSize: 24 * s,
      fontWeight: FontWeight.w600,
      color: const Color(0xFF1A2E12),
      letterSpacing: -1.2 * s,
    );
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text("You're ", style: style),
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [Color(0xFF7F89E9), Color(0xFFA87CC7), Color(0xFF658852)],
            stops: [0.06, 0.59, 1.12],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ).createShader(bounds),
          blendMode: BlendMode.srcIn,
          child: Text('Not', style: style.copyWith(color: Colors.white)),
        ),
        Text(' Alone in This.', style: style),
      ],
    );
  }
}

// ── Top carousel doctor card (Figma 360×181) ─────────────────────────────────

class _FeaturedCard extends StatelessWidget {
  final Doctor doctor;
  final double s;
  const _FeaturedCard({required this.doctor, required this.s});

  @override
  Widget build(BuildContext context) {
    final s = this.s;
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => DoctorProfileScreen(doctor: doctor),
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF7F89E9).withValues(alpha: 0.30),
          borderRadius: BorderRadius.circular(15 * s),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF7F89E9).withValues(alpha: 0.43),
              blurRadius: 11.6 * s,
              offset: Offset(0, 4 * s),
            ),
            BoxShadow(
              color: const Color(0xFF1A2E12).withValues(alpha: 0.08),
              blurRadius: 4 * s,
              offset: Offset(0, 4 * s),
            ),
          ],
        ),
        child: Stack(
          clipBehavior: Clip.hardEdge,
          children: [
            // Doctor photo (left=14, top=27, 128×128, purple border 10px)
            Positioned(
              left: 14 * s,
              top: 27 * s,
              child: Container(
                width: 128 * s,
                height: 128 * s,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                      color: const Color(0xFF7F89E9), width: 10 * s),
                ),
                child: ClipOval(
                  child: Image.asset(
                    doctor.image,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => Container(
                      color: const Color(0xFF7F89E9).withValues(alpha: 0.25),
                      child: Center(
                        child: Text(
                          doctor.initials,
                          style: GoogleFonts.poppins(
                            color: const Color(0xFF7F89E9),
                            fontSize: 28 * s,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            // Name (Figma left=169, top=38)
            Positioned(
              left: 169 * s,
              top: 38 * s,
              right: 8 * s,
              child: Text(
                doctor.name,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  color: const Color(0xFF1A2E12),
                  fontSize: 20 * s,
                  fontWeight: FontWeight.w500,
                  letterSpacing: -1 * s,
                  height: 1.189,
                ),
              ),
            ),
            // Specialty (Figma left=153, top=74)
            Positioned(
              left: 153 * s,
              top: 74 * s,
              right: 8 * s,
              child: Text(
                doctor.specialty,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  color: const Color(0xFF595959),
                  fontSize: 14 * s,
                  fontWeight: FontWeight.w300,
                  letterSpacing: -0.7 * s,
                  height: 1.189,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            // "Book a session" (Figma left=157, top=125, 97×28)
            Positioned(
              left: 157 * s,
              top: 125 * s,
              width: 97 * s,
              height: 28 * s,
              child: GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => BookSessionScreen(
                      doctorName: doctor.name,
                      doctorSpecialty: doctor.specialty,
                      doctorImage: doctor.image,
                    ),
                  ),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF7F89E9),
                    borderRadius: BorderRadius.circular(30 * s),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    'Book a session',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 13 * s,
                      fontWeight: FontWeight.w300,
                      letterSpacing: -0.65 * s,
                    ),
                  ),
                ),
              ),
            ),
            // "View Profile" (Figma left=266, top=125, 77×28)
            Positioned(
              left: 266 * s,
              top: 125 * s,
              width: 77 * s,
              height: 28 * s,
              child: GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => DoctorProfileScreen(doctor: doctor),
                  ),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30 * s),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    'View Profile',
                    style: GoogleFonts.poppins(
                      color: const Color(0xFF7F89E9),
                      fontSize: 13 * s,
                      fontWeight: FontWeight.w300,
                      letterSpacing: -0.65 * s,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Grid doctor card (Figma 168×159, green tint) ─────────────────────────────

class _TherapistGridCard extends StatelessWidget {
  final Doctor doctor;
  final VoidCallback onProfile;
  final VoidCallback onBook;
  final double s;

  const _TherapistGridCard({
    required this.doctor,
    required this.onProfile,
    required this.onBook,
    required this.s,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onProfile,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF658852).withValues(alpha: 0.30),
          borderRadius: BorderRadius.circular(15 * s),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF1A2E12).withValues(alpha: 0.08),
              blurRadius: 4 * s,
              offset: Offset(0, 4 * s),
            ),
            BoxShadow(
              color: const Color(0xFF7F89E9).withValues(alpha: 0.43),
              blurRadius: 11.6 * s,
              offset: Offset(0, 4 * s),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Photo (72×71, border 6, radius 35.5)
            Container(
              width: 72 * s,
              height: 71 * s,
              decoration: BoxDecoration(
                color: const Color(0xFF658852).withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(35.5 * s),
                border: Border.all(
                    color: const Color(0xFF658852), width: 6 * s),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(29.5 * s),
                child: Image.asset(
                  doctor.image,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => Container(
                    color: const Color(0xFF658852).withValues(alpha: 0.2),
                    child: Center(
                      child: Text(
                        doctor.initials,
                        style: GoogleFonts.poppins(
                          color: const Color(0xFF658852),
                          fontSize: 18 * s,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 6 * s),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8 * s),
              child: Text(
                doctor.name,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  color: const Color(0xFF1A2E12),
                  fontSize: 13 * s,
                  fontWeight: FontWeight.w500,
                  letterSpacing: -0.65 * s,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            SizedBox(height: 2 * s),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8 * s),
              child: Text(
                doctor.specialty,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  color: const Color(0xFF595959),
                  fontSize: 7 * s,
                  fontWeight: FontWeight.w300,
                  letterSpacing: -0.35 * s,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            SizedBox(height: 8 * s),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: onBook,
                  child: Container(
                    width: 50 * s,
                    height: 16 * s,
                    decoration: BoxDecoration(
                      color: const Color(0xFF658852),
                      borderRadius: BorderRadius.circular(30 * s),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      'Book',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 7 * s,
                        fontWeight: FontWeight.w300,
                        letterSpacing: -0.35 * s,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 6 * s),
                GestureDetector(
                  onTap: onProfile,
                  child: Container(
                    width: 44 * s,
                    height: 16 * s,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0F0F0),
                      borderRadius: BorderRadius.circular(30 * s),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      'View Profile',
                      style: GoogleFonts.poppins(
                        color: const Color(0xFF658852),
                        fontSize: 7 * s,
                        fontWeight: FontWeight.w300,
                        letterSpacing: -0.35 * s,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── Registered therapists from Firestore ─────────────────────────────────────

class _RegisteredTherapistsBanner extends StatelessWidget {
  final double s;
  const _RegisteredTherapistsBanner({required this.s});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('therapists')
          .where('available', isEqualTo: true)
          .snapshots(),
      builder: (context, snap) {
        final docs = snap.data?.docs ?? [];
        if (docs.isEmpty) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 35 * s),
              child: Row(
                children: [
                  Container(
                    width: 8 * s,
                    height: 8 * s,
                    decoration: const BoxDecoration(
                        color: Color(0xFF4CAF50), shape: BoxShape.circle),
                  ),
                  SizedBox(width: 6 * s),
                  Text(
                    'Therapists Available Now',
                    style: GoogleFonts.poppins(
                      color: const Color(0xFF292929),
                      fontSize: 16 * s,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.6 * s,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 10 * s),
            SizedBox(
              height: 130 * s,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: 35 * s),
                itemCount: docs.length,
                separatorBuilder: (_, __) => SizedBox(width: 12 * s),
                itemBuilder: (_, i) {
                  final data = docs[i].data();
                  final name = data['name'] as String? ?? 'Therapist';
                  final spec = data['specialty'] as String? ?? 'General';
                  final uid = data['uid'] as String? ?? '';
                  final initials = () {
                    final parts = name
                        .trim()
                        .split(' ')
                        .where((p) => p.isNotEmpty)
                        .toList();
                    if (parts.length >= 2) {
                      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
                    }
                    if (parts.length == 1) {
                      return parts[0]
                          .substring(0, parts[0].length.clamp(0, 2))
                          .toUpperCase();
                    }
                    return '?';
                  }();
                  return _TherapistAvailableCard(
                    s: s,
                    name: name,
                    spec: spec,
                    uid: uid,
                    initials: initials,
                  );
                },
              ),
            ),
            SizedBox(height: 20 * s),
          ],
        );
      },
    );
  }
}

class _TherapistAvailableCard extends StatefulWidget {
  final double s;
  final String name;
  final String spec;
  final String uid;
  final String initials;

  const _TherapistAvailableCard({
    required this.s,
    required this.name,
    required this.spec,
    required this.uid,
    required this.initials,
  });

  @override
  State<_TherapistAvailableCard> createState() =>
      _TherapistAvailableCardState();
}

class _TherapistAvailableCardState extends State<_TherapistAvailableCard> {
  bool _joining = false;

  Future<void> _join() async {
    if (_joining || widget.uid.isEmpty) return;
    setState(() => _joining = true);

    final nav = Navigator.of(context);
    final name = widget.name;
    final uid = widget.uid;

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('sessions')
          .where('therapistId', isEqualTo: uid)
          .where('status', isEqualTo: 'therapist_ready')
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(
                    '$name doesn\'t have an active session right now.')),
          );
        }
        return;
      }

      final sessionId = snapshot.docs.first.id;
      await SessionService.joinSession(sessionId,
          patientName: AppState.instance.userName);

      nav.push(MaterialPageRoute(
        builder: (_) => ActiveVrSessionScreen(
          sessionId: sessionId,
          therapistName: name,
          sessionType: 'therapist',
        ),
      ));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not join: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _joining = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.s;
    return GestureDetector(
      onTap: _joining ? null : _join,
      child: Container(
        width: 140 * s,
        padding: EdgeInsets.all(12 * s),
        decoration: BoxDecoration(
          color: const Color(0xFF7F89E9).withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(14 * s),
          border: Border.all(
              color: const Color(0xFF7F89E9).withValues(alpha: 0.3)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 20 * s,
              backgroundColor:
                  const Color(0xFF7F89E9).withValues(alpha: 0.25),
              child: _joining
                  ? SizedBox(
                      width: 16 * s,
                      height: 16 * s,
                      child: const CircularProgressIndicator(
                          color: Color(0xFF7F89E9), strokeWidth: 2),
                    )
                  : Text(widget.initials,
                      style: GoogleFonts.poppins(
                          color: const Color(0xFF7F89E9),
                          fontWeight: FontWeight.w700,
                          fontSize: 14 * s)),
            ),
            SizedBox(height: 6 * s),
            Text(
              widget.name,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.poppins(
                  color: const Color(0xFF1A2E12),
                  fontSize: 11 * s,
                  fontWeight: FontWeight.w600),
            ),
            Text(
              widget.spec,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.poppins(
                  color: const Color(0xFF595959), fontSize: 9 * s),
            ),
            SizedBox(height: 4 * s),
            Text(
              'Tap to join',
              style: GoogleFonts.poppins(
                  color: const Color(0xFF7F89E9),
                  fontSize: 9 * s,
                  fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Decorative blob ───────────────────────────────────────────────────────────

class _Blob extends StatelessWidget {
  final Color color;
  final double size;
  const _Blob({required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}
