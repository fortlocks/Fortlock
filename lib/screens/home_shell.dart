import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/fortlock_provider.dart';
import 'dashboard_screen.dart';
import 'history_screen.dart';
import 'guest_access_screen.dart';
import 'notifications_screen.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  final _screens = const [
    DashboardScreen(),
    HistoryScreen(),
    GuestAccessScreen(),
    NotificationsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    context.read<FortlockProvider>().init();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF050A14),
      body: IndexedStack(index: _index, children: _screens),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
        backgroundColor: const Color(0xFF0B1524),
        selectedItemColor: const Color(0xFF00D4FF),
        unselectedItemColor: const Color(0xFF4A6080),
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'Riwayat',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Tamu',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: 'Notifikasi',
          ),
        ],
      ),
    );
  }
}
