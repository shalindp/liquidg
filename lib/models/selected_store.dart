import 'supermarket.dart';

class SelectedStore {
  const SelectedStore({
    required this.id,
    required this.supermarket,
    required this.branch,
  });

  final int id;
  final Supermarket supermarket;
  final String branch;
}
