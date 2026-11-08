import 'dart:convert';

import 'package:flutter/services.dart';

class Env {
  const Env._(this.apiBaseUrl);

  final String apiBaseUrl;

  static Future<Env> load() async {
    final raw = await rootBundle.loadString('env.json');
    final json = jsonDecode(raw) as Map<String, dynamic>;
    return Env._(json['API_BASE_URL'] as String);
  }
}
