import '../../domain/models/userLogin_model.dart';

abstract class LoginRepository {
  Future<UserLogin> login(String username, String password);
}