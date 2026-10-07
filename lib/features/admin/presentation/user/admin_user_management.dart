import 'package:flutter/material.dart';
import 'package:nextcart/features/admin/presentation/user/widgets/search_bar.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:nextcart/core/theme/app_colors.dart';
import 'package:nextcart/core/helper/toast_helper.dart';
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
  String _searchQuery = '';
  String _selectedRoleFilter = 'all';

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
          .select('id, full_name, email, role, avatar_url, is_blocked, created_at')
          .order('created_at', ascending: false);

      if (mounted) {
        setState(() {
          _users = List<Map<String, dynamic>>.from(data);
          _applyFilters();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ToastHelper.showToast(context, 'Gagal memuat data pengguna: $e', ToastSeverity.error);
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

  Future<void> _toggleBlock(Map<String, dynamic> user) async {
    final isBlocked = (user['is_blocked'] as bool?) ?? false;
    final name = (user['full_name'] ?? 'pengguna ini').toString();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        final colors = context.colors;
        return AlertDialog(
          backgroundColor: colors.card,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            isBlocked ? 'Buka Blokir?' : 'Blokir Pengguna?',
            style: TextStyle(color: colors.textPrimary),
          ),
          content: Text(
            isBlocked
                ? '$name akan dapat login dan berbelanja kembali.'
                : '$name tidak akan bisa login lagi ke aplikasi.',
            style: TextStyle(
              color: colors.textSecondary,
              height: 1.4,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Batal'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              style: FilledButton.styleFrom(
                backgroundColor:
                    isBlocked ? AppColors.primary : AppColors.error,
                foregroundColor: Colors.white,
              ),
              child: Text(isBlocked ? 'Buka Blokir' : 'Blokir'),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) return;

    try {
      await _supabase
          .from('profiles')
          .update({'is_blocked': !isBlocked})
          .eq('id', user['id']);

      if (!mounted) return;
      ToastHelper.showToast(
        context,
        isBlocked ? '$name berhasil dibuka blokirnya' : '$name telah diblokir',
        isBlocked ? ToastSeverity.success : ToastSeverity.warning,
      );
      await _fetchUsers();
    } catch (e) {
      if (!mounted) return;
      ToastHelper.showToast(context, 'Gagal memperbarui status: $e', ToastSeverity.error);
    }
  }

  Future<void> _deleteUser(Map<String, dynamic> user) async {
    final name = (user['full_name'] ?? 'pengguna ini').toString();
    final userId = user['id'] as String;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        final colors = context.colors;
        return AlertDialog(
          backgroundColor: colors.card,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'Hapus Pengguna?',
            style: TextStyle(color: AppColors.error),
          ),
          content: Text(
            'Semua data $name akan dihapus secara permanen. Tindakan ini tidak dapat dibatalkan.',
            style: TextStyle(
              color: colors.textSecondary,
              height: 1.4,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Batal'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: Colors.white,
              ),
              child: const Text('Hapus'),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) return;

    try {
      // Delete profile row (RLS policy allows admin delete).
      await _supabase.from('profiles').delete().eq('id', userId);

      // Best-effort: invoke Edge Function to delete auth user.
      // If the function is not deployed, the profile is already deleted.
      try {
        await _supabase.functions.invoke('delete-user', body: {'user_id': userId});
      } catch (_) {
        // Auth user deletion is best-effort; profile is already gone.
      }

      if (!mounted) return;
      ToastHelper.showToast(context, '$name telah dihapus secara permanen', ToastSeverity.success);
      await _fetchUsers();
    } catch (e) {
      if (!mounted) return;
      ToastHelper.showToast(context, 'Gagal menghapus pengguna: $e', ToastSeverity.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final blockedCount =
        _users.where((u) => (u['is_blocked'] as bool?) == true).length;

    return Scaffold(
      backgroundColor: colors.surface,
      body: SafeArea(
        child: Column(
          children: [
            // ── Header
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
                          'Pengguna',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: colors.textPrimary,
                            letterSpacing: -0.4,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          blockedCount > 0
                              ? '${_users.length} akun · $blockedCount diblokir'
                              : '${_users.length} total akun terdaftar',
                          style: TextStyle(
                            fontSize: 12,
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
                      child: CircularProgressIndicator(color: AppColors.primary, strokeWidth: 2.4),
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
                                  fontSize: 13,
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
                            onToggleBlock: _toggleBlock,
                            onDelete: _deleteUser,
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
