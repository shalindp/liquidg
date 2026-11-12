import 'package:flutter/material.dart';
import 'package:liquid_glass_easy/liquid_glass_easy.dart';
import 'package:styled_widget/styled_widget.dart';

import '../theme/theme.dart';
import 'app_header.dart';
import 'quick_filters.dart';

class CollapsingHeader extends StatefulWidget {
  const CollapsingHeader({
    super.key,
    required this.collapsed,
    required this.onExpand,
    this.onBarcodeScanPressed,
    this.onBasketPressed,
    this.onChanged,
    this.controller,
  });

  final bool collapsed;
  final VoidCallback onExpand;
  final VoidCallback? onBarcodeScanPressed;
  final VoidCallback? onBasketPressed;
  final ValueChanged<String>? onChanged;
  final TextEditingController? controller;

  static const double controlSize = AppHeader.controlSize;
  static const double height = AppHeader.height;
  static const double fieldHeight = AppHeader.fieldHeight;
  static const double gutter = AppHeader.gutter;
  static const double gap = AppHeader.gap;
  static const Duration collapseDuration = Duration(milliseconds: 160);

  static const double filterBarExtent =
      TwSpacing.s1 + QuickFilters.extent + ProductsCountRow.height;

  static double heightOf(BuildContext context) =>
      AppHeader.heightOf(context) + filterBarExtent;

  @override
  State<CollapsingHeader> createState() => _CollapsingHeaderState();
}

class _CollapsingHeaderState extends State<CollapsingHeader> {
  static const double _button = CollapsingHeader.height;

  late final TextEditingController _controller =
      widget.controller ?? TextEditingController();
  final _focus = FocusNode();

  @override
  void didUpdateWidget(CollapsingHeader oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.collapsed && !oldWidget.collapsed) _focus.unfocus();
  }

  @override
  void dispose() {
    if (widget.controller == null) _controller.dispose();
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
    final collapsed = widget.collapsed;
    final header = AppHeader(
      collapsed: collapsed,
      controller: _controller,
      focusNode: _focus,
      onBarcodeScanPressed: widget.onBarcodeScanPressed,
      onBasketPressed: widget.onBasketPressed,
      onChanged: widget.onChanged,
      overlay:
          IgnorePointer(
            ignoring: !collapsed,
            child: LiquidGlassMorph(
              opacity: collapsed ? 1 : 0,
              style: AppGlass.foldedStyle(Theme.brightnessOf(context)),
              child: _Island(
                onSearch: _openSearch,
                onBasket: widget.onBasketPressed,
              ),
            ),
          ).positioned(
            right: CollapsingHeader.gutter,
            top: 0,
            width: _button * 2,
            height: CollapsingHeader.height,
          ),
    );
    return SizedBox(
      width: MediaQuery.sizeOf(context).width,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          header,
          const SizedBox(height: TwSpacing.s1),
          IgnorePointer(
            ignoring: collapsed,
            child: Opacity(
              opacity: collapsed ? 0 : 1,
              child: const Column(
                children: [QuickFilters(), ProductsCountRow()],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Island extends StatelessWidget {
  const _Island({required this.onSearch, required this.onBasket});

  final VoidCallback onSearch;
  final VoidCallback? onBasket;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const HeaderSearchIcon()
            .center()
            .gestures(onTap: onSearch, behavior: HitTestBehavior.opaque)
            .expanded(),
        HeaderBasketIcon(color: BrandColors.accent500)
            .center()
            .gestures(onTap: onBasket, behavior: HitTestBehavior.opaque)
            .expanded(),
      ],
    ).constrained(
      width: CollapsingHeader.height * 2,
      height: CollapsingHeader.height,
    );
  }
}
