import 'dart:math' show pi;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../../../services/app_state.dart';

class JournalWriteScreen extends StatefulWidget {
  final JournalEntry? existingEntry;
  final int? existingIndex;
  const JournalWriteScreen({super.key, this.existingEntry, this.existingIndex});

  @override
  State<JournalWriteScreen> createState() => _JournalWriteScreenState();
}

class _JournalWriteScreenState extends State<JournalWriteScreen> {
  // ── Mood face assets (same as HomeScreen) ────────────────────────────────
  static const _faceAssets = [
    'assets/images/mood_face_1.png',
    'assets/images/mood_face_2.png',
    'assets/images/mood_face_3.png',
    'assets/images/mood_face_4.png',
    'assets/images/mood_face_5.png',
  ];

  // ── Decorative cloud placements (from Figma 430-canvas, absLeft=left, absTop=top) ──
  // moodIdx 0=Grateful 1=Tired 2=Lonely 3=Motivated 4=Overwhelmed
  // containerW/H = outer bounding box; cloudW/H = the inner cloud widget
  static const _decos = [
    // top-right large (Group8)
    _CloudDeco(moodIdx: 3, cL: 339, cT:  99, cW: 83, cH: 73, deg:  15.1),
    // top-left with stars (Group10)
    _CloudDeco(moodIdx: 0, cL:  24, cT: 115, cW: 52, cH: 45, deg: -11.07),
    // right upper (Group16)
    _CloudDeco(moodIdx: 2, cL: 365, cT: 271, cW: 50, cH: 43, deg:  -7.25),
    // left upper-mid (Group34)
    _CloudDeco(moodIdx: 4, cL:  17, cT: 294, cW: 41, cH: 36, deg: -15.62),
    // right mid with stars (Group10 copy)
    _CloudDeco(moodIdx: 3, cL: 361, cT: 457, cW: 53, cH: 46, deg:  12.31),
    // left bottom-mid (Group14)
    _CloudDeco(moodIdx: 1, cL:  18, cT: 612, cW: 46, cH: 39, deg:   9.69),
    // left small (Group9)
    _CloudDeco(moodIdx: 2, cL:  30, cT: 757, cW: 34, cH: 28, deg:   0.0),
    // center bottom (Group15)
    _CloudDeco(moodIdx: 4, cL: 181, cT: 757, cW: 54, cH: 46, deg:   9.69),
    // right bottom (Group33)
    _CloudDeco(moodIdx: 0, cL: 350, cT: 747, cW: 52, cH: 44, deg:   9.69),
  ];

  late final TextEditingController _titleCtrl;
  late final TextEditingController _contentCtrl;
  final List<Uint8List> _images = [];

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController(
        text: widget.existingEntry?.title ?? '');
    _contentCtrl = TextEditingController(
        text: widget.existingEntry?.content ?? '');
    if (widget.existingEntry?.images != null) {
      _images.addAll(widget.existingEntry!.images);
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _contentCtrl.dispose();
    super.dispose();
  }

