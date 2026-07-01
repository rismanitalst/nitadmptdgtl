class ApiEndpoints {
  // Health
  static const String health = '/health';

  // Auth
  static const String login = '/auth/verify-token';
  static const String register = '/auth/register';
  static const String verifyEmailOtp = '/auth/verify-email-otp';
  static const String me = '/auth/me';
  static const String fcmToken = '/auth/fcm-token';

  // OTP
  static const String sendOtpFirebase = '/otp/send-firebase';
  static const String sendOtpEmail = '/otp/send-email';
  static const String confirmOtp = '/otp/confirm';
  static const String totpRegister = '/otp/totp/register';
  static const String totpVerify = '/otp/totp/verify';

  // Account
  static const String account = '/account';
  static const String transactions = '/account/transactions';

  // Payment
  static const String topup = '/payment/topup';
  static const String transfer = '/payment/transfer';
}