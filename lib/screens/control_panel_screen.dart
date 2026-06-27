import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_colors.dart';
import '../services/fortlock_provider.dart';

class ControlPanelScreen extends StatelessWidget {
  const ControlPanelScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<FortlockProvider>();
    final status = provider.systemStatus;
    final user = provider.currentUser;
    final canControl = user?.canControlDevice ?? false;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Control Panel',
              style: TextStyle(
                  color: AppColors.darkBlue, fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            const Text(
              'Kontrol perangkat keamanan rumah',
              style: TextStyle(color: AppColors.grey, fontSize: 12),
            ),
            const SizedBox(height: 24),

            if (!canControl)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: AppColors.warning.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.warning),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline, color: AppColors.warning),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Hanya Owner dan Admin yang dapat mengontrol perangkat.',
                        style: TextStyle(color: AppColors.warning, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),

            Row(
              children: [
                Expanded(
                  child: _ControlButton(
                    label: 'LOCK',
                    icon: Icons.lock,
                    color: AppColors.darkBlue,
                    enabled: canControl,
                    onTap: provider.lockDoor,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _ControlButton(
                    label: 'UNLOCK',
                    icon: Icons.lock_open,
                    color: AppColors.primaryBlue,
                    enabled: canControl,
                    onTap: provider.unlockDoor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _ControlButton(
                    label: 'Aktifkan Alarm',
                    icon: Icons.notifications_active,
                    color: AppColors.warning,
                    enabled: canControl,
                    onTap: provider.alarmOn,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _ControlButton(
                    label: 'Matikan Alarm',
                    icon: Icons.notifications_off,
                    color: AppColors.greyDark,
                    enabled: canControl,
                    onTap: provider.alarmOff,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: canControl
                    ? () => _confirmPanic(context, provider)
                    : null,
                icon: const Icon(Icons.emergency),
                label: const Text('PANIC MODE',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.danger,
                  foregroundColor: AppColors.white,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),

            const SizedBox(height: 24),
            Text(
              'Status saat ini: Kunci ${status.isLocked ? "terkunci" : "terbuka"}, '
              'Alarm ${status.isAlarmOn ? "aktif" : "nonaktif"}',
              style: const TextStyle(color: AppColors.greyDark, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmPanic(BuildContext context, FortlockProvider provider) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.white,
        title: const Text('Aktifkan Panic Mode?', style: TextStyle(color: AppColors.darkBlue)),
        content: const Text(
          'Alarm akan aktif, semua akses sementara dinonaktifkan, dan notifikasi darurat akan dikirim.',
          style: TextStyle(color: AppColors.greyDark),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              provider.triggerPanic();
              Navigator.pop(ctx);
            },
            child: const Text('Aktifkan', style: TextStyle(color: AppColors.danger)),
          ),
        ],
      ),
    );
  }
}

class _ControlButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool enabled;
  final VoidCallback onTap;

  const _ControlButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: enabled ? onTap : null,
      icon: Icon(icon),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: AppColors.white,
        disabledBackgroundColor: AppColors.greyLight,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}
