import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../models/receipt_model.dart';
import '../models/exchange_rate_model.dart';
import '../utils/constants.dart';
import '../widgets/receipt_card.dart';

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

  final ExchangeRate? exchangeRate;
  final bool rateLoading;
  final String? rateError;
  final VoidCallback? onRefreshRate;
  final bool simulateError;
  final VoidCallback? onToggleError;
  final bool simulateNoNet;
  final VoidCallback? onToggleNoNet;

  const HomeScreen({
    super.key,
    required this.receipts,
    required this.onView,
    required this.onDelete,
    this.exchangeRate,
    this.rateLoading = false,
    this.rateError,
    this.onRefreshRate,
    this.simulateError = false,
    this.onToggleError,
    this.simulateNoNet = false,
    this.onToggleNoNet,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  String _search = '';
  String _cat    = 'All';
  String _sortBy = 'date_desc';

  // ── Connectivity ─────────────────────────────────────────────────────────────
  bool _isOffline = false;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySub;

  late final AnimationController _pulseCtrl;
  late final AnimationController _entryCtrl;
  late final Animation<double>   _pulseAnim;
  late final Animation<double>   _entryAnim;

  // ── Filtered + sorted list ───────────────────────────────────────────────────
  List<Receipt> get _filtered {
    var list = widget.receipts.where((r) =>
        (_cat == 'All' || r.category == _cat) &&
        (r.store.toLowerCase().contains(_search.toLowerCase()) ||
            r.category.toLowerCase().contains(_search.toLowerCase()))).toList();

    switch (_sortBy) {
      case 'date_asc':    list.sort((a, b) => a.date.compareTo(b.date)); break;
      case 'date_desc':   list.sort((a, b) => b.date.compareTo(a.date)); break;
      case 'amount_desc': list.sort((a, b) => b.amount.compareTo(a.amount)); break;
      case 'amount_asc':  list.sort((a, b) => a.amount.compareTo(b.amount)); break;
      case 'name_asc':    list.sort((a, b) => a.store.toLowerCase().compareTo(b.store.toLowerCase())); break;
      case 'name_desc':   list.sort((a, b) => b.store.toLowerCase().compareTo(a.store.toLowerCase())); break;
    }
    return list;
  }

  double get _thisMonth {
    final now = DateTime.now();
    return widget.receipts.where((r) {
      try { return DateTime.parse(r.date).month == now.month; } catch (_) { return false; }
    }).fold(0.0, (sum, r) => sum + r.amount);
  }

  int get _warningCount => widget.receipts.where((r) {
    final d = r.daysToWarranty;
    return d != null && d > 0 && d <= 30;
  }).length;

  @override
  void initState() {
    super.initState();

    Connectivity().checkConnectivity().then((results) {
      if (mounted) setState(() => _isOffline = _noConnection(results));
    });

    _connectivitySub = Connectivity().onConnectivityChanged.listen((results) {
      if (!mounted) return;
      final offline = _noConnection(results);
      setState(() => _isOffline = offline);
      if (!offline) widget.onRefreshRate?.call();
    });

    _pulseCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1600))
      ..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.3, end: 1.0)
        .animate(CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));

    _entryCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 700))
      ..forward();
    _entryAnim = CurvedAnimation(parent: _entryCtrl, curve: Curves.easeOut);
  }

  bool _noConnection(List<ConnectivityResult> results) =>
      results.isEmpty || results.every((r) => r == ConnectivityResult.none);

  @override
  void dispose() {
    _connectivitySub?.cancel();
    _pulseCtrl.dispose();
    _entryCtrl.dispose();
    super.dispose();
  }

  void _showSortSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _SortSheet(
        current: _sortBy,
        onSelect: (val) {
          setState(() => _sortBy = val);
          Navigator.pop(context);
        },
      ),
    );
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
      body: Column(
        children: [
          // ── Offline banner ──────────────────────────────────────────────────
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: _isOffline ? null : 0,
            child: _isOffline
                ? Container(
                    width: double.infinity,
                    color: const Color(0xFFB71C1C),
                    padding: EdgeInsets.fromLTRB(
                        16, MediaQuery.of(context).padding.top + 10, 16, 10),
                    child: const Row(children: [
                      Icon(Icons.wifi_off_rounded, color: Colors.white, size: 18),
                      SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('No Internet Connection',
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 13)),
                            SizedBox(height: 2),
                            Text('Turn on Wi-Fi or mobile data to use the app.',
                                style: TextStyle(color: Colors.white70, fontSize: 11.5)),
                          ],
                        ),
                      ),
                    ]),
                  )
                : const SizedBox.shrink(),
          ),

          // ── Main content ────────────────────────────────────────────────────
          Expanded(
            child: FadeTransition(
              opacity: _entryAnim,
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(
                    child: _HeroCard(
                      topPad: topPad,
                      pulseAnim: _pulseAnim,
                      receipts: widget.receipts,
                      thisMonth: _thisMonth,
                      warningCount: _warningCount,
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: _ExchangeRateBanner(
                      rate: widget.exchangeRate,
                      loading: widget.rateLoading,
                      error: widget.rateError,
                      onRefresh: widget.onRefreshRate,
                      simulateError: widget.simulateError,
                      onToggleError: widget.onToggleError,
                      simulateNoNet: widget.simulateNoNet,
                      onToggleNoNet: widget.onToggleNoNet,
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _SearchBox(
                            value: _search,
                            onChange: (v) => setState(() => _search = v),
                            onSortTap: _showSortSheet,
                            sortBy: _sortBy,
                          ),
                          const SizedBox(height: 16),
                          _Chips(
                            selected: _cat,
                            onSelect: (c) => setState(() => _cat = c),
                          ),
                          const SizedBox(height: 26),
                          _SectionLabel(count: _filtered.length, sortBy: _sortBy),
                          const SizedBox(height: 14),
                        ],
                      ),
                    ),
                  ),
                  _filtered.isEmpty
                      ? const SliverFillRemaining(hasScrollBody: false, child: _EmptyState())
                      : SliverPadding(
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 110),
                          sliver: SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (ctx, i) => _AnimatedCard(
                                index: i,
                                child: ReceiptCard(
                                  receipt: _filtered[i],
                                  onTap: () => widget.onView(_filtered[i]),
                                  onDelete: () => widget.onDelete(_filtered[i].id),
                                ),
                              ),
                              childCount: _filtered.length,
                            ),
                          ),
                        ),
                ],
              ),
            ),
          ),
        ],
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
            end: Alignment.bottomRight,
            stops: [0.0, 0.5, 1.0],
            colors: [Color(0xFF1A546B), _cerulean, _cyan],
          ),
          borderRadius: BorderRadius.circular(28),
          boxShadow: [BoxShadow(color: _cerulean.withOpacity(0.38), blurRadius: 36, offset: const Offset(0, 16))],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: Stack(
            children: [
              Positioned(top: -70, right: -50,
                child: Container(width: 240, height: 240,
                  decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withOpacity(0.055)))),
              Positioned(bottom: -50, left: -40,
                child: Container(width: 180, height: 180,
                  decoration: BoxDecoration(shape: BoxShape.circle, color: _vanilla.withOpacity(0.07)))),
              Padding(
                padding: const EdgeInsets.fromLTRB(22, 22, 22, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Row(children: [
                            AnimatedBuilder(
                              animation: pulseAnim,
                              builder: (_, __) => Opacity(
                                opacity: pulseAnim.value,
                                child: Container(width: 6, height: 6,
                                  margin: const EdgeInsets.only(right: 7, bottom: 1),
                                  decoration: const BoxDecoration(color: _sandy, shape: BoxShape.circle)),
                              ),
                            ),
                            Text('Welcome back!!!',
                              style: TextStyle(color: _vanilla.withOpacity(0.78), fontSize: 12, fontWeight: FontWeight.w500)),
                          ]),
                          const SizedBox(height: 5),
                          RichText(text: const TextSpan(
                            style: TextStyle(fontFamily: 'Georgia', fontSize: 30, fontWeight: FontWeight.w900, letterSpacing: -0.8, height: 1.0),
                            children: [
                              TextSpan(text: 'Resibo', style: TextStyle(color: _white)),
                              TextSpan(text: 'Scan',  style: TextStyle(color: _vanilla)),
                            ],
                          )),
                        ]),
                        Container(
                          width: 50, height: 50,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.13),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.white.withOpacity(0.24), width: 1.2),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(14),
                            child: Image.asset('assets/images/logo.png', width: 32, height: 32, fit: BoxFit.contain),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(children: [
                      _StatTile(label: 'Total Receipts', value: '${receipts.length}', sub: 'all time',  valueColor: _vanilla, rightMargin: 10),
                      _StatTile(label: 'This Month',     value: '₱${thisMonth.toStringAsFixed(0)}', sub: 'spending', valueColor: _sandy,   rightMargin: 0),
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

class _StatTile extends StatelessWidget {
  final String label, value, sub;
  final Color valueColor;
  final double rightMargin;

  const _StatTile({required this.label, required this.value, required this.sub, required this.valueColor, required this.rightMargin});

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
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: TextStyle(color: Colors.white.withOpacity(0.55), fontSize: 10.5, letterSpacing: 0.2)),
          const SizedBox(height: 7),
          Text(value, style: TextStyle(fontFamily: 'Georgia', color: valueColor, fontSize: 26, fontWeight: FontWeight.w900, letterSpacing: -0.6, height: 1.0)),
          const SizedBox(height: 3),
          Text(sub, style: TextStyle(color: Colors.white.withOpacity(0.36), fontSize: 10)),
        ]),
      ),
    );
  }
}

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
        Container(width: 30, height: 30,
          decoration: BoxDecoration(color: _brick.withOpacity(0.28), shape: BoxShape.circle),
          child: const Center(child: Icon(Icons.warning_amber_rounded, color: _white, size: 16))),
        const SizedBox(width: 10),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('$count ${count > 1 ? "warranties" : "warranty"} expiring soon!',
            style: const TextStyle(color: _white, fontSize: 12.5, fontWeight: FontWeight.w700)),
          Text('Review before they expire',
            style: TextStyle(color: Colors.white.withOpacity(0.50), fontSize: 10.5)),
        ])),
        const Icon(Icons.chevron_right, color: Colors.white54, size: 18),
      ]),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SEARCH BOX — tune icon opens sort sheet, shows orange dot when sorted
