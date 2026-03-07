import 'package:flutter/material.dart';

// ── Vintage Hues Palette ─────────────────────────────────────────────────────
const _cerulean    = Color(0xFF2D728F);
const _cyan        = Color(0xFF3B8EA5);
const _vanilla     = Color(0xFFF5EE9E);
const _sandy       = Color(0xFFF49E4C);
const _cream       = Color(0xFFFDF8EC);
const _white       = Color(0xFFFFFFFF);
const _ink         = Color(0xFF0F2027);
const _inkLight    = Color(0xFF7A9BAA);

class BottomNavBar extends StatelessWidget {
  final int activeIndex;
  final ValueChanged<int> onTap;
  final VoidCallback onScan;

  const BottomNavBar({
    super.key,
    required this.activeIndex,
    required this.onTap,
    required this.onScan,
  });

  @override
  Widget build(BuildContext context) {
    final tabs = [
      {'icon': Icons.home_rounded,          'label': 'Home'},
      {'icon': Icons.folder_rounded,        'label': 'Folders'},
      {'icon': Icons.bar_chart_rounded,     'label': 'Expenses'},
      {'icon': Icons.notifications_rounded, 'label': 'Alerts'},
    ];

    return Container(
      decoration: BoxDecoration(
        color: _white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
        boxShadow: [
          BoxShadow(
            color: _cerulean.withOpacity(0.10),
            blurRadius: 24,
            offset: const Offset(0, -6),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 10, 8, 6),
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.generate(tabs.length + 1, (i) {
                  // Centre slot — leave room for FAB
                  if (i == 2) return const SizedBox(width: 64);

                  final idx = i > 2 ? i - 1 : i;
                  final isActive = activeIndex == idx;

                  return GestureDetector(
                    onTap: () => onTap(idx),
                    behavior: HitTestBehavior.opaque,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeOut,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: isActive
                            ? _cerulean.withOpacity(0.10)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 200),
                            child: Icon(
                              tabs[idx]['icon'] as IconData,
                              key: ValueKey(isActive),
                              color: isActive ? _cerulean : _inkLight,
                              size: 22,
                            ),
                          ),
                          const SizedBox(height: 3),
                          AnimatedDefaultTextStyle(
                            duration: const Duration(milliseconds: 200),
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: isActive
                                  ? FontWeight.w700
                                  : FontWeight.w400,
                              color: isActive ? _cerulean : _inkLight,
                            ),
                            child: Text(tabs[idx]['label'] as String),
                          ),
                          // Active indicator dot
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            margin: const EdgeInsets.only(top: 3),
                            width: isActive ? 16 : 0,
                            height: isActive ? 3 : 0,
                            decoration: BoxDecoration(
                              color: _sandy,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ),

              // ── SCAN FAB ──────────────────────────────────────────
              Positioned(
                top: -28,
                child: GestureDetector(
                  onTap: onScan,
                  child: Container(
                    width: 58, height: 58,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [_cyan, _cerulean],
                      ),
                      shape: BoxShape.circle,
                      border: Border.all(color: _white, width: 3.5),
                      boxShadow: [
                        BoxShadow(
                          color: _cerulean.withOpacity(0.38),
                          blurRadius: 18,
                          offset: const Offset(0, 6),
                        ),
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.add_rounded,
                        color: _white,
                        size: 26,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}