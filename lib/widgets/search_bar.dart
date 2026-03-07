import 'package:flutter/material.dart';

// ── Vintage Hues Palette ─────────────────────────────────────────────────────
const _cerulean = Color(0xFF2D728F);
const _cyan     = Color(0xFF3B8EA5);
const _white    = Color(0xFFFFFFFF);
const _inkMid   = Color(0xFF2C4A55);
const _inkLight = Color(0xFF7A9BAA);

class AppSearchBar extends StatefulWidget {
  final String value;
  final ValueChanged<String> onChange;
  final String placeholder;

  const AppSearchBar({
    super.key,
    required this.value,
    required this.onChange,
    this.placeholder = 'Search receipts…',
  });

  @override
  State<AppSearchBar> createState() => _AppSearchBarState();
}

class _AppSearchBarState extends State<AppSearchBar> {
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        color: _white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _focused
              ? _cerulean.withOpacity(0.45)
              : _cerulean.withOpacity(0.12),
          width: _focused ? 1.8 : 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: _focused
                ? _cerulean.withOpacity(0.12)
                : _cerulean.withOpacity(0.06),
            blurRadius: _focused ? 18 : 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(children: [
        // Search icon container
        Container(
          margin: const EdgeInsets.all(10),
          width: 34, height: 34,
          decoration: BoxDecoration(
            color: _focused
                ? _cerulean.withOpacity(0.12)
                : _cerulean.withOpacity(0.07),
            borderRadius: BorderRadius.circular(10),
          ),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: Icon(
              _focused ? Icons.search_rounded : Icons.search_rounded,
              key: ValueKey(_focused),
              color: _focused ? _cerulean : _inkLight,
              size: 17,
            ),
          ),
        ),

        // Text field
        Expanded(
          child: Focus(
            onFocusChange: (v) => setState(() => _focused = v),
            child: TextField(
              onChanged: widget.onChange,
              style: const TextStyle(
                fontSize: 13.5,
                color: _inkMid,
                fontWeight: FontWeight.w500,
              ),
              decoration: InputDecoration(
                hintText: widget.placeholder,
                hintStyle: TextStyle(
                  color: _inkLight.withOpacity(0.65),
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
            ),
          ),
        ),

        // Filter icon
        Padding(
          padding: const EdgeInsets.only(right: 12),
          child: Icon(
            Icons.tune_rounded,
            color: _inkLight.withOpacity(0.40),
            size: 18,
          ),
        ),
      ]),
    );
  }
}