// ─────────────────────────────────────────────────────────────────────────────
class _SearchBox extends StatelessWidget {
  final String value;
  final ValueChanged<String> onChange;
  final VoidCallback? onSortTap;
  final String sortBy;

  const _SearchBox({
    required this.value,
    required this.onChange,
    this.onSortTap,
    this.sortBy = 'date_desc',
  });

  @override
  Widget build(BuildContext context) {
    final isDefault = sortBy == 'date_desc';
    return Container(
      decoration: BoxDecoration(
        color: _white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: _cerulean.withOpacity(0.09), blurRadius: 18, offset: const Offset(0, 5))],
      ),
      child: TextField(
        onChanged: onChange,
        style: const TextStyle(fontSize: 13.5, color: _inkMid, fontWeight: FontWeight.w500),
        decoration: InputDecoration(
          hintText: 'Search store or category...',
          hintStyle: TextStyle(color: _inkLight.withOpacity(0.65), fontSize: 13),
          prefixIcon: Container(
            margin: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: _cerulean.withOpacity(0.09), borderRadius: BorderRadius.circular(10)),
            child: const Icon(Icons.search_rounded, color: _cerulean, size: 18),
          ),
          suffixIcon: GestureDetector(
            onTap: onSortTap,
            child: Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Stack(alignment: Alignment.center, children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: isDefault ? _inkLight.withOpacity(0.08) : _cerulean.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.tune_rounded, color: isDefault ? _inkLight : _cerulean, size: 18),
                ),
                if (!isDefault)
                  Positioned(top: 6, right: 6,
                    child: Container(width: 7, height: 7,
                      decoration: const BoxDecoration(color: _sandy, shape: BoxShape.circle))),
              ]),
            ),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// CATEGORY CHIPS
