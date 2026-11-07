import 'package:flutter/widgets.dart';
import 'package:signals_flutter/signals_flutter.dart';

class ChromeCollapseController {
  final collapsed = signal(false);

  static const double collapseSpeed = 900;
  static const double expandSpeed = 450;
  static const double collapseDistance = 64;
  static const double expandDistance = 24;
  static const double flingSpeed = 1400;
  static const double smoothing = 0.35;

  double _travel = 0;
  double _speed = 0;
  Duration? _lastStamp;

  void dispose() => collapsed.dispose();

  void expand() {
    _reset();
    collapsed.value = false;
  }

  void collapse() {
    _reset();
    collapsed.value = true;
  }

  void _reset() {
    _travel = 0;
    _speed = 0;
    _lastStamp = null;
  }

  bool onScroll(ScrollNotification notification) {
    if (notification.depth != 0 || notification.metrics.axis != Axis.vertical) {
      return false;
    }
    final metrics = notification.metrics;
    final inRange =
        metrics.pixels > metrics.minScrollExtent &&
        metrics.pixels < metrics.maxScrollExtent;

    if (notification is ScrollStartNotification) {
      _reset();
    } else if (notification is ScrollUpdateNotification) {
      if (metrics.pixels <= metrics.minScrollExtent) {
        expand();
      } else if (notification.dragDetails != null && inRange) {
        _track(notification);
      }
    } else if (notification is ScrollEndNotification) {
      final velocity = notification.dragDetails?.velocity.pixelsPerSecond.dy;
      if (velocity != null && inRange) {
        if (velocity <= -flingSpeed) {
          collapse();
        } else if (velocity >= flingSpeed) {
          expand();
        }
      }
      _reset();
    }
    return false;
  }

  void _track(ScrollUpdateNotification notification) {
    final delta = notification.scrollDelta ?? 0;
    final stamp = notification.dragDetails?.sourceTimeStamp;
    if (delta == 0 || stamp == null) return;

    if (_travel.sign != delta.sign) {
      _travel = 0;
      _speed = 0;
      _lastStamp = null;
    }
    _travel += delta;

    final last = _lastStamp;
    _lastStamp = stamp;
    if (last == null) return;
    final seconds =
        (stamp - last).inMicroseconds / Duration.microsecondsPerSecond;
    if (seconds <= 0) return;

    _speed += ((delta / seconds) - _speed) * smoothing;

    if (_travel >= collapseDistance && _speed >= collapseSpeed) {
      collapse();
    } else if (_travel <= -expandDistance && _speed <= -expandSpeed) {
      expand();
    }
  }
}
