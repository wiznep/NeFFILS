import 'package:neffils/domain/repositories/login_repository.dart';
import '../models/userLogin_model.dart';


class LoginUseCase {
  final LoginRepository repository;

  LoginUseCase(this.repository);

  Future<UserLogin> execute(String username, String password) {
    return repository.login(username, password);
  }
}
