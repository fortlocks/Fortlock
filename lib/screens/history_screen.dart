import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../theme/app_colors.dart';
import '../services/fortlock_provider.dart';
import '../models/access_history.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<FortlockProvider>();
    final history = provider.history;

    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Access History',
                  style: TextStyle(
                      color: AppColors.darkBlue, fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Text('${history.length} entri',
                    style: const TextStyle(color: AppColors.grey, fontSize: 12)),
              ],
            ),
          ),
          Expanded(
            child: history.isEmpty
                ? const Center(
                    child: Text('Belum ada riwayat akses', style: TextStyle(color: AppColors.grey)),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    itemCount: history.length,
                    itemBuilder: (context, index) => _HistoryTile(item: history[index]),
                  ),
          ),
        ],
      ),
    );
  }
}

class _HistoryTile extends StatelessWidget {
  final AccessHistory item;

  const _HistoryTile({required this.item});

  @override
  Widget build(BuildContext context) {
    final color = item.isSuccess ? AppColors.safe : AppColors.danger;
    final formatter = DateFormat('dd/MM/yyyy HH:mm');

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
          Icon(item.isSuccess ? Icons.check_circle : Icons.cancel, color: color, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.nama,
                    style: const TextStyle(
                        color: AppColors.darkBlue, fontWeight: FontWeight.w600, fontSize: 14)),
                const SizedBox(height: 2),
                Text(formatter.format(item.timestamp),
                    style: const TextStyle(color: AppColors.grey, fontSize: 11)),
                Text(
                  item.isSuccess ? 'RFID Valid · Pintu Dibuka' : 'RFID Tidak Dikenal · Akses Ditolak',
                  style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
