import 'package:flutter/material.dart';
import '../utils/constants.dart';

class AppSearchBar extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: cBorder, width: 1.5),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      child: Row(
        children: [
          const Icon(Icons.search, color: cSub, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              onChanged: onChange,
              decoration: InputDecoration(
                hintText: placeholder,
                hintStyle: const TextStyle(color: cSub, fontSize: 14),
                border: InputBorder.none,
                isDense: true,
              ),
              style: const TextStyle(fontSize: 14, color: cText),
            ),
          ),
        ],
      ),
    );
  }
}
