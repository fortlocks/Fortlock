import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../models/app_user.dart';
import '../services/auth_service.dart';

class EditUserDetailScreen extends StatefulWidget {
  final AppUser user;

  const EditUserDetailScreen({super.key, required this.user});

  @override
  State<EditUserDetailScreen> createState() => _EditUserDetailScreenState();
}

class _EditUserDetailScreenState extends State<EditUserDetailScreen> {
  final _authService = AuthService();
  late final TextEditingController _rfidCtrl;

  bool _loading = false;
  String? _error;
  String? _successMessage;

  @override
  void initState() {
    super.initState();
    _rfidCtrl = TextEditingController(text: widget.user.rfidUid);
  }

  @override
  void dispose() {
    _rfidCtrl.dispose();
    super.dispose();
  }

  Future<void> _saveRfid() async {
    setState(() {
      _loading = true;
      _error = null;
      _successMessage = null;
    });

    try {
      await _authService.updateUserRfid(widget.user.uid, _rfidCtrl.text.trim());
      if (!mounted) return;
      setState(() => _successMessage = 'RFID UID berhasil disimpan.');
    } catch (e) {
      setState(() => _error = e.toString().replaceAll('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: AppColors.grey, fontSize: 12)),
          const SizedBox(height: 2),
          Text(value,
              style: const TextStyle(
                  color: AppColors.darkBlue, fontSize: 16, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.offWhite,
      appBar: AppBar(
        backgroundColor: AppColors.offWhite,
        foregroundColor: AppColors.darkBlue,
        elevation: 0,
        title: const Text('Detail Pengguna'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _infoRow('Nama', widget.user.nama),
              _infoRow('Email', widget.user.email),
              _infoRow('Role', widget.user.role.toUpperCase()),
              const SizedBox(height: 10),

              const Text('RFID UID',
                  style: TextStyle(
                      color: AppColors.greyDark, fontSize: 12, fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
              TextField(
                controller: _rfidCtrl,
                style: const TextStyle(color: AppColors.darkBlue),
                decoration: InputDecoration(
                  hintText: 'Tempelkan kartu RFID atau masukkan UID manual',
                  filled: true,
                  fillColor: AppColors.white,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
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
              ),
              const SizedBox(height: 20),

              if (_error != null)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: AppColors.danger.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(_error!,
                      style: const TextStyle(color: AppColors.danger, fontSize: 12)),
                ),

              if (_successMessage != null)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: AppColors.safe.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(_successMessage!,
                      style: const TextStyle(color: AppColors.safe, fontSize: 12)),
                ),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _loading ? null : _saveRfid,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.darkBlue,
                    foregroundColor: AppColors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: _loading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              color: AppColors.white, strokeWidth: 2))
                      : const Text('Simpan RFID UID'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
