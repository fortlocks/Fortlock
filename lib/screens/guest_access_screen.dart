import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../theme/app_colors.dart';
import '../services/fortlock_provider.dart';
import '../models/guest_access.dart';

class GuestAccessScreen extends StatelessWidget {
  const GuestAccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<FortlockProvider>();
    final guests = provider.guestList;
    final canManage = provider.currentUser?.isOwner ?? false;

    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Guest Access',
                  style: TextStyle(
                      color: AppColors.darkBlue, fontSize: 20, fontWeight: FontWeight.bold),
                ),
                if (canManage)
                  ElevatedButton.icon(
                    onPressed: () => _showAddGuestDialog(context, provider),
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Tambah'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.darkBlue,
                      foregroundColor: AppColors.white,
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: guests.isEmpty
                ? const Center(
                    child: Text('Belum ada akses tamu', style: TextStyle(color: AppColors.grey)),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    itemCount: guests.length,
                    itemBuilder: (context, index) {
                      return _GuestTile(
                        guest: guests[index],
                        canManage: canManage,
                        onRevoke: () => provider.removeGuest(guests[index]),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  void _showAddGuestDialog(BuildContext context, FortlockProvider provider) {
    final namaCtrl = TextEditingController();
    final rfidCtrl = TextEditingController();
    DateTime tglMulai = DateTime.now();
    DateTime tglAkhir = DateTime.now().add(const Duration(days: 1));
    TimeOfDay jamMulai = const TimeOfDay(hour: 0, minute: 0);
    TimeOfDay jamAkhir = const TimeOfDay(hour: 23, minute: 59);

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) {
          return AlertDialog(
            backgroundColor: AppColors.white,
            title: const Text('Tambah Akses Tamu', style: TextStyle(color: AppColors.darkBlue)),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: namaCtrl,
                    decoration: const InputDecoration(labelText: 'Nama Tamu'),
                  ),
                  TextField(
                    controller: rfidCtrl,
                    decoration: const InputDecoration(labelText: 'RFID UID'),
                  ),
                  const SizedBox(height: 12),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Tanggal Mulai'),
                    subtitle: Text(DateFormat('dd/MM/yyyy').format(tglMulai)),
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: ctx,
                        initialDate: tglMulai,
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (picked != null) setState(() => tglMulai = picked);
                    },
                  ),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Tanggal Berakhir'),
                    subtitle: Text(DateFormat('dd/MM/yyyy').format(tglAkhir)),
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: ctx,
                        initialDate: tglAkhir,
                        firstDate: tglMulai,
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (picked != null) setState(() => tglAkhir = picked);
                    },
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
              TextButton(
                onPressed: () {
                  if (namaCtrl.text.isEmpty || rfidCtrl.text.isEmpty) return;
                  final guest = GuestAccess(
                    id: '',
                    namaTamu: namaCtrl.text,
                    rfidUid: rfidCtrl.text,
                    tanggalMulai: tglMulai,
                    tanggalBerakhir: tglAkhir,
                    jamMulai:
                        '${jamMulai.hour.toString().padLeft(2, '0')}:${jamMulai.minute.toString().padLeft(2, '0')}',
                    jamBerakhir:
                        '${jamAkhir.hour.toString().padLeft(2, '0')}:${jamAkhir.minute.toString().padLeft(2, '0')}',
                  );
                  provider.addGuest(guest);
                  Navigator.pop(ctx);
                },
                child: const Text('Simpan'),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _GuestTile extends StatelessWidget {
  final GuestAccess guest;
  final bool canManage;
  final VoidCallback onRevoke;

  const _GuestTile({required this.guest, required this.canManage, required this.onRevoke});

  @override
  Widget build(BuildContext context) {
    final color = guest.isActive ? AppColors.safe : AppColors.grey;
    final formatter = DateFormat('dd/MM/yyyy');

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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(guest.namaTamu,
                    style: const TextStyle(
                        color: AppColors.darkBlue, fontWeight: FontWeight.w600, fontSize: 14)),
                const SizedBox(height: 2),
                Text('${formatter.format(guest.tanggalMulai)} - ${formatter.format(guest.tanggalBerakhir)}',
                    style: const TextStyle(color: AppColors.grey, fontSize: 11)),
                Text(guest.isActive ? 'AKTIF' : 'EXPIRED',
                    style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          if (canManage)
            IconButton(
              onPressed: onRevoke,
              icon: const Icon(Icons.delete_outline, color: AppColors.danger),
            ),
        ],
      ),
    );
  }
}
