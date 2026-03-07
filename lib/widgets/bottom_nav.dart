import 'package:flutter/material.dart';
import '../utils/constants.dart';

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
      {'icon': Icons.home_rounded,              'label': 'Home'},
      {'icon': Icons.folder_rounded,            'label': 'Folders'},
      {'icon': Icons.bar_chart_rounded,         'label': 'Expenses'},
      {'icon': Icons.notifications_rounded,     'label': 'Alerts'},
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: cBorder)),
      ),
      padding: const EdgeInsets.only(bottom: 16, top: 8),
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(tabs.length + 1, (i) {
              // centre slot — leave room for FAB
              if (i == 2) return const SizedBox(width: 60);
              final idx = i > 2 ? i - 1 : i;
              return GestureDetector(
                onTap: () => onTap(idx),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(tabs[idx]['icon'] as IconData,
                      color: activeIndex == idx ? cPrimary : cSub,
                      size: 22),
                    const SizedBox(height: 3),
                    Text(tabs[idx]['label'] as String,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: activeIndex == idx
                            ? FontWeight.w700 : FontWeight.w400,
                        color: activeIndex == idx ? cPrimary : cSub,
                      )),
                  ],
                ),
              );
            }),
          ),
          // FAB
          Positioned(
            top: -24,
            child: GestureDetector(
              onTap: onScan,
              child: Container(
                width: 52, height: 52,
                decoration: BoxDecoration(
                  color: cPrimary,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 3),
                  boxShadow: [BoxShadow(
                    color: Colors.black.withOpacity(0.18),
                    blurRadius: 16, offset: const Offset(0, 4),
                  )],
                ),
                child: const Icon(Icons.add, color: Colors.white, size: 22),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
