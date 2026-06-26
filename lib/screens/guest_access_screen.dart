import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../services/fortlock_provider.dart';
import '../models/guest_access.dart';

class GuestAccessScreen extends StatelessWidget {
  const GuestAccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<FortlockProvider>();
    final guests = provider.guestList;

    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'AKSES TAMU',
                  style: TextStyle(
                    color: Color(0xFF00D4FF),
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () => _showAddGuestDialog(context, provider),
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Tambah'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E6FD9),
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: guests.isEmpty
                ? const Center(
                    child: Text(
                      'Belum ada akses tamu',
                      style: TextStyle(color: Color(0xFF4A6080)),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 8),
                    itemCount: guests.length,
                    itemBuilder: (context, index) {
                      return _GuestTile(
                        guest: guests[index],
                        onRevoke: () =>
                            provider.removeGuest(guests[index]),
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
            backgroundColor: const Color(0xFF0B1524),
            title: const Text('Tambah Akses Tamu',
                style: TextStyle(color: Colors.white)),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: namaCtrl,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: 'Nama Tamu',
                      labelStyle: TextStyle(color: Color(0xFF8BA4C0)),
                    ),
                  ),
                  TextField(
                    controller: rfidCtrl,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: 'RFID UID',
                      labelStyle: TextStyle(color: Color(0xFF8BA4C0)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Tanggal Mulai',
                        style: TextStyle(color: Color(0xFF8BA4C0))),
                    subtitle: Text(
                      DateFormat('dd MMM yyyy').format(tglMulai),
                      style: const TextStyle(color: Colors.white),
                    ),
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
                    title: const Text('Tanggal Berakhir',
                        style: TextStyle(color: Color(0xFF8BA4C0))),
                    subtitle: Text(
                      DateFormat('dd MMM yyyy').format(tglAkhir),
                      style: const TextStyle(color: Colors.white),
                    ),
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
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Batal'),
              ),
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
                child: const Text('Simpan',
                    style: TextStyle(color: Color(0xFF00D4FF))),
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
  final VoidCallback onRevoke;

  const _GuestTile({required this.guest, required this.onRevoke});

  @override
  Widget build(BuildContext context) {
    final color = guest.isActive
        ? const Color(0xFF00E676)
        : const Color(0xFF4A6080);
    final formatter = DateFormat('dd MMM yyyy');

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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  guest.namaTamu,
                  style: const TextStyle(
                    color: Color(0xFFEDF2FF),
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${formatter.format(guest.tanggalMulai)} - ${formatter.format(guest.tanggalBerakhir)}',
                  style: const TextStyle(
                      color: Color(0xFF8BA4C0), fontSize: 11),
                ),
                Text(
                  guest.isActive ? 'AKTIF' : 'EXPIRED',
                  style: TextStyle(
                      color: color, fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onRevoke,
            icon: const Icon(Icons.delete_outline,
                color: Color(0xFFFF3D5A)),
          ),
        ],
      ),
    );
  }
}
