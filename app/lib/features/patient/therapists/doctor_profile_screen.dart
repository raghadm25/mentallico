import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'doctor.dart';
import 'book_session_screen.dart';

class DoctorProfileScreen extends StatefulWidget {
  final Doctor doctor;
  const DoctorProfileScreen({super.key, required this.doctor});

  @override
  State<DoctorProfileScreen> createState() => _DoctorProfileScreenState();
}

class _DoctorProfileScreenState extends State<DoctorProfileScreen> {
  String? _selectedSlot;

  Doctor get _doc => widget.doctor;

  @override
  Widget build(BuildContext context) {
    final s = MediaQuery.of(context).size.width / 430;

    return Scaffold(
      backgroundColor: const Color(0xFFF0F0F0),
      bottomNavigationBar: _buildBookBar(context, s),
      body: CustomScrollView(
        slivers: [
          // ── Collapsing header ────────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 310 * s,
            pinned: true,
            backgroundColor: const Color(0xFF7F89E9),
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios_new_rounded,
                  color: Colors.white, size: 20 * s),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              _doc.name,
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 16 * s,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.5 * s,
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.pin,
              background: _buildHeader(s),
            ),
          ),

          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Stats card
                SizedBox(height: 16 * s),
                _buildStatsCard(s),
                SizedBox(height: 8 * s),

                // About
                _section(
                  'About',
                  s,
                  Text(
                    _doc.bio,
                    style: GoogleFonts.poppins(
                      fontSize: 13 * s,
                      color: const Color(0xFF595959),
                      height: 1.5,
                      letterSpacing: -0.4 * s,
                    ),
                  ),
                ),

                // Specializations
                _section(
                  'Specializations',
                  s,
                  Wrap(
                    spacing: 8 * s,
                    runSpacing: 6 * s,
                    children: _doc.categories.map((c) => Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 12 * s, vertical: 5 * s),
                      decoration: BoxDecoration(
                        color: const Color(0xFF7F89E9).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(30 * s),
                        border: Border.all(
                            color: const Color(0xFF7F89E9).withValues(alpha: 0.4)),
                      ),
                      child: Text(
                        c,
                        style: GoogleFonts.poppins(
                          fontSize: 12 * s,
                          color: const Color(0xFF7F89E9),
                          fontWeight: FontWeight.w500,
                          letterSpacing: -0.4 * s,
                        ),
                      ),
                    )).toList(),
                  ),
                ),

                // Education & Credentials
                _section(
                  'Education & Credentials',
                  s,
                  Column(
                    children: _doc.credentials.map((c) => Padding(
                      padding: EdgeInsets.only(bottom: 8 * s),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            margin: EdgeInsets.only(top: 5 * s, right: 10 * s),
                            width: 6 * s,
                            height: 6 * s,
                            decoration: const BoxDecoration(
                              color: Color(0xFF7F89E9),
                              shape: BoxShape.circle,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              c,
                              style: GoogleFonts.poppins(
                                fontSize: 13 * s,
                                color: const Color(0xFF292929),
                                height: 1.4,
                                letterSpacing: -0.4 * s,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )).toList(),
                  ),
                ),

                // Languages
                _section(
                  'Languages',
                  s,
                  Wrap(
                    spacing: 8 * s,
                    children: _doc.languages.map((l) => Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 14 * s, vertical: 6 * s),
                      decoration: BoxDecoration(
                        color: const Color(0xFF658852).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(30 * s),
                        border: Border.all(
                            color: const Color(0xFF658852).withValues(alpha: 0.4)),
                      ),
                      child: Text(
                        l,
                        style: GoogleFonts.poppins(
                          fontSize: 13 * s,
                          color: const Color(0xFF658852),
                          fontWeight: FontWeight.w500,
                          letterSpacing: -0.4 * s,
                        ),
                      ),
                    )).toList(),
                  ),
                ),

                // Available Sessions
                _section(
                  'Available Sessions',
                  s,
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _doc.availableSlots.map((slot) {
                        final sel = _selectedSlot == slot;
                        return GestureDetector(
                          onTap: () => setState(() => _selectedSlot = sel ? null : slot),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            margin: EdgeInsets.only(right: 8 * s),
                            padding: EdgeInsets.symmetric(
                                horizontal: 14 * s, vertical: 8 * s),
                            decoration: BoxDecoration(
                              color: sel
                                  ? const Color(0xFF7F89E9)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(30 * s),
                              border: Border.all(
                                color: const Color(0xFF7F89E9),
                                width: sel ? 0 : 1,
                              ),
                            ),
                            child: Text(
                              slot,
                              style: GoogleFonts.poppins(
                                fontSize: 12 * s,
                                color: sel
                                    ? Colors.white
                                    : const Color(0xFF7F89E9),
                                letterSpacing: -0.4 * s,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),

                // Reviews
                _section(
                  'Patient Reviews  ·  ${_doc.reviewCount} reviews',
                  s,
                  Column(
                    children: _doc.reviews
                        .map((r) => _buildReviewCard(r, s))
                        .toList(),
                  ),
                ),

                SizedBox(height: 24 * s),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Header background (gradient + photo + name + stars) ──────────────────

  Widget _buildHeader(double s) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF7F89E9), Color(0xFFA87CC7)],
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 44 * s),
            // Photo
            Container(
              width: 96 * s,
              height: 96 * s,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 3 * s),
                boxShadow: [
                  BoxShadow(
                    color: Colors.white.withValues(alpha: 0.25),
                    blurRadius: 20 * s,
                  ),
                ],
              ),
              child: ClipOval(
                child: Image.asset(
                  _doc.image,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => Container(
                    color: Colors.white.withValues(alpha: 0.2),
                    child: Center(
                      child: Text(
                        _doc.initials,
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 28 * s,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 12 * s),
            Text(
              _doc.name,
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 22 * s,
                fontWeight: FontWeight.w600,
                letterSpacing: -1.1 * s,
              ),
            ),
            SizedBox(height: 4 * s),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 40 * s),
              child: Text(
                _doc.specialty,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  color: Colors.white.withValues(alpha: 0.85),
                  fontSize: 13 * s,
                  fontWeight: FontWeight.w300,
                  letterSpacing: -0.5 * s,
                ),
              ),
            ),
            SizedBox(height: 10 * s),
            // Stars + review count
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ...List.generate(5, (i) {
                  final full = i < _doc.rating.floor();
                  final half = !full &&
                      i == _doc.rating.floor() &&
                      _doc.rating % 1 >= 0.5;
                  return Icon(
                    full
                        ? Icons.star_rounded
                        : half
                            ? Icons.star_half_rounded
                            : Icons.star_outline_rounded,
                    color: const Color(0xFFFFD94A),
                    size: 18 * s,
                  );
                }),
                SizedBox(width: 6 * s),
                Text(
                  '${_doc.rating}  (${_doc.reviewCount} reviews)',
                  style: GoogleFonts.poppins(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 12 * s,
                    letterSpacing: -0.4 * s,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16 * s),
          ],
        ),
      ),
    );
  }

  // ── Stats card ────────────────────────────────────────────────────────────

  Widget _buildStatsCard(double s) {
    return Padding(
      padding: EdgeInsets.fromLTRB(24 * s, 0, 24 * s, 0),
      child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16 * s),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.07),
                blurRadius: 20 * s,
                offset: Offset(0, 4 * s),
              ),
            ],
          ),
          padding: EdgeInsets.symmetric(vertical: 18 * s),
          child: Row(
            children: [
              _statCol(
                  '${_doc.rating}',
                  'Rating',
                  Icons.star_rounded,
                  const Color(0xFFFFD94A),
                  s),
              _vDivider(s),
              _statCol(
                  '${_doc.yearsExperience}yr',
                  'Experience',
                  Icons.work_history_outlined,
                  const Color(0xFF7F89E9),
                  s),
              _vDivider(s),
              _statCol(
                  '\$${_doc.pricePerSession}',
                  'Per Session',
                  Icons.payments_outlined,
                  const Color(0xFF658852),
                  s),
            ],
          ),
      ),
    );
  }

  Widget _statCol(String value, String label, IconData icon, Color color, double s) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: color, size: 22 * s),
          SizedBox(height: 4 * s),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 18 * s,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1A2E12),
              letterSpacing: -0.6 * s,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 11 * s,
              color: const Color(0xFF595959),
              letterSpacing: -0.3 * s,
            ),
          ),
        ],
      ),
    );
  }

  Widget _vDivider(double s) => Container(
        width: 1,
        height: 50 * s,
        color: const Color(0xFFE0E0E0),
      );

  // ── Generic content section card ─────────────────────────────────────────

  Widget _section(String title, double s, Widget child) {
    return Container(
      margin: EdgeInsets.fromLTRB(20 * s, 0, 20 * s, 14 * s),
      padding: EdgeInsets.all(16 * s),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16 * s),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10 * s,
            offset: Offset(0, 2 * s),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 15 * s,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1A2E12),
              letterSpacing: -0.5 * s,
            ),
          ),
          SizedBox(height: 10 * s),
          child,
        ],
      ),
    );
  }

  // ── Review card ───────────────────────────────────────────────────────────

  Widget _buildReviewCard(DoctorReview review, double s) {
    return Container(
      margin: EdgeInsets.only(bottom: 10 * s),
      padding: EdgeInsets.all(12 * s),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7F7),
        borderRadius: BorderRadius.circular(12 * s),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 16 * s,
                backgroundColor:
                    const Color(0xFF7F89E9).withValues(alpha: 0.15),
                child: Text(
                  review.authorInitials,
                  style: GoogleFonts.poppins(
                    fontSize: 11 * s,
                    color: const Color(0xFF7F89E9),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              SizedBox(width: 8 * s),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.authorName,
                      style: GoogleFonts.poppins(
                        fontSize: 13 * s,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF1A2E12),
                        letterSpacing: -0.4 * s,
                      ),
                    ),
                    Text(
                      review.date,
                      style: GoogleFonts.poppins(
                        fontSize: 11 * s,
                        color: const Color(0xFF595959),
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: List.generate(
                  5,
                  (i) => Icon(
                    i < review.rating.floor()
                        ? Icons.star_rounded
                        : Icons.star_outline_rounded,
                    size: 13 * s,
                    color: const Color(0xFFFFD94A),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8 * s),
          Text(
            review.text,
            style: GoogleFonts.poppins(
              fontSize: 12 * s,
              color: const Color(0xFF595959),
              height: 1.45,
              letterSpacing: -0.3 * s,
            ),
          ),
        ],
      ),
    );
  }

  // ── Bottom book button ────────────────────────────────────────────────────

  Widget _buildBookBar(BuildContext context, double s) {
    return Container(
      color: const Color(0xFFF0F0F0),
      padding: EdgeInsets.fromLTRB(24 * s, 12 * s, 24 * s, 24 * s),
      child: GestureDetector(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => BookSessionScreen(
              doctorName: _doc.name,
              doctorSpecialty: _doc.specialty,
              doctorImage: _doc.image,
            ),
          ),
        ),
        child: Container(
          height: 50 * s,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF7F89E9), Color(0xFFA87CC7)],
            ),
            borderRadius: BorderRadius.circular(30 * s),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF7F89E9).withValues(alpha: 0.4),
                blurRadius: 12 * s,
                offset: Offset(0, 4 * s),
              ),
            ],
          ),
          child: Center(
            child: Text(
              _selectedSlot != null
                  ? 'Book Session — $_selectedSlot'
                  : 'Book a Session',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 15 * s,
                fontWeight: FontWeight.w500,
                letterSpacing: -0.5 * s,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
