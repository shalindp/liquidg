part of 'query.dart';

class Mutation<T, A> {
  Mutation._(this._query, this._action, this._invalidates)
    : $data = signal<T?>(null),
      $loading = signal(false),
      $error = signal<Object?>(null);

  final Query _query;
  final Future<T> Function(A args) _action;
  final List<String> _invalidates;

  final Signal<T?> $data;
  final Signal<bool> $loading;
  final Signal<Object?> $error;

  int _pending = 0;
  bool _disposed = false;

  Future<T?> mutate(A args) async {
    if (_disposed) return null;
    _pending++;
    $loading.value = true;
    try {
      final value = await _action(args);
      if (_disposed) return null;
      $data.value = value;
      $error.value = null;
      _query.invalidate(_invalidates);
      return value;
    } catch (error) {
      if (_disposed) return null;
      $error.value = error;
      return null;
    } finally {
      _pending--;
      if (!_disposed) {
        $loading.value = _pending > 0;
      }
    }
  }

  void dispose() {
    if (_disposed) return;
    _disposed = true;
    $data.dispose();
    $loading.dispose();
    $error.dispose();
  }
}
