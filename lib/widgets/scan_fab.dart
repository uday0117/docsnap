import 'package:flutter/material.dart';

import '../themes/app_theme.dart';

/// CamScanner-style center scan button embedded in the bottom nav.
class ScanFab extends StatelessWidget {
  final VoidCallback onTap;
  final double size;

  const ScanFab({
    super.key,
    required this.onTap,
    this.size = 58,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      elevation: 0,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Ink(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [AppTheme.primaryLight, AppTheme.primaryColor],
            ),
            border: Border.all(
              color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
              width: 4,
            ),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryColor.withAlpha(isDark ? 110 : 90),
                blurRadius: 14,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Icon(
            Icons.camera_alt_rounded,
            color: Colors.white,
            size: size * 0.46,
          ),
        ),
      ),
    );
  }
}
