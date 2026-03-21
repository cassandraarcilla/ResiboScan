import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../models/receipt_model.dart';

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

class AlertsScreen extends StatelessWidget {
  final List<Receipt> receipts;
  const AlertsScreen({super.key, required this.receipts});

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;

    // Logic: filter and sort by days remaining
    final warranties = receipts
        .where((r) => r.warranty != null)
        .map((r) => {'receipt': r, 'days': r.daysToWarranty ?? 0})
        .toList()
      ..sort((a, b) => (a['days'] as int).compareTo(b['days'] as int));

    final expired  = warranties.where((w) => (w['days'] as int) <= 0).toList();
    final critical = warranties.where((w) => (w['days'] as int) > 0 && (w['days'] as int) <= 30).toList();
    final healthy  = warranties.where((w) => (w['days'] as int) > 30).toList();

    return Scaffold(
      backgroundColor: _cream,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── HERO HEADER ───────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(16, topPad + 14, 16, 0),
              child: Container(
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF1A546B), _cerulean, _cyan],
                  ),
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: _cerulean.withOpacity(0.3),
                      blurRadius: 30,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    Positioned(
                      top: -40, right: -30,
                      child: CircleAvatar(
                        radius: 80, 
                        backgroundColor: Colors.white.withOpacity(0.05)
                      ),
                    ),
                    Positioned(
                      bottom: -20, left: -20,
                      child: CircleAvatar(
                        radius: 60, 
                        backgroundColor: _vanilla.withOpacity(0.06)
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(24),
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
                                    'REMINDERS',
                                    style: TextStyle(
                                      color: _vanilla.withOpacity(0.7),
                                      fontSize: 10,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 1.2,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  const Text(
                                    'Warranty Alerts',
                                    style: TextStyle(
                                      fontFamily: 'Georgia',
                                      color: _white,
                                      fontSize: 26,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: Colors.white.withOpacity(0.2)),
                                ),
                                child: const Icon(Icons.notifications_active_rounded, color: _white, size: 24),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              _SummaryPill(
                                icon: Icons.error_outline_rounded,
                                iconColor: _white,
                                label: '${critical.length} Critical',
                                color: _brick.withOpacity(0.8),
                                textColor: _white,
                              ),
                              _SummaryPill(
                                icon: Icons.check_circle_outline_rounded,
                                iconColor: _white,
                                label: '${healthy.length} Healthy',
                                color: _cerulean.withOpacity(0.8),
                                textColor: _white,
                              ),
                              _SummaryPill(
                                icon: Icons.history_rounded,
                                iconColor: _inkMid,
                                label: '${expired.length} Expired',
                                color: _white.withOpacity(0.2),
                                textColor: _inkMid,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── BODY ──────────────────────────────────────────────────────
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 28, 16, 110),
            sliver: warranties.isEmpty
                ? SliverFillRemaining(
                    hasScrollBody: false,
                    child: _EmptyAlerts(),
                  )
                : SliverList(
                    delegate: SliverChildListDelegate([
                      if (critical.isNotEmpty) ...[
                        const _GroupLabel(title: 'Expiring Soon', iconColor: _brick),
                        const SizedBox(height: 12),
                        ...critical.map((w) => _WarrantyTile(
                          receipt: w['receipt'] as Receipt,
                          days: w['days'] as int,
                        )),
                        const SizedBox(height: 24),
                      ],
                      if (healthy.isNotEmpty) ...[
                        const _GroupLabel(title: 'Active Warranties', iconColor: Color(0xFF8DB48E)),
                        const SizedBox(height: 12),
                        ...healthy.map((w) => _WarrantyTile(
                          receipt: w['receipt'] as Receipt,
                          days: w['days'] as int,
                        )),
                        const SizedBox(height: 24),
                      ],
                      if (expired.isNotEmpty) ...[
                        const _GroupLabel(title: 'Expired', iconColor: _inkLight),
                        const SizedBox(height: 12),
                        ...expired.map((w) => _WarrantyTile(
                          receipt: w['receipt'] as Receipt,
                          days: w['days'] as int,
                        )),
                      ],
                    ]),
                  ),
          ),
        ],
      ),
    );
  }
}

class _SummaryPill extends StatelessWidget {
  final IconData icon;
  final Color iconColor, label, color, textColor;
  const _SummaryPill({required this.icon, required this.iconColor, required this.label, required this.color, required this.textColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 14, color: iconColor),
        const SizedBox(width: 6),
        Text(label as String, style: TextStyle(color: textColor, fontSize: 11, fontWeight: FontWeight.bold)),
      ]),
    );
  }
}

class _GroupLabel extends StatelessWidget {
  final String title;
  final Color iconColor;
  const _GroupLabel({required this.title, required this.iconColor});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      CircleAvatar(radius: 4, backgroundColor: iconColor),
      const SizedBox(width: 8),
      Text(title, style: const TextStyle(fontFamily: 'Georgia', fontSize: 17, fontWeight: FontWeight.w800, color: _ink)),
      const Spacer(),
      const Icon(Icons.arrow_forward_ios_rounded, size: 12, color: _inkLight),
    ]);
  }
}

class _WarrantyTile extends StatelessWidget {
  final Receipt receipt;
  final int days;
  const _WarrantyTile({required this.receipt, required this.days});

  @override
  Widget build(BuildContext context) {
    final isExpired = days <= 0;
    final isCritical = !isExpired && days <= 30;
    final accentColor = isExpired ? _inkLight : isCritical ? _brick : _cerulean;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: _white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: _ink.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(children: [
          Container(
            width: 52, height: 52,
            decoration: BoxDecoration(color: accentColor.withOpacity(0.08), shape: BoxShape.circle),
            child: ClipOval(
              child: SvgPicture.asset(_catSvg[receipt.category] ?? '$_imgBase/8.svg', fit: BoxFit.cover),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(receipt.store, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: _ink), maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 2),
                Text('${receipt.category} · ${receipt.formattedAmount}', style: const TextStyle(fontSize: 12, color: _inkLight)),
                const SizedBox(height: 8),
                Text(
                  isExpired ? 'Coverage Ended' : (isCritical ? 'Expires in $days days' : '$days days left'),
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: accentColor, letterSpacing: 0.2),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text('VALID UNTIL', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: _inkLight, letterSpacing: 0.5)),
              const SizedBox(height: 4),
              Text(receipt.warranty!.split('T')[0], style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: _inkMid)),
            ],
          ),
        ]),
      ),
    );
  }
}

class _EmptyAlerts extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80, height: 80,
            decoration: const BoxDecoration(color: _vanillaSoft, shape: BoxShape.circle),
            child: const Icon(Icons.notifications_none_rounded, color: _sandy, size: 40),
          ),
          const SizedBox(height: 20),
          const Text('All quiet here', style: TextStyle(fontFamily: 'Georgia', fontSize: 18, fontWeight: FontWeight.w700, color: _inkMid)),
          const SizedBox(height: 8),
          const Text('No warranty reminders to show right now', style: TextStyle(fontSize: 13, color: _inkLight)),
        ],
      ),
    );
  }
}
