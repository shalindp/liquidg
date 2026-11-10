import 'package:mobile_scanner/mobile_scanner.dart';

class BarcodeScanService {
  static const List<BarcodeFormat> formats = [
    BarcodeFormat.ean13,
    BarcodeFormat.ean8,
    BarcodeFormat.upcA,
    BarcodeFormat.upcE,
  ];
}