// ─────────────────────────────────────────────────────────────────────────────
class _Chips extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onSelect;
  const _Chips({required this.selected, required this.onSelect});

  static const _labels = ['All', 'Groceries', 'Food & Dining', 'Electronics', 'Utilities', 'Education', 'Others'];

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
                border: Border.all(color: sel ? _cerulean : _cyan.withOpacity(0.20), width: sel ? 0 : 1.5),
                boxShadow: sel
                    ? [BoxShadow(color: _cerulean.withOpacity(0.28), blurRadius: 10, offset: const Offset(0, 4))]
                    : [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 5, offset: const Offset(0, 2))],
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(icon, size: 15, color: sel ? _white : Colors.black),
                const SizedBox(width: 6),
                Text(label, style: TextStyle(fontSize: 12, fontWeight: sel ? FontWeight.w700 : FontWeight.w500, color: sel ? _white : _inkMid, letterSpacing: 0.1)),
              ]),
            ),
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SECTION LABEL — shows active sort
// ─────────────────────────────────────────────────────────────────────────────
class _SectionLabel extends StatelessWidget {
  final int count;
  final String sortBy;
  const _SectionLabel({required this.count, this.sortBy = 'date_desc'});

  String get _sortLabel {
    switch (sortBy) {
      case 'date_desc':   return 'Newest first';
      case 'date_asc':    return 'Oldest first';
      case 'amount_desc': return 'Highest amount';
      case 'amount_asc':  return 'Lowest amount';
      case 'name_asc':    return 'A → Z';
      case 'name_desc':   return 'Z → A';
      default:            return 'Newest first';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(children: [
          Container(width: 4, height: 20,
            margin: const EdgeInsets.only(right: 10),
            decoration: BoxDecoration(color: _sandy, borderRadius: BorderRadius.circular(2))),
          const Text('Recent Receipts',
            style: TextStyle(fontFamily: 'Georgia', fontSize: 17, fontWeight: FontWeight.w700, color: _ink, letterSpacing: -0.3)),
        ]),
        Row(children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(color: _cerulean.withOpacity(0.08), borderRadius: BorderRadius.circular(10)),
            child: Row(children: [
              Icon(Icons.swap_vert_rounded, size: 12, color: _cerulean.withOpacity(0.7)),
              const SizedBox(width: 3),
              Text(_sortLabel, style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w600, color: _cerulean.withOpacity(0.8))),
            ]),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              color: _vanillaSoft,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: _vanilla, width: 1.5),
            ),
            child: Text('$count found',
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: _cerulean, letterSpacing: 0.2)),
          ),
        ]),
      ],
    );
  }
}

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
      builder: (_, v, c) => Opacity(opacity: v, child: Transform.translate(offset: Offset(0, 16 * (1 - v)), child: c)),
      child: child,
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Container(
          width: 78, height: 78,
          decoration: BoxDecoration(
            color: _vanillaSoft, shape: BoxShape.circle,
            border: Border.all(color: _sandy.withOpacity(0.30), width: 1.5),
            boxShadow: [BoxShadow(color: _vanilla.withOpacity(0.6), blurRadius: 22, spreadRadius: 4)],
          ),
          child: const Center(child: Icon(Icons.receipt_long_outlined, color: _cerulean, size: 32)),
        ),
        const SizedBox(height: 16),
        const Text('No receipts found',
          style: TextStyle(fontFamily: 'Georgia', fontSize: 16, fontWeight: FontWeight.w700, color: _inkMid)),
        const SizedBox(height: 6),
        Text('Try a different filter or scan a new receipt',
          style: TextStyle(fontSize: 12.5, color: _inkLight.withOpacity(0.8))),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          decoration: BoxDecoration(
            color: _cerulean, borderRadius: BorderRadius.circular(24),
            boxShadow: [BoxShadow(color: _cerulean.withOpacity(0.28), blurRadius: 14, offset: const Offset(0, 5))],
          ),
          child: const Text('Scan a Receipt',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: _white, letterSpacing: 0.2)),
        ),
      ]),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// EXCHANGE RATE BANNER
