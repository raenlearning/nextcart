import 'package:flutter/material.dart';
import 'package:nextcart/features/admin/presentation/user/widgets/search_bar.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:nextcart/core/theme/app_colors.dart';
import 'widgets/role_filter.dart';
import 'widgets/user_list.dart';

class AdminUserManagementPage extends StatefulWidget {
  const AdminUserManagementPage({super.key});

  @override
  State<AdminUserManagementPage> createState() => _AdminUserManagementPageState();
}

class _AdminUserManagementPageState extends State<AdminUserManagementPage> {
  final SupabaseClient _supabase = Supabase.instance.client;
  List<Map<String, dynamic>> _users = [];
  List<Map<String, dynamic>> _filteredUsers = [];
  bool _isLoading = true;
  bool _isSaving = false;
  String _searchQuery = '';
  String _selectedRoleFilter = 'all';

  final Map<String, String> _pendingChanges = {};

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  Future<void> _fetchUsers() async {
    setState(() => _isLoading = true);
    try {
      final data = await _supabase
          .from('profiles')
          .select('id, full_name, email, role, avatar_url, created_at')
          .order('created_at', ascending: false);

      if (mounted) {
        setState(() {
          _users = List<Map<String, dynamic>>.from(data);
          _pendingChanges.clear();
          _applyFilters();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memuat data pengguna: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _applyFilters() {
    setState(() {
      _filteredUsers = _users.where((user) {
        final fullName = (user['full_name'] ?? '').toString().toLowerCase();
        final email = (user['email'] ?? '').toString().toLowerCase();
        final role = (user['role'] ?? '').toString().toLowerCase();

        final matchesSearch = fullName.contains(_searchQuery.toLowerCase()) ||
            email.contains(_searchQuery.toLowerCase());

        final matchesRole =
            _selectedRoleFilter == 'all' || role == _selectedRoleFilter;

        return matchesSearch && matchesRole;
      }).toList();
    });
  }

  void _onRoleSelect(String userId, String newRole) {
    final original = _users.firstWhere((u) => u['id'] == userId)['role'] ?? 'buyer';
    setState(() {
      if (newRole == original) {
        _pendingChanges.remove(userId);
      } else {
        _pendingChanges[userId] = newRole;
      }
    });
  }

  Future<void> _saveChanges() async {
    if (_pendingChanges.isEmpty || _isSaving) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        final colors = context.colors;
        return AlertDialog(
          backgroundColor: colors.card,
          title: const Text('Simpan Perubahan'),
          content: Text(
            'Ubah peran ${_pendingChanges.length} pengguna?',
            style: TextStyle(color: colors.textPrimary),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Batal'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              child: const Text('Simpan'),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) return;

    setState(() => _isSaving = true);
    try {
      await Future.wait(
        _pendingChanges.entries.map(
          (entry) => _supabase
              .from('profiles')
              .update({'role': entry.value})
              .eq('id', entry.key),
        ),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Berhasil memperbarui ${_pendingChanges.length} pengguna'),
            backgroundColor: AppColors.success,
          ),
        );
        await _fetchUsers();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menyimpan perubahan: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final hasPendingChanges = _pendingChanges.isNotEmpty;

    return Scaffold(
      backgroundColor: colors.surface,
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ──────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Kelola Pengguna',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: colors.textPrimary,
                            letterSpacing: -0.4,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${_users.length} total akun terdaftar',
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w500,
                            color: colors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: colors.card,
                      shape: BoxShape.circle,
                      border: Border.all(color: colors.border),
                    ),
                    child: IconButton(
                      icon: Icon(Icons.refresh_rounded, color: colors.textPrimary, size: 20),
                      tooltip: 'Muat ulang',
                      onPressed: _fetchUsers,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            // ── Search + filter ─────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: UserAdminSearchBar(
                onChanged: (value) {
                  _searchQuery = value;
                  _applyFilters();
                },
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Align(
                alignment: Alignment.centerLeft,
                child: RoleFilter(
                  value: _selectedRoleFilter,
                  onChanged: (value) {
                    setState(() {
                      _selectedRoleFilter = value!;
                      _applyFilters();
                    });
                  },
                ),
              ),
            ),

            const SizedBox(height: 16),

            // ── List ─────────────────────────────────────────────────
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2.4),
                    )
                  : _filteredUsers.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 72,
                                height: 72,
                                decoration: BoxDecoration(
                                  color: colors.inputFill,
                                  shape: BoxShape.circle,
                                ),
                                alignment: Alignment.center,
                                child: Icon(
                                  Icons.person_search_rounded,
                                  size: 30,
                                  color: colors.textHint,
                                ),
                              ),
                              const SizedBox(height: 14),
                              Text(
                                'Tidak ada pengguna ditemukan.',
                                style: TextStyle(
                                  color: colors.textSecondary,
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        )
                      : Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: UserList(
                            users: _filteredUsers,
                            pendingChanges: _pendingChanges,
                            onRoleSelect: _onRoleSelect,
                          ),
                        ),
            ),

            // ── Save bar ─────────────────────────────────────────────
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: hasPendingChanges
                      ? SizedBox(
                          key: const ValueKey('save-active'),
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            onPressed: !_isSaving ? _saveChanges : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black,
                              disabledBackgroundColor: colors.border,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 0,
                            ),
                            child: _isSaving
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2.5,
                                    ),
                                  )
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(Icons.check_rounded, color: Colors.white, size: 18),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Simpan ${_pendingChanges.length} perubahan',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w700,
                                          fontSize: 14.5,
                                          letterSpacing: 0.1,
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                        )
                      : const SizedBox.shrink(key: ValueKey('save-hidden')),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}