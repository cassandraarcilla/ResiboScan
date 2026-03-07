import 'package:flutter/material.dart';
import '../models/receipt_model.dart';
import '../utils/constants.dart';

class ExpensesScreen extends StatelessWidget {
  final List<Receipt> receipts;
  const ExpensesScreen({super.key, required this.receipts});

  @override
  Widget build(BuildContext context) {
    final total = receipts.fold<double>(0, (s, r) => s + r.amount);
    final colorList = catColors.values.toList();

    final byCat = categories.where((c) => c != 'All').map((c) {
      final list = receipts.where((r) => r.category == c).toList();
      return {
        'cat'   : c,
        'amount': list.fold<double>(0, (s, r) => s + r.amount),
        'count' : list.length,
      };
    }).where((c) => (c['count'] as int) > 0).toList()
      ..sort((a, b) =>
          (b['amount'] as double).compareTo(a['amount'] as double));

    return SingleChildScrollView(
      child: Column(children: [
        // Header
        Container(
          color: cPrimary,
          padding: const EdgeInsets.fromLTRB(20, 56, 20, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Overview',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7), fontSize: 12)),
              const Text('Expense Summary',
                style: TextStyle(
                  fontFamily: 'Georgia', color: Colors.white,
                  fontSize: 22, fontWeight: FontWeight.w800)),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.14),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Total Spent',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 12)),
                    const SizedBox(height: 4),
                    Text('₱${total.toStringAsFixed(2)}',
                      style: const TextStyle(
                        color: Colors.white, fontSize: 28,
                        fontWeight: FontWeight.w800)),
                    Text('${receipts.length} receipts',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.5),
                        fontSize: 12)),
                  ],
                ),
              ),
            ],
          ),
        ),

        Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 90),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: cBorder),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Breakdown',
                  style: TextStyle(
                    fontSize: 15, fontWeight: FontWeight.w700,
                    color: cText)),
                const SizedBox(height: 16),
                ...byCat.asMap().entries.map((e) {
                  final c   = e.value;
                  final pct = total > 0
                      ? (c['amount'] as double) / total : 0.0;
                  final col = colorList[e.key % colorList.length];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                          children: [
                            Text(c['cat'] as String,
                              style: const TextStyle(
                                fontSize: 13, color: cText)),
                            Text(
                              '₱${(c['amount'] as double).toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: cText)),
                          ],
                        ),
                        const SizedBox(height: 6),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: pct.toDouble(),
                            backgroundColor: cBorder,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(col),
                            minHeight: 8,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          '${c['count']} receipts · '
                          '${(pct * 100).toStringAsFixed(1)}%',
                          style: const TextStyle(
                            fontSize: 11, color: cSub)),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
      ]),
    );
  }
}
