import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_colors.dart';
import '../services/fortlock_provider.dart';
import '../models/app_user.dart';
import 'add_user_screen.dart';

class UserManagementScreen extends StatelessWidget {
  const UserManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<FortlockProvider>();
    final currentUser = provider.currentUser;
    final users = provider.userList;

    if (currentUser == null || !currentUser.canManageUsers) {
      return const SafeArea(
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Text(
              'Halaman ini hanya dapat diakses oleh Owner dan Admin.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.grey),
            ),
          ),
        ),
      );
    }

    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Manajemen Pengguna',
                  style: TextStyle(
                      color: AppColors.darkBlue, fontSize: 20, fontWeight: FontWeight.bold),
                ),
                ElevatedButton.icon(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AddUserScreen()),
                  ),
                  icon: const Icon(Icons.person_add, size: 18),
                  label: const Text('Tambah'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.darkBlue,
                    foregroundColor: AppColors.white,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: users.isEmpty
                ? const Center(
                    child: Text('Belum ada pengguna', style: TextStyle(color: AppColors.grey)),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    itemCount: users.length,
                    itemBuilder: (context, index) {
                      return _UserTile(
                        user: users[index],
                        currentUser: currentUser,
                        provider: provider,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _UserTile extends StatelessWidget {
  final AppUser user;
  final AppUser currentUser;
  final FortlockProvider provider;

  const _UserTile({required this.user, required this.currentUser, required this.provider});

  Color _roleColor() {
    switch (user.role) {
      case 'owner':
        return AppColors.darkBlue;
      case 'admin':
        return AppColors.primaryBlue;
      default:
        return AppColors.greyDark;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.greyLight),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _roleColor().withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(Icons.person, color: _roleColor()),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(user.nama,
                    style: const TextStyle(
                        color: AppColors.darkBlue, fontWeight: FontWeight.w600, fontSize: 14)),
                Text(user.email,
                    style: const TextStyle(color: AppColors.grey, fontSize: 11)),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: _roleColor().withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(user.role.toUpperCase(),
                          style: TextStyle(
                              color: _roleColor(), fontSize: 10, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(width: 6),
                    Text(user.aktif ? 'Aktif' : 'Nonaktif',
                        style: TextStyle(
                            color: user.aktif ? AppColors.safe : AppColors.danger,
                            fontSize: 10)),
                  ],
                ),
              ],
            ),
          ),
          if (currentUser.isOwner && user.uid != currentUser.uid)
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, color: AppColors.greyDark),
              onSelected: (value) {
                if (value == 'toggle') {
                  provider.authService.setUserActive(user.uid, !user.aktif);
                } else if (value == 'delete') {
                  provider.authService.deleteUser(user.uid);
                } else if (value == 'make_admin') {
                  provider.authService.updateUserRole(user.uid, 'admin');
                } else if (value == 'make_user') {
                  provider.authService.updateUserRole(user.uid, 'user');
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'toggle',
                  child: Text(user.aktif ? 'Nonaktifkan' : 'Aktifkan'),
                ),
                if (user.role != 'admin')
                  const PopupMenuItem(value: 'make_admin', child: Text('Jadikan Admin')),
                if (user.role != 'user')
                  const PopupMenuItem(value: 'make_user', child: Text('Jadikan User')),
                const PopupMenuItem(value: 'delete', child: Text('Hapus Pengguna')),
              ],
            ),
        ],
      ),
    );
  }
}
