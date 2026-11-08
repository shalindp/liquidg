import 'package:signals_flutter/signals_flutter.dart';

class ProductCardService {
  static const int maxQuantity = 99;

  final quantities = signal<Map<String, int>>(const {});

  int quantityOf(String productId) => quantities.value[productId] ?? 0;

  void setQuantity(String productId, int quantity) {
    final next = quantity.clamp(0, maxQuantity);
    final updated = {...quantities.value};
    if (next == 0) {
      updated.remove(productId);
    } else {
      updated[productId] = next;
    }
    quantities.value = updated;
  }

  void dispose() => quantities.dispose();
}
