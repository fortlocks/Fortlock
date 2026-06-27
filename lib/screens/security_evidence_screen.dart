import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../theme/app_colors.dart';
import '../services/fortlock_provider.dart';
import '../models/photo_evidence.dart';
import 'evidence_detail_screen.dart';

class SecurityEvidenceScreen extends StatelessWidget {
  const SecurityEvidenceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<FortlockProvider>();
    final evidenceList = provider.evidenceList;

    return SafeArea(
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 20, 20, 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Security Evidence',
                style: TextStyle(
                    color: AppColors.darkBlue, fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          Expanded(
            child: evidenceList.isEmpty
                ? const Center(
                    child: Text('Belum ada bukti kejadian', style: TextStyle(color: AppColors.grey)),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    itemCount: evidenceList.length,
                    itemBuilder: (context, index) {
                      return _EvidenceTile(evidence: evidenceList[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _EvidenceTile extends StatelessWidget {
  final PhotoEvidence evidence;

  const _EvidenceTile({required this.evidence});

  @override
  Widget build(BuildContext context) {
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
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.danger.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.camera_alt, color: AppColors.danger),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(formatter.format(evidence.timestamp),
                    style: const TextStyle(color: AppColors.greyDark, fontSize: 11)),
                const SizedBox(height: 2),
                Text(evidence.eventLabel,
                    style: const TextStyle(
                        color: AppColors.darkBlue, fontWeight: FontWeight.w600, fontSize: 14)),
              ],
            ),
          ),
          TextButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => EvidenceDetailScreen(evidence: evidence)),
            ),
            child: const Text('Lihat Foto'),
          ),
        ],
      ),
    );
  }
}
