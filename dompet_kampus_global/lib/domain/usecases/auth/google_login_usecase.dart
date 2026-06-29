import '../../repositories/auth_repository.dart';
import '../../entities/user_entity.dart';

class GoogleLoginUsecase {
  final AuthRepository _repository;
  GoogleLoginUsecase(this._repository);

  Future<({UserEntity user, String token})> call() {
    return _repository.loginWithGoogle();
  }
}