  // ── Save ──────────────────────────────────────────────────────────────────
  void _save() {
    final content = _contentCtrl.text.trim();
    if (content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: const Color(0xFF7F89E9),
        content: Text('Write something first!',
            style: GoogleFonts.poppins(color: Colors.white)),
      ));
      return;
    }
    final entry = JournalEntry(
      date: widget.existingEntry?.date ?? DateTime.now(),
      title: _titleCtrl.text.trim(),
      content: content,
      images: List.from(_images),
    );
    if (widget.existingIndex != null) {
      AppState.instance.updateJournalEntry(widget.existingIndex!, entry);
    } else {
      AppState.instance.addJournalEntry(entry);
    }
    Navigator.pop(context);
  }

  // ── Pick image ────────────────────────────────────────────────────────────
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
        source: ImageSource.gallery, imageQuality: 80);
    if (picked == null) return;
    final bytes = await picked.readAsBytes();
    setState(() => _images.add(bytes));
  }

  // ── Delete entry ──────────────────────────────────────────────────────────
  void _delete() {
    if (widget.existingIndex == null) return;
    AppState.instance.deleteJournalEntry(widget.existingIndex!);
    Navigator.pop(context);
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // Build
  // ═══════════════════════════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    final s = MediaQuery.of(context).size.width / 430;
    final safeTop = MediaQuery.of(context).padding.top;
    final safeBottom = MediaQuery.of(context).padding.bottom;
    final now = widget.existingEntry?.date ?? DateTime.now();
    final dateStr = '${now.day}/${now.month}/${now.year}';

    return Scaffold(
      backgroundColor: const Color(0xFFC9CDEB),
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          // ── Main content ─────────────────────────────────────────────────
          Padding(
            padding: EdgeInsets.only(top: safeTop),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Header row
                _buildHeader(s),
                // "Title" field (centered, Figma y≈49)
                _buildTitleField(s),
                SizedBox(height: 8 * s),
                // Large writing card (fills remaining space)
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 35 * s),
                    child: _buildWritingCard(s),
                  ),
                ),
                // Date row (Figma: right-aligned, y≈822)
                Padding(
                  padding: EdgeInsets.fromLTRB(
                      35 * s, 6 * s, 35 * s, (12 + safeBottom) * s),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      dateStr,
                      style: GoogleFonts.poppins(
                        fontSize: 15 * s,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF1A2E12),
                        letterSpacing: -0.45 * s,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // ── Decorative clouds (over content) ─────────────────────────────
          ..._decos.map((d) => _buildCloudWidget(d, s, safeTop)),
        ],
      ),
    );
  }

  // ── Header ────────────────────────────────────────────────────────────────
  Widget _buildHeader(double s) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20 * s, 10 * s, 20 * s, 6 * s),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 36 * s,
              height: 36 * s,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.60),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.arrow_back_ios_new_rounded,
                  size: 15 * s, color: const Color(0xFF1A2E12)),
            ),
          ),
          const Spacer(),
          if (widget.existingIndex != null)
            GestureDetector(
              onTap: _delete,
              child: Padding(
                padding: EdgeInsets.only(right: 12 * s),
                child: Icon(Icons.delete_outline_rounded,
                    size: 22 * s, color: const Color(0xFFD93333)),
              ),
            ),
          GestureDetector(
            onTap: _save,
            child: Container(
              padding:
                  EdgeInsets.symmetric(horizontal: 22 * s, vertical: 9 * s),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                    colors: [Color(0xFF7F89E9), Color(0xFFA87CC7)]),
                borderRadius: BorderRadius.circular(20 * s),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF7F89E9).withValues(alpha: 0.3),
                    blurRadius: 8 * s,
                    offset: Offset(0, 3 * s),
                  ),
                ],
              ),
              child: Text(
                'Save',
                style: GoogleFonts.poppins(
                  fontSize: 14 * s,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  letterSpacing: -0.3 * s,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Title field ───────────────────────────────────────────────────────────
  Widget _buildTitleField(double s) {
    return SizedBox(
      width: 360 * s,
      child: TextField(
        controller: _titleCtrl,
        textAlign: TextAlign.center,
        style: GoogleFonts.poppins(
          fontSize: 20 * s,
          fontWeight: FontWeight.w500,
          color: const Color(0xFF1A2E12),
          letterSpacing: -0.6 * s,
        ),
        decoration: InputDecoration(
          hintText: 'Title',
          hintStyle: GoogleFonts.poppins(
            fontSize: 20 * s,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF1A2E12).withValues(alpha: 0.55),
            letterSpacing: -0.6 * s,
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.zero,
        ),
      ),
    );
  }

  // ── Writing card ──────────────────────────────────────────────────────────
  Widget _buildWritingCard(double s) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7F7),
        borderRadius: BorderRadius.circular(30 * s),
      ),
      child: Column(
        children: [
          // Main text area
          Expanded(
            child: Padding(
              padding:
                  EdgeInsets.fromLTRB(22 * s, 18 * s, 22 * s, 4 * s),
              child: TextField(
                controller: _contentCtrl,
                autofocus: widget.existingEntry == null,
                maxLines: null,
                expands: true,
                textAlignVertical: TextAlignVertical.top,
                cursorColor: const Color(0xFF7F89E9),
                style: GoogleFonts.poppins(
                  fontSize: 14 * s,
                  fontWeight: FontWeight.w300,
                  color: const Color(0xFF292929),
                  height: 1.75,
                  letterSpacing: -0.3 * s,
                ),
                decoration: InputDecoration(
                  hintText: "What's on your mind today?",
                  hintStyle: GoogleFonts.poppins(
                    fontSize: 14 * s,
                    color:
                        const Color(0xFF595959).withValues(alpha: 0.45),
                    height: 1.75,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),
          ),
          // Picked image thumbnails
          if (_images.isNotEmpty) _buildImageRow(s),
          // Bottom toolbar
          _buildToolbar(s),
        ],
      ),
    );
  }

  // ── Image thumbnails row ──────────────────────────────────────────────────
  Widget _buildImageRow(double s) {
    return SizedBox(
      height: 84 * s,
      child: ListView.separated(
        padding: EdgeInsets.symmetric(horizontal: 18 * s, vertical: 10 * s),
        scrollDirection: Axis.horizontal,
        itemCount: _images.length,
        separatorBuilder: (ctx, i) => SizedBox(width: 8 * s),
        itemBuilder: (ctx, i) => Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12 * s),
              child: Image.memory(
                _images[i],
                width: 64 * s,
                height: 64 * s,
                fit: BoxFit.cover,
              ),
            ),
            Positioned(
              top: 2 * s,
              right: 2 * s,
              child: GestureDetector(
                onTap: () => setState(() => _images.removeAt(i)),
                child: Container(
                  width: 18 * s,
                  height: 18 * s,
                  decoration: const BoxDecoration(
                    color: Color(0xFFD93333),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.close_rounded,
                      color: Colors.white, size: 11 * s),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Bottom toolbar ────────────────────────────────────────────────────────
  Widget _buildToolbar(double s) {
    return Padding(
      padding: EdgeInsets.fromLTRB(18 * s, 4 * s, 18 * s, 14 * s),
      child: Row(
        children: [
          GestureDetector(
            onTap: _pickImage,
            child: Container(
              padding: EdgeInsets.symmetric(
                  horizontal: 14 * s, vertical: 8 * s),
              decoration: BoxDecoration(
                color: const Color(0xFF7F89E9).withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(20 * s),
                border: Border.all(
                    color: const Color(0xFF7F89E9).withValues(alpha: 0.25)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.image_rounded,
                      color: const Color(0xFF7F89E9), size: 18 * s),
                  SizedBox(width: 6 * s),
                  Text('Photo',
                      style: GoogleFonts.poppins(
                        fontSize: 12 * s,
                        color: const Color(0xFF7F89E9),
                        fontWeight: FontWeight.w500,
                      )),
                ],
              ),
            ),
          ),
          SizedBox(width: 10 * s),
          // word count
          ValueListenableBuilder(
            valueListenable: _contentCtrl,
            builder: (ctx, val, _) {
              final wc = val.text.trim().isEmpty
                  ? 0
                  : val.text.trim().split(RegExp(r'\s+')).length;
              return Text(
                '$wc words',
                style: GoogleFonts.poppins(
                  fontSize: 11 * s,
                  color: const Color(0xFF595959).withValues(alpha: 0.5),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // Cloud face widget — uses OverflowBox for reliable face centering
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildCloudWidget(_CloudDeco d, double s, double safeTop) {
    // Face natural display size (maintains sprite aspect ratio)
    final faceW = d.cW * 0.58; // 58 % of cloud container width
    final faceH = faceW * (386.0 / 493.0); // preserve face aspect ratio

    // The visible face widget
    final faceWidget = SizedBox(
      width: faceW * s,
      height: faceH * s,
      child: Image.asset(
        _faceAssets[d.moodIdx],
        fit: BoxFit.contain,
        filterQuality: FilterQuality.high,
      ),
    );

    // Cloud bubble: white oval with shadow, face exactly centered
    final cloud = Transform.rotate(
      angle: d.deg * pi / 180,
      child: Container(
        width: d.cW * s,
        height: d.cH * s,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.78),
          borderRadius: BorderRadius.circular(d.cH * 0.46 * s),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF7B80C2).withValues(alpha: 0.18),
              blurRadius: 6 * s,
              offset: Offset(0, 3 * s),
            ),
          ],
        ),
        // Center guarantees the face SizedBox sits at the geometric center
        child: Center(child: faceWidget),
      ),
    );

    return Positioned(
      left: d.cL * s,
      top: (d.cT + safeTop) * s,
      child: cloud,
    );
  }
}

// ── Data class ────────────────────────────────────────────────────────────────
class _CloudDeco {
  final int moodIdx;
  final double cL; // container left (canvas px)
  final double cT; // container top (canvas px, before safeTop)
  final double cW; // container width
  final double cH; // container height
  final double deg; // rotation degrees
  const _CloudDeco({
    required this.moodIdx,
    required this.cL,
    required this.cT,
    required this.cW,
    required this.cH,
    required this.deg,
  });
}
