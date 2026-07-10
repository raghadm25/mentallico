import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/initials.dart';
import '../../../core/widgets/card_with_shadow.dart';
import '../../../core/widgets/user_avatar.dart';
import '../../../services/app_state.dart';
import '../../../services/session_service.dart';
import '../session/session_control_panel.dart';

class TherapistDashboardScreen extends StatefulWidget {
  const TherapistDashboardScreen({super.key});

  @override
  State<TherapistDashboardScreen> createState() => _TherapistDashboardScreenState();
}

class _TherapistDashboardScreenState extends State<TherapistDashboardScreen> {
  bool _opening = false;

  String get _therapistName => AppState.instance.userName;

  Future<void> _openSession() async {
    if (_opening) return;
    setState(() => _opening = true);
    try {
      final sessionId = await SessionService.createSession(therapistName: _therapistName);
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => SessionControlPanel(
            sessionId: sessionId,
            patientName: 'Waiting for patient…',
            patientInitials: '?',
            patientColor: const Color(0xFF7F89E9),
            sessionType: 'VR Session',
          ),
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not open session: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _opening = false);
    }
  }

  void _enterSession(String sessionId, String patientName, String patientId) {
    final initials = initialsFor(patientName.isEmpty ? '?' : patientName);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SessionControlPanel(
          sessionId: sessionId,
          patientName: patientName.isEmpty ? 'Patient' : patientName,
          patientInitials: initials,
          patientColor: const Color(0xFFA87CC7),
          sessionType: 'VR Session',
          patientId: patientId,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStatsRow(),
                  const SizedBox(height: 20),

                  // ── Open VR Session button ────────────────────────────────
                  GestureDetector(
                    onTap: _opening ? null : _openSession,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.35),
                            blurRadius: 12, offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (_opening)
                            const SizedBox(
                              width: 20, height: 20,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2),
                            )
                          else ...[
                            const Icon(Icons.view_in_ar_rounded,
                                color: Colors.white, size: 22),
                            const SizedBox(width: 10),
                            Text('Open VR Session',
                                style: GoogleFonts.poppins(
                                    color: Colors.white, fontSize: 16,
                                    fontWeight: FontWeight.w700)),
                          ],
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ── Live sessions ─────────────────────────────────────────
                  _buildSectionTitle('My Sessions'),
                  const SizedBox(height: 12),
                  _buildSessionList(),

                  const SizedBox(height: 20),
                  _buildSectionTitle('Weekly Overview'),
                  const SizedBox(height: 12),
                  _buildWeeklyChart(),
                  const SizedBox(height: 20),
                  _buildSectionTitle('Recent Activity'),
                  const SizedBox(height: 12),
                  _buildActivityItem(
                    icon: Icons.check_circle_outline_rounded,
                    text: 'Session flow active — patients can now join live',
                    time: 'Now',
                    color: AppColors.green,
                  ),
                  _buildActivityItem(
                    icon: Icons.note_add_outlined,
                    text: 'Open a VR session above to start connecting',
                    time: '',
                    color: AppColors.primary,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 56, 20, 24),
      decoration: const BoxDecoration(
        gradient: AppColors.headerGradient,
        borderRadius: BorderRadius.only(
          bottomLeft:  Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Dashboard',
                  style: GoogleFonts.poppins(
                      color: Colors.white.withValues(alpha: 0.85), fontSize: 13)),
              Text(_therapistName,
                  style: GoogleFonts.poppins(
                      color: Colors.white, fontSize: 22, fontWeight: FontWeight.w700)),
            ],
          ),
          UserAvatar(
            radius: 24,
            backgroundColor: Colors.white.withValues(alpha: 0.25),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            value: '—', label: 'Sessions\nToday',
            icon: Icons.calendar_today_outlined, color: AppColors.primary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            value: '—', label: 'Total\nPatients',
            icon: Icons.people_outline_rounded, color: AppColors.secondary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            value: '—', label: 'Avg\nRating',
            icon: Icons.star_outline_rounded, color: const Color(0xFFFFC107),
          ),
        ),
      ],
    );
  }

  Widget _buildSessionList() {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: SessionService.myTherapistSessionsStream(),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: CircularProgressIndicator(color: AppColors.primary, strokeWidth: 2),
            ),
          );
        }

        final all = snap.data?.docs ?? [];
        final sessions = all.where((d) {
          final status = d.data()['status'] as String? ?? '';
          return status == 'therapist_ready' || status == 'active';
        }).toList()
          ..sort((a, b) {
            final ta = (a.data()['createdAt'] as Timestamp?)?.millisecondsSinceEpoch ?? 0;
            final tb = (b.data()['createdAt'] as Timestamp?)?.millisecondsSinceEpoch ?? 0;
            return tb.compareTo(ta);
          });

        if (sessions.isEmpty) {
          return CardWithShadow(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const Icon(Icons.video_call_outlined,
                    color: Color(0xFFBBBBBB), size: 42),
                const SizedBox(height: 10),
                Text('No active sessions.\nTap "Open VR Session" above to start one.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                        color: AppColors.darkGray, fontSize: 13, height: 1.4)),
              ],
            ),
          );
        }

        return Column(
          children: sessions.map((doc) {
            final data       = doc.data();
            final status     = data['status'] as String? ?? '';
            final patientName = data['patientName'] as String? ?? '';
            final patientId  = data['patientId'] as String? ?? '';
            final isActive   = status == 'active';
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _SessionCard(
                sessionId:   doc.id,
                patientName: patientName,
                isActive:    isActive,
                onEnter:     () => _enterSession(doc.id, patientName, patientId),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(title,
        style: GoogleFonts.poppins(
            color: AppColors.black, fontSize: 16, fontWeight: FontWeight.w700));
  }

  Widget _buildWeeklyChart() {
    const days     = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    const sessions = [3, 4, 2, 5, 3, 1, 0];
    return CardWithShadow(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(7, (i) {
          return Column(
            children: [
              SizedBox(
                width: 32, height: 80,
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    width: 32,
                    height: sessions[i] == 0 ? 4 : 80.0 * sessions[i] / 5,
                    decoration: BoxDecoration(
                      gradient: sessions[i] > 0
                          ? AppColors.primaryGradient
                          : const LinearGradient(
                              colors: [AppColors.lightGray, AppColors.lightGray]),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Text(days[i],
                  style: GoogleFonts.poppins(color: AppColors.darkGray, fontSize: 10)),
              Text('${sessions[i]}',
                  style: GoogleFonts.poppins(
                      color: AppColors.primary, fontSize: 10, fontWeight: FontWeight.w600)),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildActivityItem({
    required IconData icon,
    required String text,
    required String time,
    required Color color,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: CardWithShadow(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(text,
                  style: GoogleFonts.poppins(color: AppColors.black, fontSize: 13)),
            ),
            if (time.isNotEmpty)
              Text(time,
                  style: GoogleFonts.poppins(color: AppColors.darkGray, fontSize: 11)),
          ],
        ),
      ),
    );
  }
}

// ── Session card ──────────────────────────────────────────────────────────────

class _SessionCard extends StatelessWidget {
  final String sessionId;
  final String patientName;
  final bool isActive;
  final VoidCallback onEnter;

  const _SessionCard({
    required this.sessionId,
    required this.patientName,
    required this.isActive,
    required this.onEnter,
  });

  @override
  Widget build(BuildContext context) {
    final display  = patientName.isEmpty ? 'Waiting for patient…' : patientName;
    final initials = patientName.isEmpty ? '?' : initialsFor(patientName);

    return CardWithShadow(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: (isActive ? AppColors.green : AppColors.primary)
                .withValues(alpha: 0.12),
            child: Text(initials,
                style: GoogleFonts.poppins(
                    color: isActive ? AppColors.green : AppColors.primary,
                    fontWeight: FontWeight.w700, fontSize: 13)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(display,
                    style: GoogleFonts.poppins(
                        color: AppColors.black, fontSize: 14, fontWeight: FontWeight.w600)),
                Row(
                  children: [
                    Container(
                      width: 7, height: 7,
                      decoration: BoxDecoration(
                        color: isActive
                            ? const Color(0xFF4CAF50)
                            : const Color(0xFFFFA726),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      isActive ? 'Patient connected — Live' : 'Open — Waiting for patient',
                      style: GoogleFonts.poppins(fontSize: 11, color: AppColors.darkGray),
                    ),
                  ],
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: onEnter,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(isActive ? 'Enter' : 'Open',
                  style: GoogleFonts.poppins(
                      color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Stat card ─────────────────────────────────────────────────────────────────

class _StatCard extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.value, required this.label,
    required this.icon,  required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return CardWithShadow(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(height: 10),
          Text(value,
              style: GoogleFonts.poppins(
                  color: AppColors.black, fontSize: 22, fontWeight: FontWeight.w700)),
          Text(label,
              style: GoogleFonts.poppins(
                  color: AppColors.darkGray, fontSize: 11, height: 1.3)),
        ],
      ),
    );
  }
}
