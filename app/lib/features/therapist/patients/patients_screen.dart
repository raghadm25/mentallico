import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/card_with_shadow.dart';
import '../../../services/app_state.dart';
import '../../../services/session_service.dart';
import '../session/session_control_panel.dart';
import 'patient.dart';

class TherapistPatientsScreen extends StatelessWidget {
  const TherapistPatientsScreen({super.key});

  List<TherapistPatient> get _patients => kMockPatients;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(20, 56, 20, 20),
            decoration: const BoxDecoration(
              gradient: AppColors.headerGradient,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(32),
                bottomRight: Radius.circular(32),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'My Patients',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${_patients.length} patients',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Container(
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: TextField(
                    style: GoogleFonts.poppins(fontSize: 13),
                    decoration: InputDecoration(
                      hintText: 'Search patients...',
                      hintStyle: GoogleFonts.poppins(
                          color: AppColors.lightGray, fontSize: 13),
                      prefixIcon: const Icon(Icons.search_rounded,
                          color: AppColors.primary, size: 20),
                      border: InputBorder.none,
                      contentPadding:
                          const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: _patients.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (ctx, i) => _PatientCard(patient: _patients[i], ctx: ctx),
            ),
          ),
        ],
      ),
    );
  }
}

class _PatientCard extends StatelessWidget {
  final TherapistPatient patient;
  final BuildContext ctx;
  const _PatientCard({required this.patient, required this.ctx});

  @override
  Widget build(BuildContext context) {
    final progress = patient.progress;
    return CardWithShadow(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: patient.color.withValues(alpha: 0.15),
                child: Text(
                  patient.initials,
                  style: GoogleFonts.poppins(
                    color: patient.color,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          patient.name,
                          style: GoogleFonts.poppins(
                            color: AppColors.black,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.green.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            patient.status,
                            style: GoogleFonts.poppins(
                              color: AppColors.green,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Text(
                      patient.condition,
                      style: GoogleFonts.poppins(
                        color: AppColors.darkGray,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Progress',
                          style: GoogleFonts.poppins(
                            color: AppColors.darkGray,
                            fontSize: 11,
                          ),
                        ),
                        Text(
                          '${(progress * 100).round()}%',
                          style: GoogleFonts.poppins(
                            color: AppColors.primary,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: progress,
                        backgroundColor:
                            AppColors.primary.withValues(alpha: 0.12),
                        valueColor: const AlwaysStoppedAnimation<Color>(
                            AppColors.primary),
                        minHeight: 6,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.video_call_outlined,
                      color: AppColors.primary, size: 14),
                  const SizedBox(width: 4),
                  Text(
                    '${patient.sessions} sessions',
                    style: GoogleFonts.poppins(
                        color: AppColors.darkGray, fontSize: 11),
                  ),
                  const SizedBox(width: 14),
                  const Icon(Icons.schedule_rounded,
                      color: AppColors.darkGray, size: 14),
                  const SizedBox(width: 4),
                  Text(
                    'Last: ${patient.lastSession}',
                    style: GoogleFonts.poppins(
                        color: AppColors.darkGray, fontSize: 11),
                  ),
                ],
              ),
              Row(
                children: [
                  _ActionIcon(
                      icon: Icons.chat_bubble_outline_rounded,
                      color: AppColors.primary),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () async {
                      final sessionId = await SessionService.createSession(
                        patientName: patient.name,
                        therapistName: AppState.instance.userName,
                      );
                      if (ctx.mounted) {
                        Navigator.push(
                          ctx,
                          MaterialPageRoute(
                            builder: (_) => SessionControlPanel(
                              sessionId: sessionId,
                              patientName: patient.name,
                              patientInitials: patient.initials,
                              patientColor: patient.color,
                              sessionType: patient.condition,
                            ),
                          ),
                        );
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.play_arrow_rounded,
                              color: Colors.white, size: 14),
                          const SizedBox(width: 4),
                          Text(
                            'Start Session',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActionIcon extends StatelessWidget {
  final IconData icon;
  final Color color;
  const _ActionIcon({required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, color: color, size: 16),
    );
  }
}
