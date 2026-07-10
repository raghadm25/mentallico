import 'package:flutter/material.dart';

/// Mock patient roster shared by the Patients and Messages screens, so the
/// same name/initials/color show up consistently in both places instead of
/// each screen inventing its own disconnected fake roster.
class TherapistPatient {
  final String name;
  final String condition;
  final int sessions;
  final double progress;
  final String initials;
  final Color color;
  final String lastSession;
  final String status;
  final bool online;
  final String lastMessage;
  final String messageTime;
  final int unread;

  const TherapistPatient({
    required this.name,
    required this.condition,
    required this.sessions,
    required this.progress,
    required this.initials,
    required this.color,
    required this.lastSession,
    required this.status,
    required this.online,
    required this.lastMessage,
    required this.messageTime,
    required this.unread,
  });
}

const kMockPatients = <TherapistPatient>[
  TherapistPatient(
    name: 'Alex Johnson',
    condition: 'Anxiety Disorder',
    sessions: 12,
    progress: 0.75,
    initials: 'AJ',
    color: Color(0xFF7F89E9),
    lastSession: '2 days ago',
    status: 'Active',
    online: true,
    lastMessage: 'Thank you for the session today!',
    messageTime: '2m ago',
    unread: 1,
  ),
  TherapistPatient(
    name: 'Maya Brown',
    condition: 'Depression',
    sessions: 8,
    progress: 0.55,
    initials: 'MB',
    color: Color(0xFFA87CC7),
    lastSession: 'Today',
    status: 'Active',
    online: true,
    lastMessage: 'I\'ve been practicing the breathing exercises.',
    messageTime: '30m ago',
    unread: 0,
  ),
  TherapistPatient(
    name: 'Omar Hassan',
    condition: 'Stress & Burnout',
    sessions: 5,
    progress: 0.40,
    initials: 'OH',
    color: Color(0xFF658852),
    lastSession: '1 week ago',
    status: 'Active',
    online: false,
    lastMessage: 'Can we reschedule Thursday\'s session?',
    messageTime: '2h ago',
    unread: 2,
  ),
  TherapistPatient(
    name: 'Lena Kim',
    condition: 'Social Anxiety',
    sessions: 20,
    progress: 0.88,
    initials: 'LK',
    color: Color(0xFF5C7BD4),
    lastSession: 'Yesterday',
    status: 'Active',
    online: false,
    lastMessage: 'Feeling much better this week 😊',
    messageTime: 'Yesterday',
    unread: 0,
  ),
  TherapistPatient(
    name: 'Tariq Mansour',
    condition: 'PTSD',
    sessions: 15,
    progress: 0.62,
    initials: 'TM',
    color: Color(0xFFE07B5A),
    lastSession: '3 days ago',
    status: 'Active',
    online: false,
    lastMessage: 'The journal exercise is really helping.',
    messageTime: '2 days',
    unread: 0,
  ),
];
