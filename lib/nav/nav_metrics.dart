import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import '../theme/theme.dart';

abstract final class NavMetrics {
  static const double height = 68;

  static double bottomOf(BuildContext context) => math.max(
    TwSpacing.s2,
    MediaQuery.viewPaddingOf(context).bottom + TwSpacing.s2 - TwSpacing.s4,
  );

  static double clearanceOf(BuildContext context) =>
      bottomOf(context) + height + TwSpacing.s3;
}
