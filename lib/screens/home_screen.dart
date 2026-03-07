import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/receipt_model.dart';
import '../utils/constants.dart';
import '../widgets/receipt_card.dart';

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

class _HomeScreenState extends State<HomeScreen>
    with TickerProviderStateMixin {
  String _search = '';
  String _cat    = 'All';

  late final AnimationController _pulseCtrl;
  late final AnimationController _entryCtrl;
  late final Animation<double>   _pulseAnim;
  late final Animation<double>   _entryAnim;

  List<Receipt> get _filtered => widget.receipts.where((r) =>
    (_cat == 'All' || r.category == _cat) &&
    (r.store.toLowerCase().contains(_search.toLowerCase()) ||
     r.category.toLowerCase().contains(_search.toLowerCase()))
  ).toList();

  double get _thisMonth {
    final now = DateTime.now();
    return widget.receipts
        .where((r) {
          try { return DateTime.parse(r.date).month == now.month; }
          catch (_) { return false; }
        })
        .fold(0.0, (sum, r) => sum + r.amount);
  }

  int get _warningCount => widget.receipts.where((r) {
    final d = r.daysToWarranty;
    return d != null && d > 0 && d <= 30;
  }).length;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));

    _entryCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..forward();
    _entryAnim = CurvedAnimation(
      parent: _entryCtrl, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    _entryCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));

    final topPad = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: _cream,
      body: FadeTransition(
        opacity: _entryAnim,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [

            // ── HERO CARD ────────────────────────────────────────────
            SliverToBoxAdapter(
              child: _HeroCard(
                topPad:       topPad,
                pulseAnim:    _pulseAnim,
                receipts:     widget.receipts,
                thisMonth:    _thisMonth,
                warningCount: _warningCount,
              ),
            ),

            // ── SEARCH + CHIPS + HEADING ─────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SearchBox(
                      value: _search,
                      onChange: (v) => setState(() => _search = v),
                    ),
                    const SizedBox(height: 16),
                    _Chips(
                      selected: _cat,
                      onSelect: (c) => setState(() => _cat = c),
                    ),
                    const SizedBox(height: 26),
                    _SectionLabel(count: _filtered.length),
                    const SizedBox(height: 14),
                  ],
                ),
              ),
            ),

            // ── RECEIPT CARDS ─────────────────────────────────────────
            _filtered.isEmpty
                ? const SliverFillRemaining(
                    hasScrollBody: false,
                    child: _EmptyState(),
                  )
                : SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 110),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (ctx, i) => _AnimatedCard(
                          index: i,
                          child: ReceiptCard(
                            receipt:  _filtered[i],
                            onTap:    () => widget.onView(_filtered[i]),
                            onDelete: () =>
                                widget.onDelete(_filtered[i].id),
                          ),
                        ),
                        childCount: _filtered.length,
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// HERO CARD
// ─────────────────────────────────────────────────────────────────────────────
class _HeroCard extends StatelessWidget {
  final double topPad;
  final Animation<double> pulseAnim;
  final List<Receipt> receipts;
  final double thisMonth;
  final int warningCount;

