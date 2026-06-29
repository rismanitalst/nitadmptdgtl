import '../../core/error/exceptions.dart';
import '../../core/error/failures.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/local/secure_storage_datasource.dart';
import '../datasources/remote/auth_remote_datasource.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDatasource _remote;
  final SecureStorageDatasource _local;

  AuthRepositoryImpl(this._remote, this._local);

  @override
  Future<({UserEntity user, String token})> login({
    required String email,
    required String password,
  }) async {
    try {
      final result = await _remote.login(email: email, password: password);
      await _local.saveToken(result.token);
      await _local.saveUserJson(result.user.toJsonString());
      await _local.saveAuthVerified(false);
      return (user: result.user, token: result.token);
    } on UnauthorizedException catch (e) {
      throw AuthFailure(e.message, errorCode: e.errorCode);
    } on ServerException catch (e) {
      throw ServerFailure(e.message, errorCode: e.errorCode);
    } on NetworkException catch (e) {
      throw NetworkFailure(e.message);
    }
  }

  @override
  Future<({UserEntity user, String token})> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final result = await _remote.register(name: name, email: email, password: password);
      await _local.saveToken(result.token);
      await _local.saveUserJson(result.user.toJsonString());
      await _local.saveAuthVerified(false);
      return (user: result.user, token: result.token);
    } on UnauthorizedException catch (e) {
      throw AuthFailure(e.message, errorCode: e.errorCode);
    } on ServerException catch (e) {
      throw ServerFailure(e.message, errorCode: e.errorCode);
    } on NetworkException catch (e) {
      throw NetworkFailure(e.message);
    }
  }

  @override
  Future<void> verifyEmailOtp(String code) async {
    try {
      await _remote.verifyEmailOtp(code);
    } on ServerException catch (e) {
      throw ServerFailure(e.message, errorCode: e.errorCode);
    } on NetworkException catch (e) {
      throw NetworkFailure(e.message);
    }
  }

  @override
  Future<UserEntity> getMe() async {
    try {
      return await _remote.getMe();
    } on ServerException catch (e) {
      throw ServerFailure(e.message);
    } on NetworkException catch (e) {
      throw NetworkFailure(e.message);
    }
  }

  @override
  Future<void> updateFcmToken(String fcmToken) async {
    try {
      await _remote.updateFcmToken(fcmToken);
    } catch (_) {
      // Non-critical, silently ignore
    }
  }

  @override
  Future<void> logout() async {
    await _local.clearAll();
    _remote.clearAuthToken();
  }

  @override
  Future<({UserEntity user, String token})> loginWithGoogle() async {
    try {
      final result = await _remote.loginWithGoogle();
      await _local.saveToken(result.token);
      await _local.saveUserJson(result.user.toJsonString());
      await _local.saveAuthVerified(false);
      return (user: result.user, token: result.token);
    } on UnauthorizedException catch (e) {
      throw AuthFailure(e.message, errorCode: e.errorCode);
    } on ServerException catch (e) {
      throw ServerFailure(e.message, errorCode: e.errorCode);
    } on NetworkException catch (e) {
      throw NetworkFailure(e.message);
    }
  }

  @override
  Future<void> setAuthVerified(bool verified) => _local.saveAuthVerified(verified);

  @override
  Future<bool> isAuthVerified() => _local.getAuthVerified();

  @override
  Future<String?> getSavedToken() => _local.getToken();

  @override
  Future<UserEntity?> getSavedUser() async {
    final json = await _local.getUserJson();
    if (json == null) return null;
    return UserModel.fromJsonString(json);
  }
}
