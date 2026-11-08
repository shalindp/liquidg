import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:signals_flutter/signals_flutter.dart';
import 'package:styled_widget/styled_widget.dart';

import '../service_locator.dart';
import '../services/products_screen_service.dart';
import '../theme/theme.dart';
import 'app_glass_button.dart';

class AppHeader extends StatefulWidget {
  const AppHeader({
    super.key,
    this.collapsed = false,
    this.showActions = true,
    this.hintText = 'Search',
    this.onBarcodeScanPressed,
    this.onBasketPressed,
    this.onChanged,
    this.onFocusChanged,
    this.controller,
    this.focusNode,
    this.overlay,
  });

  final bool collapsed;
  final bool showActions;
  final String hintText;
  final VoidCallback? onBarcodeScanPressed;
  final VoidCallback? onBasketPressed;
  final ValueChanged<String>? onChanged;
  final ValueChanged<bool>? onFocusChanged;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final Widget? overlay;

  static const double controlSize = TwSpacing.s12;
  static const double height = controlSize;
  static const double fieldHeight = TwSpacing.s11;
  static const double gutter = TwSpacing.s4;
  static const double gap = TwSpacing.s2;

  static double heightOf(BuildContext context) =>
      MediaQuery.viewPaddingOf(context).top + height + TwSpacing.s2;

  @override
  State<AppHeader> createState() => _AppHeaderState();
}

class _AppHeaderState extends State<AppHeader> {
  static const double _button = AppHeader.height;
  static const double _side = AppHeader.gutter + _button + AppHeader.gap;

  TextEditingController? _ownedController;
  FocusNode? _ownedFocus;

  TextEditingController get _controller =>
      widget.controller ?? (_ownedController ??= TextEditingController());
  FocusNode get _focus => widget.focusNode ?? (_ownedFocus ??= FocusNode());

  @override
  void initState() {
    super.initState();
    _focus.addListener(_notifyFocus);
  }

  void _notifyFocus() => widget.onFocusChanged?.call(_focus.hasFocus);

  @override
  void dispose() {
    _focus.removeListener(_notifyFocus);
    _ownedController?.dispose();
    _ownedFocus?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final width = MediaQuery.sizeOf(context).width;
    final collapsed = widget.collapsed;
    final side = widget.showActions ? _side : AppHeader.gutter;
    final searchWidth = width - 2 * side;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        if (widget.showActions)
          AppGlassButton(
            size: _button,
            folded: collapsed,
            onPressed: widget.onBarcodeScanPressed,
            child: HugeIcon(
              icon: HugeIcons.strokeRoundedBarcodeScan,
              color: colors.textPrimary,
              size: 22,
            ),
          ).positioned(left: AppHeader.gutter, top: 0),
        if (widget.showActions)
          AppGlassButton(
            size: _button,
            visible: !collapsed,
            onPressed: widget.onBasketPressed,
            child: HeaderBasketIcon(color: BrandColors.accent500),
          ).positioned(right: AppHeader.gutter, top: 0),
        IgnorePointer(
          ignoring: collapsed,
          child: ExcludeSemantics(
            excluding: collapsed,
            child: _SearchField(
              width: searchWidth,
              controller: _controller,
              focusNode: _focus,
              onChanged: widget.onChanged,
              hintText: widget.hintText,
            ).center().translate(offset: Offset(collapsed ? -width : 0, 0)),
          ),
        ).positioned(left: side, right: side, top: 0, height: AppHeader.height),
        ?widget.overlay,
        if (widget.showActions)
          const IgnorePointer(child: Center(child: _BasketBadge())).positioned(
            right: AppHeader.gutter,
            top: 0,
            width: _button,
            height: AppHeader.height,
          ),
      ],
    ).constrained(width: width, height: AppHeader.height);
  }
}

class HeaderBasketIcon extends StatelessWidget {
  const HeaderBasketIcon({super.key, required this.color});

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

class _BasketBadge extends StatelessWidget {
  const _BasketBadge();

  static const double _size = 24;
  static const double _font = 10;
  static const int _max = 99;
  static const Offset _offset = Offset(TwSpacing.s3, -TwSpacing.s4);

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final service = getIt<ProductsScreenService>();
    return SignalBuilder(
      builder: (context) {
        final count = service.totalCount.value;
        if (count == 0) return const SizedBox.shrink();
        final label = count > _max ? '$_max+' : '$count';
        return Center(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  textHeightBehavior: const TextHeightBehavior(
                    applyHeightToFirstAscent: false,
                    applyHeightToLastDescent: false,
                    leadingDistribution: TextLeadingDistribution.even,
                  ),
                  style: TextStyle(
                    letterSpacing: label.length > 1 ? -0.4 : 0,
                    fontFeatures: const [FontFeature.tabularFigures()],
                    color: colors.textOnAccent,
                    fontSize: _font,
                    fontWeight: TwFontWeight.bold,
                    height: 1,
                  ),
                ),
              ),
            )
            .padding(horizontal: TwSpacing.s0_5)
            .constrained(width: _size, height: _size)
            .decorated(
              color: BrandColors.accent500,
              shape: BoxShape.circle,
              border: Border.all(color: TwColors.white, width: 1.5),
            )
            .translate(offset: _offset);
      },
    );
  }
}

class HeaderSearchIcon extends StatelessWidget {
  const HeaderSearchIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return HugeIcon(
      icon: HugeIcons.strokeRoundedSearch01,
      color: context.colors.textSecondary,
      size: 20,
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({
    required this.width,
    required this.controller,
    required this.focusNode,
    required this.onChanged,
    required this.hintText,
  });

  final double width;
  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String>? onChanged;
  final String hintText;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return SearchBar(
          controller: controller,
          focusNode: focusNode,
          onChanged: onChanged,
          onTapOutside: (_) => focusNode.unfocus(),
          hintText: hintText,
          elevation: const WidgetStatePropertyAll(0),
          overlayColor: const WidgetStatePropertyAll(Colors.transparent),
          backgroundColor: const WidgetStatePropertyAll(Colors.transparent),
          shape: const WidgetStatePropertyAll(RoundedRectangleBorder()),
          constraints: const BoxConstraints(minHeight: AppHeader.fieldHeight),
          textStyle: WidgetStatePropertyAll(
            TextStyle(color: colors.textPrimary, fontSize: 16),
          ),
          hintStyle: WidgetStatePropertyAll(
            TextStyle(color: colors.textSecondary, fontSize: 16),
          ),
          leading: const HeaderSearchIcon(),
          trailing: [
            ListenableBuilder(
              listenable: controller,
              builder: (context, _) => controller.text.isEmpty
                  ? const SizedBox.shrink()
                  : TextFieldTapRegion(
                      child: IconButton(
                        onPressed: () {
                          controller.clear();
                          onChanged?.call('');
                          focusNode.requestFocus();
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
            ),
          ],
          padding: const WidgetStatePropertyAll(
            EdgeInsetsDirectional.only(start: TwSpacing.s3, end: TwSpacing.s1),
          ),
        )
        .constrained(width: width, height: AppHeader.fieldHeight)
        .clipRRect(all: TwRadius.full)
        .decorated(
          color: colors.surfaceMuted,
          borderRadius: BorderRadius.circular(TwRadius.full),
        );
  }
}
