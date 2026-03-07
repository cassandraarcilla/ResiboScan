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
                          padding: const EdgeInsets.fromLTRB(22, 22, 22, 24),
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
                                        'Organized',
                                        style: TextStyle(
                                          color: _vanilla.withOpacity(0.72),
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                          letterSpacing: 0.3,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      const Text(
                                        'My Folders',
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
                                      borderRadius:
                                          BorderRadius.circular(16),
                                      border: Border.all(
                                        color: Colors.white.withOpacity(0.24),
                                        width: 1.2,
                                      ),
                                    ),
                                    child: const Center(
                                      child: Icon(
                                        Icons.folder_open_rounded,
                                        color: Colors.white,
                                        size: 26,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 18),
                              Text(
                                '${widget.receipts.length} receipts across'
                                ' ${folders.length - 1} folders',
                                style: TextStyle(
                                  color: _vanilla.withOpacity(0.65),
                                  fontSize: 12.5,
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
                padding: const EdgeInsets.fromLTRB(16, 22, 16, 0),
                child: IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: folders.map((f) {
                      final isLast   = f == folders.last;
                      final isActive = _active == f;
                      return Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(right: isLast ? 0 : 10),
                          child: _FolderTab(
                            label   : f,
                            icon    : f == 'All'      ? Icons.shopping_cart_rounded
                                    : f == 'Personal' ? Icons.home_rounded
                                                      : Icons.work_rounded,
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
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 14),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(children: [
                      Container(
                        width: 4, height: 20,
                        margin: const EdgeInsets.only(right: 10),
                        decoration: BoxDecoration(
                          color: _sandy,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      Text(
                        _active == 'All'
                            ? 'All Receipts'
                            : '$_active Folder',
                        style: const TextStyle(
                          fontFamily: 'Georgia',
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: _ink,
                          letterSpacing: -0.3,
                        ),
                      ),
                    ]),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 5),
                      decoration: BoxDecoration(
                        color: _vanillaSoft,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: _vanilla, width: 1.5),
                      ),
                      child: Text(
                        '${_filtered.length} found',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: _cerulean,
                          letterSpacing: 0.2,
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
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 110),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (ctx, i) => TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0.0, end: 1.0),
                          duration: Duration(
                            milliseconds: 350 + i * 50),
                          curve: Curves.easeOutCubic,
                          builder: (_, v, c) => Opacity(
                            opacity: v,
                            child: Transform.translate(
                              offset: Offset(0, 14 * (1 - v)),
                              child: c,
                            ),
                          ),
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
// FOLDER TAB
// Uses StatefulWidget for press-scale animation.
// `crossAxisAlignment: CrossAxisAlignment.stretch` on the parent Row +
// `SizedBox.expand` makes this card fill the IntrinsicHeight row height
// so all three cards are always the same height.
// ─────────────────────────────────────────────────────────────────────────────
class _FolderTab extends StatefulWidget {
  final String       label;
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
        // SizedBox.expand fills the IntrinsicHeight-constrained space
        // so all cards are identical in height regardless of content.
        child: SizedBox.expand(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOut,
            // padding: vertical is handled by Column's mainAxisAlignment
            decoration: BoxDecoration(
              gradient: active
                  ? const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [_cerulean, _cyan],
                    )
                  : null,
              color: active ? null : _white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: active
                    ? Colors.transparent
                    : _cerulean.withOpacity(0.14),
                width: 1.5,
              ),
              boxShadow: active
                  ? [
                      BoxShadow(
                        color: _cerulean.withOpacity(0.34),
                        blurRadius: 18,
                        offset: const Offset(0, 7),
                      ),
                    ]
                  : [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 4, vertical: 16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.max, // fill expanded height
                children: [

                  // Icon — scales up when active, color flips with bg
                  AnimatedScale(
                    scale: active ? 1.18 : 1.0,
                    duration: const Duration(milliseconds: 220),
                    curve: Curves.easeOut,
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      child: Icon(
                        widget.icon,
                        key: ValueKey(active),
                        color: active ? Colors.white : Colors.black,
                        size: 28,
                      ),
                    ),
                  ),
                  const SizedBox(height: 7),

                  // Label
                  AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 200),
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                      color: active ? _white : _inkMid,
                    ),
                    child: Text(
                      widget.label,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 3),

                  // Receipt count
                  AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 200),
                    style: TextStyle(
                      fontSize: 10.5,
                      color: active
                          ? _vanilla.withOpacity(0.72)
                          : _inkLight,
                    ),
                    child: Text(
                      '${widget.count} receipt'
                      '${widget.count != 1 ? "s" : ""}',
                      textAlign: TextAlign.center,
                    ),
                  ),

                  // Total spend
                  if (widget.count > 0) ...[
                    const SizedBox(height: 2),
                    AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 200),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: active ? _vanilla : _sandy,
                      ),
                      child: Text(
                        '₱${widget.total.toStringAsFixed(0)}',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],

                  // Active indicator pill
                  const SizedBox(height: 6),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    curve: Curves.easeOut,
                    width : active ? 20 : 0,
                    height: active ? 3  : 0,
                    decoration: BoxDecoration(
                      color: _vanilla.withOpacity(0.55),
                      borderRadius: BorderRadius.circular(4),
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
                Icons.folder_open_rounded,
                color: Colors.black,
                size: 32,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'No receipts in $folder',
            style: const TextStyle(
              fontFamily: 'Georgia',
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: _inkMid,
            )),
          const SizedBox(height: 6),
          Text(
            'Add a receipt and assign it to this folder',
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