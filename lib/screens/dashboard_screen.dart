import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/fortlock_provider.dart';
import '../widgets/status_card.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<FortlockProvider>();
    final status = provider.systemStatus;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'FORTLOCK',
                  style: TextStyle(
                    color: Color(0xFF00D4FF),
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: provider.mqttConnected
                            ? const Color(0xFF00E676)
                            : const Color(0xFFFF3D5A),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      provider.mqttConnected ? 'MQTT OK' : 'MQTT OFF',
                      style: const TextStyle(
                        color: Color(0xFF8BA4C0),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),

            if (status.isPanicMode) _buildPanicBanner(context),

            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.3,
              children: [
                StatusCard(
                  label: 'PINTU',
                  value: status.isDoorOpen ? 'TERBUKA' : 'TERTUTUP',
                  icon: status.isDoorOpen
                      ? Icons.door_sliding
                      : Icons.door_front_door,
                  color: status.isDoorOpen
                      ? const Color(0xFFFFB300)
                      : const Color(0xFF00E676),
                ),
                StatusCard(
                  label: 'KUNCI',
                  value: status.isLocked ? 'TERKUNCI' : 'TERBUKA',
                  icon: status.isLocked ? Icons.lock : Icons.lock_open,
                  color: status.isLocked
                      ? const Color(0xFF00E676)
                      : const Color(0xFFFF3D5A),
                ),
                StatusCard(
                  label: 'ALARM',
                  value: status.isAlarmOn ? 'AKTIF' : 'NONAKTIF',
                  icon: Icons.notifications_active,
                  color: status.isAlarmOn
                      ? const Color(0xFFFF3D5A)
                      : const Color(0xFF8BA4C0),
                ),
                StatusCard(
                  label: 'ESP32',
                  value: status.isOnline ? 'ONLINE' : 'OFFLINE',
                  icon: Icons.developer_board,
                  color: status.isOnline
                      ? const Color(0xFF00D4FF)
                      : const Color(0xFF4A6080),
                ),
              ],
            ),
            const SizedBox(height: 24),

            const Text(
              'KONTROL CEPAT',
              style: TextStyle(
                color: Color(0xFF8BA4C0),
                fontSize: 12,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: provider.mqttConnected
                        ? () => status.isLocked
                            ? provider.unlockDoor()
                            : provider.lockDoor()
                        : null,
                    icon: Icon(status.isLocked ? Icons.lock_open : Icons.lock),
                    label: Text(status.isLocked ? 'Buka Kunci' : 'Kunci Pintu'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E6FD9),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: status.isAlarmOn ? provider.silenceAlarm : null,
                    icon: const Icon(Icons.notifications_off),
                    label: const Text('Matikan Alarm'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0F1E30),
                      foregroundColor: const Color(0xFFEDF2FF),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => status.isPanicMode
                    ? provider.cancelPanic()
                    : _confirmPanic(context, provider),
                icon: const Icon(Icons.emergency),
                label: Text(status.isPanicMode
                    ? 'BATALKAN MODE PANIC'
                    : 'AKTIFKAN MODE PANIC'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF3D5A),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPanicBanner(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFF3D5A).withOpacity(0.12),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFFF3D5A)),
      ),
      child: const Row(
        children: [
          Icon(Icons.warning_amber, color: Color(0xFFFF3D5A)),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'MODE PANIC AKTIF — Periksa kondisi rumah segera',
              style: TextStyle(
                color: Color(0xFFFF3D5A),
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmPanic(BuildContext context, FortlockProvider provider) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF0B1524),
        title: const Text('Aktifkan Mode Panic?',
            style: TextStyle(color: Colors.white)),
        content: const Text(
          'Ini akan memicu alarm dan notifikasi darurat ke semua pengguna.',
          style: TextStyle(color: Color(0xFF8BA4C0)),
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
            child: const Text('Aktifkan',
                style: TextStyle(color: Color(0xFFFF3D5A))),
          ),
        ],
      ),
    );
  }
}
