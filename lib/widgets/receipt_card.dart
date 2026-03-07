import 'package:flutter/material.dart';
import '../models/receipt_model.dart';
import '../utils/constants.dart';

class ReceiptCard extends StatelessWidget {
  final Receipt receipt;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const ReceiptCard({
    super.key,
    required this.receipt,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final color = catColors[receipt.category] ?? cSub;
    final days  = receipt.daysToWarranty;

    return Card(
      elevation: 2,                                         // elevation
      margin: const EdgeInsets.symmetric(vertical: 5),     // margin
      color: cCard,                                         // color
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: cBorder),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              // Emoji icon
              Container(
                width: 52, height: 52,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.13),
                  borderRadius: BorderRadius.circular(14),
                ),
                alignment: Alignment.center,
                child: Text(receipt.image,
                  style: const TextStyle(fontSize: 26)),
              ),
              const SizedBox(width: 14),

              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(receipt.store,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15, color: cText)),
                    const SizedBox(height: 2),
                    Text('${receipt.formattedDate} · ${receipt.category}',
                      style: const TextStyle(fontSize: 12, color: cSub)),
                    if (days != null && days > 0) ...[
                      const SizedBox(height: 3),
                      Text('⏰ Warranty: ${days}d left',
                        style: TextStyle(
                          fontSize: 11, fontWeight: FontWeight.w600,
                          color: days < 30 ? cDanger : cPrimaryLt)),
                    ],
                    if (days != null && days <= 0) ...[
                      const SizedBox(height: 3),
                      const Text('Warranty expired',
                        style: TextStyle(fontSize: 11, color: cSub)),
                    ],
                  ],
                ),
              ),

              // Amount + delete
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(receipt.formattedAmount,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 15, color: cPrimary)),
                  IconButton(
                    onPressed: onDelete,
                    icon: const Icon(Icons.delete_outline, size: 16),
                    color: cSub,
                    padding: const EdgeInsets.all(4),
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
