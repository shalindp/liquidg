import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:liquid_glass_easy/liquid_glass_easy.dart';
import 'package:mix/mix.dart';

import '../theme/theme.dart';
import 'app_glass_button.dart';

class CollapsingHeader extends StatefulWidget {
  const CollapsingHeader({
    super.key,
    required this.collapsed,
    required this.onExpand,
    this.onMenuPressed,
    this.onBasketPressed,
    this.onChanged,
  });

  final bool collapsed;
  final VoidCallback onExpand;
  final VoidCallback? onMenuPressed;
  final VoidCallback? onBasketPressed;
  final ValueChanged<String>? onChanged;

  static const double controlSize = TwSpacing.s12;
  static const double height = controlSize;
  static const double fieldHeight = TwSpacing.s11;
  static const double gutter = TwSpacing.s4;
  static const double gap = TwSpacing.s2;
  static const Duration collapseDuration = Duration(milliseconds: 160);

  static double heightOf(BuildContext context) =>
      MediaQuery.viewPaddingOf(context).top + height + TwSpacing.s2;

  @override
  State<CollapsingHeader> createState() => _CollapsingHeaderState();
}

class _CollapsingHeaderState extends State<CollapsingHeader> {
  static const double _button = CollapsingHeader.height;
  static const double _side =
      CollapsingHeader.gutter + _button + CollapsingHeader.gap;

  final _controller = TextEditingController();
  final _focus = FocusNode();

  @override
  void didUpdateWidget(CollapsingHeader oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.collapsed && !oldWidget.collapsed) _focus.unfocus();
  }

  @override
  void dispose() {
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _openSearch() {
    widget.onExpand();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _focus.requestFocus();
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final width = MediaQuery.sizeOf(context).width;
    final collapsed = widget.collapsed;
    final fieldBox = width - _side - CollapsingHeader.gutter;
    final searchWidth = fieldBox - _button - CollapsingHeader.gap;
    final fieldStyle = BoxStyler()
        .height(CollapsingHeader.fieldHeight)
        .borderRadius(.all($radiusFull()))
        .color($surfaceMuted())
        .clipBehavior(Clip.antiAlias);

    return SizedBox(
      width: width,
      height: CollapsingHeader.height,
      child: Stack(
        children: [
          Positioned(
            left: CollapsingHeader.gutter,
            top: 0,
            child: AppGlassButton(
              size: _button,
              onPressed: widget.onMenuPressed,
              child: HugeIcon(
                icon: HugeIcons.strokeRoundedMenu01,
                color: colors.textPrimary,
                size: 22,
              ),
            ),
          ),
          Positioned(
            right: CollapsingHeader.gutter,
            top: 0,
            child: AppGlassButton(
              size: _button,
              visible: !collapsed,
              onPressed: widget.onBasketPressed,
              child: _Basket(color: BrandColors.accent500),
            ),
          ),
          Positioned(
            left: _side,
            right: _side,
            top: 0,
            height: CollapsingHeader.height,
            child: Visibility(
              visible: !collapsed,
              maintainState: true,
              child: Center(
                child: Box(
                  style: fieldStyle,
                  child: _SearchField(
                    width: searchWidth,
                    controller: _controller,
                    focusNode: _focus,
                    onChanged: widget.onChanged,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            right: CollapsingHeader.gutter,
            top: 0,
            width: _button * 2,
            height: CollapsingHeader.height,
            child: IgnorePointer(
              ignoring: !collapsed,
              child: LiquidGlassMorph(
                opacity: collapsed ? 1 : 0,
                style: AppGlass.style(Theme.brightnessOf(context))
                    .copyWith(blur: 12),
                child: _Island(
                  onSearch: _openSearch,
                  onBasket: widget.onBasketPressed,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Basket extends StatelessWidget {
  const _Basket({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      'assets/icons/basket.svg',
      width: 22,
      height: 22,
      colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
    );
  }
}

class _SearchIcon extends StatelessWidget {
  const _SearchIcon();

  @override
  Widget build(BuildContext context) {
    return HugeIcon(
      icon: HugeIcons.strokeRoundedSearch01,
      color: context.colors.textSecondary,
      size: 20,
    );
  }
}

class _Island extends StatelessWidget {
  const _Island({required this.onSearch, required this.onBasket});

  final VoidCallback onSearch;
  final VoidCallback? onBasket;

  @override
  Widget build(BuildContext context) {
    const size = CollapsingHeader.height;
    return SizedBox(
      width: size * 2,
      height: size,
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onSearch,
              child: const Center(child: _SearchIcon()),
            ),
          ),
          Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onBasket,
              child: Center(child: _Basket(color: BrandColors.accent500)),
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({
    required this.width,
    required this.controller,
    required this.focusNode,
    required this.onChanged,
  });

  final double width;
  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return SizedBox(
      width: width,
      height: CollapsingHeader.fieldHeight,
      child: SearchBar(
        controller: controller,
        focusNode: focusNode,
        onChanged: onChanged,
        hintText: 'Search',
        elevation: const WidgetStatePropertyAll(0),
        overlayColor: const WidgetStatePropertyAll(Colors.transparent),
        backgroundColor: const WidgetStatePropertyAll(Colors.transparent),
        shape: const WidgetStatePropertyAll(RoundedRectangleBorder()),
        constraints: const BoxConstraints(
          minHeight: CollapsingHeader.fieldHeight,
        ),
        textStyle: WidgetStatePropertyAll(
          TextStyle(color: colors.textPrimary, fontSize: 16),
        ),
        hintStyle: WidgetStatePropertyAll(
          TextStyle(color: colors.textSecondary, fontSize: 16),
        ),
        leading: const _SearchIcon(),
        trailing: [
          ListenableBuilder(
            listenable: controller,
            builder: (context, _) => controller.text.isEmpty
                ? const SizedBox.shrink()
                : IconButton(
                    onPressed: () {
                      controller.clear();
                      onChanged?.call('');
                    },
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
    );
  }
}
