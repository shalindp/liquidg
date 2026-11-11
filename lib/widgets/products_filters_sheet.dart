import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:ominicart_api/ominicart_api.dart';
import 'package:signals_flutter/signals_flutter.dart';
import 'package:styled_widget/styled_widget.dart';

import '../models/product_filters.dart';
import '../service_locator.dart';
import '../services/products_screen_service.dart';
import '../theme/theme.dart';
import 'app_glass_button.dart';

const double _hairline = 0.5;
const double _control = TwSpacing.s11;
const double _sideWidth = TwSpacing.s28;

Future<void> showProductsFiltersSheet(BuildContext context) {
  final height = MediaQuery.sizeOf(context).height * 0.88;
  return showModalBottomSheet<void>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (sheetContext) => SizedBox(
      height: height,
      child: Navigator(
        onGenerateRoute: (_) => MaterialPageRoute<void>(
          builder: (_) =>
              _FilterPage(onClose: () => Navigator.of(sheetContext).pop()),
        ),
      ),
    ),
  );
}

TextStyle _text(
  Color color,
  double size,
  FontWeight weight, {
  double? height,
}) =>
    TextStyle(color: color, fontSize: size, fontWeight: weight, height: height);

class _Page extends StatelessWidget {
  const _Page({required this.header, required this.body});

  final Widget header;
  final Widget body;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color:
          theme.bottomSheetTheme.modalBackgroundColor ??
          theme.bottomSheetTheme.backgroundColor ??
          theme.colorScheme.surfaceContainerLow,
      child: Column(
        children: [
          header.padding(
            left: TwSpacing.s4,
            right: TwSpacing.s4,
            bottom: TwSpacing.s3,
          ),
          body.expanded(),
          const _SeeResults(),
        ],
      ),
    );
  }
}

class _SheetHeader extends StatelessWidget {
  const _SheetHeader({
    required this.leading,
    required this.title,
    required this.trailing,
  });

  final Widget leading;
  final String title;
  final Widget trailing;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Row(
      children: [
        SizedBox(
          width: _sideWidth,
          child: Align(alignment: Alignment.centerLeft, child: leading),
        ),
        Text(
          title,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: _text(
            colors.textPrimary,
            TwFontSize.base,
            TwFontWeight.semibold,
          ),
        ).expanded(),
        SizedBox(
          width: _sideWidth,
          child: Align(alignment: Alignment.centerRight, child: trailing),
        ),
      ],
    ).constrained(height: _control);
  }
}

class _CircleButton extends StatelessWidget {
  const _CircleButton({required this.icon, required this.onTap});

  final List<List<dynamic>> icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppGlassButton(
      size: _control,
      onPressed: onTap,
      child: HugeIcon(
        icon: icon,
        color: context.colors.textPrimary,
        size: TwSpacing.s5,
      ),
    );
  }
}

class _PillButton extends StatelessWidget {
  const _PillButton({
    required this.label,
    required this.onTap,
    this.enabled = true,
  });

  static const double _width = TwSpacing.s24;

  final String label;
  final VoidCallback onTap;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return AppGlassButton(
      size: _control,
      width: _width,
      onPressed: enabled ? onTap : null,
      child: Text(
        label,
        maxLines: 1,
        softWrap: false,
        style: _text(
          enabled
              ? colors.textPrimary
              : colors.textSecondary.withValues(alpha: 0.5),
          TwFontSize.sm,
          TwFontWeight.medium,
        ),
      ),
    );
  }
}

class _SeeResults extends StatelessWidget {
  const _SeeResults();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final service = getIt<ProductsScreenService>();
    final bottomInset = MediaQuery.viewPaddingOf(context).bottom;
    return SignalBuilder(
      builder: (context) {
        final total = service.total.value ?? 0;
        return FilledButton(
              onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
              style: FilledButton.styleFrom(
                backgroundColor: BrandColors.accent500,
                foregroundColor: colors.textOnAccent,
                minimumSize: const Size.fromHeight(TwSpacing.s14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(TwRadius.xl2),
                ),
                textStyle: const TextStyle(
                  fontSize: TwFontSize.base,
                  fontWeight: TwFontWeight.semibold,
                ),
              ),
              child: Text(total == 1 ? 'See 1 Result' : 'See $total Results'),
            )
            .padding(
              left: TwSpacing.s4,
              right: TwSpacing.s4,
              top: TwSpacing.s3,
              bottom: TwSpacing.s3 + bottomInset,
            )
            .decorated(
              border: Border(
                top: BorderSide(color: colors.border, width: _hairline),
              ),
            );
      },
    );
  }
}

