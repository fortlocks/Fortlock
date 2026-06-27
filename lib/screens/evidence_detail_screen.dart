import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../theme/app_colors.dart';
import '../models/photo_evidence.dart';

class EvidenceDetailScreen extends StatelessWidget {
  final PhotoEvidence evidence;

  const EvidenceDetailScreen({super.key, required this.evidence});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.offWhite,
      appBar: AppBar(
        backgroundColor: AppColors.offWhite,
        foregroundColor: AppColors.darkBlue,
        elevation: 0,
        title: const Text('Detail Kejadian'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: evidence.imageUrl.isNotEmpty
                    ? Image.network(
                        evidence.imageUrl,
                        width: double.infinity,
                        height: 240,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _placeholder(),
                      )
                    : _placeholder(),
              ),
              const SizedBox(height: 20),
              _detailRow('Jenis', evidence.eventLabel),
              _detailRow('Tanggal', DateFormat('dd/MM/yyyy').format(evidence.timestamp)),
              _detailRow('Jam', DateFormat('HH:mm').format(evidence.timestamp)),
              if (evidence.rfidUid.isNotEmpty) _detailRow('UID RFID', evidence.rfidUid),
              _detailRow('Status', evidence.status),
            ],
          ),
        ),
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      width: double.infinity,
      height: 240,
      color: AppColors.greyLight,
      child: const Icon(Icons.image_not_supported, color: AppColors.grey, size: 48),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(color: AppColors.grey, fontSize: 12)),
          const SizedBox(height: 2),
          Text(value,
              style: const TextStyle(
                  color: AppColors.darkBlue, fontSize: 16, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
