import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'hub_screen.dart';
import 'hub_all_screen.dart';

// ── Data ──────────────────────────────────────────────────────────────────────

const _kBookOfWeek = HubResource(
  title: 'This Book Will Change Your Mind About Mental Health',
  subtitle: 'Nathan Filer',
  url: 'https://www.goodreads.com/book/show/38746795',
  platform: 'Goodreads',
  color: Color(0xFF2D4A6B),
  imageUrl: 'https://covers.openlibrary.org/b/isbn/9780571353989-L.jpg',
);

class _Featured {
  final HubResource resource;
  final List<String> categories;
  final double rating;
  const _Featured(this.resource, this.categories, this.rating);
}

const _kFeatured = [
  _Featured(
    HubResource(
      title: 'The Body Keeps the Score',
      subtitle: 'Bessel van der Kolk',
      url: 'https://www.goodreads.com/book/show/18693771',
      platform: 'Goodreads',
      color: Color(0xFF7F89E9),
      imageUrl: 'https://covers.openlibrary.org/b/isbn/9780143127741-L.jpg',
    ),
    ['Trauma', 'Anxiety', 'Depression'],
    4.37,
  ),
  _Featured(
    HubResource(
      title: 'Maybe You Should Talk to Someone',
      subtitle: 'Lori Gottlieb',
      url: 'https://www.goodreads.com/book/show/37570546',
      platform: 'Goodreads',
      color: Color(0xFFA87CC7),
      imageUrl: 'https://covers.openlibrary.org/b/isbn/9781328662057-L.jpg',
    ),
    ['Therapy', 'Self-Care', 'Mental Health'],
    4.23,
  ),
  _Featured(
    HubResource(
      title: 'Lost Connections',
      subtitle: 'Johann Hari',
      url: 'https://www.goodreads.com/book/show/34921573',
      platform: 'Goodreads',
      color: Color(0xFF5A8A44),
      imageUrl: 'https://covers.openlibrary.org/b/isbn/9781632868305-L.jpg',
    ),
    ['Depression', 'Society', 'Wellbeing'],
    4.12,
  ),
  _Featured(
    HubResource(
      title: 'The Gifts of Imperfection',
      subtitle: 'Brené Brown',
      url: 'https://www.goodreads.com/book/show/6452796',
      platform: 'Goodreads',
      color: Color(0xFFD4845A),
      imageUrl: 'https://covers.openlibrary.org/b/isbn/9781592858491-L.jpg',
    ),
    ['Self-Worth', 'Mindfulness', 'Growth'],
    4.07,
  ),
];

// ── BooksScreen ───────────────────────────────────────────────────────────────

class BooksScreen extends StatefulWidget {
  const BooksScreen({super.key});

  @override
  State<BooksScreen> createState() => _BooksScreenState();
}

class _BooksScreenState extends State<BooksScreen> {
  late final PageController _pageCtrl;
  int _currentPage = 0;
  final Set<int> _hearted = {};

  @override
  void initState() {
    super.initState();
    _pageCtrl = PageController();
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    super.dispose();
  }

  // ── Link dialog ────────────────────────────────────────────────────────────

