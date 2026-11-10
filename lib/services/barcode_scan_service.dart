import 'package:mobile_scanner/mobile_scanner.dart';

class BarcodeScanService {
  static const List<BarcodeFormat> formats = [
    BarcodeFormat.ean13,
    BarcodeFormat.ean8,
    BarcodeFormat.upcA,
    BarcodeFormat.upcE,
  ];

  Future<bool> requestCameraAccess() async {
    final controller = MobileScannerController(
      autoStart: false,
      formats: formats,
    );
    try {
      await controller.start();
      return true;
    } on MobileScannerException catch (error) {
      return error.errorCode != MobileScannerErrorCode.permissionDenied;
    } finally {
      await controller.dispose();
    }
  }
}
