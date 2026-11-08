part of 'query.dart';

class LazyQuery<T> {
  LazyQuery._(this._query, this._entry, this._fetch);

  final Query _query;
  final _QueryEntry<T> _entry;
  final Future<T> Function() _fetch;
  bool _disposed = false;
  bool _triggered = false;

  Signal<T?> get $data => _entry.$data;
  Signal<bool> get $loading => _entry.$loading;
  Signal<Object?> get $error => _entry.$error;

  Future<T?> trigger({bool force = false}) {
    if (_disposed) return Future.value(null);
    _triggered = true;
    return _entry.fetch(this, force: force);
  }

  Future<T?> _refetch() {
    if (_disposed) return Future.value(null);
    _triggered = true;
    return _entry.fetch(this, force: true);
  }

  void dispose() {
    if (_disposed) return;
    _disposed = true;
    _query._detach(_entry, this);
  }
}
