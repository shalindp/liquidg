import 'package:ominicart_api/ominicart_api.dart';

import '../config/env.dart';

class ClientService {
  ClientService(Env env) : api = OminicartApi(basePathOverride: env.apiBaseUrl);

  final OminicartApi api;

  String get baseUrl => api.dio.options.baseUrl;
}
