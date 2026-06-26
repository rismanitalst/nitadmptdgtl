import '../../repositories/auth_repository.dart';
import '../../entities/user_entity.dart';

class LoginUsecase {
  final AuthRepository _repository;
  LoginUsecase(this._repository);

  Future<({UserEntity user, String token})> call({
    required String email,
    required String password,
  }) {
    return _repository.login(email: email, password: password);
  }
}
