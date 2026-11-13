import 'package:flutter/material.dart';
import 'package:signals_flutter/signals_flutter.dart';
import 'package:styled_widget/styled_widget.dart';

import '../../services/basket_screen_service.dart';
import '../../theme/theme.dart';

const List<String> _months = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];

Future<bool> showPlanShopSheet(
  BuildContext context, {
  required BasketScreenService service,
}) async {
  final saved = await showModalBottomSheet<bool>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => _PlanShopSheet(service: service),
  );
  return saved ?? false;
}

class _PlanShopSheet extends StatefulWidget {
  const _PlanShopSheet({required this.service});

  final BasketScreenService service;

  @override
  State<_PlanShopSheet> createState() => _PlanShopSheetState();
}

class _PlanShopSheetState extends State<_PlanShopSheet> {
  static const int maxLength = 100;
  static const Duration _fade = Duration(milliseconds: 180);

  late final _name = TextEditingController(text: _suggestion());
  late final int _count = widget.service.itemCount.value;
  bool _failed = false;

  static String _suggestion() {
    final now = DateTime.now();
    return 'Shop ${now.day} ${_months[now.month - 1]}';
  }

  @override
  void initState() {
    super.initState();
    _name.selection = TextSelection(
      baseOffset: 0,
      extentOffset: _name.text.length,
    );
  }

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = _name.text.trim();
    if (name.isEmpty) return;
    setState(() => _failed = false);
    final saved = await widget.service.createList(name);
    if (!mounted) return;
    if (saved) {
      Navigator.of(context).pop(true);
    } else {
      setState(() => _failed = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final service = widget.service;
    return SignalBuilder(
      builder: (context) {
        final saving = service.creating.value;
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: TwSpacing.s3,
          children: [
            Text(
              'Plan a shop',
              style: TextStyle(
                color: colors.textPrimary,
                fontSize: TwFontSize.xl,
                fontWeight: TwFontWeight.bold,
              ),
            ),
            Text(
              'Save $_count ${_count == 1 ? 'item' : 'items'} as a list. '
              'Your basket will be emptied.',
              style: TextStyle(
                color: colors.textSecondary,
                fontSize: TwFontSize.sm,
              ),
            ),
            TextField(
              controller: _name,
              autofocus: true,
              enabled: !saving,
              maxLength: maxLength,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _save(),
              onChanged: (_) => setState(() => _failed = false),
              style: TextStyle(
                color: colors.textPrimary,
                fontSize: TwFontSize.base,
              ),
              decoration: InputDecoration(
                hintText: 'List name',
                counterText: '',
                filled: true,
                fillColor: colors.surfaceMuted,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: TwSpacing.s4,
                  vertical: TwSpacing.s4,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(TwRadius.xl),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            if (_failed)
              Text(
                'Could not save your list. Try again.',
                style: TextStyle(color: colors.danger, fontSize: TwFontSize.sm),
              ),
            FilledButton(
              onPressed: saving || _name.text.trim().isEmpty ? null : _save,
              style: FilledButton.styleFrom(
                overlayColor: Colors.transparent,
                splashFactory: NoSplash.splashFactory,
                backgroundColor: BrandColors.accent500,
                foregroundColor: colors.textOnAccent,
                disabledBackgroundColor: BrandColors.accent500.withValues(
                  alpha: saving ? 1 : 0.4,
                ),
                disabledForegroundColor: colors.textOnAccent,
                minimumSize: const Size.fromHeight(TwSpacing.s14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(TwRadius.xl2),
                ),
                textStyle: const TextStyle(
                  fontSize: TwFontSize.base,
                  fontWeight: TwFontWeight.semibold,
                ),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  AnimatedOpacity(
                    opacity: saving ? 0 : 1,
                    duration: _fade,
                    curve: Curves.easeOut,
                    child: const Text('Save list'),
                  ),
                  AnimatedOpacity(
                    opacity: saving ? 1 : 0,
                    duration: _fade,
                    curve: Curves.easeIn,
                    child: SizedBox(
                      width: TwSpacing.s5,
                      height: TwSpacing.s5,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: colors.textOnAccent,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ).padding(
          left: TwSpacing.s4,
          right: TwSpacing.s4,
          top: TwSpacing.s2,
          bottom:
              TwSpacing.s4 +
              MediaQuery.viewInsetsOf(context).bottom +
              MediaQuery.viewPaddingOf(context).bottom,
        );
      },
    );
  }
}
