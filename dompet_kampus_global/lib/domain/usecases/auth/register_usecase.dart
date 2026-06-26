import '../../repositories/auth_repository.dart';
import '../../entities/user_entity.dart';

class RegisterUsecase {
  final AuthRepository _repository;
  RegisterUsecase(this._repository);

  Future<({UserEntity user, String token})> call({
    required String name,
    required String email,
    required String password,
  }) {
    return _repository.register(name: name, email: email, password: password);
  }
}
