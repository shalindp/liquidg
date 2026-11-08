part of '../stores_map.dart';

class _FilterBar extends StatelessWidget {
  const _FilterBar({
    required this.filters,
    required this.onToggle,
    required this.onClear,
  });

  static const double height = TwSpacing.s10;
  static const double _logo = TwSpacing.s5;
  static const double _tick = TwSpacing.s4;
  static const Duration _animation = Duration(milliseconds: 200);

  final Set<Supermarket> filters;
  final ValueChanged<Supermarket> onToggle;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final chips = [
      _chip(
        colors,
        label: 'All stores',
        active: filters.isEmpty,
        onTap: onClear,
      ),
      for (final supermarket in Supermarket.values)
        _chip(
          colors,
          label: supermarket.label,
          logo: SupermarketLogo(chain: supermarket, size: _logo),
          active: filters.contains(supermarket),
          onTap: () => onToggle(supermarket),
        ),
    ];
    return ListView.separated(
      scrollDirection: Axis.horizontal,
      clipBehavior: Clip.none,
      padding: const EdgeInsets.symmetric(horizontal: TwSpacing.s4),
      itemCount: chips.length,
      separatorBuilder: (_, _) => const SizedBox(width: TwSpacing.s2),
      itemBuilder: (context, i) => Center(child: chips[i]),
    ).constrained(height: height);
  }

  Widget _chip(
    AppColors colors, {
    required String label,
    required bool active,
    required VoidCallback onTap,
    Widget? logo,
  }) {
    return Semantics(
      label: label,
      button: true,
      selected: active,
      child:
          AnimatedSize(
                duration: _animation,
                curve: Curves.easeOutCubic,
                alignment: Alignment.centerLeft,
                child:
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      spacing: TwSpacing.s1_5,
                      children: [
                        ?logo,
                        if (logo == null)
                          Text(
                            label,
                            maxLines: 1,
                            style: TextStyle(
                              color: colors.textPrimary,
                              fontSize: TwFontSize.xs,
                              fontWeight: active
                                  ? TwFontWeight.semibold
                                  : TwFontWeight.medium,
                            ),
                          ),
                        if (active)
                          HugeIcon(
                            icon: HugeIcons.strokeRoundedTick02,
                            size: _tick,
                            color: BrandColors.accent500,
                          ),
                      ],
                    ).padding(
                      horizontal: logo == null ? TwSpacing.s3 : TwSpacing.s2_5,
                    ),
              )
              .center()
              .constrained(height: height - TwSpacing.s2)
              .decorated(
                color: colors.surface,
                borderRadius: BorderRadius.circular(TwRadius.full),
                border: Border.all(color: colors.border, width: _hairline),
                boxShadow: _panel(colors).boxShadow,
              )
              .gestures(behavior: HitTestBehavior.opaque, onTap: onTap),
    );
  }
}