  const _HeroCard({
    required this.topPad,
    required this.pulseAnim,
    required this.receipts,
    required this.thisMonth,
    required this.warningCount,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16, topPad + 14, 16, 0),
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end:   Alignment.bottomRight,
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
                top: -70, right: -50,
                child: Container(
                  width: 240, height: 240,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.055),
                  ),
                ),
              ),
              Positioned(
                bottom: -50, left: -40,
                child: Container(
                  width: 180, height: 180,
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
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(children: [
                              AnimatedBuilder(
                                animation: pulseAnim,
                                builder: (_, __) => Opacity(
                                  opacity: pulseAnim.value,
                                  child: Container(
                                    width: 6, height: 6,
                                    margin: const EdgeInsets.only(
                                        right: 7, bottom: 1),
                                    decoration: const BoxDecoration(
                                      color: _sandy,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ),
                              ),
                              Text('Welcome back!!!',
                                style: TextStyle(
                                  color: _vanilla.withOpacity(0.78),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                )),
                            ]),
                            const SizedBox(height: 5),
                            RichText(
                              text: const TextSpan(
                                style: TextStyle(
                                  fontFamily: 'Georgia',
                                  fontSize: 30,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: -0.8,
                                  height: 1.0,
                                ),
                                children: [
                                  TextSpan(text: 'Resibo',
                                    style: TextStyle(color: _white)),
                                  TextSpan(text: 'Scan',
                                    style: TextStyle(color: _vanilla)),
                                ],
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
                            child: Text('🧾',
                              style: TextStyle(fontSize: 24))),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(children: [
                      _StatTile(
                        label: 'Total Receipts',
                        value: '${receipts.length}',
                        sub: 'all time',
                        valueColor: _vanilla,
                        rightMargin: 10,
                      ),
                      _StatTile(
                        label: 'This Month',
                        value: '₱${thisMonth.toStringAsFixed(0)}',
                        sub: 'spending',
                        valueColor: _sandy,
                        rightMargin: 0,
                      ),
                    ]),
                    if (warningCount > 0) ...[
                      const SizedBox(height: 12),
                      _WarningBanner(count: warningCount),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
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
    required this.label, required this.value, required this.sub,
    required this.valueColor, required this.rightMargin,
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
          border: Border.all(color: Colors.white.withOpacity(0.18), width: 1.0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(
              color: Colors.white.withOpacity(0.55),
              fontSize: 10.5, letterSpacing: 0.2)),
            const SizedBox(height: 7),
            Text(value, style: TextStyle(
              fontFamily: 'Georgia', color: valueColor,
              fontSize: 26, fontWeight: FontWeight.w900,
              letterSpacing: -0.6, height: 1.0)),
            const SizedBox(height: 3),
            Text(sub, style: TextStyle(
              color: Colors.white.withOpacity(0.36), fontSize: 10)),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// WARNING BANNER
// ─────────────────────────────────────────────────────────────────────────────
class _WarningBanner extends StatelessWidget {
  final int count;
  const _WarningBanner({required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      decoration: BoxDecoration(
        color: _brick.withOpacity(0.22),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _brick.withOpacity(0.45), width: 1.0),
      ),
      child: Row(children: [
        Container(
          width: 30, height: 30,
          decoration: BoxDecoration(
            color: _brick.withOpacity(0.28), shape: BoxShape.circle),
          child: const Center(
            child: Text('⚠️', style: TextStyle(fontSize: 13))),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$count ${count > 1 ? "warranties" : "warranty"} expiring soon!',
                style: const TextStyle(
                  color: _white, fontSize: 12.5, fontWeight: FontWeight.w700)),
              Text('Review before they expire',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.50), fontSize: 10.5)),
            ],
          ),
        ),
        const Icon(Icons.chevron_right, color: Colors.white54, size: 18),
      ]),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SEARCH BOX
// ─────────────────────────────────────────────────────────────────────────────
class _SearchBox extends StatelessWidget {
  final String value;
  final ValueChanged<String> onChange;
  const _SearchBox({required this.value, required this.onChange});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(
          color: _cerulean.withOpacity(0.09),
          blurRadius: 18, offset: const Offset(0, 5))],
      ),
      child: TextField(
        onChanged: onChange,
        style: const TextStyle(
          fontSize: 13.5, color: _inkMid, fontWeight: FontWeight.w500),
        decoration: InputDecoration(
          hintText: 'Search store or category...',
          hintStyle: TextStyle(
            color: _inkLight.withOpacity(0.65), fontSize: 13),
          prefixIcon: Container(
            margin: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: _cerulean.withOpacity(0.09),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.search_rounded,
              color: _cerulean, size: 18),
          ),
          suffixIcon: Padding(
            padding: const EdgeInsets.only(right: 14),
            child: Icon(Icons.tune_rounded,
              color: _inkLight.withOpacity(0.40), size: 18),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 8, vertical: 16),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// CATEGORY CHIPS — real Material Icons, black color
// ─────────────────────────────────────────────────────────────────────────────
class _Chips extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onSelect;
  const _Chips({required this.selected, required this.onSelect});

  // Uses catIcons from constants.dart — real icons, no emoji
  static const _labels = [
    'All', 'Groceries', 'Food & Dining',
    'Electronics', 'Utilities', 'Education', 'Others',
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: _labels.length,
        itemBuilder: (_, i) {
          final label = _labels[i];
          final icon  = catIcons[label] ?? Icons.category_rounded;
          final sel   = selected == label;

          return GestureDetector(
            onTap: () => onSelect(label),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
              margin: const EdgeInsets.only(right: 9),
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: sel ? _cerulean : _white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: sel ? _cerulean : _cyan.withOpacity(0.20),
                  width: sel ? 0 : 1.5,
                ),
                boxShadow: sel
                    ? [BoxShadow(
                        color: _cerulean.withOpacity(0.28),
                        blurRadius: 10,
                        offset: const Offset(0, 4))]
                    : [BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 5,
                        offset: const Offset(0, 2))],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    icon,
                    size: 15,
                    // black when unselected, white when selected
                    color: sel ? _white : Colors.black,
                  ),
                  const SizedBox(width: 6),
                  Text(label,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: sel ? FontWeight.w700 : FontWeight.w500,
                      color: sel ? _white : _inkMid,
                      letterSpacing: 0.1,
                    )),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SECTION LABEL
// ─────────────────────────────────────────────────────────────────────────────
class _SectionLabel extends StatelessWidget {
  final int count;
  const _SectionLabel({required this.count});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(children: [
          Container(
            width: 4, height: 20,
            margin: const EdgeInsets.only(right: 10),
            decoration: BoxDecoration(
              color: _sandy, borderRadius: BorderRadius.circular(2)),
          ),
          const Text('Recent Receipts',
            style: TextStyle(
              fontFamily: 'Georgia', fontSize: 17,
              fontWeight: FontWeight.w700, color: _ink,
              letterSpacing: -0.3)),
        ]),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          decoration: BoxDecoration(
            color: _vanillaSoft,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: _vanilla, width: 1.5),
          ),
          child: Text('$count found',
            style: const TextStyle(
              fontSize: 11, fontWeight: FontWeight.w700,
              color: _cerulean, letterSpacing: 0.2)),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ANIMATED CARD
// ─────────────────────────────────────────────────────────────────────────────
class _AnimatedCard extends StatelessWidget {
  final int index;
  final Widget child;
  const _AnimatedCard({required this.index, required this.child});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 350 + index * 60),
      curve: Curves.easeOutCubic,
      builder: (_, v, c) => Opacity(
        opacity: v,
        child: Transform.translate(
          offset: Offset(0, 16 * (1 - v)),
          child: c,
        ),
      ),
      child: child,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// EMPTY STATE
// ─────────────────────────────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  const _EmptyState();

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
              boxShadow: [BoxShadow(
                color: _vanilla.withOpacity(0.6),
                blurRadius: 22, spreadRadius: 4)],
            ),
            child: const Center(
              child: Text('🧾', style: TextStyle(fontSize: 28))),
          ),
          const SizedBox(height: 16),
          const Text('No receipts found',
            style: TextStyle(
              fontFamily: 'Georgia', fontSize: 16,
              fontWeight: FontWeight.w700, color: _inkMid)),
          const SizedBox(height: 6),
          Text('Try a different filter or scan a new receipt',
            style: TextStyle(
              fontSize: 12.5, color: _inkLight.withOpacity(0.8))),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 24, vertical: 12),
            decoration: BoxDecoration(
              color: _cerulean,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [BoxShadow(
                color: _cerulean.withOpacity(0.28),
                blurRadius: 14, offset: const Offset(0, 5))],
            ),
            child: const Text('Scan a Receipt',
              style: TextStyle(
                fontSize: 13, fontWeight: FontWeight.w700,
                color: _white, letterSpacing: 0.2)),
          ),
        ],
      ),
    );
  }
}