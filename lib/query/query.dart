library;

import 'dart:async';

import 'package:signals/signals.dart';

part 'lazy_query.dart';
part 'mutation.dart';
part 'query_entry.dart';

class Query {
  final Map<String, _QueryEntry<Object?>> _cache = {};

  LazyQuery<T> useLazyQuery<T>(String key, Future<T> Function() fetch) {
    final entry = _entry<T>(key);
    final handle = LazyQuery<T>._(this, entry, fetch);
    entry.handles.add(handle);
    return handle;
  }

  Mutation<T, A> useMutation<T, A>(
    Future<T> Function(A args) action, {
    List<String> invalidates = const [],
  }) => Mutation<T, A>._(this, action, invalidates);

  void invalidate(List<String> keys) {
    for (final key in _cache.keys.toList(growable: false)) {
      final matches = keys.any(
        (prefix) => key == prefix || key.startsWith('$prefix/'),
      );
      if (!matches) continue;
      final entry = _cache[key];
      if (entry == null) continue;
      if (!entry._invalidate()) {
        _remove(key);
      }
    }
  }

  _QueryEntry<T> _entry<T>(String key) {
    final existing = _cache[key];
    if (existing == null) {
      final entry = _QueryEntry<T>(key, T);
      _cache[key] = entry;
      return entry;
    }
    if (existing.type != T) {
      throw StateError('Query key "$key" is bound to ${existing.type}, not $T');
    }
    return existing as _QueryEntry<T>;
  }

  void _detach<T>(_QueryEntry<T> entry, LazyQuery<T> handle) {
    entry.handles.remove(handle);
    if (entry.handles.isEmpty && entry.$data.value == null) {
      _remove(entry.key);
    }
  }

  void _remove(String key) {
    _cache.remove(key)?._dispose();
  }

  void dispose() {
    for (final entry in _cache.values) {
      entry._dispose();
    }
    _cache.clear();
  }
}
