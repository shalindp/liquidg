extension GroupedInt on int {
  String get grouped =>
      toString().replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (_) => ',');
}
