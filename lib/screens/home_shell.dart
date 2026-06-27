import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_colors.dart';
import '../services/fortlock_provider.dart';
import 'dashboard_screen.dart';
import 'control_panel_screen.dart';
import 'history_screen.dart';
import 'guest_access_screen.dart';
import 'notifications_screen.dart';
import 'user_management_screen.dart';
import 'security_evidence_screen.dart';
import 'login_screen.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final provider = context.read<FortlockProvider>();
    await provider.init();
    if (mounted) setState(() => _initialized = true);
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized) {
      return const Scaffold(
        backgroundColor: AppColors.offWhite,
        body: Center(child: CircularProgressIndicator(color: AppColors.primaryBlue)),
      );
    }

    final provider = context.watch<FortlockProvider>();
    final user = provider.currentUser;
    final canManageUsers = user?.canManageUsers ?? false;

    final screens = <Widget>[
      const DashboardScreen(),
      const ControlPanelScreen(),
      const HistoryScreen(),
      const GuestAccessScreen(),
      const NotificationsScreen(),
      if (canManageUsers) const UserManagementScreen(),
      if (canManageUsers) const SecurityEvidenceScreen(),
    ];

    final navItems = <BottomNavigationBarItem>[
      const BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Dashboard'),
      const BottomNavigationBarItem(icon: Icon(Icons.tune), label: 'Kontrol'),
      const BottomNavigationBarItem(icon: Icon(Icons.history), label: 'Riwayat'),
      const BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Tamu'),
      const BottomNavigationBarItem(icon: Icon(Icons.notifications), label: 'Notifikasi'),
      if (canManageUsers)
        const BottomNavigationBarItem(icon: Icon(Icons.manage_accounts), label: 'Users'),
      if (canManageUsers)
        const BottomNavigationBarItem(icon: Icon(Icons.security), label: 'Evidence'),
    ];

    if (_index >= screens.length) _index = 0;

    return Scaffold(
      backgroundColor: AppColors.offWhite,
      appBar: AppBar(
        backgroundColor: AppColors.darkBlue,
        foregroundColor: AppColors.white,
        elevation: 0,
        title: const Text('Fortlock'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () => _confirmLogout(context, provider),
          ),
        ],
      ),
      body: IndexedStack(index: _index, children: screens),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
        backgroundColor: AppColors.white,
        selectedItemColor: AppColors.darkBlue,
        unselectedItemColor: AppColors.grey,
        type: BottomNavigationBarType.fixed,
        items: navItems,
      ),
    );
  }

  void _confirmLogout(BuildContext context, FortlockProvider provider) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.white,
        title: const Text('Logout?', style: TextStyle(color: AppColors.darkBlue)),
        content: const Text('Anda akan keluar dari akun ini.',
            style: TextStyle(color: AppColors.greyDark)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          TextButton(
            onPressed: () async {
              await provider.logout();
              if (!context.mounted) return;
              Navigator.pop(ctx);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              );
            },
            child: const Text('Logout', style: TextStyle(color: AppColors.danger)),
          ),
        ],
      ),
    );
  }
}
