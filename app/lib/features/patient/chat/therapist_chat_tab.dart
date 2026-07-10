import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../therapists/doctor.dart';
import 'therapist_chat_conversation.dart';

class TherapistChatTab extends StatelessWidget {
  const TherapistChatTab({super.key});

  // Chat-preview metadata only — name/initials/image/specialty always come
  // from kAllDoctors (the canonical therapist directory) via doctorId, so
  // they can't drift out of sync with the rest of the app.
  static const List<Map<String, dynamic>> _previews = [
    {
      'doctorId': 'sara_hany',
      'lastMessage': 'Session confirmed tomorrow',
      'time': '2m',
      'unread': 2,
      'color': Color(0xFF7F89E9),
    },
    {
      'doctorId': 'ali_samir',
      'lastMessage': 'How have you been this week?',
      'time': '45m',
      'unread': 0,
      'color': Color(0xFF5C7BD4),
    },
    {
      'doctorId': 'hager_osama',
      'lastMessage': 'I shared resources for you',
      'time': '2h',
      'unread': 0,
      'color': Color(0xFFA87CC7),
    },
    {
      'doctorId': 'kareem_hadidy',
      'lastMessage': 'Great progress today!',
      'time': 'Tue',
      'unread': 0,
      'color': Color(0xFF658852),
    },
  ];

  static Doctor _doctorFor(String id) =>
      kAllDoctors.firstWhere((d) => d.id == id);

  @override
  Widget build(BuildContext context) {
    final s = MediaQuery.of(context).size.width / 430;
    return ListView.separated(
      padding: EdgeInsets.symmetric(horizontal: 17 * s),
      itemCount: _previews.length,
      separatorBuilder: (_, _) => Container(
        height: 1,
        color: const Color(0xFFD2D5DE).withValues(alpha: 0.5),
      ),
      itemBuilder: (ctx, i) {
        final preview = _previews[i];
        final doctor = _doctorFor(preview['doctorId'] as String);
        return _ConversationItem(
          doctor: doctor,
          preview: preview,
          s: s,
          onTap: () => Navigator.push(
            ctx,
            MaterialPageRoute(
              builder: (_) => TherapistChatConversation(
                therapistName: doctor.name,
                specialty: doctor.specialty,
                initials: doctor.initials,
                color: preview['color'] as Color,
                image: doctor.image,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ConversationItem extends StatelessWidget {
  final Doctor doctor;
  final Map<String, dynamic> preview;
  final VoidCallback onTap;
  final double s;

  const _ConversationItem(
      {required this.doctor, required this.preview, required this.onTap, required this.s});

  @override
  Widget build(BuildContext context) {
    final int unread = preview['unread'] as int;
    final Color color = preview['color'] as Color;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        height: 80 * s,
        child: Row(
          children: [
            // Avatar
            Container(
              width: 54 * s,
              height: 54 * s,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.25),
                shape: BoxShape.circle,
              ),
              child: ClipOval(
                child: Image.asset(
                  doctor.image,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => Center(
                    child: Text(
                      doctor.initials,
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 16 * s,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(width: 14 * s),
            // Text content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          doctor.name,
                          style: GoogleFonts.poppins(
                            fontSize: 15.795 * s,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        preview['time'] as String,
                        style: GoogleFonts.poppins(
                          fontSize: 11.282 * s,
                          color: const Color(0xFFD9DEFA),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 2 * s),
                  Text(
                    doctor.specialty,
                    style: GoogleFonts.poppins(
                      fontSize: 12.41 * s,
                      color: const Color(0xFFD9DEFA),
                    ),
                  ),
                  SizedBox(height: 2 * s),
                  Text(
                    preview['lastMessage'] as String,
                    style: GoogleFonts.poppins(
                      fontSize: 12.41 * s,
                      color: const Color(0xFFD9DEFA),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            // Unread badge
            if (unread > 0) ...[
              SizedBox(width: 8 * s),
              Container(
                width: 26 * s,
                height: 26 * s,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '$unread',
                    style: GoogleFonts.poppins(
                      fontSize: 12.41 * s,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF7F89E9),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
