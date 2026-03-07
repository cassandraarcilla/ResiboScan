import 'package:flutter/material.dart';
import '../models/receipt_model.dart';
import '../utils/constants.dart';
import '../widgets/receipt_card.dart';

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

class _FoldersScreenState extends State<FoldersScreen> {
  String _active = 'All';

  List<Receipt> get _filtered => _active == 'All'
      ? widget.receipts
      : widget.receipts.where((r) => r.folder == _active).toList();

  int _count(String f) => f == 'All'
      ? widget.receipts.length
      : widget.receipts.where((r) => r.folder == f).length;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(children: [
        // Header
        Container(
          color: cPrimary,
          padding: const EdgeInsets.fromLTRB(20, 56, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Organized',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7), fontSize: 12)),
              const Text('My Folders',
                style: TextStyle(
                  fontFamily: 'Georgia', color: Colors.white,
                  fontSize: 22, fontWeight: FontWeight.w800)),
            ],
          ),
        ),

        Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 90),
          child: Column(children: [
            // Folder tabs
            Row(
              children: folders.map((f) {
                final active = _active == f;
                final isLast = f == folders.last;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _active = f),
                    child: Container(
                      margin: EdgeInsets.only(right: isLast ? 0 : 10),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: active ? cPrimary : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: active ? cPrimary : cBorder,
                          width: 1.5),
                      ),
                      child: Column(children: [
                        Text(
                          f == 'All' ? '📂'
                          : f == 'Personal' ? '🏠' : '💼',
                          style: const TextStyle(fontSize: 22)),
                        const SizedBox(height: 4),
                        Text(f, style: TextStyle(
                          fontWeight: FontWeight.w700, fontSize: 13,
                          color: active ? Colors.white : cText)),
                        Text('${_count(f)} receipts',
                          style: TextStyle(
                            fontSize: 11,
                            color: active
                                ? Colors.white.withOpacity(0.7) : cSub)),
                      ]),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            if (_filtered.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 40),
                  child: Text('No receipts in this folder',
                    style: TextStyle(color: cSub, fontSize: 14)),
                ),
              )
            else
              ...(_filtered.map((r) => ReceiptCard(
                receipt: r,
                onTap: () => widget.onView(r),
                onDelete: () => widget.onDelete(r.id),
              ))),
          ]),
        ),
      ]),
    );
  }
}
