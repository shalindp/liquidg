import 'package:dio/dio.dart';
import 'package:ominicart_api/ominicart_api.dart';
import 'package:signals_flutter/signals_flutter.dart';

import 'client_service.dart';
import 'query_service.dart';

class AuthService {
  AuthService(this._client, this._queries) {
    _client.api.dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          final token = session.value?.accessToken;
          if (token != null) {
            options.headers[_authorizationHeader] = '$_bearerPrefix$token';
          }
          handler.next(options);
        },
        onError: (error, handler) async {
          final request = error.requestOptions;
          final expired =
              error.response?.statusCode == _unauthorizedStatus &&
              !request.path.startsWith(_authPathPrefix) &&
              request.extra[_retriedKey] != true;
          if (!expired || !await _relogin()) {
            handler.next(error);
            return;
          }
          request.extra[_retriedKey] = true;
          request.headers[_authorizationHeader] =
              '$_bearerPrefix${session.value?.accessToken}';
          try {
            handler.resolve(await _client.api.dio.fetch<dynamic>(request));
          } on DioException catch (retryError) {
            handler.next(retryError);
          }
        },
      ),
    );
  }

  static const int _unauthorizedStatus = 401;
  static const String _authPathPrefix = '/auth/';
  static const String _retriedKey = 'authRetried';
  static const String _authorizationHeader = 'Authorization';
  static const String _bearerPrefix = 'Bearer ';
  static const String _email = 'testa@test.com';
  static const String _password = '123456789aa';

  final ClientService _client;
  final QueryService _queries;

  final session = signal<AuthResponse?>(null);

  Future<bool>? _relogging;

  Future<bool> _relogin() {
    return _relogging ??= login().whenComplete(() => _relogging = null);
  }

  Future<bool> login() async {
    final mutation = _queries.useLogin();
    try {
      final result = await mutation.mutate(
        LoginRequest(email: _email, password: _password),
      );
      session.value = result;
      return result != null;
    } finally {
      mutation.dispose();
    }
  }

  void dispose() => session.dispose();
}
