import 'package:flutter/material.dart';

class Responsive {
  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < 600;

  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= 600 &&
      MediaQuery.of(context).size.width < 1100;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= 1100;

  static double padding(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width >= 1100) return 64;
    if (width >= 600) return 32;
    return 16;
  }

  static double maxContentWidth(BuildContext context) {
    if (isMobile(context)) return double.infinity;
    return 900;
  }
}

class ResponsiveBuilder extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;

  const ResponsiveBuilder({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
  });

  @override
  Widget build(BuildContext context) {
    if (Responsive.isDesktop(context) && desktop != null) return desktop!;
    if (Responsive.isTablet(context) && tablet != null) return tablet!;
    return mobile;
  }
}
