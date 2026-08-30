import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nextcart/core/helper/auth_error_helper.dart';
import 'package:nextcart/core/theme/app_colors.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;
  bool _isSaving = false;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _changePassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    try {
      final auth = Supabase.instance.client.auth;
      await auth.signInWithPassword(
        email: auth.currentUser?.email ?? '',
        password: _currentPasswordController.text,
      );
      await auth.updateUser(
        UserAttributes(password: _newPasswordController.text),
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kata sandi berhasil diubah')),
      );
      context.pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal mengubah kata sandi: ${mapAuthErrorMessage(e)}'),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Ganti Kata Sandi',
          style: TextStyle(
            color: colors.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 17,
          ),
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            children: [
              Text(
                'Masukkan kata sandi saat ini dan kata sandi baru kamu.',
                style: TextStyle(color: colors.textSecondary, fontSize: 12.5),
              ),
              const SizedBox(height: 24),
              _buildPasswordField(
                controller: _currentPasswordController,
                label: 'Kata Sandi Saat Ini',
                obscure: _obscureCurrent,
                onToggle: () => setState(() => _obscureCurrent = !_obscureCurrent),
                validator: (value) => (value == null || value.isEmpty)
                    ? 'Kata sandi saat ini wajib diisi'
                    : null,
              ),
              const SizedBox(height: 16),
              _buildPasswordField(
                controller: _newPasswordController,
                label: 'Kata Sandi Baru',
                obscure: _obscureNew,
                onToggle: () => setState(() => _obscureNew = !_obscureNew),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Kata sandi baru wajib diisi';
                  }
                  if (value.length < 6) {
                    return 'Minimal 6 karakter';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _buildPasswordField(
                controller: _confirmPasswordController,
                label: 'Konfirmasi Kata Sandi Baru',
                obscure: _obscureConfirm,
                onToggle: () =>
                    setState(() => _obscureConfirm = !_obscureConfirm),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Konfirmasi kata sandi wajib diisi';
                  }
                  if (value != _newPasswordController.text) {
                    return 'Konfirmasi tidak cocok dengan kata sandi baru';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _changePassword,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Simpan Kata Sandi Baru',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required bool obscure,
    required VoidCallback onToggle,
    required String? Function(String?) validator,
  }) {
    final colors = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: colors.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: obscure,
          validator: validator,
          style: TextStyle(color: colors.textPrimary, fontSize: 13),
          decoration: InputDecoration(
            suffixIcon: IconButton(
              icon: Icon(
                obscure ? Icons.visibility_off : Icons.visibility,
                size: 20,
                color: colors.textSecondary,
              ),
              onPressed: onToggle,
            ),
          ),
        ),
      ],
    );
  }
}