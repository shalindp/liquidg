import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:styled_widget/styled_widget.dart';

import '../../services/basket_screen_service.dart';
import '../../services/products_screen_service.dart';
import '../../theme/theme.dart';
import 'basket_stepper.dart';

class BasketLineTile extends StatelessWidget {
  const BasketLineTile({super.key, required this.line, required this.service});

  static const double _image = 80;

  final BasketLine line;
  final BasketScreenService service;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final item = line.item;
    final row =
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: TwSpacing.s3,
          children: [
            _Thumb(url: item.imageUrl),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: TwSpacing.s2,
              children: [
                Text(
                  '${item.name} ${item.packSize}',
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: colors.textPrimary,
                    fontSize: TwFontSize.base,
                    fontWeight: TwFontWeight.medium,
                    height: 1.25,
                  ),
                ).padding(right: TwSpacing.s8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    BasketStepper(
                      quantity: line.quantity,
                      canDecrement:
                          line.quantity > BasketScreenService.minQuantity,
                      canIncrement:
                          line.quantity < ProductsScreenService.maxQuantity,
                      onDecrement: () => service.decrement(line),
                      onIncrement: () => service.increment(line),
                    ),
                    const Spacer(),
                    Text(
                      line.total.label,
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        color: colors.textPrimary,
                        fontSize: TwFontSize.base,
                        fontWeight: TwFontWeight.semibold,
                      ),
                    ),
                  ],
                ),
              ],
            ).expanded(),
          ],
        ).padding(
          left: TwSpacing.s4,
          right: TwSpacing.s4,
          top: TwSpacing.s3,
          bottom: TwSpacing.s3,
        );
    return Stack(
      children: [
        row,
        Positioned(
          top: TwSpacing.s3,
          right: TwSpacing.s3,
          child: _RemoveButton(onTap: () => service.remove(line)),
        ),
      ],
    );
  }
}

class _Thumb extends StatelessWidget {
  const _Thumb({required this.url});

  final String? url;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final url = this.url;
    return SizedBox(
      width: BasketLineTile._image,
      height: BasketLineTile._image,
      child: url == null
          ? HugeIcon(
              icon: HugeIcons.strokeRoundedImage01,
              color: colors.textSecondary,
              size: TwSpacing.s8,
            ).center()
          : Image.network(
              url,
              fit: BoxFit.contain,
              cacheWidth:
                  (BasketLineTile._image *
                          MediaQuery.devicePixelRatioOf(context))
                      .round(),
              loadingBuilder: (context, child, progress) =>
                  progress == null ? child : const SizedBox.shrink(),
              errorBuilder: (context, _, _) => HugeIcon(
                icon: HugeIcons.strokeRoundedImage01,
                color: colors.textSecondary,
                size: TwSpacing.s8,
              ).center(),
            ),
    );
  }
}

class _RemoveButton extends StatelessWidget {
  const _RemoveButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Remove from basket',
      button: true,
      child:
          SvgPicture.asset(
                'assets/icons/clear.svg',
                width: TwSpacing.s6,
                height: TwSpacing.s6,
                colorFilter: ColorFilter.mode(
                  context.colors.textSecondary.withValues(alpha: 0.45),
                  BlendMode.srcIn,
                ),
              )
              .padding(all: TwSpacing.s1)
              .gestures(behavior: HitTestBehavior.opaque, onTap: onTap),
    );
  }
}
