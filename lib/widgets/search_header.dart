import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:mix/mix.dart';

import '../theme/theme.dart';
import 'app_glass_button.dart';

class SearchHeader extends StatefulWidget {
  const SearchHeader({
    super.key,
    this.controller,
    this.onChanged,
    this.onBasketPressed,
  });

  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onBasketPressed;

  static const double barHeight = 56;
  static const double _fieldHeight = TwSpacing.s11;

  static double heightOf(BuildContext context) =>
      MediaQuery.viewPaddingOf(context).top + barHeight;

  @override
  State<SearchHeader> createState() => _SearchHeaderState();
}

class _SearchHeaderState extends State<SearchHeader> {
  static const double _fieldHeight = SearchHeader._fieldHeight;

  TextEditingController? _ownController;

  TextEditingController get _controller =>
      widget.controller ?? (_ownController ??= TextEditingController());

  @override
  void dispose() {
    _ownController?.dispose();
    super.dispose();
  }

  void _clear() {
    _controller.clear();
    widget.onChanged?.call('');
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final topInset = MediaQuery.viewPaddingOf(context).top;

    final barStyle = BoxStyler()
        .color($background())
        .padding(.horizontal($space2()));

    final fieldStyle = BoxStyler()
        .height(_fieldHeight)
        .borderRadius(.all($radiusFull()))
        .color($surfaceMuted())
        .clipBehavior(Clip.antiAlias);

    return Box(
      style: barStyle,
      child: Padding(
        padding: EdgeInsets.only(top: topInset),
        child: SizedBox(
          height: SearchHeader.barHeight,
          child: Row(
            children: [
              Expanded(
                child: Box(
                  style: fieldStyle,
                  child: SearchBar(
                    controller: _controller,
                    onChanged: widget.onChanged,
                    hintText: 'Search',
                    elevation: const WidgetStatePropertyAll(0),
                    overlayColor: const WidgetStatePropertyAll(
                      Colors.transparent,
                    ),
                    backgroundColor: const WidgetStatePropertyAll(
                      Colors.transparent,
                    ),
                    shape: const WidgetStatePropertyAll(
                      RoundedRectangleBorder(),
                    ),
                    constraints: const BoxConstraints(minHeight: _fieldHeight),
                    textStyle: WidgetStatePropertyAll(
                      TextStyle(color: colors.textPrimary, fontSize: 16),
                    ),
                    hintStyle: WidgetStatePropertyAll(
                      TextStyle(color: colors.textSecondary, fontSize: 16),
                    ),
                    leading: HugeIcon(
                      icon: HugeIcons.strokeRoundedSearch01,
                      color: colors.textSecondary,
                      size: 20,
                    ),
                    trailing: [
                      ListenableBuilder(
                        listenable: _controller,
                        builder: (context, _) => _controller.text.isEmpty
                            ? const SizedBox.shrink()
                            : IconButton(
                                onPressed: _clear,
                                visualDensity: VisualDensity.compact,
                                style: IconButton.styleFrom(
                                  overlayColor: Colors.transparent,
                                  splashFactory: NoSplash.splashFactory,
                                ),
                                icon: SvgPicture.asset(
                                  'assets/icons/clear.svg',
                                  width: 20,
                                  height: 20,
                                  colorFilter: ColorFilter.mode(
                                    colors.textSecondary,
                                    BlendMode.srcIn,
                                  ),
                                ),
                              ),
                      ),
                    ],
                    padding: const WidgetStatePropertyAll(
                      EdgeInsets.symmetric(horizontal: TwSpacing.s3),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: TwSpacing.s2),
              AppGlassButton(
                size: _fieldHeight,
                onPressed: widget.onBasketPressed,
                child: SvgPicture.asset(
                  'assets/icons/basket.svg',
                  width: 22,
                  height: 22,
                  colorFilter: const ColorFilter.mode(
                    BrandColors.accent500,
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
