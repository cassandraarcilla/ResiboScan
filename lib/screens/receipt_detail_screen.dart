import 'package:flutter/material.dart';
import '../models/receipt_model.dart';
import '../utils/constants.dart';

class ReceiptDetailScreen extends StatelessWidget {
  final Receipt receipt;
  final VoidCallback onBack;
  final ValueChanged<int> onDelete;

  const ReceiptDetailScreen({
    super.key,
    required this.receipt,
    required this.onBack,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final days = receipt.daysToWarranty;

    return SingleChildScrollView(
      child: Column(children: [
        // Header
        Container(
          color: cPrimary,
          padding: const EdgeInsets.fromLTRB(20, 56, 20, 28),
          child: Row(children: [
            GestureDetector(
              onTap: onBack,
              child: Container(
                width: 38, height: 38,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.arrow_back,
                    color: Colors.white, size: 18),
              ),
            ),
            const SizedBox(width: 14),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Receipt Detail',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7), fontSize: 12)),
              Text(receipt.store,
                style: const TextStyle(
                  color: Colors.white, fontSize: 18,
                  fontWeight: FontWeight.w800)),
            ]),
          ]),
        ),

        Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 90),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image / emoji box
              Container(
                height: 200, width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F0F0),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: cBorder),
                ),
                alignment: Alignment.center,
                child: Text(receipt.image,
                  style: const TextStyle(fontSize: 72)),
              ),
              const SizedBox(height: 20),

              // Info rows
              for (final row in [
                ['Store',    receipt.store],
                ['Amount',   receipt.formattedAmount],
                ['Date',     receipt.formattedDate],
                ['Category', receipt.category],
                ['Folder',   receipt.folder],
                ['Notes',    receipt.notes.isEmpty ? '—' : receipt.notes],
                if (receipt.warranty != null)
                  ['Warranty',
                    receipt.warranty!.split('T')[0] +
                    (days != null && days > 0
                        ? ' (${days}d left)' : ' (Expired)')],
              ])
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: const BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: cBorder))),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(row[0], style: const TextStyle(
                          fontSize: 13, color: cSub)),
                      Text(row[1], style: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w600,
                          color: cText)),
                    ],
                  ),
                ),
              const SizedBox(height: 24),

              // Action buttons
              Row(children: [
                Expanded(child: ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.cloud_upload_outlined,
                      size: 16, color: Colors.white),
                  label: const Text('Backup',
                    style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w700)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: cPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14))),
                )),
                const SizedBox(width: 10),
                Expanded(child: ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.download_outlined,
                      size: 16, color: Colors.white),
                  label: const Text('Export',
                    style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w700)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: cAccent,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14))),
                )),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () => onDelete(receipt.id),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFEE2E2),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14))),
                  child: const Icon(Icons.delete_outline,
                      color: cDanger, size: 16),
                ),
              ]),
            ],
          ),
        ),
      ]),
    );
  }
}
