part of 'query.dart';

class _QueryEntry<T> {
  _QueryEntry(this.key, this.type)
    : $data = signal<T?>(null),
      $loading = signal(false),
      $error = signal<Object?>(null);

  final String key;
  final Type type;
  final Signal<T?> $data;
  final Signal<bool> $loading;
  final Signal<Object?> $error;
  final Set<LazyQuery<T>> handles = {};

  Future<T?>? _inflight;
  int _generation = 0;
  bool _closed = false;

  Future<T?> fetch(LazyQuery<T> handle, {bool force = false}) {
    final running = _inflight;
    if (running != null) return running;
    if (!force && !_closed && $data.value != null) {
      return Future.value($data.value);
    }
    final future = _run(handle);
    _inflight = future;
    future.whenComplete(() {
      if (identical(_inflight, future)) {
        _inflight = null;
      }
    });
    return future;
  }

  Future<T?> _run(LazyQuery<T> handle) async {
    final generation = _generation;
    if (!_closed) {
      $loading.value = true;
    }
    try {
      final value = await handle._fetch();
      if (_closed || generation != _generation) return null;
      $data.value = value;
      $error.value = null;
      return value;
    } catch (error) {
      if (_closed || generation != _generation) return null;
      $error.value = error;
      return null;
    } finally {
      if (!_closed && generation == _generation) {
        $loading.value = false;
      }
    }
  }

  bool _invalidate() {
    _generation++;
    _inflight = null;
    if (handles.isEmpty) return false;
    final active = handles
        .where((handle) => handle._triggered && !handle._disposed)
        .toList(growable: false);
    if (active.isEmpty) {
      $data.value = null;
      $error.value = null;
      $loading.value = false;
      return true;
    }
    for (final handle in active) {
      unawaited(handle._refetch());
    }
    return true;
  }

  void _dispose() {
    _closed = true;
    _inflight = null;
    handles.clear();
    $data.dispose();
    $loading.dispose();
    $error.dispose();
  }
}
