import 'package:flutter/material.dart';
import '../models/receipt_model.dart';
import '../utils/constants.dart';

class ScanModal extends StatefulWidget {
  final ValueChanged<Receipt> onSave;
  const ScanModal({super.key, required this.onSave});
  @override
  State<ScanModal> createState() => _ScanModalState();
}

class _ScanModalState extends State<ScanModal> {
  String _step     = 'choose';
  String _store    = '';
  String _amount   = '';
  String _notes    = '';
  String _warranty = '';
  String _date     = DateTime.now().toIso8601String().split('T')[0];
  String _category = 'Others';
  String _folder   = 'Personal';
  String _image    = '🧾';

  final _emojis = ['🛒','🍔','📱','💡','📚','💻','👕','🏥','🚗','🧾'];

  void _save() {
    if (_store.isEmpty || _amount.isEmpty) return;
    widget.onSave(Receipt(
      id       : DateTime.now().millisecondsSinceEpoch,
      store    : _store,
      amount   : double.tryParse(_amount) ?? 0,
      date     : _date,
      category : _category,
      warranty : _warranty.isEmpty ? null : _warranty,
      image    : _image,
      folder   : _folder,
      notes    : _notes,
    ));
    Navigator.pop(context);
  }

  Widget _field(String label, ValueChanged<String> onChanged,
      {TextInputType? type, String? hint}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(
            fontSize: 12, fontWeight: FontWeight.w600, color: cSub)),
        const SizedBox(height: 6),
        TextField(
          onChanged: onChanged,
          keyboardType: type,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: cSub),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: cBorder),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: cBorder, width: 1.5),
            ),
            filled: true, fillColor: Colors.white,
          ),
        ),
        const SizedBox(height: 14),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: cBg,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 32),
      child: SingleChildScrollView(
        child: Column(children: [
          Container(
            width: 40, height: 4,
            margin: const EdgeInsets.only(top: 12),
            decoration: BoxDecoration(
              color: cBorder, borderRadius: BorderRadius.circular(4))),

          // ── CHOOSE STEP ─────────────────────────────────────────────────
          if (_step == 'choose')
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Add Receipt', style: TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w800, color: cText)),
                  const SizedBox(height: 6),
                  const Text('How would you like to add?',
                      style: TextStyle(fontSize: 13, color: cSub)),
                  const SizedBox(height: 24),
                  for (final opt in [
                    {'icon': Icons.camera_alt_outlined, 'label': 'Scan with Camera',    'sub': 'Use your camera to capture'},
                    {'icon': Icons.image_outlined,      'label': 'Upload from Gallery', 'sub': 'Pick from your photos'},
                    {'icon': Icons.edit_outlined,       'label': 'Enter Manually',      'sub': 'Type receipt details'},
                  ])
                    GestureDetector(
                      onTap: () => setState(() => _step = 'form'),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: cBorder, width: 1.5),
                        ),
                        child: Row(children: [
                          Container(
                            width: 44, height: 44,
                            decoration: BoxDecoration(
                              color: cPrimary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(opt['icon'] as IconData,
                                color: cPrimary, size: 20),
                          ),
                          const SizedBox(width: 14),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(opt['label'] as String,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14, color: cText)),
                              Text(opt['sub'] as String,
                                  style: const TextStyle(
                                    fontSize: 12, color: cSub)),
                            ],
                          ),
                        ]),
                      ),
                    ),
                ],
              ),
            ),

          // ── FORM STEP ───────────────────────────────────────────────────
          if (_step == 'form')
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    GestureDetector(
                      onTap: () => setState(() => _step = 'choose'),
                      child: const Icon(Icons.arrow_back, color: cText)),
                    const SizedBox(width: 10),
                    const Text('Receipt Details', style: TextStyle(
                        fontSize: 18, fontWeight: FontWeight.w800, color: cText)),
                  ]),
                  const SizedBox(height: 16),

                  // Emoji picker
                  SizedBox(
                    height: 48,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: _emojis.map((e) => GestureDetector(
                        onTap: () => setState(() => _image = e),
                        child: Container(
                          width: 44, height: 44,
                          margin: const EdgeInsets.only(right: 8),
                          decoration: BoxDecoration(
                            color: _image == e
                                ? cPrimary.withOpacity(0.1) : Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: _image == e ? cPrimary : cBorder,
                              width: 2),
                          ),
                          alignment: Alignment.center,
                          child: Text(e,
                            style: const TextStyle(fontSize: 22)),
                        ),
                      )).toList(),
                    ),
                  ),
                  const SizedBox(height: 16),

                  _field('Store / Merchant *',
                      (v) => setState(() => _store = v),
                      hint: 'e.g. SM Supermarket'),
                  _field('Amount (PHP) *',
                      (v) => setState(() => _amount = v),
                      type: TextInputType.number, hint: '0.00'),
                  _field('Notes (optional)',
                      (v) => setState(() => _notes = v)),

                  // Category
                  const Text('Category', style: TextStyle(
                      fontSize: 12, fontWeight: FontWeight.w600, color: cSub)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8, runSpacing: 8,
                    children: categories
                        .where((c) => c != 'All')
                        .map((c) => GestureDetector(
                      onTap: () => setState(() => _category = c),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: _category == c ? cPrimary : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: _category == c ? cPrimary : cBorder,
                            width: 1.5),
                        ),
                        child: Text(c, style: TextStyle(
                          fontSize: 12,
                          fontWeight: _category == c
                              ? FontWeight.w700 : FontWeight.w400,
                          color: _category == c ? Colors.white : cSub,
                        )),
                      ),
                    )).toList(),
                  ),
                  const SizedBox(height: 14),

                  // Folder
                  const Text('Folder', style: TextStyle(
                      fontSize: 12, fontWeight: FontWeight.w600, color: cSub)),
                  const SizedBox(height: 8),
                  Row(
                    children: folders
                        .where((f) => f != 'All')
                        .map((f) => GestureDetector(
                      onTap: () => setState(() => _folder = f),
                      child: Container(
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: _folder == f ? cPrimary : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: _folder == f ? cPrimary : cBorder,
                            width: 1.5),
                        ),
                        child: Text(f, style: TextStyle(
                          fontSize: 12,
                          fontWeight: _folder == f
                              ? FontWeight.w700 : FontWeight.w400,
                          color: _folder == f ? Colors.white : cSub,
                        )),
                      ),
                    )).toList(),
                  ),
                  const SizedBox(height: 20),

                  // Save button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: (_store.isEmpty || _amount.isEmpty)
                          ? null : _save,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: cPrimary,
                        disabledBackgroundColor: cBorder,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                      ),
                      child: const Text('Save Receipt',
                        style: TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w800,
                          color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ),
        ]),
      ),
    );
  }
}