  Future<void> _open(HubResource item) async {
    final go = await showDialog<bool>(
      context: context,
      builder: (c) {
        final s = MediaQuery.of(c).size.width / 430;
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20 * s)),
          backgroundColor: Colors.white,
          title: Text('Visit External Link',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 16 * s, color: const Color(0xFF1A2E12))),
          content: Text('Open "${item.title}" on ${item.platform}?',
              style: GoogleFonts.poppins(fontSize: 13 * s, color: const Color(0xFF595959), height: 1.5)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(c, false),
              child: Text('Cancel', style: GoogleFonts.poppins(color: const Color(0xFF595959), fontSize: 14 * s)),
            ),
            TextButton(
              onPressed: () => Navigator.pop(c, true),
              child: Text('Visit',
                  style: GoogleFonts.poppins(color: const Color(0xFF7F89E9), fontWeight: FontWeight.w600, fontSize: 14 * s)),
            ),
          ],
        );
      },
    );
    if (go == true) {
      final uri = Uri.parse(item.url);
      if (await canLaunchUrl(uri)) launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final s = MediaQuery.of(context).size.width / 430;
    return Scaffold(
      backgroundColor: const Color(0xFFF0F0F0),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(s),
            SizedBox(height: 24 * s),
            _buildBookOfWeek(s),
            SizedBox(height: 28 * s),
            _buildCarousel(s),
            SizedBox(height: 28 * s),
            _buildBookList(s),
            SizedBox(height: 40 * s),
          ],
        ),
      ),
    );
  }

  // ── Header (Books chip selected) ───────────────────────────────────────────

  Widget _buildHeader(double s) {
    const chips = ['Books', 'Podcasts', 'TED Talks', 'Habits Lists', 'Mentallico Community'];
    return Container(
      color: const Color(0xFF7F89E9),
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 16 * s),
            // Title row with back arrow
            Stack(
              alignment: Alignment.center,
              children: [
                Text('Our Hub',
                    style: GoogleFonts.poppins(
                        fontSize: 20 * s, fontWeight: FontWeight.w500, color: Colors.white, letterSpacing: -0.6 * s)),
                Positioned(
                  left: 20 * s,
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20 * s),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12 * s),
            Container(height: 1, color: const Color(0xFFD2D5DE).withValues(alpha: 0.5)),
            SizedBox(height: 12 * s),
            Padding(
              padding: EdgeInsets.fromLTRB(35 * s, 0, 35 * s, 18 * s),
              child: Wrap(
                spacing: 8 * s,
                runSpacing: 8 * s,
                children: chips.map((chip) {
                  final selected = chip == 'Books';
                  return GestureDetector(
                    onTap: () { if (!selected) Navigator.pop(context); },
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 14 * s, vertical: 5 * s),
                      decoration: BoxDecoration(
                        color: selected ? const Color(0xFF1A2E12) : const Color(0xFFF0F0F0),
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
                      child: Text(
                        chip,
                        style: GoogleFonts.inter(
                          fontSize: 14 * s,
                          color: selected ? const Color(0xFFF0F0F0) : const Color(0xFF7F89E9),
                          letterSpacing: -0.7 * s,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Book of the Week ───────────────────────────────────────────────────────

  Widget _buildBookOfWeek(double s) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 35 * s),
          child: Text('Book Of the Week',
              style: GoogleFonts.poppins(
                  fontSize: 20 * s, fontWeight: FontWeight.w500,
                  color: const Color(0xFF1A2E12), letterSpacing: -1 * s)),
        ),
        SizedBox(height: 20 * s),
        // Shelf lines above book
        _shelfLine(s, opacity: 0.5, thick: 2),
        SizedBox(height: 4 * s),
        _shelfLine(s, opacity: 0.3, thick: 1),
        SizedBox(height: 20 * s),
        // Centered book image
        GestureDetector(
          onTap: () => _open(_kBookOfWeek),
          child: Center(
            child: Container(
              width: 136 * s,
              height: 209 * s,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6 * s),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.31), blurRadius: 4.5 * s, offset: Offset(0, 10 * s)),
                  BoxShadow(color: Colors.black.withValues(alpha: 0.25), blurRadius: 4 * s, offset: Offset(0, 4 * s)),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(6 * s),
                child: Image.network(
                  _kBookOfWeek.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => _bookFallback(_kBookOfWeek, 136 * s, 209 * s, 11 * s),
                ),
              ),
            ),
          ),
        ),
        SizedBox(height: 18 * s),
        // Shelf lines below book
        _shelfLine(s, opacity: 0.55, thick: 3),
        SizedBox(height: 5 * s),
        _shelfLine(s, opacity: 0.28, thick: 1),
        SizedBox(height: 22 * s),
        // Gradient title banner
        GestureDetector(
          onTap: () => _open(_kBookOfWeek),
          child: Center(
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 35 * s),
              padding: EdgeInsets.symmetric(horizontal: 20 * s, vertical: 10 * s),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF7F89E9), Color(0xFFA87CC7), Color(0xFF658852)],
                  stops: [0.059, 0.594, 1.0],
                ),
                borderRadius: BorderRadius.circular(30 * s),
                boxShadow: [
                  BoxShadow(color: const Color(0xFF7F89E9).withValues(alpha: 0.43), blurRadius: 11.6 * s, offset: Offset(0, 4 * s)),
                ],
              ),
              child: Text(
                _kBookOfWeek.title,
                style: GoogleFonts.poppins(
                  fontSize: 14 * s,
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFFF0F0F0),
                  letterSpacing: -0.7 * s,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _shelfLine(double s, {required double opacity, required double thick}) => Container(
        margin: EdgeInsets.symmetric(horizontal: 33 * s),
        height: thick * s,
        decoration: BoxDecoration(
          color: const Color(0xFF1A2E12).withValues(alpha: opacity),
          borderRadius: BorderRadius.circular(2 * s),
        ),
      );

  // ── Carousel ───────────────────────────────────────────────────────────────

  Widget _buildCarousel(double s) {
    const cW = 283.0; // card width in design px
    const cH = 468.0; // card height in design px

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 35 * s),
          child: Text('Books That Understand You',
              style: GoogleFonts.poppins(
                  fontSize: 20 * s, fontWeight: FontWeight.w500,
                  color: Colors.black, letterSpacing: -1 * s)),
        ),
        SizedBox(height: 20 * s),
        // Carousel: centred card, partial peek via viewportFraction
        SizedBox(
          height: cH * s,
          child: PageView.builder(
            controller: PageController(viewportFraction: cW / 430),
            onPageChanged: (i) => setState(() => _currentPage = i),
            itemCount: _kFeatured.length,
            itemBuilder: (_, i) => Padding(
              padding: EdgeInsets.symmetric(horizontal: 6 * s),
              child: _buildCard(_kFeatured[i], i, s, cW, cH),
            ),
          ),
        ),
        SizedBox(height: 20 * s),
        // Dot indicators
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(_kFeatured.length, (i) {
            final active = i == _currentPage;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 280),
              margin: EdgeInsets.only(right: i < _kFeatured.length - 1 ? 8 * s : 0),
              width: active ? 64 * s : 6 * s,
              height: 6 * s,
              decoration: BoxDecoration(
                color: active ? const Color(0xFF7F89E9) : const Color(0xFFD2D5DE),
                borderRadius: BorderRadius.circular(30 * s),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildCard(_Featured fb, int idx, double s, double cW, double cH) {
    // Key measurements from Figma (in design px, relative to 283×468 card):
    //   Image: left=7.33%*283≈20.7, top=28, right=7.04%*283≈19.9, aspect 3:4
    //   Heart: left=200, top=36, size=54
    //   Title: left=7.33%*283, right=40.18%*283, top=80.48%*468
    //   Rating: left=80.16%*283, top=82.45%*468
    //   Pills: left=7.33%*283, bottom=5.78%*468, right=8
    final imgLeft = cW * 0.0733;  // ~20.7
    final imgRight = cW * 0.0704; // ~19.9
    final imgTop = 28.0;
    final imgW = cW - imgLeft - imgRight; // ~242.4
    final imgH = imgW * 4 / 3;            // ~323

    final heartL = 200.0; // left of heart button
    final heartT = 36.0;  // top of heart button
    final heartSz = 54.0; // diameter

    return GestureDetector(
      onTap: () => _open(fb.resource),
      child: Container(
        width: cW * s,
        height: cH * s,
        decoration: BoxDecoration(
          color: const Color(0xFFF0F0F0),
          borderRadius: BorderRadius.circular(30 * s),
          boxShadow: [
            BoxShadow(color: const Color(0xFF1A2E12).withValues(alpha: 0.18), blurRadius: 4 * s, offset: Offset(0, 4 * s)),
            BoxShadow(color: const Color(0xFF7F89E9).withValues(alpha: 0.43), blurRadius: 11.6 * s, offset: Offset(0, 4 * s)),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30 * s),
          child: Stack(
            children: [
              // ── Book cover image ──────────────────────────────────────────
              Positioned(
                left: imgLeft * s,
                right: imgRight * s,
                top: imgTop * s,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15 * s),
                  child: SizedBox(
                    height: imgH * s,
                    child: fb.resource.imageUrl.isNotEmpty
                        ? Image.network(
                            fb.resource.imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) =>
                                _bookFallback(fb.resource, imgW * s, imgH * s, 15 * s),
                          )
                        : _bookFallback(fb.resource, imgW * s, imgH * s, 15 * s),
                  ),
                ),
              ),
              // ── Inner glow on card ────────────────────────────────────────
              Positioned.fill(
                child: IgnorePointer(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30 * s),
                      boxShadow: [
                        BoxShadow(color: const Color(0xFFA87CC7).withValues(alpha: 0.22),
                            blurRadius: 13 * s, offset: Offset(-4 * s, 0)),
                        BoxShadow(color: const Color(0xFF7F89E9).withValues(alpha: 0.23),
                            blurRadius: 7.7 * s, offset: Offset(2 * s, 0)),
                      ],
                    ),
                  ),
                ),
              ),
              // ── Heart / wishlist button ────────────────────────────────────
              Positioned(
                left: heartL * s,
                top: heartT * s,
                child: GestureDetector(
                  onTap: () => setState(() {
                    if (_hearted.contains(idx)) {
                      _hearted.remove(idx);
                    } else {
                      _hearted.add(idx);
                    }
                  }),
                  child: Container(
                    width: heartSz * s,
                    height: heartSz * s,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(color: const Color(0xFF7F89E9).withValues(alpha: 0.35),
                            blurRadius: 10 * s, offset: Offset(0, 4 * s)),
                      ],
                    ),
                    child: Icon(
                      _hearted.contains(idx)
                          ? Icons.favorite_rounded
                          : Icons.favorite_border_rounded,
                      color: _hearted.contains(idx) ? Colors.red : const Color(0xFF7F89E9),
                      size: 26 * s,
                    ),
                  ),
                ),
              ),
              // ── Book title ────────────────────────────────────────────────
              Positioned(
                left: imgLeft * s,
                right: cW * 0.40 * s,
                top: cH * 0.8048 * s,
                child: Text(
                  fb.resource.title,
                  style: GoogleFonts.poppins(
                    fontSize: 22 * s,
                    color: const Color(0xFF1A2E12),
                    letterSpacing: -1.1 * s,
                    height: 1.19,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              // ── Star + rating ─────────────────────────────────────────────
              Positioned(
                left: cW * 0.8016 * s,
                top: cH * 0.8245 * s,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.star_rounded, color: const Color(0xFFFFBB00), size: 13 * s),
                    SizedBox(width: 2 * s),
                    Text(fb.rating.toStringAsFixed(2),
                        style: GoogleFonts.poppins(
                            fontSize: 12 * s, color: const Color(0xFF595959), letterSpacing: -0.6 * s)),
                  ],
                ),
              ),
              // ── Category pills ────────────────────────────────────────────
              Positioned(
                left: imgLeft * s,
                bottom: cH * 0.0578 * s,
                right: 8 * s,
                child: Wrap(
                  spacing: 8 * s,
                  runSpacing: 6 * s,
                  children: fb.categories
                      .map((cat) => Container(
                            padding: EdgeInsets.symmetric(horizontal: 10 * s, vertical: 5 * s),
                            decoration: BoxDecoration(
                              color: const Color(0xFFA87CC7).withValues(alpha: 0.46),
                              borderRadius: BorderRadius.circular(30 * s),
                            ),
                            child: Text(
                              cat,
                              style: GoogleFonts.poppins(
                                fontSize: 12 * s,
                                color: Colors.white,
                                fontWeight: FontWeight.w300,
                                letterSpacing: -0.6 * s,
                              ),
                            ),
                          ))
                      .toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Book List (2-column preview + See All) ─────────────────────────────────

  Widget _buildBookList(double s) {
    final preview = kHubBooks.take(4).toList();
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 35 * s),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Book List',
                  style: GoogleFonts.poppins(
                      fontSize: 20 * s, fontWeight: FontWeight.w500,
                      color: Colors.black, letterSpacing: -1 * s)),
              GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => HubAllScreen.books(items: kHubBooks, onTap: _open),
                  ),
                ),
                child: Text('See All',
                    style: GoogleFonts.poppins(
                        fontSize: 11 * s, fontWeight: FontWeight.w500,
                        color: const Color(0xFF292929), letterSpacing: -0.55 * s)),
              ),
            ],
          ),
          SizedBox(height: 24 * s),
          // 2-column grid using Wrap (inside SingleChildScrollView parent)
          Wrap(
            spacing: 24 * s,
            runSpacing: 38 * s,
            children: preview.map((book) => _buildListCard(book, s)).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildListCard(HubResource book, double s) {
    return GestureDetector(
      onTap: () => _open(book),
      child: Container(
        width: 168 * s,
        height: 215 * s,
        decoration: BoxDecoration(
          color: const Color(0xFF7F89E9).withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(15 * s),
          boxShadow: [
            BoxShadow(color: const Color(0xFF1A2E12).withValues(alpha: 0.08),
                blurRadius: 4 * s, offset: Offset(0, 4 * s)),
            BoxShadow(color: const Color(0xFF7F89E9).withValues(alpha: 0.43),
                blurRadius: 11.6 * s, offset: Offset(0, 4 * s)),
            BoxShadow(color: const Color(0xFFA87CC7).withValues(alpha: 0.22),
                blurRadius: 13 * s, offset: Offset(-4 * s, 0)),
            BoxShadow(color: const Color(0xFF7F89E9).withValues(alpha: 0.23),
                blurRadius: 7.7 * s, offset: Offset(2 * s, 0)),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(15 * s),
          child: Stack(
            children: [
              Container(color: const Color(0xFF7F89E9).withValues(alpha: 0.3)),
              Positioned(
                left: 17 * s,
                top: 19 * s,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10 * s),
                  child: book.imageUrl.isNotEmpty
                      ? Image.network(
                          book.imageUrl,
                          width: 133 * s,
                          height: 177 * s,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) =>
                              _bookFallback(book, 133 * s, 177 * s, 10 * s),
                        )
                      : _bookFallback(book, 133 * s, 177 * s, 10 * s),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _bookFallback(HubResource book, double w, double h, double radius) =>
      Container(
        width: w,
        height: h,
        decoration: BoxDecoration(
          color: book.color,
          borderRadius: BorderRadius.circular(radius),
        ),
        padding: EdgeInsets.all(w * 0.07),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              book.title,
              style: GoogleFonts.poppins(
                  fontSize: w * 0.07, fontWeight: FontWeight.w600,
                  color: Colors.white, height: 1.3),
              textAlign: TextAlign.center,
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: h * 0.04),
            Text(
              book.subtitle,
              style: GoogleFonts.poppins(
                  fontSize: w * 0.06, color: Colors.white.withValues(alpha: 0.8)),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      );
}
