import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../models/receipt_model.dart';

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

// ── SVG asset map — same as expenses_screen & scan_modal ─────────────────────
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

    final warranties = receipts
        .where((r) => r.warranty != null)
        .map((r) => {'receipt': r, 'days': r.daysToWarranty!})
        .toList()
      ..sort((a, b) =>
          (a['days'] as int).compareTo(b['days'] as int));

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
                        top: -50, right: -40,
                        child: Container(
                          width: 180, height: 180,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.055),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: -30, left: -30,
                        child: Container(
                          width: 130, height: 130,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _vanilla.withOpacity(0.07),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(22, 22, 22, 22),
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
                                      'Reminders',
                                      style: TextStyle(
                                        color: _vanilla.withOpacity(0.72),
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                        letterSpacing: 0.3,
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
                                      Icons.notifications_rounded,
                                      color: Colors.white,
                                      size: 26,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 18),
                            Row(children: [
                              _SummaryPill(
                                icon: Icons.circle,
                                iconColor: _brick,
                                label: '${critical.length} Critical',
                                color: _brick.withOpacity(0.28),
                                textColor: _vanilla,
                              ),
                              const SizedBox(width: 8),
                              _SummaryPill(
                                icon: Icons.check_circle_rounded,
                                iconColor: Colors.greenAccent,
                                label: '${healthy.length} Healthy',
                                color: Colors.white.withOpacity(0.12),
                                textColor: _vanilla,
                              ),
                              const SizedBox(width: 8),
                              _SummaryPill(
                                icon: Icons.warning_rounded,
                                iconColor: _sandy,
                                label: '${expired.length} Expired',
                                color: Colors.white.withOpacity(0.08),
                                textColor: _inkLight,
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

          // ── BODY ──────────────────────────────────────────────────────
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 110),
            sliver: warranties.isEmpty
                ? SliverFillRemaining(
                    hasScrollBody: false,
                    child: _EmptyAlerts(),
                  )
                : SliverList(
                    delegate: SliverChildListDelegate([
                      if (critical.isNotEmpty) ...[
                        const _GroupLabel(
                          title: 'Expiring Soon',
                          icon: Icons.circle,
                          iconColor: _brick,
                        ),
                        const SizedBox(height: 10),
                        ...critical.map((w) => _WarrantyTile(
                          receipt: w['receipt'] as Receipt,
                          days: w['days'] as int,
                        )),
                        const SizedBox(height: 20),
                      ],
                      if (healthy.isNotEmpty) ...[
                        const _GroupLabel(
                          title: 'Active Warranties',
                          icon: Icons.check_circle_rounded,
                          iconColor: Color(0xFF8DB48E),
                        ),
                        const SizedBox(height: 10),
                        ...healthy.map((w) => _WarrantyTile(
                          receipt: w['receipt'] as Receipt,
                          days: w['days'] as int,
                        )),
                        const SizedBox(height: 20),
                      ],
                      if (expired.isNotEmpty) ...[
                        const _GroupLabel(
                          title: 'Expired',
                          icon: Icons.warning_rounded,
                          iconColor: _sandy,
                        ),
                        const SizedBox(height: 10),
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

// ─────────────────────────────────────────────────────────────────────────────
class _SummaryPill extends StatelessWidget {
  final IconData icon;
  final Color    iconColor;
  final String   label;
  final Color    color, textColor;

  const _SummaryPill({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.color,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.12), width: 1),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 11, color: iconColor),
        const SizedBox(width: 5),
        Text(label, style: TextStyle(
          color: textColor,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        )),
      ]),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
class _GroupLabel extends StatelessWidget {
  final String   title;
  final IconData icon;
  final Color    iconColor;

  const _GroupLabel({
    required this.title,
    required this.icon,
    required this.iconColor,
  });

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
      Icon(icon, size: 14, color: iconColor),
      const SizedBox(width: 6),
      Text(
        title,
        style: const TextStyle(
          fontFamily: 'Georgia',
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: _ink,
          letterSpacing: -0.3,
        ),
      ),
    ]);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// WARRANTY TILE — SVG image from category, same as expenses & scan modal
// ─────────────────────────────────────────────────────────────────────────────
class _WarrantyTile extends StatelessWidget {
  final Receipt receipt;
  final int days;
  const _WarrantyTile({required this.receipt, required this.days});

  @override
  Widget build(BuildContext context) {
    final isExpired  = days <= 0;
    final isCritical = !isExpired && days <= 30;

    final Color accentColor = isExpired
        ? _inkLight
        : isCritical
            ? _brick
            : _cerulean;

    final Color bgTint = isExpired
        ? _inkLight.withOpacity(0.06)
        : isCritical
            ? _brick.withOpacity(0.06)
            : _cerulean.withOpacity(0.05);

    final IconData statusIcon = isExpired
        ? Icons.warning_rounded
        : isCritical
            ? Icons.circle
            : Icons.check_circle_rounded;

    final String statusText = isExpired
        ? 'Warranty expired'
        : isCritical
            ? 'Expires in $days days!'
            : '$days days remaining';

    // Resolve SVG: prefer category SVG, fall back to stored image path
    final String svgAsset =
        _catSvg[receipt.category] ?? '$_imgBase/8.svg';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: _white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: accentColor.withOpacity(0.18),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: accentColor.withOpacity(0.07),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(children: [
          // SVG circle image — matches category icon
          ClipOval(
            child: SvgPicture.asset(
              svgAsset,
              width : 52,
              height: 52,
              fit   : BoxFit.cover,
              placeholderBuilder: (_) => Container(
                width: 52, height: 52,
                color: bgTint,
                child: Icon(
                  Icons.receipt_long_rounded,
                  color: accentColor,
                  size: 26,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  receipt.store,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14.5,
                    color: _ink,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${receipt.category} · ${receipt.formattedAmount}',
                  style: const TextStyle(fontSize: 12, color: _inkLight),
                ),
                const SizedBox(height: 5),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: accentColor.withOpacity(0.10),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(statusIcon, size: 11, color: accentColor),
                      const SizedBox(width: 4),
                      Text(
                        statusText,
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          color: accentColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Date column
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('Until', style: TextStyle(
                fontSize: 11,
                color: _inkLight.withOpacity(0.7),
              )),
              const SizedBox(height: 3),
              Text(
                receipt.warranty!.split('T')[0],
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                  color: _inkMid,
                ),
              ),
            ],
          ),
        ]),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
class _EmptyAlerts extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 78, height: 78,
            decoration: BoxDecoration(
              color: _vanillaSoft,
              shape: BoxShape.circle,
              border: Border.all(
                color: _sandy.withOpacity(0.30), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: _vanilla.withOpacity(0.6),
                  blurRadius: 22,
                  spreadRadius: 4,
                ),
              ],
            ),
            child: const Center(
              child: Icon(
                Icons.notifications_off_rounded,
                color: Colors.black,
                size: 32,
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text('No warranty reminders yet',
            style: TextStyle(
              fontFamily: 'Georgia',
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: _inkMid,
            )),
          const SizedBox(height: 6),
          Text(
            'Add receipts with warranty dates to get alerts',
            style: TextStyle(
              fontSize: 12.5,
              color: _inkLight.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }
}