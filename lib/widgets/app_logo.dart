import 'package:flutter/material.dart';

/// App mark: teal tile with document + scan corners.
class AppLogo extends StatelessWidget {
  final double size;
  final bool showShadow;

  const AppLogo({
    super.key,
    this.size = 96,
    this.showShadow = true,
  });

  static const _assetPath = 'assets/icon/app-logo-square.png';

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(size * 0.24),
        boxShadow: showShadow
            ? [
                BoxShadow(
                  color: const Color(0xFF00897B).withAlpha(90),
                  blurRadius: size * 0.28,
                  offset: Offset(0, size * 0.1),
                ),
              ]
            : null,
      ),
      clipBehavior: Clip.antiAlias,
      child: Image.asset(
        _assetPath,
        width: size,
        height: size,
        fit: BoxFit.cover,
      ),
    );
  }
}
