import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_state.dart';

enum AuthMode { login, register }

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

  bool _rememberMe = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
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

  InputDecoration _buildInputDecoration(String hintText, {Widget? suffixIcon}) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: TextStyle(color: context.colors.textSecondary, fontSize: 14),
      filled: true,
      fillColor: context.colors.inputFill,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide.none,
      ),
      suffixIcon: suffixIcon,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLogin = _currentMode == AuthMode.login;

    return Scaffold(
      backgroundColor: context.colors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: BlocConsumer<AuthBloc, AuthState>(
            listener: (context, state) {
              final isLogin = _currentMode == AuthMode.login;
              if (state is AuthSuccess) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      isLogin ? 'Login Berhasil!' : 'Registrasi Berhasil!',
                    ),
                    backgroundColor: AppColors.secondary,
                  ),
                );
                context.go('/auth');
              }
              if (state is AuthFailure) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.errorMessage),
                    backgroundColor: AppColors.error,
                  ),
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
                        style:  TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          height: 1.3,
                          color: context.colors.textPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: context.colors.inputFill,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () => _switchMode(AuthMode.login),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 500),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),

                                decoration: BoxDecoration(
                                  color: isLogin
                                      ? AppColors.primary
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  'Login',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: isLogin
                                        ? Colors.white
                                        : Colors.black,
                                  ), 
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () => _switchMode(AuthMode.register),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 500),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                decoration: BoxDecoration(
                                  color: !isLogin
                                      ? AppColors.primary
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  'Register',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: isLogin
                                        ? Colors.black
                                        : Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    AnimatedSize(
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeOutCubic,
                      child: SizedBox(
                        height: isLogin ? 300 : 320,
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
                                  _buildRememberMeRow(),
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
                                    decoration: _buildInputDecoration(
                                      'Masukkan nama lengkap Anda',
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
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                      onPressed: state is AuthLoading ? null : _handleSubmit,
                      child: state is AuthLoading
                          ?  SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: context.colors.textPrimary,
                                strokeWidth: 2,
                              ),
                            )
                          : Text(
                              isLogin ? 'Login' : 'Register',
                              style:  TextStyle(
                                color: AppColors.slate100,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                    ),
                    const SizedBox(height: 32),

                    Row(
                      children:  [
                        Expanded(child: Divider(color: Colors.black12)),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            'Atau lanjutkan dengan',
                            style: TextStyle(
                              color: context.colors.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        Expanded(child: Divider(color: Colors.black12)),
                      ],
                    ),
                    const SizedBox(height: 24),

                    Row(
                      children: [
                        Expanded(
                          child: _buildOAuthButton(
                            'Google',
                            Icons.g_mobiledata,
                            () {},
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildOAuthButton('Apple', Icons.apple, () {}),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          isLogin
                              ? "Belum punya akun? "
                              : "Sudah punya akun? ",
                          style:  TextStyle(
                            color: context.colors.textSecondary,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => _switchMode(
                            isLogin ? AuthMode.register : AuthMode.login,
                          ),
                          child: Text(
                            isLogin ? 'Daftar' : 'Masuk',
                            style:  TextStyle(
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
          decoration: _buildInputDecoration('Masukkan alamat email Anda'),
          validator: (value) => (value == null || !value.contains('@'))
              ? 'Email tidak valid'
              : null,
              style: TextStyle(color: context.colors.textPrimary),
        ),
      ],
    );
  }

  Widget _buildPasswordField() {
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
          obscureText: _obscurePassword,
          decoration: _buildInputDecoration(
            'Masukkan kata sandi Anda',
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
          validator: (value) => (value == null || value.length < 6)
              ? 'Password minimal 6 karakter'
              : null,
        ),
      ],
    );
  }

  Widget _buildRememberMeRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            SizedBox(
              width: 24,
              height: 24,
              child: Checkbox(
                value: _rememberMe,
                activeColor: context.colors.border,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
                onChanged: (val) => setState(() => _rememberMe = val ?? false),
              ),
            ),
            const SizedBox(width: 8),
             Text(
              'Ingat Saya',
              style: TextStyle(
                color: context.colors.textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        TextButton(
          onPressed: () {},
          child:  Text(
            'Lupa Kata Sandi',
            style: TextStyle(
              color: context.colors.textPrimary,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOAuthButton(String label, IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black12),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 24, color: context.colors.textPrimary),
            const SizedBox(width: 8),
            Text(
              label,
              style:  TextStyle(
                fontWeight: FontWeight.bold,
                color: context.colors.textPrimary,
              ),
            ),
          ],
        ),
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
