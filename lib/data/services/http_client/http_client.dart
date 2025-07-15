import 'package:http/http.dart' as http;
import 'package:http_interceptor/http_interceptor.dart';
import '../../providers/auth_providers.dart';
import '../auth_Interceptor/auth_interceptor.dart';
import '../login_auth_api_service.dart';

class HttpClient {
  static InterceptedClient getClient({
    required LoginAuthApiService authService,
    required AuthProvider authProvider,
  }) {
    return InterceptedClient.build(
      interceptors: [AuthInterceptor(authService, authProvider)],
      retryPolicy: ExpiredTokenRetryPolicy(),
    );
  }
}

class ExpiredTokenRetryPolicy extends RetryPolicy {
  @override
  Future<bool> shouldAttemptRetryOnResponse(BaseResponse response) async {
    return response.statusCode == 401;
  }

  @override
  Future<bool> shouldAttemptRetryOnException(Exception exception, BaseRequest request) async {
    return false;
  }
}
