import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../models/receipt_model.dart';
import '../utils/constants.dart';

// ── Vintage Hues Palette ─────────────────────────────────────────────────────
const _cerulean    = Color(0xFF2D728F);
const _cyan        = Color(0xFF3B8EA5);
const _vanilla     = Color(0xFFF5EE9E);
const _sandy       = Color(0xFFF49E4C);
const _brick       = Color(0xFFAB3428);
const _cream       = Color(0xFFFDF8EC);
const _white       = Color(0xFFFFFFFF);
const _ink         = Color(0xFF0F2027);
const _inkMid      = Color(0xFF2C4A55);
const _inkLight    = Color(0xFF7A9BAA);
const _vanillaSoft = Color(0xFFFAF3C0);

// ── SVG asset map — matches _receiptIcons order in scan_modal.dart ────────────
//   1.svg = Grocery   2.svg = Dining    3.svg = Electronics  4.svg = Utilities
//   5.svg = Education 6.svg = Health    7.svg = Clothing      8.svg = Others
//   9.svg = Personal  10.svg = Work
const _imgBase = 'assets/images';
const _catSvg = <String, String>{
  'Grocery'      : '$_imgBase/1.svg',
  'Groceries'    : '$_imgBase/1.svg',
  'Dining'       : '$_imgBase/2.svg',
  'Food & Dining': '$_imgBase/2.svg',
  'Electronics'  : '$_imgBase/3.svg',
  'Utilities'    : '$_imgBase/4.svg',
  'Education'    : '$_imgBase/5.svg',
  'Health'       : '$_imgBase/6.svg',
  'Clothing'     : '$_imgBase/7.svg',
  'Others'       : '$_imgBase/8.svg',
  'Personal'     : '$_imgBase/9.svg',
  'Work'         : '$_imgBase/10.svg',
};

class ExpensesScreen extends StatelessWidget {
  final List<Receipt> receipts;
  const ExpensesScreen({super.key, required this.receipts});

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;
    final total  = receipts.fold<double>(0, (s, r) => s + r.amount);

    // Category breakdown
    final byCat = categories.where((c) => c != 'All').map((c) {
      final list = receipts.where((r) => r.category == c).toList();
      return {
        'cat'   : c,
        'amount': list.fold<double>(0, (s, r) => s + r.amount),
        'count' : list.length,
        'svg'   : _catSvg[c] ?? '$_imgBase/8.svg',
      };
    }).where((c) => (c['count'] as int) > 0).toList()
      ..sort((a, b) => (b['amount'] as double).compareTo(a['amount'] as double));

    // Monthly breakdown (last 3 months)
    final now = DateTime.now();
    final monthly = List.generate(3, (i) {
      final month = DateTime(now.year, now.month - i, 1);
      final sum   = receipts
          .where((r) {
            final d = DateTime.parse(r.date);
            return d.month == month.month && d.year == month.year;
          })
          .fold<double>(0, (s, r) => s + r.amount);
      return {'label': _monthLabel(month), 'amount': sum};
    }).reversed.toList();

    // Vintage category color palette
    final catColorList = [
      _cerulean,
      _sandy,
      _brick,
      _cyan,
      const Color(0xFF8DB48E),
      const Color(0xFFD4A853),
    ];

