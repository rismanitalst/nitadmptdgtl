import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_field.dart';
import '../../widgets/app_logo.dart';
import '../../widgets/feature_icon.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String _email = '';
  String _pw = '';
  bool _showPw = false;

  bool get _valid => _email.contains('@') && _pw.length >= 4;

  void _login() {
    context.read<AuthBloc>().add(AuthLoginRequested(
      email: _email,
      password: _pw,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthNeedsVerification) {
          context.go('/2fa/smtp');
        } else if (state is AuthAuthenticated) {
          context.go('/home');
        } else if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: AppColors.red),
          );
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Column(
            children: [
              Align(
                alignment: Alignment.topLeft,
                child: IconButton(
                  icon: const Icon(DkgIcons.arrowLeft, color: AppColors.ink),
                  onPressed: () => context.go('/'),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(26, 10, 26, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const AppLogo(size: 50),
                      const SizedBox(height: 22),
                      const Text('Masuk',
                          style: TextStyle(
                            fontFamily: 'PlusJakartaSans',
                            fontSize: 27,
                            fontWeight: FontWeight.w800,
                            color: AppColors.ink,
                            letterSpacing: -0.4,
                          )),
                      const SizedBox(height: 6),
                      const Text('Selamat datang kembali',
                          style: TextStyle(fontSize: 14.5, color: AppColors.slate500)),
                      const SizedBox(height: 28),
                      AppField(
                        label: 'Email',
                        value: _email,
                        onChanged: (v) => setState(() => _email = v),
                        placeholder: 'nama@email.com',
                        keyboardType: TextInputType.emailAddress,
                        prefixIcon: const Icon(DkgIcons.mail, size: 20),
                      ),
                      const SizedBox(height: 14),
                      AppField(
                        label: 'Kata sandi',
                        value: _pw,
                        onChanged: (v) => setState(() => _pw = v),
                        obscureText: !_showPw,
                        placeholder: '••••••••',
                        prefixIcon: const Icon(DkgIcons.lock, size: 20),
                        suffixIcon: IconButton(
                          icon: Icon(_showPw ? DkgIcons.eyeOff : DkgIcons.eye,
                              size: 20, color: AppColors.slate400),
                          onPressed: () => setState(() => _showPw = !_showPw),
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {},
                          child: const Text('Lupa kata sandi?',
                              style: TextStyle(
                                fontFamily: 'PlusJakartaSans',
                                color: AppColors.primary,
                                fontWeight: FontWeight.w700,
                                fontSize: 13.5,
                              )),
                        ),
                      ),
                      const SizedBox(height: 18),
                      BlocBuilder<AuthBloc, AuthState>(
                        builder: (context, state) => AppButton(
                          label: 'Masuk',
                          onPressed: _valid ? _login : null,
                          isLoading: state is AuthLoading,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('Belum punya akun? ',
                              style: TextStyle(fontSize: 14, color: AppColors.slate500)),
                          GestureDetector(
                            onTap: () => context.go('/register'),
                            child: const Text('Daftar',
                                style: TextStyle(
                                  fontFamily: 'PlusJakartaSans',
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                )),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
