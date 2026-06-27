import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../theme/app_colors.dart';
import '../services/fortlock_provider.dart';
import '../widgets/status_card.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<FortlockProvider>();
    final status = provider.systemStatus;
    final isDanger = status.isAlarmOn || status.isPanicMode || status.isDoorOpen;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Dashboard',
                      style: TextStyle(
                        color: AppColors.darkBlue,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      provider.currentUser != null
                          ? 'Halo, ${provider.currentUser!.nama}'
                          : 'Smart Anti-Theft Home',
                      style: const TextStyle(color: AppColors.grey, fontSize: 12),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: provider.mqttConnected ? AppColors.safe : AppColors.danger,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      provider.mqttConnected ? 'Terhubung' : 'Putus',
                      style: const TextStyle(color: AppColors.greyDark, fontSize: 11),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDanger ? AppColors.danger : AppColors.safe,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  Icon(isDanger ? Icons.warning_amber : Icons.verified_user,
                      color: AppColors.white, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isDanger ? 'STATUS: BAHAYA' : 'STATUS: AMAN',
                          style: const TextStyle(
                              color: AppColors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 15),
                        ),
                        Text(
                          status.lastUpdate != null
                              ? 'Update terakhir: ${DateFormat('HH:mm:ss').format(status.lastUpdate!)}'
                              : 'Menunggu data...',
                          style: const TextStyle(color: AppColors.white, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.3,
              children: [
                StatusCard(
                  label: 'STATUS PINTU',
                  value: status.isDoorOpen ? 'TERBUKA' : 'TERTUTUP',
                  icon: status.isDoorOpen ? Icons.door_sliding : Icons.door_front_door,
                  isSafe: !status.isDoorOpen,
                ),
                StatusCard(
                  label: 'STATUS KUNCI',
                  value: status.isLocked ? 'TERKUNCI' : 'TERBUKA',
                  icon: status.isLocked ? Icons.lock : Icons.lock_open,
                  isSafe: status.isLocked,
                ),
                StatusCard(
                  label: 'STATUS ALARM',
                  value: status.isAlarmOn ? 'AKTIF' : 'NONAKTIF',
                  icon: Icons.notifications_active,
                  isSafe: !status.isAlarmOn,
                ),
                StatusCard(
                  label: 'STATUS ESP32',
                  value: status.isOnline ? 'ONLINE' : 'OFFLINE',
                  icon: Icons.developer_board,
                  isSafe: status.isOnline,
                ),
              ],
            ),
            const SizedBox(height: 16),

            if (status.isPanicMode)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                margin: const EdgeInsets.only(top: 4),
                decoration: BoxDecoration(
                  color: AppColors.danger.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.danger),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.emergency, color: AppColors.danger),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'PANIC MODE AKTIF — Semua akses dinonaktifkan sementara',
                        style: TextStyle(
                            color: AppColors.danger,
                            fontWeight: FontWeight.bold,
                            fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
