import 'package:flutter/material.dart';
import '../../services/app_state.dart';
import '../../services/auth_service.dart';
import '../theme/app_colors.dart';
import '../utils/initials.dart';

/// Shows the signed-in user's real Google profile photo when available,
/// otherwise a colored circle with their initials. Used wherever the app
/// previously showed a static placeholder avatar image.
class UserAvatar extends StatelessWidget {
  final double radius;
  final double borderWidth;
  final Color? borderColor;
  final Color? backgroundColor;
  final Color? textColor;
  final double? fontSize;

  const UserAvatar({
    super.key,
    required this.radius,
    this.borderWidth = 0,
    this.borderColor,
    this.backgroundColor,
    this.textColor,
    this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    final photoUrl = AuthService.currentUser?.photoURL;
    final initials = initialsFor(AppState.instance.userName);
    final size = radius * 2;

    final fallback = Container(
      color: backgroundColor ?? AppColors.primary,
      alignment: Alignment.center,
      child: Text(
        initials,
        style: TextStyle(
          color: textColor ?? Colors.white,
          fontWeight: FontWeight.w700,
          fontSize: fontSize ?? radius * 0.6,
        ),
      ),
    );

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: borderWidth > 0
            ? Border.all(
                color: borderColor ?? Colors.white, width: borderWidth)
            : null,
      ),
      child: ClipOval(
        child: (photoUrl != null && photoUrl.isNotEmpty)
            ? Image.network(
                photoUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => fallback,
              )
            : fallback,
      ),
    );
  }
}
