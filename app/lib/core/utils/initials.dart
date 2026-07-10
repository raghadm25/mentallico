/// Returns up to 2 uppercase initials derived from a display name.
String initialsFor(String name) {
  final parts = name.trim().split(' ').where((p) => p.isNotEmpty).toList();
  if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  if (parts.length == 1) {
    return parts[0].substring(0, parts[0].length.clamp(0, 2)).toUpperCase();
  }
  return '??';
}
