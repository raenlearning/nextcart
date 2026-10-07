import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:nextcart/core/helper/toast_helper.dart';
import 'package:nextcart/core/helper/validators.dart';
import 'package:nextcart/core/theme/app_colors.dart';
import 'package:nextcart/features/auth/bloc/auth_bloc.dart';
import 'package:nextcart/features/auth/bloc/auth_state.dart';
import 'package:nextcart/features/auth/presentation/widgets/auth_mode_toggle.dart';
import 'package:nextcart/features/auth/presentation/widgets/forgot_password_sheet.dart';
import 'package:nextcart/features/auth/presentation/widgets/oauth_button.dart';
import 'package:nextcart/features/auth/presentation/widgets/password_strength_indicator.dart';
import 'package:nextcart/features/auth/presentation/widgets/remember_me_row.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final _formKey = GlobalKey<FormState>();

  late PageController _pageController;
  AuthMode _currentMode = AuthMode.login;

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final _nameFocusNode = FocusNode();
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  final _confirmPasswordFocusNode = FocusNode();

  bool _rememberMe = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  int _passwordStrength = 0;

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nameFocusNode.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
    _passwordController.addListener(_updatePasswordStrength);
  }

  void _updatePasswordStrength() {
    final value = _passwordController.text;
    int score = 0;
    if (value.length >= 8) score++;
    if (RegExp(r'[A-Za-z]').hasMatch(value)) score++;
    if (RegExp(r'[0-9]').hasMatch(value)) score++;
    if (RegExp(r'[^A-Za-z0-9]').hasMatch(value)) score++;
    if (score != _passwordStrength) {
      setState(() => _passwordStrength = score);
    }
  }

  void _switchMode(AuthMode mode) {
    if (_currentMode == mode) return;

    setState(() {
      _currentMode = mode;
    });

    _pageController.animateToPage(
      mode == AuthMode.login ? 0 : 1,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOutCubic,
    );
  }

  InputDecoration _buildInputDecoration(String hintText,
      {Widget? prefixIcon, Widget? suffixIcon}) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: TextStyle(color: context.colors.textSecondary, fontSize: 13),
      filled: true,
      fillColor: context.colors.inputFill,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide.none,
      ),
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
    );
  }

  Widget _prefixIcon(IconData icon) {
    return Icon(icon, size: 20, color: context.colors.textSecondary);
  }

  @override
  Widget build(BuildContext context) {
    final isLogin = _currentMode == AuthMode.login;

    return Scaffold(
      backgroundColor: context.colors.background,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: context.isDark
                ? [
                    AppColors.authGradientDark,
                    context.colors.background,
                  ]
                : [
                    AppColors.primaryLight,
                    context.colors.background,
                  ],
            stops: const [0.0, 0.45],
          ),
        ),
        child: SafeArea(
        child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          padding: EdgeInsets.only(
            left: 24.0,
            right: 24.0,
            top: 16.0,
            bottom: MediaQuery.of(context).viewInsets.bottom + 16.0,
          ),
          child: BlocConsumer<AuthBloc, AuthState>(
            listener: (context, state) {
              final isLogin = _currentMode == AuthMode.login;
              if (state is AuthSuccess) {
                ToastHelper.showTopToast(
                  context,
                  isLogin ? 'Login Berhasil!' : 'Registrasi Berhasil!',
                );
                context.go('/');
              }
              if (state is AuthFailure) {
                ToastHelper.showToast(context, state.errorMessage, ToastSeverity.error);
              }
              if (state is AuthForgotPasswordSent) {
                ToastHelper.showTopToast(
                  context,
                  'Tautan reset kata sandi telah dikirim ke email Anda.',
                );
              }
            },
            builder: (context, state) {
              return Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [

                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 500),
                      child: Text(
                        isLogin
                            ? 'Langkah Menuju Masa Depan\nBelanja'
                            : 'Buat akun',
                        key: ValueKey(_currentMode),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          height: 1.3,
                          color: context.colors.textPrimary,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      isLogin
                          ? 'Masuk untuk melanjutkan belanja'
                          : 'Gabung dan mulai jelajahi teknologi terbaru',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12.5,
                        color: context.colors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 28),

                    AuthModeToggle(
                      currentMode: _currentMode,
                      onSwitch: _switchMode,
                    ),
                    const SizedBox(height: 32),

                    AnimatedSize(
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeOutCubic,
                      child: SizedBox(
                        height: isLogin ? 300 : 460,
                        child: PageView(
                          controller: _pageController,
                          physics: const BouncingScrollPhysics(),
                          onPageChanged: (index) {
                            setState(() {
                              _currentMode = index == 0
                                  ? AuthMode.login
                                  : AuthMode.register;
                            });
                          },
                          clipBehavior: Clip.none,
                          children: [
                            _buildPageContainer(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  _buildEmailField(),
                                  const SizedBox(height: 20),
                                  _buildPasswordField(),
                                  const SizedBox(height: 16),
                                  RememberMeRow(
                                    value: _rememberMe,
                                    onChanged: (val) =>
                                        setState(() => _rememberMe = val),
                                    onForgotPassword: _showForgotPasswordSheet,
                                  ),
                                ],
                              ),
                            ),

                            _buildPageContainer(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Text(
                                    'Nama Lengkap',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: context.colors.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  TextFormField(
                                    controller: _nameController,
                                    focusNode: _nameFocusNode,
                                    textInputAction: TextInputAction.next,
                                    autofillHints: const [
                                      AutofillHints.name,
                                    ],
                                    onFieldSubmitted: (_) =>
                                        _emailFocusNode.requestFocus(),
                                    decoration: _buildInputDecoration(
                                      'Masukkan nama lengkap Anda',
                                      prefixIcon: _prefixIcon(
                                        Icons.person_outline_rounded,
                                      ),
                                    ),
                                    validator: (value) {
                                      if (_currentMode == AuthMode.register &&
                                          (value == null || value.isEmpty)) {
                                        return 'Nama lengkap wajib diisi';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 20),
                                  _buildEmailField(),
                                  const SizedBox(height: 20),
                                  _buildPasswordField(),
                                  const SizedBox(height: 10),
                                  if (_currentMode == AuthMode.register) ...[
                                    PasswordStrengthIndicator(
                                      score: _passwordStrength,
                                      hasText:
                                          _passwordController.text.isNotEmpty,
                                    ),
                                    const SizedBox(height: 20),
                                    _buildConfirmPasswordField(),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28),
                        ),
                        shadowColor: AppColors.primary,
                      ),
                      onPressed: state is AuthLoading ? null : _handleSubmit,
                      child: state is AuthLoading
                          ? SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: context.colors.textPrimary,
                                strokeWidth: 2,
                              ),
                            )
                          : Text(
                              isLogin ? 'Masuk' : 'Daftar',
                              style: TextStyle(
                                color: AppColors.slate100,
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                    ),
                    const SizedBox(height: 32),

                    Row(
                      children: [
                        Expanded(
                          child: Divider(color: context.colors.divider),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            'Atau lanjutkan dengan',
                            style: TextStyle(
                              color: context.colors.textSecondary,
                              fontSize: 11.5,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Divider(color: context.colors.divider),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    Row(
                      children: [
                        Expanded(
                          child: OAuthButton(
                            label: 'Google',
                            icon: SvgPicture.asset(
                              'assets/images/google_logo.svg',
                              width: 20,
                              height: 20,
                            ),
                            onTap: () => context
                                .read<AuthBloc>()
                                .add(AuthGoogleSignInRequested()),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          isLogin ? "Belum punya akun? " : "Sudah punya akun? ",
                          style: TextStyle(
                            color: context.colors.textSecondary,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => _switchMode(
                            isLogin ? AuthMode.register : AuthMode.login,
                          ),
                          child: Text(
                            isLogin ? 'Daftar' : 'Masuk',
                            style: TextStyle(
                              color: context.colors.textPrimary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        ),
      ),
      ),
    );
  }

  Widget _buildEmailField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Alamat Email',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: context.colors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _emailController,
          focusNode: _emailFocusNode,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          autofillHints: const [AutofillHints.email],
          onFieldSubmitted: (_) => _passwordFocusNode.requestFocus(),
          decoration: _buildInputDecoration(
            'Masukkan alamat email Anda',
            prefixIcon: _prefixIcon(Icons.email_outlined),
          ),
          validator: Validators.email,
          style: TextStyle(color: context.colors.textPrimary),
        ),
      ],
    );
  }

  Widget _buildPasswordField() {
    final isLogin = _currentMode == AuthMode.login;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Password',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: context.colors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _passwordController,
          focusNode: _passwordFocusNode,
          obscureText: _obscurePassword,
          autocorrect: false,
          enableSuggestions: false,
          textInputAction: isLogin ? TextInputAction.done : TextInputAction.next,
          autofillHints: [AutofillHints.password],
          onFieldSubmitted: isLogin
              ? (_) => _handleSubmit()
              : (_) => _confirmPasswordFocusNode.requestFocus(),
          decoration: _buildInputDecoration(
            'Masukkan kata sandi Anda',
            prefixIcon: _prefixIcon(Icons.lock_outline_rounded),
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: context.colors.textSecondary,
                size: 20,
              ),
              onPressed: () =>
                  setState(() => _obscurePassword = !_obscurePassword),
            ),
          ),
          validator: (value) {
            final v = value ?? '';
            if (v.isEmpty) return 'Password wajib diisi';
            if (_currentMode == AuthMode.register) {
              if (v.length < 8) return 'Password minimal 8 karakter';
              if (!RegExp(r'[A-Za-z]').hasMatch(v) ||
                  !RegExp(r'[0-9]').hasMatch(v)) {
                return 'Harus mengandung huruf dan angka';
              }
            } else if (v.length < 6) {
              return 'Password minimal 6 karakter';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildConfirmPasswordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Konfirmasi Password',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: context.colors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _confirmPasswordController,
          focusNode: _confirmPasswordFocusNode,
          obscureText: _obscureConfirmPassword,
          autocorrect: false,
          enableSuggestions: false,
          textInputAction: TextInputAction.done,
          autofillHints: const [AutofillHints.newPassword],
          onFieldSubmitted: (_) => _handleSubmit(),
          decoration: _buildInputDecoration(
            'Ulangi kata sandi Anda',
            prefixIcon: _prefixIcon(Icons.lock_outline_rounded),
            suffixIcon: IconButton(
              icon: Icon(
                _obscureConfirmPassword
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: context.colors.textSecondary,
                size: 20,
              ),
              onPressed: () => setState(
                () => _obscureConfirmPassword = !_obscureConfirmPassword,
              ),
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Konfirmasi password wajib diisi';
            }
            if (value != _passwordController.text) {
              return 'Password tidak cocok';
            }
            return null;
          },
        ),
      ],
    );
  }


  void _showForgotPasswordSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.colors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) => ForgotPasswordSheet(
        initialEmail: _emailController.text,
        onSend: (email) {
          context.read<AuthBloc>().add(
                AuthForgotPasswordRequested(email: email),
              );
        },
      ),
    );
  }

  Widget _buildPageContainer({required Widget child}) {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 0),
        child: child,
      ),
    );
  }

  void _handleSubmit() {
    if (_formKey.currentState!.validate()) {
      if (_currentMode == AuthMode.login) {
        context.read<AuthBloc>().add(
          AuthLoginRequested(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
          ),
        );
      } else {
        context.read<AuthBloc>().add(
          AuthRegisterRequested(
            fullName: _nameController.text.trim(),
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
          ),
        );
      }
    }
  }
}