class _FilterPage extends StatelessWidget {
  const _FilterPage({required this.onClose});

  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final service = getIt<ProductsScreenService>();
    return _Page(
      header: SignalBuilder(
        builder: (context) => _SheetHeader(
          leading: _CircleButton(
            icon: HugeIcons.strokeRoundedArrowDown01,
            onTap: onClose,
          ),
          title: 'Filter',
          trailing: _PillButton(
            label: 'Reset',
            enabled: service.activeFilterCount.value > 0,
            onTap: service.resetFilters,
          ),
        ),
      ),
      body: SignalBuilder(
        builder: (context) {
          final sort = service.sort.value;
          final selected = service.selectedCategoryPaths.value.length;
          final view = service.viewMode.value;
          return ListView(
            padding: const EdgeInsets.fromLTRB(
              TwSpacing.s4,
              TwSpacing.s2,
              TwSpacing.s4,
              TwSpacing.s6,
            ),
            children: [
              const _SectionTitle('Sort By'),
              const SizedBox(height: TwSpacing.s3),
              LayoutBuilder(
                builder: (context, constraints) {
                  final width = (constraints.maxWidth - TwSpacing.s2) / 2;
                  return Wrap(
                    spacing: TwSpacing.s2,
                    runSpacing: TwSpacing.s2,
                    children: [
                      for (final option in ProductSort.values)
                        _OptionTile(
                          width: width,
                          selected: sort == option,
                          enabled: option.available,
                          onTap: () => service.setSort(option),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                option.title,
                                style: _text(
                                  colors.textPrimary,
                                  TwFontSize.sm,
                                  TwFontWeight.medium,
                                ),
                              ),
                              if (option.subtitle != null)
                                Text(
                                  option.subtitle!,
                                  style: _text(
                                    colors.textSecondary,
                                    TwFontSize.xs,
                                    TwFontWeight.normal,
                                  ),
                                ),
                            ],
                          ),
                        ),
                    ],
                  );
                },
              ),
              const SizedBox(height: TwSpacing.s6),
              const _SectionTitle('Filter By'),
              const SizedBox(height: TwSpacing.s3),
              _GroupCard(
                children: [
                  const _NavRow(label: 'Allergens', enabled: false),
                  const _NavRow(label: 'Dietary and Lifestyle', enabled: false),
                  _NavRow(
                    label: 'Categories',
                    detail: selected == 0 ? null : '$selected selected',
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const _CategoriesPage(),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: TwSpacing.s6),
              const _SectionTitle('View Options'),
              const SizedBox(height: TwSpacing.s3),
              Row(
                spacing: TwSpacing.s2,
                children: [
                  _OptionTile(
                    selected: view == ProductView.grid,
                    enabled: false,
                    onTap: () {},
                    child: HugeIcon(
                      icon: HugeIcons.strokeRoundedGridView,
                      color: colors.textPrimary,
                      size: TwSpacing.s5,
                    ),
                  ).expanded(),
                  _OptionTile(
                    selected: view == ProductView.list,
                    enabled: true,
                    onTap: () {},
                    child: HugeIcon(
                      icon: HugeIcons.strokeRoundedListMinus,
                      color: colors.textPrimary,
                      size: TwSpacing.s5,
                    ),
                  ).expanded(),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: _text(
        context.colors.textPrimary,
        TwFontSize.xl,
        TwFontWeight.semibold,
      ),
    );
  }
}

class _OptionTile extends StatelessWidget {
  const _OptionTile({
    required this.selected,
    required this.enabled,
    required this.onTap,
    required this.child,
    this.width,
  });

  final bool selected;
  final bool enabled;
  final VoidCallback onTap;
  final Widget child;
  final double? width;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 160),
      opacity: enabled ? 1 : 0.4,
      child:
          AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            width: width,
            height: TwSpacing.s14,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: selected
                  ? BrandColors.accent500.withValues(alpha: 0.1)
                  : colors.surface,
              borderRadius: BorderRadius.circular(TwRadius.xl2),
              border: Border.all(
                color: selected ? BrandColors.accent500 : colors.border,
                width: selected ? 1.5 : 1,
              ),
            ),
            child: child,
          ).gestures(
            behavior: HitTestBehavior.opaque,
            onTap: enabled ? onTap : null,
          ),
    );
  }
}

class _GroupCard extends StatelessWidget {
  const _GroupCard({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Column(
          children: [
            for (var i = 0; i < children.length; i++) ...[
              if (i > 0)
                const SizedBox(height: _hairline)
                    .backgroundColor(colors.border)
                    .padding(left: TwSpacing.s4),
              children[i],
            ],
          ],
        )
        .decorated(
          color: colors.surface,
          borderRadius: BorderRadius.circular(TwRadius.xl2),
        )
        .clipRRect(all: TwRadius.xl2);
  }
}

class _NavRow extends StatelessWidget {
  const _NavRow({
    required this.label,
    this.detail,
    this.enabled = true,
    this.onTap,
  });

