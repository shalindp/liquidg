import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../models/supermarket.dart';

class SupermarketLogo extends StatelessWidget {
  const SupermarketLogo({super.key, required this.chain, required this.size});

  final Supermarket chain;
  final double size;

  @override
  Widget build(BuildContext context) {
    final asset = chain.logoAsset;
    final inner = size * chain.logoScale;
    final logo = asset.endsWith('.svg')
        ? SvgPicture.asset(asset, width: inner, height: inner)
        : Image.asset(
            asset,
            width: inner,
            height: inner,
            fit: BoxFit.contain,
            filterQuality: FilterQuality.medium,
          );
    return SizedBox(
      width: size,
      height: size,
      child: Center(child: logo),
    );
  }
}
