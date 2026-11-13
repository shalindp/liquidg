import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:signals_flutter/signals_flutter.dart';
import 'package:styled_widget/styled_widget.dart';

import '../service_locator.dart';
import '../services/basket_screen_service.dart';
import '../theme/theme.dart';
import '../widgets/app_glass_button.dart';
import '../widgets/basket/basket_footer.dart';
import '../widgets/basket/basket_line_tile.dart';
import '../widgets/basket/basket_more_sheet.dart';

class BasketScreen extends StatefulWidget {
  const BasketScreen({super.key});

  @override
  State<BasketScreen> createState() => _BasketScreenState();
}

class _BasketScreenState extends State<BasketScreen> {
  static const double _hairline = 0.5;
  static const double _titleFadeDistance = 56;

  final _service = getIt<BasketScreenService>();
  final _scroll = ScrollController();

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  double get _progress {
    if (!_scroll.hasClients) return 0;
    return (_scroll.offset / _titleFadeDistance).clamp(0.0, 1.0);
  }

  String _count(int count) => count == 1 ? '1 item' : '$count items';

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Scaffold(
      body: SignalBuilder(
        builder: (context) {
          final groups = _service.groups.value;
          final count = _service.itemCount.value;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _header(colors, count),
              if (groups.isEmpty)
                _empty(colors).expanded()
              else
                _list(colors, groups, count).expanded(),
              if (groups.isNotEmpty) BasketFooter(service: _service),
            ],
          );
        },
      ),
    );
  }

  Widget _header(AppColors colors, int count) {
    return ListenableBuilder(
      listenable: _scroll,
      builder: (context, _) {
        final progress = _progress;
        return Stack(
              alignment: Alignment.center,
              children: [
                Opacity(
                  opacity: progress,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Basket',
                        style: TextStyle(
                          color: colors.textPrimary,
                          fontSize: TwFontSize.base,
                          fontWeight: TwFontWeight.semibold,
                        ),
                      ),
                      Text(
                        _count(count),
                        style: TextStyle(
                          color: colors.textSecondary,
                          fontSize: TwFontSize.xs,
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    AppGlassButton(
                      size: TwSpacing.s12,
                      onPressed: () => context.pop(),
                      child: HugeIcon(
                        icon: HugeIcons.strokeRoundedArrowLeft01,
                        color: colors.textPrimary,
                        size: TwSpacing.s6,
                      ),
                    ),
                    const Spacer(),
                    AppGlassButton(
                      size: TwSpacing.s12,
                      onPressed: () => showBasketMoreSheet(
                        context,
                        onRemoveAll: _service.clear,
                      ),
                      child: HugeIcon(
                        icon: HugeIcons.strokeRoundedMoreHorizontal,
                        color: BrandColors.accent500,
                        size: TwSpacing.s6,
                      ),
                    ),
                  ],
                ),
              ],
            )
            .padding(
              left: TwSpacing.s4,
              right: TwSpacing.s4,
              top: MediaQuery.viewPaddingOf(context).top + TwSpacing.s2,
              bottom: TwSpacing.s2,
            )
            .decorated(
              color: colors.background,
              border: Border(
                bottom: BorderSide(
                  color: colors.border.withValues(alpha: progress),
                  width: _hairline,
                ),
              ),
            );
      },
    );
  }

  Widget _list(AppColors colors, List<BasketGroup> groups, int count) {
    final rows = <Widget>[
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Basket',
            style: TextStyle(
              color: colors.textPrimary,
              fontSize: TwFontSize.xl4,
              fontWeight: TwFontWeight.bold,
            ),
          ),
          Text(
            _count(count),
            style: TextStyle(
              color: colors.textSecondary,
              fontSize: TwFontSize.base,
            ),
          ),
        ],
      ).padding(
        left: TwSpacing.s4,
        right: TwSpacing.s4,
        top: TwSpacing.s2,
        bottom: TwSpacing.s4,
      ),
      for (final group in groups) ...[
        Text(
              group.category.toUpperCase(),
              style: TextStyle(
                color: colors.textSecondary,
                fontSize: TwFontSize.sm,
                fontWeight: TwFontWeight.medium,
                letterSpacing: 0.4,
              ),
            )
            .padding(horizontal: TwSpacing.s4, vertical: TwSpacing.s3)
            .constrained(width: double.infinity)
            .backgroundColor(colors.surfaceMuted),
        for (var i = 0; i < group.lines.length; i++) ...[
          if (i > 0)
            const SizedBox(height: _hairline).backgroundColor(colors.border),
          BasketLineTile(
            key: ValueKey(group.lines[i].item.id),
            line: group.lines[i],
            service: _service,
          ).backgroundColor(colors.surface),
        ],
      ],
    ];
    return ListView(
      controller: _scroll,
      padding: EdgeInsets.zero,
      physics: const BouncingScrollPhysics(
        parent: AlwaysScrollableScrollPhysics(),
      ),
      children: rows,
    );
  }

  Widget _empty(AppColors colors) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: TwSpacing.s3,
        children: [
          HugeIcon(
            icon: HugeIcons.strokeRoundedShoppingBasket01,
            color: colors.textSecondary,
            size: TwSpacing.s14,
          ),
          Text(
            'Your basket is empty',
            style: TextStyle(
              color: colors.textPrimary,
              fontSize: TwFontSize.lg,
              fontWeight: TwFontWeight.semibold,
            ),
          ),
          Text(
            'Add products and they will show up here.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: colors.textSecondary,
              fontSize: TwFontSize.sm,
            ),
          ),
        ],
      ).padding(horizontal: TwSpacing.s8),
    );
  }
}
