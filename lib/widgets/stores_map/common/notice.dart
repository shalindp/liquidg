part of '../stores_map.dart';

class _Notice extends StatelessWidget {
  const _Notice({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Text(
          text,
          style: TextStyle(
            color: colors.textPrimary,
            fontSize: TwFontSize.sm,
            fontWeight: TwFontWeight.medium,
          ),
        )
        .padding(horizontal: TwSpacing.s4, vertical: TwSpacing.s3)
        .decorated(
          color: colors.surface,
          borderRadius: BorderRadius.circular(TwRadius.xl2),
          border: Border.all(color: colors.border, width: _hairline),
          boxShadow: _panel(colors).boxShadow,
        )
        .padding(bottom: TwSpacing.s2);
  }
}
