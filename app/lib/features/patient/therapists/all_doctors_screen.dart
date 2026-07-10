import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'doctor.dart';
import 'doctor_profile_screen.dart';
import 'book_session_screen.dart';

class AllDoctorsScreen extends StatefulWidget {
  final String? initialCategory;
  const AllDoctorsScreen({super.key, this.initialCategory});

  @override
  State<AllDoctorsScreen> createState() => _AllDoctorsScreenState();
}

class _AllDoctorsScreenState extends State<AllDoctorsScreen> {
  late String _category;
  String _sortBy = 'Recommended';
  final TextEditingController _searchCtrl = TextEditingController();

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

  @override
  void initState() {
    super.initState();
    _category = widget.initialCategory ?? 'General';
    _searchCtrl.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<Doctor> get _filtered {
    final q = _searchCtrl.text.trim().toLowerCase();
    var docs = kAllDoctors.where((d) {
      final matchesCat =
          _category == 'General' || d.categories.contains(_category);
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
  Widget build(BuildContext context) {
    final s = MediaQuery.of(context).size.width / 430;
    final docs = _filtered;

    return Scaffold(
      backgroundColor: const Color(0xFFF0F0F0),
      appBar: AppBar(
        backgroundColor: const Color(0xFF7F89E9),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded,
              color: Colors.white, size: 20 * s),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'All Therapists',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 18 * s,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.6 * s,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.sort_rounded, color: Colors.white, size: 24 * s),
            onPressed: () => _showSortSheet(context, s),
            tooltip: 'Sort',
          ),
        ],
      ),
      body: Column(
        children: [
          // ── Search bar ────────────────────────────────────────────────────
          Container(
            color: const Color(0xFF7F89E9),
            padding: EdgeInsets.fromLTRB(20 * s, 0, 20 * s, 14 * s),
            child: Container(
              height: 40 * s,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.22),
                borderRadius: BorderRadius.circular(30 * s),
              ),
              child: TextField(
                controller: _searchCtrl,
                style: GoogleFonts.poppins(
                    fontSize: 13 * s, color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Search by name or specialty…',
                  hintStyle: GoogleFonts.poppins(
                      fontSize: 13 * s,
                      color: Colors.white.withValues(alpha: 0.7)),
                  border: InputBorder.none,
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 10 * s),
                  prefixIcon: Icon(Icons.search_rounded,
                      color: Colors.white.withValues(alpha: 0.85),
                      size: 18 * s),
                  suffixIcon: _searchCtrl.text.isNotEmpty
                      ? IconButton(
                          icon: Icon(Icons.close_rounded,
                              color: Colors.white.withValues(alpha: 0.85),
                              size: 18 * s),
                          onPressed: () => _searchCtrl.clear(),
                        )
                      : null,
                ),
              ),
            ),
          ),

          // ── Category chips ────────────────────────────────────────────────
          Container(
            color: const Color(0xFF7F89E9),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding:
                  EdgeInsets.fromLTRB(20 * s, 0, 20 * s, 14 * s),
              child: Row(
                children: _categories.map((cat) {
                  final active = _category == cat;
                  return GestureDetector(
                    onTap: () => setState(() => _category = cat),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: EdgeInsets.only(right: 8 * s),
                      padding: EdgeInsets.symmetric(
                          horizontal: 14 * s, vertical: 6 * s),
                      decoration: BoxDecoration(
                        color: active
                            ? Colors.white
                            : Colors.white.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(30 * s),
                      ),
                      child: Text(
                        cat,
                        style: GoogleFonts.poppins(
                          fontSize: 12 * s,
                          color: active
                              ? const Color(0xFF7F89E9)
                              : Colors.white,
                          fontWeight: active
                              ? FontWeight.w600
                              : FontWeight.w300,
                          letterSpacing: -0.4 * s,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          // ── Sort label strip ──────────────────────────────────────────────
          if (_sortBy != 'Recommended')
            Container(
              width: double.infinity,
              color: const Color(0xFFEDECFF),
              padding: EdgeInsets.symmetric(
                  horizontal: 20 * s, vertical: 6 * s),
              child: Row(
                children: [
                  Icon(Icons.sort_rounded,
                      size: 14 * s, color: const Color(0xFF7F89E9)),
                  SizedBox(width: 6 * s),
                  Text(
                    'Sorted by: $_sortBy',
                    style: GoogleFonts.poppins(
                      fontSize: 11 * s,
                      color: const Color(0xFF7F89E9),
                      letterSpacing: -0.3 * s,
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => setState(() => _sortBy = 'Recommended'),
                    child: Text(
                      'Clear',
                      style: GoogleFonts.poppins(
                        fontSize: 11 * s,
                        color: const Color(0xFF7F89E9),
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.3 * s,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // ── Result count ──────────────────────────────────────────────────
          Padding(
            padding: EdgeInsets.fromLTRB(20 * s, 12 * s, 20 * s, 4 * s),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '${docs.length} therapist${docs.length != 1 ? "s" : ""} found',
                style: GoogleFonts.poppins(
                  fontSize: 12 * s,
                  color: const Color(0xFF595959),
                  letterSpacing: -0.3 * s,
                ),
              ),
            ),
          ),

          // ── Doctor cards list ─────────────────────────────────────────────
          Expanded(
            child: docs.isEmpty
                ? _buildEmpty(s)
                : ListView.separated(
                    padding: EdgeInsets.fromLTRB(
                        (MediaQuery.of(context).size.width - 294 * s) / 2,
                        12 * s,
                        (MediaQuery.of(context).size.width - 294 * s) / 2,
                        24 * s),
                    itemCount: docs.length,
                    separatorBuilder: (_, _) => SizedBox(height: 20 * s),
                    itemBuilder: (ctx, i) =>
                        _DoctorListCard(doctor: docs[i], s: s),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty(double s) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.search_off_rounded,
              size: 56 * s,
              color: const Color(0xFF7F89E9).withValues(alpha: 0.4)),
          SizedBox(height: 12 * s),
          Text(
            'No therapists found',
            style: GoogleFonts.poppins(
              fontSize: 16 * s,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF595959),
              letterSpacing: -0.5 * s,
            ),
          ),
          SizedBox(height: 4 * s),
          Text(
            'Try a different search or filter',
            style: GoogleFonts.poppins(
              fontSize: 13 * s,
              color: const Color(0xFF595959).withValues(alpha: 0.6),
            ),
          ),
        ],
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
                        color: const Color(0xFF7F89E9), size: 20 * s)
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

// ── Doctor card (Figma node 1512:1301 — 294×332) ─────────────────────────────

class _DoctorListCard extends StatelessWidget {
  final Doctor doctor;
  final double s;
  const _DoctorListCard({required this.doctor, required this.s});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => DoctorProfileScreen(doctor: doctor),
        ),
      ),
      child: Container(
        width: 294 * s,
        height: 332 * s,
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
          children: [
            // Inner shadow overlay
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15 * s),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF7F89E9).withValues(alpha: 0.23),
                      blurRadius: 7.7 * s,
                      offset: const Offset(2, 0),
                    ),
                    BoxShadow(
                      color: const Color(0xFFA87CC7).withValues(alpha: 0.22),
                      blurRadius: 13 * s,
                      offset: const Offset(-4, 0),
                    ),
                  ],
                ),
              ),
            ),
            // Doctor photo (150×150, centered, top=31)
            Positioned(
              left: (294 - 150) / 2 * s,
              top: 31 * s,
              child: Container(
                width: 150 * s,
                height: 150 * s,
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
                      color:
                          const Color(0xFF7F89E9).withValues(alpha: 0.25),
                      child: Center(
                        child: Text(
                          doctor.initials,
                          style: GoogleFonts.poppins(
                            color: const Color(0xFF7F89E9),
                            fontSize: 36 * s,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            // Doctor name (top=192, centered)
            Positioned(
              top: 192 * s,
              left: 0,
              right: 0,
              child: Text(
                doctor.name,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 20 * s,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF1A2E12),
                  letterSpacing: -1.0 * s,
                  height: 1.189,
                ),
              ),
            ),
            // Specialty (top=232, centered, w=247)
            Positioned(
              top: 232 * s,
              left: (294 - 247) / 2 * s,
              width: 247 * s,
              child: Text(
                doctor.specialty,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 14 * s,
                  fontWeight: FontWeight.w300,
                  color: const Color(0xFF595959),
                  letterSpacing: -0.7 * s,
                  height: 1.189,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            // "Book a session" button (left=45, top=269, w=105, h=32)
            Positioned(
              left: 45 * s,
              top: 269 * s,
              width: 105 * s,
              height: 32 * s,
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
                      fontSize: 13 * s,
                      fontWeight: FontWeight.w300,
                      color: const Color(0xFFF0F0F0),
                      letterSpacing: -0.65 * s,
                    ),
                  ),
                ),
              ),
            ),
            // "View Profile" button (left=156, top=269, w=93, h=32)
            Positioned(
              left: 156 * s,
              top: 269 * s,
              width: 93 * s,
              height: 32 * s,
              child: GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => DoctorProfileScreen(doctor: doctor),
                  ),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0F0F0),
                    borderRadius: BorderRadius.circular(30 * s),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    'View Profile',
                    style: GoogleFonts.poppins(
                      fontSize: 13 * s,
                      fontWeight: FontWeight.w300,
                      color: const Color(0xFF7F89E9),
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
