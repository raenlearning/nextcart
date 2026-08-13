import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
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
      hintStyle: TextStyle(color: context.colors.textSecondary, fontSize: 14),
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
              if (state is AuthForgotPasswordSent) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text(
                      'Tautan reset kata sandi telah dikirim ke email Anda.',
                    ),
                    backgroundColor: AppColors.secondary,
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
                                    _buildPasswordStrength(),
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
                            FaIcon(
                              FontAwesomeIcons.google,
                              size: 20,
                              color: context.colors.textPrimary,
                            ),
                            () => _showOAuthNotice('Google'),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildOAuthButton(
                            'Apple',
                            FaIcon(
                              FontAwesomeIcons.apple,
                              size: 20,
                              color: context.colors.textPrimary,
                            ),
                            () => _showOAuthNotice('Apple'),
                          ),
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
          focusNode: _emailFocusNode,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          autofillHints: const [AutofillHints.email],
          onFieldSubmitted: (_) => _passwordFocusNode.requestFocus(),
          decoration: _buildInputDecoration(
            'Masukkan alamat email Anda',
            prefixIcon: _prefixIcon(Icons.email_outlined),
          ),
          validator: (value) => (value == null || !value.contains('@'))
              ? 'Email tidak valid'
              : null,
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

  Widget _buildPasswordStrength() {
    final labels = ['Lemah', 'Cukup', 'Baik', 'Kuat'];
    final colors = [
      AppColors.error,
      AppColors.warning,
      AppColors.info,
      AppColors.success,
    ];
    final score = _passwordStrength;
    final show = _passwordController.text.isNotEmpty;
    return AnimatedOpacity(
      opacity: show ? 1 : 0.3,
      duration: const Duration(milliseconds: 200),
      child: Row(
        children: [
          Expanded(
            child: Row(
              children: List.generate(4, (i) {
                final active = i < score;
                return Expanded(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    height: 4,
                    margin: const EdgeInsets.only(right: 6),
                    decoration: BoxDecoration(
                      color: active ? colors[score.clamp(1, 4) - 1] : AppColors.slate200,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            show ? labels[score.clamp(1, 4) - 1] : 'Keamanan password',
            style: TextStyle(
              fontSize: 12,
              color: show
                  ? colors[score.clamp(1, 4) - 1]
                  : context.colors.textSecondary,
            ),
          ),
        ],
      ),
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
                activeColor: AppColors.primary,
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
          onPressed: _showForgotPasswordSheet,
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

  void _showOAuthNotice(String provider) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Masuk dengan $provider segera hadir.'),
        backgroundColor: AppColors.info,
      ),
    );
  }

  void _showForgotPasswordSheet() {
    final controller = TextEditingController(text: _emailController.text);
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.colors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) => Padding(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 24,
          bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 32,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.slate200,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Lupa Kata Sandi',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: context.colors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Masukkan email Anda. Kami akan mengirimkan tautan untuk mereset kata sandi.',
              style: TextStyle(
                fontSize: 13,
                color: context.colors.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            Form(
              key: formKey,
              child: TextFormField(
                controller: controller,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.done,
                autofillHints: const [AutofillHints.email],
                onFieldSubmitted: (_) => _submitForgotPassword(
                  sheetContext,
                  formKey,
                  controller,
                ),
                decoration: _buildInputDecoration(
                  'Masukkan alamat email Anda',
                  prefixIcon: _prefixIcon(Icons.email_outlined),
                ),
                validator: (value) => (value == null || !value.contains('@'))
                    ? 'Email tidak valid'
                    : null,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onPressed: () => _submitForgotPassword(
                sheetContext,
                formKey,
                controller,
              ),
              child: const Text(
                'Kirim Tautan Reset',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _submitForgotPassword(
    BuildContext sheetContext,
    GlobalKey<FormState> formKey,
    TextEditingController controller,
  ) {
    if (!formKey.currentState!.validate()) return;
    Navigator.of(sheetContext).pop();
    context.read<AuthBloc>().add(
          AuthForgotPasswordRequested(email: controller.text.trim()),
        );
  }

  Widget _buildOAuthButton(String label, Widget icon, VoidCallback onTap) {
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
            icon,
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
