import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

class TherapistHubScreen extends StatefulWidget {
  const TherapistHubScreen({super.key});

  @override
  State<TherapistHubScreen> createState() => _TherapistHubScreenState();
}

class _TherapistHubScreenState extends State<TherapistHubScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 4, vsync: this);
    _tabCtrl.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = MediaQuery.of(context).size.width / 430;
    final safeTop = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: const Color(0xFFF0F0F0),
      body: Column(
        children: [
          _buildHeader(s, safeTop),
          Expanded(
            child: TabBarView(
              controller: _tabCtrl,
              children: [
                _AssessmentsTab(s: s),
                _WorksheetsTab(s: s),
                _GuidesTab(s: s),
                _PodcastsTab(s: s),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(double s, double safeTop) {
    final tabs = ['Assessments', 'Worksheets', 'Guides', 'Podcasts'];
    return Container(
      padding: EdgeInsets.fromLTRB(22 * s, safeTop + 18 * s, 22 * s, 0),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF7F89E9), Color(0xFFA87CC7)],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft:  Radius.circular(30 * s),
          bottomRight: Radius.circular(30 * s),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Our Hub',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 24 * s,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.8 * s,
            ),
          ),
          SizedBox(height: 2 * s),
          Text(
            'Professional tools and resources',
            style: GoogleFonts.poppins(
              color: Colors.white.withValues(alpha: 0.8),
              fontSize: 13 * s,
              letterSpacing: -0.4 * s,
            ),
          ),
          SizedBox(height: 18 * s),
          // Tab bar
          Row(
            children: List.generate(tabs.length, (i) {
              final selected = _tabCtrl.index == i;
              return GestureDetector(
                onTap: () => _tabCtrl.animateTo(i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  margin: EdgeInsets.only(right: 8 * s),
                  padding: EdgeInsets.symmetric(
                      horizontal: 14 * s, vertical: 8 * s),
                  decoration: BoxDecoration(
                    color: selected
                        ? Colors.white
                        : Colors.white.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.only(
                      topLeft:  Radius.circular(14 * s),
                      topRight: Radius.circular(14 * s),
                    ),
                  ),
                  child: Text(
                    tabs[i],
                    style: GoogleFonts.poppins(
                      color: selected
                          ? const Color(0xFF7F89E9)
                          : Colors.white,
                      fontSize: 12 * s,
                      fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                      letterSpacing: -0.3 * s,
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

// ── Shared card ───────────────────────────────────────────────────────────────

class _ResourceCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String badge;
  final Color color;
  final IconData icon;
  final String url;
  final double s;

  const _ResourceCard({
    required this.title,
    required this.subtitle,
    required this.badge,
    required this.color,
    required this.icon,
    required this.url,
    required this.s,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final uri = Uri.tryParse(url);
        if (uri != null && await canLaunchUrl(uri)) await launchUrl(uri);
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 14 * s),
        padding: EdgeInsets.all(16 * s),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20 * s),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF000000).withValues(alpha: 0.06),
              blurRadius: 8 * s,
              offset: Offset(0, 2 * s),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 50 * s,
              height: 50 * s,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14 * s),
              ),
              child: Icon(icon, color: color, size: 26 * s),
            ),
            SizedBox(width: 14 * s),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: GoogleFonts.poppins(
                          fontSize: 13 * s,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF1A2E12),
                          letterSpacing: -0.3 * s)),
                  SizedBox(height: 2 * s),
                  Text(subtitle,
                      style: GoogleFonts.poppins(
                          fontSize: 11 * s,
                          color: const Color(0xFF595959),
                          letterSpacing: -0.3 * s),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
            SizedBox(width: 10 * s),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8 * s, vertical: 3 * s),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20 * s),
                  ),
                  child: Text(badge,
                      style: GoogleFonts.poppins(
                          color: color,
                          fontSize: 10 * s,
                          fontWeight: FontWeight.w600)),
                ),
                SizedBox(height: 8 * s),
                Icon(Icons.open_in_new_rounded,
                    color: const Color(0xFFD2D5DE), size: 16 * s),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

Widget _tabScroll(List<Widget> cards, double s) {
  return ListView(
    padding: EdgeInsets.fromLTRB(22 * s, 20 * s, 22 * s, 100 * s),
    children: cards,
  );
}

// ── Assessments tab ───────────────────────────────────────────────────────────

class _AssessmentsTab extends StatelessWidget {
  final double s;
  const _AssessmentsTab({required this.s});

  @override
  Widget build(BuildContext context) {
    return _tabScroll([
      _ResourceCard(title: 'GAD-7 Anxiety Scale',
          subtitle: 'Generalized Anxiety Disorder 7-item assessment for screening and measuring anxiety severity',
          badge: 'Anxiety', color: const Color(0xFF7F89E9),
          icon: Icons.psychology_outlined,
          url: 'https://www.psychiatry.org/psychiatrists/practice/dsm', s: s),
      _ResourceCard(title: 'PHQ-9 Depression Screener',
          subtitle: 'Patient Health Questionnaire for depression screening and severity measurement',
          badge: 'Depression', color: const Color(0xFFA87CC7),
          icon: Icons.mood_outlined,
          url: 'https://www.phqscreeners.com', s: s),
      _ResourceCard(title: 'Beck Depression Inventory',
          subtitle: '21-item self-report inventory measuring the severity of depression',
          badge: 'BDI-II', color: const Color(0xFF658852),
          icon: Icons.assignment_outlined,
          url: 'https://www.pearsonassessments.com', s: s),
      _ResourceCard(title: 'PTSD Checklist (PCL-5)',
          subtitle: '20-item self-report measure that assesses DSM-5 PTSD symptoms',
          badge: 'PTSD', color: const Color(0xFF5C7BD4),
          icon: Icons.health_and_safety_outlined,
          url: 'https://www.ptsd.va.gov/professional/assessment/adult-sr/ptsd-checklist.asp', s: s),
      _ResourceCard(title: 'Y-BOCS Obsession Scale',
          subtitle: 'Yale-Brown Obsessive Compulsive Scale for OCD severity rating',
          badge: 'OCD', color: const Color(0xFFE07B5A),
          icon: Icons.repeat_outlined,
          url: 'https://www.ocdresearch.com', s: s),
    ], s);
  }
}

// ── Worksheets tab ────────────────────────────────────────────────────────────

class _WorksheetsTab extends StatelessWidget {
  final double s;
  const _WorksheetsTab({required this.s});

  @override
  Widget build(BuildContext context) {
    return _tabScroll([
      _ResourceCard(title: 'CBT Thought Record',
          subtitle: 'Automatic thought challenging worksheet for cognitive restructuring sessions',
          badge: 'CBT', color: const Color(0xFF7F89E9),
          icon: Icons.edit_note_rounded,
          url: 'https://psychologytools.com/professional/therapist-resources', s: s),
      _ResourceCard(title: 'Behavioral Activation Log',
          subtitle: 'Activity scheduling and mood monitoring worksheet for depression treatment',
          badge: 'BA', color: const Color(0xFFA87CC7),
          icon: Icons.checklist_rounded,
          url: 'https://psychologytools.com/professional/therapist-resources', s: s),
      _ResourceCard(title: 'Worry Time Worksheet',
          subtitle: 'Structured worry postponement technique for anxiety management',
          badge: 'CBT', color: const Color(0xFF658852),
          icon: Icons.timer_outlined,
          url: 'https://psychologytools.com/professional/therapist-resources', s: s),
      _ResourceCard(title: 'Safety Planning Template',
          subtitle: 'Collaborative crisis safety plan for high-risk patients',
          badge: 'Crisis', color: const Color(0xFFE07B5A),
          icon: Icons.shield_outlined,
          url: 'https://suicidepreventionlifeline.org/help-someone-else', s: s),
      _ResourceCard(title: 'DBT Diary Card',
          subtitle: 'Daily tracking of emotions, urges, behaviors and DBT skills use',
          badge: 'DBT', color: const Color(0xFF5C7BD4),
          icon: Icons.book_outlined,
          url: 'https://behavioraltech.org', s: s),
    ], s);
  }
}

// ── Guides tab ────────────────────────────────────────────────────────────────

class _GuidesTab extends StatelessWidget {
  final double s;
  const _GuidesTab({required this.s});

  @override
  Widget build(BuildContext context) {
    return _tabScroll([
      _ResourceCard(title: 'APA Clinical Practice Guidelines',
          subtitle: 'Evidence-based treatment recommendations for major mental health conditions',
          badge: 'Clinical', color: const Color(0xFF7F89E9),
          icon: Icons.menu_book_rounded,
          url: 'https://www.apa.org/practice/guidelines', s: s),
      _ResourceCard(title: 'NICE Mental Health Pathways',
          subtitle: 'UK National Institute for Health guidelines on mental health treatment',
          badge: 'NICE', color: const Color(0xFFA87CC7),
          icon: Icons.route_outlined,
          url: 'https://www.nice.org.uk/guidance/mental-health', s: s),
      _ResourceCard(title: 'Motivational Interviewing Guide',
          subtitle: 'Core MI skills, techniques, and OARS framework for patient engagement',
          badge: 'MI', color: const Color(0xFF658852),
          icon: Icons.record_voice_over_outlined,
          url: 'https://motivationalinterviewing.org', s: s),
      _ResourceCard(title: 'Trauma-Informed Care Principles',
          subtitle: 'SAMHSA framework and best practices for trauma-sensitive therapy',
          badge: 'Trauma', color: const Color(0xFF5C7BD4),
          icon: Icons.healing_outlined,
          url: 'https://www.samhsa.gov/trauma-violence', s: s),
      _ResourceCard(title: 'Mindfulness-Based Protocols',
          subtitle: 'MBSR and MBCT session scripts, handouts, and guided practices',
          badge: 'MBSR', color: const Color(0xFFE07B5A),
          icon: Icons.self_improvement_outlined,
          url: 'https://www.umassmed.edu/cfm/mindfulness-based-programs', s: s),
    ], s);
  }
}

// ── Podcasts tab ──────────────────────────────────────────────────────────────

class _PodcastsTab extends StatelessWidget {
  final double s;
  const _PodcastsTab({required this.s});

  @override
  Widget build(BuildContext context) {
    return _tabScroll([
      _ResourceCard(title: 'The Shrink Next Door',
          subtitle: 'Compelling stories about the therapy relationship and professional ethics',
          badge: 'Podcast', color: const Color(0xFF7F89E9),
          icon: Icons.headphones_rounded,
          url: 'https://open.spotify.com', s: s),
      _ResourceCard(title: 'Psychologists Off The Clock',
          subtitle: 'Cutting-edge psychology research discussed by practicing clinicians',
          badge: 'Podcast', color: const Color(0xFFA87CC7),
          icon: Icons.headphones_rounded,
          url: 'https://open.spotify.com', s: s),
      _ResourceCard(title: 'The Trauma Therapist Podcast',
          subtitle: 'Interviews with trauma-focused therapists on healing and recovery',
          badge: 'Podcast', color: const Color(0xFF658852),
          icon: Icons.headphones_rounded,
          url: 'https://open.spotify.com', s: s),
      _ResourceCard(title: 'Speaking of Psychology',
          subtitle: "APA's podcast on the latest psychology research and its applications",
          badge: 'APA', color: const Color(0xFF5C7BD4),
          icon: Icons.headphones_rounded,
          url: 'https://www.apa.org/research/action/speaking-of-psychology', s: s),
      _ResourceCard(title: 'Terrible, Thanks for Asking',
          subtitle: 'Honest conversations about grief and emotional pain — useful for patient psychoed',
          badge: 'Podcast', color: const Color(0xFFE07B5A),
          icon: Icons.headphones_rounded,
          url: 'https://open.spotify.com', s: s),
    ], s);
  }
}
