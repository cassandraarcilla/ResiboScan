import 'package:flutter/material.dart';
import '../models/receipt_model.dart';
import '../utils/constants.dart';
import '../widgets/receipt_card.dart';

// ── Vintage Hues Palette ─────────────────────────────────────────────────────
const _cerulean    = Color(0xFF2D728F);
const _cyan        = Color(0xFF3B8EA5);
const _vanilla     = Color(0xFFF5EE9E);
const _sandy       = Color(0xFFF49E4C);
const _cream       = Color(0xFFFDF8EC);
const _white       = Color(0xFFFFFFFF);
const _ink         = Color(0xFF0F2027);
const _inkMid      = Color(0xFF2C4A55);
const _inkLight    = Color(0xFF7A9BAA);
const _vanillaSoft = Color(0xFFFAF3C0);

class FoldersScreen extends StatefulWidget {
  final List<Receipt> receipts;
  final ValueChanged<Receipt> onView;
  final ValueChanged<int> onDelete;

  const FoldersScreen({
    super.key,
    required this.receipts,
    required this.onView,
    required this.onDelete,
  });

  @override
  State<FoldersScreen> createState() => _FoldersScreenState();
}

class _FoldersScreenState extends State<FoldersScreen>
    with TickerProviderStateMixin {
  String _active = 'All';

  late final AnimationController _entryCtrl;
  late final Animation<double>   _entryAnim;

  List<Receipt> get _filtered => _active == 'All'
      ? widget.receipts
      : widget.receipts.where((r) => r.folder == _active).toList();

  int _count(String f) => f == 'All'
      ? widget.receipts.length
      : widget.receipts.where((r) => r.folder == f).length;

  double _total(String f) {
    final list = f == 'All'
        ? widget.receipts
        : widget.receipts.where((r) => r.folder == f).toList();
    return list.fold(0.0, (s, r) => s + r.amount);
  }

  @override
  void initState() {
    super.initState();
    _entryCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();
    _entryAnim = CurvedAnimation(
      parent: _entryCtrl, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _entryCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: _cream,
      body: FadeTransition(
        opacity: _entryAnim,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [

            // ── HERO HEADER ──────────────────────────────────────────
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
                          padding: const EdgeInsets.fromLTRB(26, 28, 26, 30),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Organized'.toUpperCase(),
                                        style: TextStyle(
                                          color: _vanilla.withOpacity(0.8),
                                          fontSize: 11,
                                          fontWeight: FontWeight.w800,
                                          letterSpacing: 1.5,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      const Text(
                                        'My Folders',
                                        style: TextStyle(
                                          fontFamily: 'Georgia',
                                          color: _white,
                                          fontSize: 30,
                                          fontWeight: FontWeight.w900,
                                          letterSpacing: -0.8,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Container(
                                    width: 54, height: 54,
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(18),
                                      border: Border.all(
                                        color: Colors.white.withOpacity(0.25),
                                        width: 1.5,
                                      ),
                                    ),
                                    child: const Center(
                                      child: Icon(
                                        Icons.folder_copy_rounded,
                                        color: Colors.white,
                                        size: 26,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 22),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  '${widget.receipts.length} total receipts across ${folders.length - 1} folders',
                                  style: TextStyle(
                                    color: _vanilla.withOpacity(0.9),
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // ── FOLDER TABS ───────────────────────────────────────────
            // IntrinsicHeight forces all cards to the same height as
            // the tallest one (the active card), eliminating the gap.
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 26, 16, 0),
                child: IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: folders.map((f) {
                      final isLast   = f == folders.last;
                      final isActive = _active == f;
                      return Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(right: isLast ? 0 : 12),
                          child: _FolderTab(
                            label   : f,
                            icon    : f == 'All'      ? Icons.auto_awesome_motion_rounded
                                    : f == 'Personal' ? Icons.person_rounded
                                                      : Icons.business_center_rounded,
                            count   : _count(f),
                            total   : _total(f),
                            isActive: isActive,
                            onTap   : () => setState(() => _active = f),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),

            // ── SECTION LABEL ─────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 28, 20, 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(children: [
                      Container(
                        width: 5, height: 22,
                        margin: const EdgeInsets.only(right: 12),
                        decoration: BoxDecoration(
                          color: _sandy,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                      Text(
                        _active == 'All'
                            ? 'All Transactions'
                            : '$_active Collection',
                        style: const TextStyle(
                          fontFamily: 'Georgia',
                          fontSize: 19,
                          fontWeight: FontWeight.w900,
                          color: _ink,
                          letterSpacing: -0.4,
                        ),
                      ),
                    ]),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: _vanillaSoft,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: _vanilla, width: 2),
                      ),
                      child: Text(
                        '${_filtered.length} items',
                        style: const TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w800,
                          color: _cerulean,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── RECEIPT CARDS ─────────────────────────────────────────
            _filtered.isEmpty
                ? SliverFillRemaining(
                    hasScrollBody: false,
                    child: _EmptyFolder(folder: _active),
                  )
                : SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 120),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (ctx, i) => TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0.0, end: 1.0),
                          duration: Duration(
                            milliseconds: 400 + i * 60),
                          curve: Curves.easeOutQuart,
                          builder: (_, v, c) => Opacity(
                            opacity: v,
                            child: Transform.translate(
                              offset: Offset(0, 20 * (1 - v)),
                              child: c,
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: ReceiptCard(
                              receipt:  _filtered[i],
                              onTap:    () => widget.onView(_filtered[i]),
                              onDelete: () =>
                                  widget.onDelete(_filtered[i].id),
                            ),
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
// FOLDER TAB
// Uses StatefulWidget for press-scale animation.
// `crossAxisAlignment: CrossAxisAlignment.stretch` on the parent Row +
// `SizedBox.expand` makes this card fill the IntrinsicHeight row height
// so all three cards are always the same height.
// ─────────────────────────────────────────────────────────────────────────────
class _FolderTab extends StatefulWidget {
  final String      label;
  final IconData     icon;
  final int          count;
  final double       total;
  final bool         isActive;
  final VoidCallback onTap;

  const _FolderTab({
    required this.label,
    required this.icon,
    required this.count,
    required this.total,
    required this.isActive,
    required this.onTap,
  });

  @override
  State<_FolderTab> createState() => _FolderTabState();
}

class _FolderTabState extends State<_FolderTab>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pressCtrl;
  late final Animation<double>   _scaleAnim;

  @override
  void initState() {
    super.initState();
    _pressCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 90),
      reverseDuration: const Duration(milliseconds: 220),
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.93).animate(
      CurvedAnimation(parent: _pressCtrl, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _pressCtrl.dispose();
    super.dispose();
  }

  void _down(TapDownDetails _) => _pressCtrl.forward();
  void _up(TapUpDetails _)     { _pressCtrl.reverse(); widget.onTap(); }
  void _cancel()               => _pressCtrl.reverse();

  @override
  Widget build(BuildContext context) {
    final active = widget.isActive;

    return GestureDetector(
      onTapDown  : _down,
      onTapUp    : _up,
      onTapCancel: _cancel,
      child: ScaleTransition(
        scale: _scaleAnim,
        child: SizedBox.expand(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 280),
            curve: Curves.fastOutSlowIn,
            decoration: BoxDecoration(
              gradient: active
                  ? const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [_cerulean, _cyan],
                    )
                  : null,
              color: active ? null : _white,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: active
                    ? Colors.white.withOpacity(0.2)
                    : _cerulean.withOpacity(0.12),
                width: 2,
              ),
              boxShadow: active
                  ? [
                      BoxShadow(
                        color: _cerulean.withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ]
                  : [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 8, vertical: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                children: [

                  // Icon — scales up when active, color flips with bg
                  AnimatedScale(
                    scale: active ? 1.2 : 1.0,
                    duration: const Duration(milliseconds: 280),
                    curve: Curves.backOut,
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      child: Icon(
                        widget.icon,
                        key: ValueKey(active),
                        color: active ? Colors.white : _inkMid,
                        size: 30,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Label
                  AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 200),
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 14,
                      color: active ? _white : _ink,
                      letterSpacing: -0.2,
                    ),
                    child: Text(
                      widget.label,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 4),

                  // Receipt count
                  AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 200),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: active
                          ? _vanilla.withOpacity(0.75)
                          : _inkLight,
                    ),
                    child: Text(
                      '${widget.count} item'
                      '${widget.count != 1 ? "s" : ""}',
                      textAlign: TextAlign.center,
                    ),
                  ),

                  // Total spend
                  if (widget.count > 0) ...[
                    const SizedBox(height: 4),
                    AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 200),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        color: active ? _vanilla : _sandy,
                      ),
                      child: Text(
                        '₱${widget.total.toStringAsFixed(0)}',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],

                  // Active indicator pill
                  const SizedBox(height: 10),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeOutBack,
                    width : active ? 24 : 0,
                    height: active ? 4  : 0,
                    decoration: BoxDecoration(
                      color: _vanilla.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// EMPTY STATE
// ─────────────────────────────────────────────────────────────────────────────
class _EmptyFolder extends StatelessWidget {
  final String folder;
  const _EmptyFolder({required this.folder});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 86, height: 86,
            decoration: BoxDecoration(
              color: _vanillaSoft,
              shape: BoxShape.circle,
              border: Border.all(
                color: _sandy.withOpacity(0.35), width: 2),
              boxShadow: [
                BoxShadow(
                  color: _vanilla.withOpacity(0.5),
                  blurRadius: 30,
                  spreadRadius: 6,
                ),
              ],
            ),
            child: const Center(
              child: Icon(
                Icons.folder_open_rounded,
                color: _inkMid,
                size: 38,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Nothing in $folder',
            style: const TextStyle(
              fontFamily: 'Georgia',
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: _ink,
            )),
          const SizedBox(height: 8),
          Text(
            'Start scanning to fill this folder up',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: _inkLight.withOpacity(0.9),
            ),
          ),
        ],
      ),
    );
  }
}
