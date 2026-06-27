import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../theme/app_colors.dart';
import '../services/fortlock_provider.dart';
import '../models/app_notification.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  Color _colorFor(String type) {
    switch (type) {
      case 'danger':
        return AppColors.danger;
      case 'warning':
        return AppColors.warning;
      default:
        return AppColors.primaryBlue;
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<FortlockProvider>();
    final notifications = provider.notifications;

    return SafeArea(
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 20, 20, 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Notification Center',
                style: TextStyle(
                    color: AppColors.darkBlue, fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          Expanded(
            child: notifications.isEmpty
                ? const Center(
                    child: Text('Tidak ada notifikasi', style: TextStyle(color: AppColors.grey)),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    itemCount: notifications.length,
                    itemBuilder: (context, index) {
                      final notif = notifications[index];
                      return _NotifTile(
                        notif: notif,
                        color: _colorFor(notif.type),
                        onTap: () => provider.firebaseService.markNotificationRead(notif.id),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _NotifTile extends StatelessWidget {
  final AppNotification notif;
  final Color color;
  final VoidCallback onTap;

  const _NotifTile({required this.notif, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final formatter = DateFormat('dd/MM HH:mm');

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: notif.read ? AppColors.white : color.withOpacity(0.06),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 4),
              width: 8,
              height: 8,
              decoration: BoxDecoration(shape: BoxShape.circle, color: color),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(notif.judul,
                      style: const TextStyle(
                          color: AppColors.darkBlue, fontWeight: FontWeight.w600, fontSize: 14)),
                  const SizedBox(height: 3),
                  Text(notif.pesan, style: const TextStyle(color: AppColors.greyDark, fontSize: 12)),
                  const SizedBox(height: 4),
                  Text(formatter.format(notif.timestamp),
                      style: const TextStyle(color: AppColors.grey, fontSize: 10)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
