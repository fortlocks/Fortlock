import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../services/auth_service.dart';
import 'setup_owner_screen.dart';
import 'login_screen.dart';
import 'home_shell.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final _authService = AuthService();
  String _statusText = 'Memulai...';
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _decideNextScreen();
  }

  Future<void> _decideNextScreen() async {
    await Future.delayed(const Duration(milliseconds: 400));
    if (!mounted) return;

    setState(() => _statusText = 'Menghubungkan ke Firebase...');

    bool ownerExists;
    try {
      ownerExists = await _authService
          .ownerExists()
          .timeout(const Duration(seconds: 10));
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _statusText = 'Gagal terhubung ke Firebase';
        _errorText = e.toString();
      });
      return;
    }

    if (!mounted) return;
    setState(() => _statusText = 'Memeriksa status akun...');

    if (!ownerExists) {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const SetupOwnerScreen()),
      );
      return;
    }

    final currentUser = _authService.currentFirebaseUser;
    if (currentUser != null) {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeShell()),
      );
    } else {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBlueDeep,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  color: AppColors.darkBlue,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppColors.accentBlue, width: 2),
                ),
                child: const Icon(Icons.shield, color: AppColors.white, size: 48),
              ),
              const SizedBox(height: 20),
              const Text(
                'FORTLOCK',
                style: TextStyle(
                  color: AppColors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 3,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Smart Anti-Theft Home',
                style: TextStyle(color: AppColors.grey, fontSize: 13),
              ),
              const SizedBox(height: 32),
              if (_errorText == null) ...[
                const SizedBox(
                  width: 28,
                  height: 28,
                  child: CircularProgressIndicator(
                    color: AppColors.accentBlue,
                    strokeWidth: 3,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  _statusText,
                  style: const TextStyle(color: AppColors.grey, fontSize: 12),
                ),
              ] else ...[
                const Icon(Icons.error_outline, color: AppColors.danger, size: 32),
                const SizedBox(height: 12),
                Text(
                  _statusText,
                  style: const TextStyle(
                      color: AppColors.danger, fontSize: 14, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _errorText!,
                    style: const TextStyle(color: AppColors.grey, fontSize: 11),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _errorText = null;
                      _statusText = 'Mencoba lagi...';
                    });
                    _decideNextScreen();
                  },
                  child: const Text('Coba Lagi',
                      style: TextStyle(color: AppColors.accentBlue)),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
