import 'package:flutter/material.dart';

enum RiskLevel { none, low, moderate, high }

extension RiskLevelX on RiskLevel {
  String get label => const ['No Risk', 'Low Risk', 'Moderate Risk', 'HIGH RISK'][index];

  Color get color => const [
        Color(0xFF658852),
        Color(0xFF8BC34A),
        Color(0xFFFFA726),
        Color(0xFFE53935),
      ][index];

  IconData get icon => const [
        Icons.check_circle_outline,
        Icons.info_outline,
        Icons.warning_amber_outlined,
        Icons.error_outline,
      ][index];
}

class MoodResult {
  final String primaryMood;
  final int intensity;
  final List<String> indicators;
  final RiskLevel riskLevel;
  final List<String> riskFlags;
  final List<String> themes;
  final String clinicalNote;

  const MoodResult({
    required this.primaryMood,
    required this.intensity,
    required this.indicators,
    required this.riskLevel,
    required this.riskFlags,
    required this.themes,
    required this.clinicalNote,
  });

  factory MoodResult.fromJson(Map<String, dynamic> json) => MoodResult(
        primaryMood: (json['primaryMood'] as String?)?.toLowerCase() ?? 'neutral',
        intensity: (json['intensity'] as num?)?.toInt().clamp(0, 10) ?? 5,
        indicators: List<String>.from(json['mentalHealthIndicators'] as List? ?? []),
        riskLevel: _parseRisk(json['riskLevel'] as String?),
        riskFlags: List<String>.from(json['riskFlags'] as List? ?? []),
        themes: List<String>.from(json['themes'] as List? ?? []),
        clinicalNote: json['clinicalNote'] as String? ?? '',
      );

  static RiskLevel _parseRisk(String? s) {
    switch (s?.toLowerCase()) {
      case 'low':
        return RiskLevel.low;
      case 'moderate':
        return RiskLevel.moderate;
      case 'high':
        return RiskLevel.high;
      default:
        return RiskLevel.none;
    }
  }

  String get emoji {
    switch (primaryMood) {
      case 'anxious':
        return '😰';
      case 'depressed':
        return '😞';
      case 'hopeful':
        return '🌟';
      case 'frustrated':
        return '😤';
      case 'sad':
        return '😢';
      case 'calm':
        return '😊';
      case 'confused':
        return '😕';
      case 'resistant':
        return '😡';
      case 'reflective':
        return '🤔';
      case 'distressed':
        return '😣';
      default:
        return '😐';
    }
  }

  /// Best-effort mapping onto the app's 5-face mood scale
  /// (0=Angry, 1=Sad, 2=Neutral, 3=Happy, 4=Amazing), so a session's AI mood
  /// analysis can be recorded on the same Mood Tracker the patient uses.
  /// Risk takes priority over the mood word since it's the more clinically
  /// salient signal.
  int get faceIndex {
    if (riskLevel.index >= RiskLevel.moderate.index) return 0;
    switch (primaryMood) {
      case 'hopeful':
        return 4;
      case 'calm':
        return 3;
      case 'sad':
      case 'depressed':
        return 1;
      case 'anxious':
      case 'distressed':
      case 'frustrated':
      case 'resistant':
        return 0;
      case 'reflective':
      case 'confused':
      default:
        return 2;
    }
  }

  Color get color {
    switch (primaryMood) {
      case 'anxious':
        return const Color(0xFF7F89E9);
      case 'depressed':
        return const Color(0xFF5C7BD4);
      case 'hopeful':
        return const Color(0xFF658852);
      case 'frustrated':
        return const Color(0xFFE07B5A);
      case 'sad':
        return const Color(0xFF5C7BD4);
      case 'calm':
        return const Color(0xFF658852);
      case 'confused':
        return const Color(0xFFA87CC7);
      case 'resistant':
        return const Color(0xFFE53935);
      case 'reflective':
        return const Color(0xFF50B8A8);
      case 'distressed':
        return const Color(0xFFE53935);
      default:
        return const Color(0xFF9E9E9E);
    }
  }
}

class PatientEntry {
  final String id;
  final String text;
  final DateTime timestamp;
  final MoodResult? mood;
  final bool isAnalyzing;

  const PatientEntry({
    required this.id,
    required this.text,
    required this.timestamp,
    this.mood,
    this.isAnalyzing = false,
  });

  PatientEntry copyWith({MoodResult? mood, bool? isAnalyzing}) => PatientEntry(
        id: id,
        text: text,
        timestamp: timestamp,
        mood: mood ?? this.mood,
        isAnalyzing: isAnalyzing ?? this.isAnalyzing,
      );
}
