import 'package:neffils/domain/repositories/register_repository.dart';
import '../models/userRegister_model.dart';

class RegisterUseCase {
  final RegisterRepository repository;

  RegisterUseCase(this.repository);

  Future<UserRegistration> execute(
      String fullName,
      String email,
      String phone,
      String username,
      String password,
      ) {
    return repository.register(fullName, username, phone, email, password);
  }
}