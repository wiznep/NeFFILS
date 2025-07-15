import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:http_interceptor/http_interceptor.dart';
import 'package:neffils/data/services/login_auth_api_service.dart';
import '../../providers/auth_providers.dart';
import '../token/token_storage_service.dart';

class AuthInterceptor implements InterceptorContract {
  final LoginAuthApiService authService;
  final AuthProvider authProvider;

  AuthInterceptor(this.authService, this.authProvider);

  @override
  Future<BaseRequest> interceptRequest({required BaseRequest request}) async {
    final accessToken = await TokenStorageService.getAccessToken();
    if (accessToken != null) {
      request.headers['Authorization'] = 'Bearer $accessToken';
    }
    return request;
  }

  @override
  Future<BaseResponse> interceptResponse({required BaseResponse response}) async {
    if (response.statusCode == 401) {
      final refreshToken = await TokenStorageService.getRefreshToken();
      if (refreshToken != null) {
        final newAccessToken = await authService.refreshToken();
        if (newAccessToken != null) {
          final userData = await TokenStorageService.getUserData();
          if (userData != null) {
            await TokenStorageService.saveTokensAndUser(
              newAccessToken,
              refreshToken,
              userData,
            );
          }

          // Retry request with new access token
          final oldRequest = response.request as http.Request;

          final retryRequest = http.Request(oldRequest.method, oldRequest.url)
            ..headers.addAll({
              ...oldRequest.headers,
              'Authorization': 'Bearer $newAccessToken',
            })
            ..bodyBytes = await oldRequest.finalize().toBytes();

          final client = http.Client();
          try {
            final streamed = await client.send(retryRequest);
            return await http.Response.fromStream(streamed);
          } finally {
            client.close();
          }
        }
      }
      await authProvider.logout();
    }

    return response;
  }

  @override
  FutureOr<bool> shouldInterceptRequest() {
    return true;
  }

  @override
  FutureOr<bool> shouldInterceptResponse() {
    return true;
  }
}
