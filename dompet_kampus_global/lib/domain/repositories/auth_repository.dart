import '../entities/user_entity.dart';

abstract class AuthRepository {
  Future<({UserEntity user, String token})> login({
    required String email,
    required String password,
  });
  Future<({UserEntity user, String token})> register({
    required String name,
    required String email,
    required String password,
  });
  Future<void> verifyEmailOtp(String code);
  Future<UserEntity> getMe();
  Future<void> updateFcmToken(String fcmToken);
  Future<void> logout();
  Future<String?> getSavedToken();
  Future<UserEntity?> getSavedUser();
  Future<void> setAuthVerified(bool verified);
  Future<bool> isAuthVerified();
}
