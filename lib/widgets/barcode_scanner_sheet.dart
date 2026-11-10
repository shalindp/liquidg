import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:styled_widget/styled_widget.dart';

import '../services/barcode_scan_service.dart';
import '../theme/theme.dart';
import 'app_glass_button.dart';

Future<String?> showBarcodeScannerSheet(BuildContext context) {
  final height = MediaQuery.sizeOf(context).height * 0.78;
  return showModalBottomSheet<String>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (context) =>
        SizedBox(height: height, child: const _ScannerSheet()),
  );
}

class _ScannerSheet extends StatefulWidget {
  const _ScannerSheet();

  @override
  State<_ScannerSheet> createState() => _ScannerSheetState();
}

class _ScannerSheetState extends State<_ScannerSheet> {
  static const double _control = TwSpacing.s11;
  static const double _frameHeight = 168;
  static const double _frameWidthFactor = 0.78;
  static const double _frameBorder = 3;

  final _controller = MobileScannerController(
    formats: BarcodeScanService.formats,
    detectionSpeed: DetectionSpeed.noDuplicates,
  );
  bool _handled = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_handled) return;
    for (final barcode in capture.barcodes) {
      final value = barcode.rawValue;
      if (value == null || value.isEmpty) continue;
      _handled = true;
      HapticFeedback.mediumImpact();
      Navigator.of(context).pop(value);
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final bottomInset = MediaQuery.viewPaddingOf(context).bottom;
    return Material(
      color: Theme.of(context).bottomSheetTheme.modalBackgroundColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              AppGlassButton(
                size: _control,
                onPressed: () => Navigator.of(context).pop(),
                child: HugeIcon(
                  icon: HugeIcons.strokeRoundedArrowDown01,
                  color: colors.textPrimary,
                  size: TwSpacing.s5,
                ),
              ),
              Text(
                'Scan barcode',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: colors.textPrimary,
                  fontSize: TwFontSize.base,
                  fontWeight: TwFontWeight.semibold,
                ),
              ).expanded(),
              ValueListenableBuilder<MobileScannerState>(
                valueListenable: _controller,
                builder: (context, state, _) {
                  final on = state.torchState == TorchState.on;
                  final available = state.torchState != TorchState.unavailable;
                  return AnimatedOpacity(
                    duration: const Duration(milliseconds: 160),
                    opacity: available ? 1 : 0.4,
                    child: AppGlassButton(
                      size: _control,
                      onPressed: available ? _controller.toggleTorch : null,
                      child: HugeIcon(
                        icon: on
                            ? HugeIcons.strokeRoundedFlash
                            : HugeIcons.strokeRoundedFlashOff,
                        color: on ? BrandColors.accent500 : colors.textPrimary,
                        size: TwSpacing.s5,
                      ),
                    ),
                  );
                },
              ),
            ],
          ).padding(horizontal: TwSpacing.s4, bottom: TwSpacing.s3),
          Stack(
            fit: StackFit.expand,
            children: [
              MobileScanner(
                controller: _controller,
                onDetect: _onDetect,
                errorBuilder: (context, error) =>
                    _Unavailable(message: _messageFor(error)),
              ),
              IgnorePointer(
                child: LayoutBuilder(
                  builder: (context, constraints) => Center(
                    child:
                        SizedBox(
                          width: constraints.maxWidth * _frameWidthFactor,
                          height: _frameHeight,
                        ).decorated(
                          borderRadius: BorderRadius.circular(TwRadius.xl2),
                          border: Border.all(
                            color: BrandColors.accent500,
                            width: _frameBorder,
                          ),
                        ),
                  ),
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: TwSpacing.s4,
                child: IgnorePointer(
                  child: Center(
                    child:
                        Text(
                              'Point the camera at a product barcode',
                              style: TextStyle(
                                color: TwColors.white,
                                fontSize: TwFontSize.sm,
                                fontWeight: TwFontWeight.medium,
                              ),
                            )
                            .padding(
                              horizontal: TwSpacing.s4,
                              vertical: TwSpacing.s2,
                            )
                            .decorated(
                              color: TwColors.black.withValues(alpha: 0.55),
                              borderRadius: BorderRadius.circular(
                                TwRadius.full,
                              ),
                            ),
                  ),
                ),
              ),
            ],
          ).clipRRect(all: TwRadius.xl3).expanded(),
          SizedBox(height: TwSpacing.s4 + bottomInset),
        ],
      ).padding(horizontal: TwSpacing.s0),
    );
  }

  String _messageFor(MobileScannerException error) {
    return switch (error.errorCode) {
      MobileScannerErrorCode.permissionDenied =>
        'Camera access is turned off. Allow it in Settings to scan.',
      MobileScannerErrorCode.unsupported =>
        'This device has no camera available.',
      _ => 'The camera could not be started.',
    };
  }
}

class _Unavailable extends StatelessWidget {
  const _Unavailable({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return ColoredBox(
      color: colors.surfaceMuted,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: TwSpacing.s3,
          children: [
            HugeIcon(
              icon: HugeIcons.strokeRoundedBarcodeScan,
              color: colors.textSecondary,
              size: TwSpacing.s12,
            ),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: colors.textSecondary,
                fontSize: TwFontSize.sm,
              ),
            ),
          ],
        ).padding(horizontal: TwSpacing.s8),
      ),
    );
  }
}
