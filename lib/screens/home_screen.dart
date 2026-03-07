import 'package:flutter/material.dart';
import '../models/receipt_model.dart';
import '../utils/constants.dart';
import '../widgets/receipt_card.dart';
import '../widgets/search_bar.dart';

class HomeScreen extends StatefulWidget {
  final List<Receipt> receipts;
  final ValueChanged<Receipt> onView;
  final ValueChanged<int> onDelete;

  const HomeScreen({
    super.key,
    required this.receipts,
    required this.onView,
    required this.onDelete,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _search = '';
  String _cat    = 'All';

  List<Receipt> get _filtered => widget.receipts.where((r) =>
    (_cat == 'All' || r.category == _cat) &&
    (r.store.toLowerCase().contains(_search.toLowerCase()) ||
     r.category.toLowerCase().contains(_search.toLowerCase()))
  ).toList();

  double get _thisMonth {
    final now = DateTime.now();
    return widget.receipts
        .where((r) => DateTime.parse(r.date).month == now.month)
        .fold(0, (sum, r) => sum + r.amount);
  }

  int get _warningCount => widget.receipts.where((r) {
    final d = r.daysToWarranty;
    return d != null && d > 0 && d <= 30;
  }).length;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ──────────────────────────────────────────────────────
          Container(
            decoration: const BoxDecoration(
              color: cPrimary,
              borderRadius:
                  BorderRadius.vertical(bottom: Radius.circular(28)),
            ),
            padding: const EdgeInsets.fromLTRB(20, 56, 20, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Welcome back 👋',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7), fontSize: 13)),
                const Text('ResiboScan',
                  style: TextStyle(
                    fontFamily: 'Georgia', color: Colors.white,
                    fontSize: 22, fontWeight: FontWeight.w800)),
                const SizedBox(height: 20),

                // Summary cards
                Row(children: [
                  for (final s in [
                    {'label': 'Total Receipts', 'value': '${widget.receipts.length}',         'sub': 'all time'},
                    {'label': 'This Month',     'value': '₱${_thisMonth.toStringAsFixed(0)}', 'sub': 'spending'},
                  ])
                    Expanded(
                      child: Container(
                        margin: EdgeInsets.only(
                          right: s['label'] == 'Total Receipts' ? 6 : 0),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.14),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(s['label']!, style: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                              fontSize: 11)),
                            const SizedBox(height: 4),
                            Text(s['value']!, style: const TextStyle(
                              color: Colors.white, fontSize: 20,
                              fontWeight: FontWeight.w800)),
                            Text(s['sub']!, style: TextStyle(
                              color: Colors.white.withOpacity(0.5),
                              fontSize: 11)),
                          ],
                        ),
                      ),
                    ),
                ]),

                // Warranty warning banner
                if (_warningCount > 0) ...[
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: cAccent.withOpacity(0.13),
                      borderRadius: BorderRadius.circular(12),
                      border:
                          Border.all(color: cAccent.withOpacity(0.33)),
                    ),
                    child: Row(children: [
                      const Icon(Icons.warning_amber_rounded,
                          color: cAccent, size: 16),
                      const SizedBox(width: 8),
                      Text(
                        '$_warningCount warranty'
                        '${_warningCount > 1 ? "s" : ""} expiring soon!',
                        style: const TextStyle(
                          color: Colors.white, fontSize: 12)),
                    ]),
                  ),
                ],
              ],
            ),
          ),

          // ── Body ────────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 90),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppSearchBar(
                  value: _search,
                  onChange: (v) => setState(() => _search = v)),
                const SizedBox(height: 14),

                // Category chips
                SizedBox(
                  height: 36,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: categories.map((c) => GestureDetector(
                      onTap: () => setState(() => _cat = c),
                      child: Container(
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: _cat == c ? cPrimary : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: _cat == c ? cPrimary : cBorder,
                            width: 1.5),
                        ),
                        child: Text(c, style: TextStyle(
                          fontSize: 12,
                          fontWeight: _cat == c
                              ? FontWeight.w700 : FontWeight.w400,
                          color: _cat == c ? Colors.white : cSub,
                        )),
                      ),
                    )).toList(),
                  ),
                ),
                const SizedBox(height: 16),

                // Results header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Recent Receipts',
                      style: TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w700,
                        color: cText)),
                    Text('${_filtered.length} found',
                      style: const TextStyle(fontSize: 12, color: cSub)),
                  ],
                ),
                const SizedBox(height: 10),

                // Receipt list
                if (_filtered.isEmpty)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 40),
                      child: Text('No receipts found',
                        style: TextStyle(color: cSub, fontSize: 14)),
                    ),
                  )
                else
                  ...(_filtered.map((r) => ReceiptCard(
                    receipt: r,
                    onTap: () => widget.onView(r),
                    onDelete: () => widget.onDelete(r.id),
                  ))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
