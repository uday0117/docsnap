import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../themes/app_theme.dart';
import 'scan_fab.dart';

class AppBottomNav extends StatelessWidget {
  static const _navBarHeight = 56.0;
  static const _fabSize = 58.0;
  static const _fabRise = 22.0;

  final RxInt currentIndexRx;
  final ValueChanged<int> onTabSelected;
  final VoidCallback onScanTap;

  const AppBottomNav({
    super.key,
    required this.currentIndexRx,
    required this.onTabSelected,
    required this.onScanTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF1C1C1E) : Colors.white;
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    final totalHeight = _navBarHeight + bottomInset + _fabRise;

    return Obx(() {
      final currentIndex = currentIndexRx.value;

      return SizedBox(
        height: totalHeight,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.bottomCenter,
          children: [
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: CustomPaint(
                painter: _NavBarNotchPainter(
                  backgroundColor: bgColor,
                  isDark: isDark,
                ),
                child: SizedBox(
                  height: _navBarHeight + bottomInset,
                  child: Padding(
                    padding: EdgeInsets.only(bottom: bottomInset),
                    child: Row(
                      children: [
                        _NavItem(
                          index: 0,
                          currentIndex: currentIndex,
                          icon: Icons.home_outlined,
                          selectedIcon: Icons.home_rounded,
                          label: 'nav_home'.tr,
                          onTap: onTabSelected,
                        ),
                        _NavItem(
                          index: 1,
                          currentIndex: currentIndex,
                          icon: Icons.folder_open_outlined,
                          selectedIcon: Icons.folder_rounded,
                          label: 'nav_documents'.tr,
                          onTap: onTabSelected,
                        ),
                        const SizedBox(width: _fabSize + 8),
                        _NavItem(
                          index: 2,
                          currentIndex: currentIndex,
                          icon: Icons.grid_view_rounded,
                          selectedIcon: Icons.grid_view_rounded,
                          label: 'nav_tools'.tr,
                          onTap: onTabSelected,
                        ),
                        _NavItem(
                          index: 3,
                          currentIndex: currentIndex,
                          icon: Icons.person_outline_rounded,
                          selectedIcon: Icons.person_rounded,
                          label: 'nav_settings'.tr,
                          onTap: onTabSelected,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: _navBarHeight + bottomInset - (_fabSize * 0.52),
              child: Center(
                child: ScanFab(size: _fabSize, onTap: onScanTap),
              ),
            ),
          ],
        ),
      );
    });
  }
}

class _NavBarNotchPainter extends CustomPainter {
  final Color backgroundColor;
  final bool isDark;

  _NavBarNotchPainter({
    required this.backgroundColor,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = backgroundColor;
    final path = Path()..moveTo(0, 0);

    final centerX = size.width / 2;
    const notchRadius = 34.0;
    const notchDepth = 14.0;

    path.lineTo(centerX - notchRadius - 12, 0);
    path.quadraticBezierTo(
      centerX - notchRadius,
      0,
      centerX - notchRadius + 8,
      notchDepth,
    );
    path.arcToPoint(
      Offset(centerX + notchRadius - 8, notchDepth),
      radius: const Radius.circular(notchRadius),
      clockwise: false,
    );
    path.quadraticBezierTo(
      centerX + notchRadius,
      0,
      centerX + notchRadius + 12,
      0,
    );
    path.lineTo(size.width, 0);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawShadow(
      path,
      Colors.black.withAlpha(isDark ? 50 : 25),
      8,
      false,
    );
    canvas.drawPath(path, paint);

    canvas.drawLine(
      Offset(0, 0),
      Offset(size.width, 0),
      Paint()
        ..color = isDark
            ? Colors.white.withAlpha(18)
            : Colors.grey.shade200
        ..strokeWidth = 0.5,
    );
  }

  @override
  bool shouldRepaint(covariant _NavBarNotchPainter oldDelegate) =>
      oldDelegate.backgroundColor != backgroundColor ||
      oldDelegate.isDark != isDark;
}

class _NavItem extends StatelessWidget {
  final int index;
  final int currentIndex;
  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final ValueChanged<int> onTap;

  const _NavItem({
    required this.index,
    required this.currentIndex,
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final selected = currentIndex == index;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final inactiveColor =
        isDark ? Colors.grey.shade500 : const Color(0xFF9E9E9E);
    final color = selected ? AppTheme.primaryColor : inactiveColor;

    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => onTap(index),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                selected ? selectedIcon : icon,
                color: color,
                size: 24,
              ),
              const SizedBox(height: 2),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  color: color,
                  height: 1.1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
