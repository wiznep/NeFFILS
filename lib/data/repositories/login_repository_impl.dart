import '../../domain/repositories/login_repository.dart';
import '../../domain/models/userLogin_model.dart';
import '../services/login_auth_api_service.dart';

class LoginRepositoryImpl implements LoginRepository {
  final LoginAuthApiService apiService;

  LoginRepositoryImpl(this.apiService);

  @override
  Future<UserLogin> login(String username, String password) {
    return apiService.login(username, password);
  }
}