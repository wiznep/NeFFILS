import '../../domain/models/userRegister_model.dart';

abstract class RegisterRepository {
  Future<UserRegistration> register(
      String fullName,
      String username,
      String phone,
      String email,
      String password,
      );
}