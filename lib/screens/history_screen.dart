import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
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
                  'RIWAYAT AKSES',
                  style: TextStyle(
                    color: Color(0xFF00D4FF),
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
                Text(
                  '${history.length} entri',
                  style: const TextStyle(
                      color: Color(0xFF8BA4C0), fontSize: 12),
                ),
              ],
            ),
          ),
          Expanded(
            child: history.isEmpty
                ? const Center(
                    child: Text(
                      'Belum ada riwayat akses',
                      style: TextStyle(color: Color(0xFF4A6080)),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 8),
                    itemCount: history.length,
                    itemBuilder: (context, index) {
                      return _HistoryTile(item: history[index]);
                    },
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
    final color =
        item.isSuccess ? const Color(0xFF00E676) : const Color(0xFFFF3D5A);
    final formatter = DateFormat('dd MMM yyyy, HH:mm');

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF0B1524),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Row(
        children: [
          Icon(
            item.isSuccess ? Icons.check_circle : Icons.error,
            color: color,
            size: 22,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.nama,
                  style: const TextStyle(
                    color: Color(0xFFEDF2FF),
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${item.jenis.toUpperCase()} · ${formatter.format(item.timestamp)}',
                  style: const TextStyle(
                    color: Color(0xFF8BA4C0),
                    fontSize: 11,
                  ),
                ),
                if (item.keterangan.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      item.keterangan,
                      style: const TextStyle(
                        color: Color(0xFF4A6080),
                        fontSize: 11,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