// ─────────────────────────────────────────────────────────────────────────────
class _ExchangeRateBanner extends StatelessWidget {
  final ExchangeRate? rate;
  final bool loading;
  final String? error;
  final VoidCallback? onRefresh;
  final bool simulateError;
  final VoidCallback? onToggleError;
  final bool simulateNoNet;
  final VoidCallback? onToggleNoNet;

  static const _highlight = ['USD', 'EUR', 'JPY', 'GBP', 'SGD'];

  const _ExchangeRateBanner({
    required this.rate,
    required this.loading,
    this.error,
    this.onRefresh,
    this.simulateError = false,
    this.onToggleError,
    this.simulateNoNet = false,
    this.onToggleNoNet,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [Color(0xFF0F3547), _cerulean], begin: Alignment.topLeft, end: Alignment.bottomRight),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: _cerulean.withOpacity(0.30), blurRadius: 18, offset: const Offset(0, 6))],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            const Icon(Icons.currency_exchange_rounded, color: _vanilla, size: 16),
            const SizedBox(width: 8),
            const Expanded(child: Text('Live Exchange Rates  PHP base',
              style: TextStyle(color: _white, fontSize: 12.5, fontWeight: FontWeight.w700, letterSpacing: 0.2))),
            if (onRefresh != null && !loading)
              GestureDetector(onTap: onRefresh,
                child: Icon(Icons.refresh_rounded, size: 18, color: _vanilla.withOpacity(0.70))),
            if (loading)
              const SizedBox(width: 14, height: 14,
                child: CircularProgressIndicator(strokeWidth: 1.8, color: _vanilla)),
            const SizedBox(width: 6),
            // Debug: wrong URL
            GestureDetector(onTap: onToggleError,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: simulateError ? Colors.red.withOpacity(0.35) : Colors.white.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: simulateError ? Colors.red.withOpacity(0.70) : Colors.white.withOpacity(0.20), width: 1),
                ),
                child: Text(simulateError ? '❌ Bad URL' : '🔗 URL',
                  style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w700, color: _vanilla.withOpacity(0.90))),
              )),
            const SizedBox(width: 5),
            // Debug: no internet
            GestureDetector(onTap: onToggleNoNet,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: simulateNoNet ? Colors.orange.withOpacity(0.35) : Colors.white.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: simulateNoNet ? Colors.orange.withOpacity(0.70) : Colors.white.withOpacity(0.20), width: 1),
                ),
                child: Text(simulateNoNet ? '📵 No Net' : '📶 Net',
                  style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w700, color: _vanilla.withOpacity(0.90))),
              )),
          ]),
          const SizedBox(height: 12),
          if (loading && rate == null)       _shimmer()
          else if (error != null && rate == null) _errorRow()
          else if (rate != null)             _ratesRow(rate!)
          else                               _shimmer(),
          if (rate != null) ...[
            const SizedBox(height: 10),
            Text('Updated: ${_shortDate(rate!.lastUpdated)}',
              style: TextStyle(color: _vanilla.withOpacity(0.45), fontSize: 10, letterSpacing: 0.1)),
          ],
        ]),
      ),
    );
  }

  Widget _ratesRow(ExchangeRate rate) {
    final pairs = _highlight.map((c) => MapEntry(c, rate.rateFor(c))).where((e) => e.value != null).toList();
    return Wrap(spacing: 8, runSpacing: 8, children: pairs.map((e) => _RatePill(currency: e.key, rate: e.value!)).toList());
  }

  Widget _shimmer() => Wrap(spacing: 8, children: List.generate(5, (i) =>
    Container(width: 64, height: 38, decoration: BoxDecoration(color: Colors.white.withOpacity(0.10), borderRadius: BorderRadius.circular(10)))));

  Widget _errorRow() => Row(children: [
    Icon(Icons.wifi_off_rounded, size: 15, color: _vanilla.withOpacity(0.55)),
    const SizedBox(width: 6),
    Expanded(child: Text(error ?? 'Could not load rates.',
      style: TextStyle(color: _vanilla.withOpacity(0.60), fontSize: 11.5), maxLines: 2, overflow: TextOverflow.ellipsis)),
    if (onRefresh != null)
      GestureDetector(onTap: onRefresh,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(color: Colors.white.withOpacity(0.12), borderRadius: BorderRadius.circular(8)),
          child: Text('Retry', style: TextStyle(color: _vanilla.withOpacity(0.85), fontSize: 11, fontWeight: FontWeight.w600)))),
  ]);

  String _shortDate(String utc) {
    final parts = utc.split(' ');
    return parts.length >= 4 ? '${parts[1]} ${parts[2]} ${parts[3]}' : utc;
  }
}

