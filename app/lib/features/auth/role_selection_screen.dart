import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class RoleSelectionScreen extends StatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen> {
  String _selected = 'patient';

  void _proceed() {
    Navigator.pushReplacementNamed(context, '/login', arguments: _selected);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final s = size.width / 430; // scale factor — everything derived from 430px canvas

    return Scaffold(
      backgroundColor: const Color(0xFFF0F0F0),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(s, size.width),

            // Gap: header bottom (210s) → label top (233s) = 23s
            SizedBox(height: 23 * s),

            // "Select your role" — Figma: left=22, top=233, Regular 13.538px, #595959
            Padding(
              padding: EdgeInsets.only(left: 22 * s),
              child: Text(
                'Select your role',
                style: GoogleFonts.poppins(
                  color: const Color(0xFF595959),
                  fontSize: 13.538 * s,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),

            // Gap: label bottom → card top (264s) ≈ 15s
            SizedBox(height: 15 * s),

            // Patient card — Figma top=264, h=155.692
            _RoleCard(
              role: 'patient',
              isSelected: _selected == 'patient',
              onTap: () => setState(() => _selected = 'patient'),
              s: s,
            ),

            // Gap: patient bottom (419.7s) → therapist top (437.7s) = 18s
            SizedBox(height: 18 * s),

            // Therapist card — Figma top=437.74
            _RoleCard(
              role: 'therapist',
              isSelected: _selected == 'therapist',
              onTap: () => setState(() => _selected = 'therapist'),
              s: s,
            ),

            // Gap: therapist bottom (593.4s) → button top (618.3s) ≈ 25s
            SizedBox(height: 25 * s),

            // Continue button — Figma: centered, w=385.846, h=60.923, radius=33.846, gradient
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 22 * s),
              child: GestureDetector(
                onTap: _proceed,
                child: Container(
                  width: double.infinity,
                  height: 60.923 * s,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [Color(0xFF7F89E9), Color(0xFFA87CC7)],
                    ),
                    borderRadius: BorderRadius.circular(33.846 * s),
                  ),
                  child: Center(
                    child: Text(
                      'Continue',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 18.051 * s,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Gap: button bottom (679.2s) → settings top (699.5s) ≈ 20s
            SizedBox(height: 20 * s),

            // Settings hint — Figma: centered, Regular 13.538px, #595959
            SizedBox(
              width: double.infinity,
              child: Text(
                'You can change this later in Settings',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  color: const Color(0xFF595959),
                  fontSize: 13.538 * s,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),

            SizedBox(height: 40 * s),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(double s, double screenWidth) {
    // Header shape: 430×210, bottom corners only rounded at r≈30 (from SVG path)
    // The PNG already has transparent bottom corners matching this shape.
    return SizedBox(
      width: screenWidth,
      height: 210 * s,
      child: Stack(
        children: [
          // Background PNG (emoji pattern on #7F89E9, bottom-rounded)
          Positioned.fill(
            child: Image.asset(
              'assets/images/role_selection_header_bg.png',
              fit: BoxFit.cover,
              gaplessPlayback: true,
            ),
          ),

          // Title — Figma: top=45, w=347, center, SemiBold 40px
          // "Start your journey with " dark (#424242) + "Mentallico" light (#F0F0F0)
          Positioned(
            left: 41.5 * s,
            right: 41.5 * s,
            top: 45 * s,
            child: RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                children: [
                  TextSpan(
                    text: 'Start your journey with ',
                    style: GoogleFonts.poppins(
                      color: const Color(0xFF424242),
                      fontSize: 40 * s,
                      fontWeight: FontWeight.w600,
                      height: 1.208,
                      letterSpacing: -2.0 * s,
                    ),
                  ),
                  TextSpan(
                    text: 'Mentallico',
                    style: GoogleFonts.poppins(
                      color: const Color(0xFFF0F0F0),
                      fontSize: 40 * s,
                      fontWeight: FontWeight.w600,
                      height: 1.208,
                      letterSpacing: -2.0 * s,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Subtitle — Figma: top=156, centered, SemiBold 14.667px, #555555
          Positioned(
            left: 0,
            right: 0,
            top: 156 * s,
            child: Text(
              "Choose how you'll use the app",
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                color: const Color(0xFF555555),
                fontSize: 14.667 * s,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Role Card ────────────────────────────────────────────────────────────────
// Figma card: w=385.846, h=155.692, radius=16.923
// Selected:  bg=#F2F5FC, left accent bar 4.513px #7F89E9, shadow rgba(127,137,233,0.25)
// Unselected: bg=white, no bar, shadow rgba(0,0,0,0.08)

class _RoleCard extends StatelessWidget {
  final String role;
  final bool isSelected;
  final VoidCallback onTap;
  final double s;

  const _RoleCard({
    required this.role,
    required this.isSelected,
    required this.onTap,
    required this.s,
  });

  @override
  Widget build(BuildContext context) {
    final isPt = role == 'patient';
    final letter = isPt ? 'P' : 'T';
    final title = isPt ? "I'm a Patient" : "I'm a Therapist";
    final subtitle1 = isPt ? 'Mental health support' : 'Manage patients, sessions';
    final subtitle2 = isPt ? '& therapy sessions' : '& treatment plans';

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 22 * s),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 155.692 * s,
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFF2F5FC) : Colors.white,
            borderRadius: BorderRadius.circular(16.923 * s),
            boxShadow: [
              BoxShadow(
                color: isSelected
                    ? const Color(0xFF7F89E9).withOpacity(0.25)
                    : Colors.black.withOpacity(0.08),
                blurRadius: isSelected ? 22.564 * s : 18.051 * s,
                offset: Offset(0, 4.513 * s),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16.923 * s),
            child: Stack(
              children: [
                // Left accent bar — only when selected, overlaid on card bg
                if (isSelected)
                  Positioned(
                    left: 0,
                    top: 0,
                    bottom: 0,
                    child: Container(
                      width: 4.513 * s,
                      color: const Color(0xFF7F89E9),
                    ),
                  ),

                // Row content — left padding fixed at Figma's 22.56px from card edge
                Positioned.fill(
                  child: Padding(
                    padding: EdgeInsets.only(left: 22.56 * s),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Avatar circle
                        // Figma: size=60.923, selected=purple #7F89E9 / unselected=gray #D2D5DE
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 60.923 * s,
                          height: 60.923 * s,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(0xFF7F89E9)
                                : const Color(0xFFD2D5DE),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              letter,
                              style: GoogleFonts.poppins(
                                color: isSelected
                                    ? Colors.white
                                    : const Color(0xFF595959),
                                fontSize: 24.821 * s,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),

                        // Gap: avatar right → title left = 101.54 - 22.56 - 60.923 = 18.057
                        SizedBox(width: 18.057 * s),

                        // Title + subtitle
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                title,
                                style: GoogleFonts.poppins(
                                  color: const Color(0xFF292929),
                                  fontSize: 19.179 * s,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(height: 6 * s),
                              Text(
                                '$subtitle1\n$subtitle2',
                                style: GoogleFonts.poppins(
                                  color: const Color(0xFF595959),
                                  fontSize: 13.538 * s,
                                  fontWeight: FontWeight.w400,
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Radio button
                        // Figma: outer=33.846px, inner dot=13px, right margin=33.846px
                        Container(
                          width: 33.846 * s,
                          height: 33.846 * s,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(0xFFD8DCFA)
                                : const Color(0xFFEBEBEB),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              width: 13 * s,
                              height: 13 * s,
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? const Color(0xFF7F89E9)
                                    : const Color(0xFFBBBBBB),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ),

                        // Right margin matching Figma: 385.846 - 318.15 - 33.846 ≈ 33.85
                        SizedBox(width: 33.846 * s),
                      ],
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
}
