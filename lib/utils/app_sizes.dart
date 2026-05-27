import 'package:flutter/material.dart';

class AppSizes {
  AppSizes._();

  static const double radiusXs = 4;
  static const double radiusSm = 8;
  static const double radiusMd = 12;
  static const double radiusLg = 16;
  static const double radiusXl = 24;
  static const double radiusFull = 999;

  static const double paddingXs = 4;
  static const double paddingSm = 8;
  static const double paddingMd = 16;
  static const double paddingLg = 24;
  static const double paddingXl = 32;

  static const double iconSm = 18;
  static const double iconMd = 24;
  static const double iconLg = 32;
  static const double iconXl = 48;

  static const double buttonHeight = 52;
  static const double appBarHeight = 56;
  static const double bottomNavHeight = 64;
  static const double cardElevation = 2;

  static double screenWidth(BuildContext context) =>
      MediaQuery.of(context).size.width;
  static double screenHeight(BuildContext context) =>
      MediaQuery.of(context).size.height;

  static bool isMobile(BuildContext context) => screenWidth(context) < 600;
  static bool isTablet(BuildContext context) =>
      screenWidth(context) >= 600 && screenWidth(context) < 1024;
  static bool isDesktop(BuildContext context) => screenWidth(context) >= 1024;

  static int gridCrossAxisCount(BuildContext context) {
    final width = screenWidth(context);
    if (width >= 1024) return 4;
    if (width >= 600) return 3;
    return 2;
  }
}
