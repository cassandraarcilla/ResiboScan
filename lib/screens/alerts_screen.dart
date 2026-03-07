import 'package:flutter/material.dart';
import '../models/receipt_model.dart';
import '../utils/constants.dart';

class AlertsScreen extends StatelessWidget {
  final List<Receipt> receipts;
  const AlertsScreen({super.key, required this.receipts});

  @override
  Widget build(BuildContext context) {
    final warranties = receipts
        .where((r) => r.warranty != null)
        .map((r) => {'receipt': r, 'days': r.daysToWarranty!})
        .toList()
      ..sort((a, b) =>
          (a['days'] as int).compareTo(b['days'] as int));

    return SingleChildScrollView(
      child: Column(children: [
        // Header
        Container(
          color: cPrimary,
          padding: const EdgeInsets.fromLTRB(20, 56, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Reminders',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7), fontSize: 12)),
              const Text('Warranty Alerts',
                style: TextStyle(
                  fontFamily: 'Georgia', color: Colors.white,
                  fontSize: 22, fontWeight: FontWeight.w800)),
            ],
          ),
        ),

        Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 90),
          child: warranties.isEmpty
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 60),
                    child: Column(children: [
                      Text('🔔', style: TextStyle(fontSize: 48)),
                      SizedBox(height: 12),
                      Text('No warranty reminders yet',
                        style: TextStyle(fontSize: 14, color: cSub)),
                      SizedBox(height: 4),
                      Text(
                        'Add receipts with warranty dates to get alerts',
                        style: TextStyle(fontSize: 12, color: cSub)),
                    ]),
                  ),
                )
              : Column(
                  children: warranties.map((w) {
                    final r    = w['receipt'] as Receipt;
                    final days = w['days'] as int;
                    final borderColor = days <= 0
                        ? cSub
                        : days <= 30 ? cDanger : cPrimaryLt;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: borderColor.withOpacity(0.13),
                          width: 1.5),
                      ),
                      child: Row(children: [
                        Text(r.image,
                          style: const TextStyle(fontSize: 32)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(r.store,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 15, color: cText)),
                              Text('${r.category} · ${r.formattedAmount}',
                                style: const TextStyle(
                                  fontSize: 12, color: cSub)),
                              const SizedBox(height: 4),
                              Text(
                                days <= 0
                                    ? '⚠️ Warranty expired'
                                    : days <= 30
                                        ? '🔴 Expires in $days days!'
                                        : '✅ $days days remaining',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: days <= 0
                                      ? cSub
                                      : days <= 30 ? cDanger : cPrimary),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const Text('Until',
                              style: TextStyle(
                                fontSize: 12, color: cSub)),
                            Text(r.warranty!.split('T')[0],
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 13, color: cText)),
                          ],
                        ),
                      ]),
                    );
                  }).toList(),
                ),
        ),
      ]),
    );
  }
}
