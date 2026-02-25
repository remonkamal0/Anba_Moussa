import 'package:flutter/material.dart';

/// Breakpoints:
///   Mobile  : width < 600
///   Tablet  : 600 ≤ width < 1024
///   Desktop : width ≥ 1024
class Responsive {
  // ── Breakpoint checks ─────────────────────────────────────────────────────
  static bool isMobile(BuildContext context) =>
      MediaQuery.sizeOf(context).width < 600;

  static bool isTablet(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    return w >= 600 && w < 1024;
  }

  static bool isDesktop(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= 1024;

  // ── Generic value picker ───────────────────────────────────────────────────
  /// Returns [mobile] on phones, [tablet] on tablets, [desktop] on desktops.
  /// Falls back to [mobile] if [tablet]/[desktop] are null.
  static T value<T>(
    BuildContext context, {
    required T mobile,
    T? tablet,
    T? desktop,
  }) {
    final w = MediaQuery.sizeOf(context).width;
    if (w >= 1024) return desktop ?? tablet ?? mobile;
    if (w >= 600)  return tablet ?? mobile;
    return mobile;
  }

  // ── Common responsive values ───────────────────────────────────────────────

  /// Grid column count: 2 → mobile, 3 → tablet, 4 → desktop
  static int gridColumns(BuildContext context) =>
      value(context, mobile: 2, tablet: 3, desktop: 4);

  /// Horizontal page padding
  static double pagePadding(BuildContext context) =>
      value(context, mobile: 16.0, tablet: 32.0, desktop: 64.0);

  /// Max content width (for centering on wide screens)
  static double maxContentWidth(BuildContext context) =>
      value(context, mobile: double.infinity, tablet: 680.0, desktop: 900.0);

  /// Wraps [child] with a centred, max-width constraint on tablet/desktop
  static Widget constrain(BuildContext context, Widget child) {
    final max = maxContentWidth(context);
    if (max == double.infinity) return child;
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: max),
        child: child,
      ),
    );
  }
}