    return Scaffold(
      backgroundColor: _cream,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── HERO HEADER ──────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(16, topPad + 14, 16, 0),
              child: Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    stops: [0.0, 0.5, 1.0],
                    colors: [Color(0xFF1A546B), _cerulean, _cyan],
                  ),
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: _cerulean.withOpacity(0.38),
                      blurRadius: 36,
                      offset: const Offset(0, 16),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(28),
                  child: Stack(
                    children: [
                      Positioned(
                        top: -60, right: -40,
                        child: Container(
                          width: 200, height: 200,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.055),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: -40, left: -30,
                        child: Container(
                          width: 150, height: 150,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _vanilla.withOpacity(0.07),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(22, 22, 22, 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Overview',
                                      style: TextStyle(
                                        color: _vanilla.withOpacity(0.72),
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                        letterSpacing: 0.3,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    const Text(
                                      'Expense Summary',
                                      style: TextStyle(
                                        fontFamily: 'Georgia',
                                        color: _white,
                                        fontSize: 26,
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: -0.5,
                                      ),
                                    ),
                                  ],
                                ),
                                Container(
                                  width: 50, height: 50,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.13),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: Colors.white.withOpacity(0.24),
                                      width: 1.2,
                                    ),
                                  ),
                                  child: const Center(
                                    child: Icon(
                                      Icons.bar_chart_rounded,
                                      color: Colors.white,
                                      size: 26,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 18),
                            Row(children: [
                              _StatTile(
                                label: 'Total Spent',
                                value: '₱${total.toStringAsFixed(0)}',
                                sub: 'all time',
                                valueColor: _vanilla,
                                rightMargin: 10,
                              ),
                              _StatTile(
                                label: 'Receipts',
                                value: '${receipts.length}',
                                sub: 'recorded',
                                valueColor: _sandy,
                                rightMargin: 0,
                              ),
                            ]),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 110),
            sliver: SliverList(
              delegate: SliverChildListDelegate([

                // ── MONTHLY TREND ──────────────────────────────────────
                const _SectionLabel(
                  title: 'Monthly Trend',
                  icon: Icons.calendar_month_rounded,
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: _white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: _cerulean.withOpacity(0.10),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: _cerulean.withOpacity(0.06),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: monthly.asMap().entries.map((e) {
                      final m    = e.value;
                      final maxA = monthly
                          .map((x) => x['amount'] as double)
                          .reduce((a, b) => a > b ? a : b);
                      final ratio = maxA > 0
                          ? (m['amount'] as double) / maxA
                          : 0.0;
                      final isLast = e.key == monthly.length - 1;

                      return _MonthBar(
                        label   : m['label'] as String,
                        amount  : m['amount'] as double,
                        ratio   : ratio,
                        isActive: isLast,
                      );
                    }).toList(),
                  ),
                ),

                const SizedBox(height: 24),

                // ── CATEGORY BREAKDOWN ──────────────────────────────────
                const _SectionLabel(
                  title: 'By Category',
                  icon: Icons.label_rounded,
                ),
                const SizedBox(height: 12),

                if (byCat.isEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 32),
                    alignment: Alignment.center,
                    child: Text(
                      'No expenses recorded yet',
                      style: TextStyle(
                        fontSize: 13,
                        color: _inkLight.withOpacity(0.8),
                      ),
                    ),
                  )
                else
                  ...byCat.asMap().entries.map((e) {
                    final c   = e.value;
                    final pct = total > 0
                        ? (c['amount'] as double) / total : 0.0;
                    final col = catColorList[e.key % catColorList.length];

                    return _CategoryTile(
                      svgAsset: c['svg'] as String,
                      cat     : c['cat'] as String,
                      amount  : c['amount'] as double,
                      count   : c['count'] as int,
                      pct     : pct,
                      color   : col,
                    );
                  }),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  String _monthLabel(DateTime d) {
    const months = ['Jan','Feb','Mar','Apr','May','Jun',
                    'Jul','Aug','Sep','Oct','Nov','Dec'];
    return months[d.month - 1];
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// STAT TILE
// ─────────────────────────────────────────────────────────────────────────────
class _StatTile extends StatelessWidget {
  final String label, value, sub;
  final Color  valueColor;
  final double rightMargin;

  const _StatTile({
    required this.label,
    required this.value,
    required this.sub,
    required this.valueColor,
    required this.rightMargin,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        margin: EdgeInsets.only(right: rightMargin),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.10),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: Colors.white.withOpacity(0.18),
            width: 1.0,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
              style: TextStyle(
                color: Colors.white.withOpacity(0.55),
                fontSize: 10.5,
                letterSpacing: 0.2,
              )),
            const SizedBox(height: 7),
            Text(value,
              style: TextStyle(
                fontFamily: 'Georgia',
                color: valueColor,
                fontSize: 26,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.6,
                height: 1.0,
              )),
            const SizedBox(height: 3),
            Text(sub,
              style: TextStyle(
                color: Colors.white.withOpacity(0.36),
                fontSize: 10,
              )),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
class _SectionLabel extends StatelessWidget {
  final String   title;
  final IconData icon;
  const _SectionLabel({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Container(
        width: 4, height: 20,
        margin: const EdgeInsets.only(right: 10),
        decoration: BoxDecoration(
          color: _sandy,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
      Icon(icon, size: 16, color: Colors.black),
      const SizedBox(width: 6),
      Text(
        title,
        style: const TextStyle(
          fontFamily: 'Georgia',
          fontSize: 17,
          fontWeight: FontWeight.w700,
          color: _ink,
          letterSpacing: -0.3,
        ),
      ),
    ]);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
class _MonthBar extends StatelessWidget {
  final String label;
  final double amount, ratio;
  final bool   isActive;

  const _MonthBar({
    required this.label,
    required this.amount,
    required this.ratio,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    const maxH = 80.0;

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(
          '₱${amount.toStringAsFixed(0)}',
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: isActive ? _cerulean : _inkLight,
          ),
        ),
        const SizedBox(height: 4),
        AnimatedContainer(
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeOut,
          width: 36,
          height: (ratio * maxH).clamp(6.0, maxH),
          decoration: BoxDecoration(
            gradient: isActive
                ? const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [_cyan, _cerulean],
                  )
                : null,
            color: isActive ? null : _inkLight.withOpacity(0.18),
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
            color: isActive ? _inkMid : _inkLight,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// CATEGORY TILE — uses SVG circle image matching the receipt icon picker
// ─────────────────────────────────────────────────────────────────────────────
class _CategoryTile extends StatelessWidget {
  final String svgAsset, cat;
  final double amount, pct;
  final int    count;
  final Color  color;

  const _CategoryTile({
    required this.svgAsset,
    required this.cat,
    required this.amount,
    required this.count,
    required this.pct,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withOpacity(0.15), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.07),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(children: [
            // SVG circle — same style as the icon picker in scan_modal
            ClipOval(
              child: SvgPicture.asset(
                svgAsset,
                width : 44,
                height: 44,
                fit   : BoxFit.cover,
                placeholderBuilder: (_) => Container(
                  width: 44, height: 44,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.10),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.category_rounded, color: color, size: 22),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(cat, style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: _ink,
                  )),
                  Text('$count receipt${count != 1 ? "s" : ""}',
                    style: TextStyle(
                      fontSize: 11,
                      color: _inkLight.withOpacity(0.8),
                    )),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '₱${amount.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: _inkMid,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${(pct * 100).toStringAsFixed(1)}%',
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                      color: color,
                    ),
                  ),
                ),
              ],
            ),
          ]),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: pct),
              duration: const Duration(milliseconds: 700),
              curve: Curves.easeOut,
              builder: (_, v, __) => LinearProgressIndicator(
                value: v,
                backgroundColor: color.withOpacity(0.10),
                valueColor: AlwaysStoppedAnimation<Color>(color),
                minHeight: 7,
              ),
            ),
          ),
        ],
      ),
    );
  }
}