class _RatePill extends StatelessWidget {
  final String currency;
  final double rate;
  const _RatePill({required this.currency, required this.rate});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.10),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white.withOpacity(0.12), width: 1),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(currency, style: const TextStyle(color: _vanilla, fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 0.5)),
        const SizedBox(height: 2),
        Text(rate < 0.01 ? rate.toStringAsFixed(5) : rate.toStringAsFixed(4),
          style: const TextStyle(color: _white, fontSize: 12, fontWeight: FontWeight.w600)),
      ]),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SORT BOTTOM SHEET
// ─────────────────────────────────────────────────────────────────────────────
class _SortSheet extends StatelessWidget {
  final String current;
  final ValueChanged<String> onSelect;
  const _SortSheet({required this.current, required this.onSelect});

  static const _options = [
    ('date_desc',   Icons.arrow_downward_rounded, 'Newest first',   'Sort by date, newest on top'),
    ('date_asc',    Icons.arrow_upward_rounded,   'Oldest first',   'Sort by date, oldest on top'),
    ('amount_desc', Icons.trending_down_rounded,  'Highest amount', 'Most expensive first'),
    ('amount_asc',  Icons.trending_up_rounded,    'Lowest amount',  'Cheapest first'),
    ('name_asc',    Icons.sort_by_alpha_rounded,  'Name A → Z',     'Alphabetical order'),
    ('name_desc',   Icons.sort_by_alpha_rounded,  'Name Z → A',     'Reverse alphabetical'),
  ];

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).padding.bottom;
    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.72),
      child: Container(
        decoration: const BoxDecoration(
          color: _cream,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          // Handle
          Container(width: 38, height: 4,
            margin: const EdgeInsets.only(top: 16, bottom: 4),
            decoration: BoxDecoration(color: _cerulean.withOpacity(0.18), borderRadius: BorderRadius.circular(4))),
          // Title
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 14),
            child: Row(children: [
              Container(width: 3, height: 16, margin: const EdgeInsets.only(right: 10),
                decoration: BoxDecoration(color: _sandy, borderRadius: BorderRadius.circular(2))),
              const Text('Sort By', style: TextStyle(fontFamily: 'Georgia', fontSize: 17, fontWeight: FontWeight.w700, color: _ink)),
            ]),
          ),
          // Options
          Flexible(
            child: ListView(
              shrinkWrap: true,
              padding: EdgeInsets.fromLTRB(20, 0, 20, bottomPad + 20),
              children: _options.map((opt) {
                final (value, icon, label, sub) = opt;
                final selected = current == value;
                return GestureDetector(
                  onTap: () => onSelect(value),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: selected ? _cerulean : _white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: selected ? _cerulean : _cerulean.withOpacity(0.12),
                        width: selected ? 0 : 1.5),
                      boxShadow: selected
                          ? [BoxShadow(color: _cerulean.withOpacity(0.25), blurRadius: 10, offset: const Offset(0, 4))]
                          : [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 4, offset: const Offset(0, 2))],
                    ),
                    child: Row(children: [
                      Container(
                        width: 36, height: 36,
                        decoration: BoxDecoration(
                          color: selected ? Colors.white.withOpacity(0.20) : _cerulean.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(10)),
                        child: Icon(icon, size: 18, color: selected ? _white : _cerulean),
                      ),
                      const SizedBox(width: 12),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(label, style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: selected ? _white : _ink)),
                        Text(sub, style: TextStyle(fontSize: 11.5, color: selected ? Colors.white.withOpacity(0.65) : _inkLight.withOpacity(0.80))),
                      ])),
                      if (selected) const Icon(Icons.check_circle_rounded, color: _white, size: 18),
                    ]),
                  ),
                );
              }).toList(),
            ),
          ),
        ]),
      ),
    );
  }
}