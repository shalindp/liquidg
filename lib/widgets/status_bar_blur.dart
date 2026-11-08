import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../theme/theme.dart';

class StatusBarBlur extends StatelessWidget {
  const StatusBarBlur({super.key});

  static const double _zone = 48;
  static const double _sigma = 70;
  static const double _solidBelowInset = 6;
  static const int _steps = 12;

  static List<double> _curve(double hold) => [
    for (var i = 0; i <= _steps; i++) _alphaAt(i / _steps, hold),
  ];

  static double _alphaAt(double t, double hold) {
    if (t <= hold) return 1;
    final x = (t - hold) / (1 - hold);
    final eased = x * x * x * (x * (x * 6 - 15) + 10);
    return 1 - eased;
  }

  static List<double> get _stops => [
    for (var i = 0; i <= _steps; i++) i / _steps,
  ];

  static double heightOf(BuildContext context) =>
      MediaQuery.viewPaddingOf(context).top + _zone;

  @override
  Widget build(BuildContext context) {
    final background = context.colors.background;
    final height = heightOf(context);
    final hold =
        (MediaQuery.viewPaddingOf(context).top + _solidBelowInset) / height;
    final curve = _curve(hold);
    final fade = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      stops: _stops,
      colors: [for (final a in curve) background.withValues(alpha: a)],
    );
    return IgnorePointer(
      child: RepaintBoundary(
        child: SizedBox(
          height: height / 2,
          width: double.infinity,
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (ui.ImageFilter.isShaderFilterSupported)
                ShaderMask(
                  blendMode: BlendMode.dstIn,
                  shaderCallback: (rect) => LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: _stops,
                    colors: [
                      for (final a in curve) Colors.black.withValues(alpha: a),
                    ],
                  ).createShader(rect),
                  child: ClipRect(
                    child: BackdropFilter(
                      filter: ui.ImageFilter.blur(
                        sigmaX: _sigma,
                        sigmaY: _sigma,
                      ),
                      child: const SizedBox.expand(),
                    ),
                  ),
                ),
              DecoratedBox(decoration: BoxDecoration(gradient: fade)),
            ],
          ),
        ),
      ),
    );
  }
}