  final String label;
  final String? detail;
  final bool enabled;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 160),
      opacity: enabled ? 1 : 0.4,
      child:
          Row(
                children: [
                  Text(
                    label,
                    style: _text(
                      colors.textPrimary,
                      TwFontSize.base,
                      TwFontWeight.normal,
                    ),
                  ).expanded(),
                  if (detail != null)
                    Text(
                      detail!,
                      style: _text(
                        colors.textSecondary,
                        TwFontSize.sm,
                        TwFontWeight.normal,
                      ),
                    ).padding(right: TwSpacing.s2),
                  HugeIcon(
                    icon: HugeIcons.strokeRoundedArrowRight01,
                    color: colors.textSecondary,
                    size: TwSpacing.s5,
                  ),
                ],
              )
              .padding(horizontal: TwSpacing.s4)
              .constrained(height: TwSpacing.s14)
              .gestures(
                behavior: HitTestBehavior.opaque,
                onTap: enabled ? onTap : null,
              ),
    );
  }
}

class _CategoriesPage extends StatelessWidget {
  const _CategoriesPage({this.parent});

  final ProductCategory? parent;

  @override
  Widget build(BuildContext context) {
    final service = getIt<ProductsScreenService>();
    return _Page(
      header: SignalBuilder(
        builder: (context) {
          final list = parent?.children ?? service.categories.value;
          final ids = [for (final category in list) category.path];
          final selected = service.selectedCategoryPaths.value;
          final all = ids.isNotEmpty && ids.every(selected.contains);
          return _SheetHeader(
            leading: _CircleButton(
              icon: HugeIcons.strokeRoundedArrowLeft01,
              onTap: () => Navigator.of(context).pop(),
            ),
            title: parent?.name ?? 'Categories',
            trailing: _PillButton(
              label: all ? 'Clear' : 'Select All',
              enabled: ids.isNotEmpty,
              onTap: () => service.setCategories(ids, on: !all),
            ),
          );
        },
      ),
      body: SignalBuilder(
        builder: (context) {
          final list = parent?.children ?? service.categories.value;
          final selected = service.selectedCategoryPaths.value;
          if (list.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          return ListView(
            padding: const EdgeInsets.fromLTRB(
              TwSpacing.s4,
              TwSpacing.s2,
              TwSpacing.s4,
              TwSpacing.s6,
            ),
            children: [
              _GroupCard(
                children: [
                  for (final category in list)
                    _CategoryRow(
                      category: category,
                      selected: selected.contains(category.path),
                      onToggle: () => service.toggleCategory(category.path),
                      onOpen: category.children.isEmpty
                          ? null
                          : () => Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (_) =>
                                    _CategoriesPage(parent: category),
                              ),
                            ),
                    ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

class _CategoryRow extends StatelessWidget {
  const _CategoryRow({
    required this.category,
    required this.selected,
    required this.onToggle,
    required this.onOpen,
  });

  final ProductCategory category;
  final bool selected;
  final VoidCallback onToggle;
  final VoidCallback? onOpen;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Row(
      children: [
        Row(
              spacing: TwSpacing.s3,
              children: [
                _Check(selected: selected),
                Text(
                  '${category.name} (${category.productCount})',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: _text(
                    colors.textPrimary,
                    TwFontSize.base,
                    TwFontWeight.normal,
                  ),
                ).expanded(),
              ],
            )
            .gestures(behavior: HitTestBehavior.opaque, onTap: onToggle)
            .expanded(),
        if (onOpen != null)
          HugeIcon(
                icon: HugeIcons.strokeRoundedArrowRight01,
                color: colors.textSecondary,
                size: TwSpacing.s5,
              )
              .padding(left: TwSpacing.s4, vertical: TwSpacing.s4)
              .gestures(behavior: HitTestBehavior.opaque, onTap: onOpen),
      ],
    ).padding(horizontal: TwSpacing.s4).constrained(height: TwSpacing.s14);
  }
}

class _Check extends StatelessWidget {
  const _Check({required this.selected});

  static const double _size = TwSpacing.s6;

  final bool selected;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      width: _size,
      height: _size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: selected ? BrandColors.accent500 : colors.surface,
        border: Border.all(
          color: selected ? BrandColors.accent500 : colors.border,
          width: 1.5,
        ),
      ),
      child: selected
          ? HugeIcon(
              icon: HugeIcons.strokeRoundedTick02,
              color: colors.textOnAccent,
              size: TwSpacing.s4,
            )
          : null,
    );
  }
}
