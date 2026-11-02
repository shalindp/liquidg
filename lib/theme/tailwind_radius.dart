// Tailwind v4 border-radius scale. Source: tailwindcss.com/docs/border-radius

/// Tailwind radii in logical pixels.
abstract final class TwRadius {
  static const double none = 0;
  static const double xs = 2;
  static const double sm = 4;
  static const double md = 6;
  static const double lg = 8;
  static const double xl = 12;
  static const double xl2 = 16;
  static const double xl3 = 24;
  static const double xl4 = 32;

  /// Tailwind `rounded-full` is `calc(infinity * 1px)`; this is a large
  /// finite stand-in that renders as a pill/circle.
  static const double full = 9999;
}
