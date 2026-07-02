import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../services/auth_service.dart';
import 'home_shell.dart';

class SetupOwnerScreen extends StatefulWidget {
  const SetupOwnerScreen({super.key});

  @override
  State<SetupOwnerScreen> createState() => _SetupOwnerScreenState();
}

class _SetupOwnerScreenState extends State<SetupOwnerScreen> {
  final _authService = AuthService();
  final _namaCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _teleponCtrl = TextEditingController();
  final _rfidCtrl = TextEditingController();

  bool _loading = false;
  String? _error;

  Future<void> _submit() async {
    if (_namaCtrl.text.isEmpty ||
        _emailCtrl.text.isEmpty ||
        _passCtrl.text.isEmpty) {
      setState(() => _error = 'Nama, email, dan password wajib diisi.');
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try{

await _authService.setupOwner(
  nama: _namaCtrl.text.trim(),
  email: _emailCtrl.text.trim(),
  password: _passCtrl.text,
  noTelepon: _teleponCtrl.text.trim(),
  rfidUid: _rfidCtrl.text.trim(),
);
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeShell()),
      );
    } catch (e) {
      setState(() => _error = e.toString().replaceAll('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.offWhite,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.darkBlue,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.admin_panel_settings,
                    color: AppColors.white, size: 32),
              ),
              const SizedBox(height: 20),
              const Text(
                'Setup Akun Owner',
                style: TextStyle(
                  color: AppColors.darkBlue,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Buat akun pemilik pertama untuk mengelola sistem Fortlock.',
                style: TextStyle(color: AppColors.greyDark, fontSize: 13),
              ),
              const SizedBox(height: 28),

              _buildLabel('Nama Pemilik'),
              _buildTextField(_namaCtrl, hint: 'Masukkan nama lengkap'),
              const SizedBox(height: 16),

              _buildLabel('Email'),
              _buildTextField(_emailCtrl,
                  hint: 'nama@email.com', keyboardType: TextInputType.emailAddress),
              const SizedBox(height: 16),

              _buildLabel('Password'),
              _buildTextField(_passCtrl, hint: 'Minimal 6 karakter', obscure: true),
              const SizedBox(height: 16),

_buildLabel('Nomor Telepon'),
_buildTextField(_teleponCtrl,
    hint: '08xxxxxxxxxx', keyboardType: TextInputType.phone),
const SizedBox(height: 16),

_buildLabel('RFID UID (Opsional)'),
_buildTextField(_rfidCtrl,
    hint: 'Tempelkan kartu RFID atau masukkan UID manual'),
const SizedBox(height: 24),
              if (_error != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: AppColors.danger.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.danger.withOpacity(0.3)),
                  ),
                  child: Text(_error!,
                      style: const TextStyle(color: AppColors.danger, fontSize: 12)),
                ),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _loading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.darkBlue,
                    foregroundColor: AppColors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  child: _loading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              color: AppColors.white, strokeWidth: 2),
                        )
                      : const Text('Buat Akun Owner'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(text,
          style: const TextStyle(
              color: AppColors.greyDark, fontSize: 12, fontWeight: FontWeight.w600)),
    );
  }

  Widget _buildTextField(
    TextEditingController controller, {
    required String hint,
    bool obscure = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      style: const TextStyle(color: AppColors.darkBlue),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: AppColors.grey),
        filled: true,
        fillColor: AppColors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: AppColors.greyLight),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: AppColors.greyLight),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.primaryBlue, width: 1.5),
        ),
      ),
    );
  }
}
