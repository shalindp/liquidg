import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:styled_widget/styled_widget.dart';

import '../../theme/theme.dart';

Future<void> showBasketMoreSheet(
  BuildContext context, {
  required VoidCallback onCreateList,
  required VoidCallback onRemoveAll,
}) {
  return showModalBottomSheet<void>(
    context: context,
    useRootNavigator: true,
    showDragHandle: true,
    builder: (sheetContext) => _BasketMoreSheet(
      onCreateList: onCreateList,
      onRemoveAll: () {
        Navigator.of(sheetContext).pop();
        onRemoveAll();
      },
    ),
  );
}

class _BasketMoreSheet extends StatelessWidget {
  const _BasketMoreSheet({
    required this.onCreateList,
    required this.onRemoveAll,
  });

  static const double _hairline = 0.5;

  final VoidCallback onCreateList;
  final VoidCallback onRemoveAll;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Column(
              children: [
                _Action(
                  icon: HugeIcons.strokeRoundedTaskAdd01,
                  label: 'Create list',
                  color: colors.textPrimary,
                  onTap: onCreateList,
                ),
                const SizedBox(height: _hairline)
                    .backgroundColor(colors.border)
                    .padding(left: TwSpacing.s4),
                _Action(
                  icon: HugeIcons.strokeRoundedDelete02,
                  label: 'Remove all',
                  color: colors.danger,
                  onTap: onRemoveAll,
                ),
              ],
            )
            .decorated(
              color: colors.surface,
              borderRadius: BorderRadius.circular(TwRadius.xl2),
            )
            .clipRRect(all: TwRadius.xl2),
      ],
    ).padding(
      left: TwSpacing.s4,
      right: TwSpacing.s4,
      top: TwSpacing.s2,
      bottom: TwSpacing.s4 + MediaQuery.viewPaddingOf(context).bottom,
    );
  }
}

class _Action extends StatelessWidget {
  const _Action({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final List<List<dynamic>> icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Row(
          spacing: TwSpacing.s3,
          children: [
            HugeIcon(icon: icon, color: color, size: TwSpacing.s6),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: TwFontSize.base,
                fontWeight: TwFontWeight.medium,
              ),
            ).expanded(),
          ],
        )
        .padding(horizontal: TwSpacing.s4)
        .constrained(height: TwSpacing.s14)
        .gestures(behavior: HitTestBehavior.opaque, onTap: onTap);
  }
}
