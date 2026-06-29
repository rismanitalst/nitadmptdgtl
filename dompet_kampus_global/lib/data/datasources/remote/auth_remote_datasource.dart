import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:google_sign_in/google_sign_in.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/api_client.dart';
import '../../models/user_model.dart';

abstract class AuthRemoteDatasource {
  Future<({UserModel user, String token})> login({
    required String email,
    required String password,
  });
  Future<({UserModel user, String token})> register({
    required String name,
    required String email,
    required String password,
  });
  Future<({UserModel user, String token})> loginWithGoogle();
  Future<void> verifyEmailOtp(String code);
  Future<UserModel> getMe();
  Future<void> updateFcmToken(String fcmToken);
  void clearAuthToken();
}

class AuthRemoteDatasourceImpl implements AuthRemoteDatasource {
  final ApiClient _client;
  AuthRemoteDatasourceImpl(this._client);

  @override
  Future<({UserModel user, String token})> login({
    required String email,
    required String password,
  }) async {
    // Login via Firebase Auth, then verify token with backend
    final cred = await fb.FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    final idToken = await cred.user!.getIdToken();

    final response = await _client.post(
      ApiEndpoints.login,
      data: {'firebase_token': idToken},
    );
    final data = response['data'] as Map<String, dynamic>;
    final token = data['access_token'] as String;
    final user = UserModel.fromJson(data['user'] as Map<String, dynamic>);
    _client.setAuthToken(token);
    return (user: user, token: token);
  }

  @override
  Future<({UserModel user, String token})> register({
    required String name,
    required String email,
    required String password,
  }) async {
    // 1. Create user in Firebase Auth
    final cred = await fb.FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    // Update display name
    await cred.user!.updateDisplayName(name);

    // 2. Get Firebase ID token
    final idToken = await cred.user!.getIdToken();

    // 3. Send token to backend → backend creates user in DB + sends OTP
    final response = await _client.post(
      ApiEndpoints.register,
      data: {'firebase_token': idToken},
    );
    final data = response['data'] as Map<String, dynamic>;
    final token = data['access_token'] as String;
    final user = UserModel.fromJson(data['user'] as Map<String, dynamic>);
    _client.setAuthToken(token);
    return (user: user, token: token);
  }

  @override
  Future<void> verifyEmailOtp(String code) async {
    await _client.post(ApiEndpoints.verifyEmailOtp, data: {'code': code});
  }

  @override
  Future<UserModel> getMe() async {
    final response = await _client.get(ApiEndpoints.me);
    return UserModel.fromJson(response['data'] as Map<String, dynamic>);
  }

  @override
  Future<void> updateFcmToken(String fcmToken) async {
    await _client.put(ApiEndpoints.fcmToken, data: {'fcm_token': fcmToken});
  }

  @override
  void clearAuthToken() {
    _client.clearAuthToken();
  }

  @override
  Future<({UserModel user, String token})> loginWithGoogle() async {
    // 1. Sign in with Google
    final googleUser = await GoogleSignIn(scopes: ['email']).signIn();
    if (googleUser == null) {
      throw Exception('Login Google dibatalkan');
    }

    // 2. Get authentication from Google
    final googleAuth = await googleUser.authentication;
    final credential = fb.GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    // 3. Sign in to Firebase with Google credential
    final cred = await fb.FirebaseAuth.instance.signInWithCredential(credential);

    // 4. Get Firebase ID token
    final idToken = await cred.user!.getIdToken();

    // 5. Send token to backend
    final response = await _client.post(
      ApiEndpoints.login,
      data: {'firebase_token': idToken},
    );
    final data = response['data'] as Map<String, dynamic>;
    final token = data['access_token'] as String;
    final user = UserModel.fromJson(data['user'] as Map<String, dynamic>);
    _client.setAuthToken(token);
    return (user: user, token: token);
  }
}
