import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import '../services/api_service.dart';
import '../models/receipt_model.dart';
import '../utils/constants.dart';

// ── Vintage Hues Palette ─────────────────────────────────────────────────────
const _cerulean    = Color(0xFF2D728F);
const _cyan        = Color(0xFF3B8EA5);
const _sandy       = Color(0xFFF49E4C);
const _cream       = Color(0xFFFDF8EC);
const _white       = Color(0xFFFFFFFF);
const _ink         = Color(0xFF0F2027);
const _inkMid      = Color(0xFF2C4A55);
const _inkLight    = Color(0xFF7A9BAA);

// ── Icon asset paths ──────────────────────────────────────────────────────────
const _imgBase = 'assets/images';

final _receiptIcons = <Map<String, String>>[
  {'asset': '$_imgBase/1.svg',  'label': 'Grocery'},
  {'asset': '$_imgBase/2.svg',  'label': 'Dining'},
  {'asset': '$_imgBase/3.svg',  'label': 'Electronics'},
  {'asset': '$_imgBase/4.svg',  'label': 'Utilities'},
  {'asset': '$_imgBase/5.svg',  'label': 'Education'},
  {'asset': '$_imgBase/6.svg',  'label': 'Health'},
  {'asset': '$_imgBase/7.svg',  'label': 'Clothing'},
  {'asset': '$_imgBase/8.svg',  'label': 'Others'},
  {'asset': '$_imgBase/9.svg',  'label': 'Personal'},
  {'asset': '$_imgBase/10.svg', 'label': 'Work'},
];

class ScanModal extends StatefulWidget {
  final ValueChanged<Receipt> onSave;
  final Receipt? existing;
  const ScanModal({super.key, required this.onSave, this.existing});

  @override
  State<ScanModal> createState() => _ScanModalState();
}

class _ScanModalState extends State<ScanModal>
    with SingleTickerProviderStateMixin {
  late String _step;
  late String _store;
  late String _amount;
  late String _notes;
  late String _warranty;
  late String _date;
  late String _category;
  late String _folder;
  late String _image;
  XFile?       _pickedXFile;
  Uint8List?   _pickedBytes;
  String?      _pickedPath;

  // ── Validation errors ─────────────────────────────────────────────────────
  String? _storeError;
  String? _amountError;

  late final AnimationController _slideCtrl;
  late final Animation<Offset>   _slideAnim;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    // Pre-fill from existing receipt if editing
    _step     = e != null ? 'form' : 'choose';
    _store    = e?.store    ?? '';
    _amount   = e != null ? e.amount.toStringAsFixed(2) : '';
    _notes    = e?.notes    ?? '';
    _warranty = e?.warranty ?? '';
    _date     = e?.date     ?? DateTime.now().toIso8601String().split('T')[0];
    _category = e?.category ?? 'Grocery';
    _folder   = e?.folder   ?? 'Personal';
    _image    = e?.image.startsWith('assets/') == true
                  ? e!.image
                  : '$_imgBase/1.svg';
    _pickedBytes = e?.imageBytes;

    _slideCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    )..forward();
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideCtrl, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _slideCtrl.dispose();
    super.dispose();
  }

  void _goToForm()   { setState(() => _step = 'form');   _slideCtrl..reset()..forward(); }
  void _goToChoose() { setState(() => _step = 'choose'); _slideCtrl..reset()..forward(); }

  Future<void> _pickFromCamera() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.camera);
      if (pickedFile == null) return;
      
      final bytes = await pickedFile.readAsBytes();
      
      try {
        final result = await ApiService.scanReceiptOcr(bytes);
        if (result['store'] != null && result['store'].toString().isNotEmpty) {
          setState(() => _store = result['store'].toString());
        }
        if (result['amount'] != null && result['amount'].toString().isNotEmpty) {
          setState(() => _amount = result['amount'].toString());
        }
        if (result['date'] != null && result['date'].toString().isNotEmpty) {
          setState(() => _date = result['date'].toString());
        }
      } catch (e) {
        // OCR failed, ignore
      }
      
      _goToForm();
    } catch (e) {
      _goToForm();
    }
  }

  Future<void> _pickFromGallery() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);
      if (pickedFile == null) return;
      
      final bytes = await pickedFile.readAsBytes();
      
      try {
        final result = await ApiService.scanReceiptOcr(bytes);
        if (result['store'] != null && result['store'].toString().isNotEmpty) {
          setState(() => _store = result['store'].toString());
        }
        if (result['amount'] != null && result['amount'].toString().isNotEmpty) {
          setState(() => _amount = result['amount'].toString());
        }
        if (result['date'] != null && result['date'].toString().isNotEmpty) {
          setState(() => _date = result['date'].toString());
        }
      } catch (e) {
        // OCR failed, ignore
      }
      
      _goToForm();
    } catch (e) {
      _goToForm();
    }
  }

  // Returns true if bytes are an SVG file (starts with '<')
  bool _isSvgBytes(Uint8List bytes) {
    if (bytes.length < 5) return false;
    final prefix = String.fromCharCodes(bytes.take(5));
    return prefix.trimLeft().startsWith('<');
  }

  Future<void> _pickFromGallery() async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      if (!mounted) return;
      if (picked != null) {
        final bytes = await picked.readAsBytes();
        setState(() {
          _pickedXFile = picked;
          _pickedBytes = bytes;
          _pickedPath  = picked.path;
        });
        _goToForm();
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Could not open gallery: $e'),
        backgroundColor: Colors.red.shade700,
      ));
    }
  }

  Future<void> _pickFromCamera() async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
      );
      if (!mounted) return;
      if (picked != null) {
        final bytes = await picked.readAsBytes();
        setState(() {
          _pickedXFile = picked;
          _pickedBytes = bytes;
          _pickedPath  = picked.path;
        });
        _goToForm();
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Could not open camera: $e'),
        backgroundColor: Colors.red.shade700,
      ));
    }
  }

  void _save() {
    // ── Validate ────────────────────────────────────────────────────────────
    String? storeErr;
    String? amountErr;

    if (_store.trim().isEmpty) {
      storeErr = 'Store name is required.';
    }

    if (_amount.trim().isEmpty) {
      amountErr = 'Amount is required.';
    } else {
      try {
        final parsed = double.parse(_amount.trim());
        if (parsed < 0) amountErr = 'Amount cannot be negative.';
      } catch (_) {
        amountErr = 'Enter a valid number (e.g. 150.00).';
      }
    }

    if (storeErr != null || amountErr != null) {
      setState(() {
        _storeError  = storeErr;
        _amountError = amountErr;
      });
      return;
    }

    // ── Save ────────────────────────────────────────────────────────────────
    try {
      widget.onSave(Receipt(
        id         : widget.existing?.id ?? DateTime.now().millisecondsSinceEpoch,
        store      : _store.trim(),
        amount     : double.parse(_amount.trim()),
        date       : _date,
        category   : _category,
        warranty   : _warranty.isEmpty ? null : _warranty,
        image      : _pickedPath ?? _image,
        folder     : _folder,
        notes      : _notes,
        imageBytes : _pickedBytes,
      ));
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save receipt: $e'),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Widget _field(
    String label,
    ValueChanged<String> onChanged, {
    TextInputType? type,
    String? hint,
    bool optional = false,
    String? errorText,
    String? initialValue,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          Text(label, style: const TextStyle(
            fontSize: 12, fontWeight: FontWeight.w600, color: _inkMid)),
          if (optional) ...[
            const SizedBox(width: 5),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
              decoration: BoxDecoration(
                color: _inkLight.withOpacity(0.10),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text('optional', style: TextStyle(
                fontSize: 9.5, color: _inkLight.withOpacity(0.75))),
            ),
          ],
        ]),
        const SizedBox(height: 7),
        TextFormField(
          initialValue: initialValue,
          onChanged: (v) {
            onChanged(v);
            if (errorText != null) {
              setState(() {
                if (label.contains('Store'))  _storeError  = null;
                if (label.contains('Amount')) _amountError = null;
              });
            }
          },
          keyboardType: type,
          style: const TextStyle(
            fontSize: 13.5, color: _inkMid, fontWeight: FontWeight.w500),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: _inkLight.withOpacity(0.55), fontSize: 13),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14, vertical: 13),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(13),
              borderSide: BorderSide(color: _cerulean.withOpacity(0.15)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(13),
              borderSide: BorderSide(
                color: errorText != null
                    ? Colors.red.shade400
                    : _cerulean.withOpacity(0.15),
                width: 1.5),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(13),
              borderSide: BorderSide(
                color: errorText != null ? Colors.red.shade500 : _cerulean,
                width: 1.8),
            ),
            filled: true,
            fillColor: errorText != null ? Colors.red.shade50 : _white,
          ),
        ),
        if (errorText != null) ...[
          const SizedBox(height: 5),
          Row(children: [
            Icon(Icons.error_outline_rounded,
              size: 13, color: Colors.red.shade500),
            const SizedBox(width: 4),
            Text(errorText,
              style: TextStyle(
                fontSize: 11.5,
                color: Colors.red.shade600,
                fontWeight: FontWeight.w500,
              )),
          ]),
        ],
        SizedBox(height: errorText != null ? 10 : 14),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: _cream,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 32),
      child: SlideTransition(
        position: _slideAnim,
        child: SingleChildScrollView(
          child: Column(children: [

            // ── Drag handle ──────────────────────────────────────────
            Container(
              width: 40, height: 4,
              margin: const EdgeInsets.only(top: 14, bottom: 4),
              decoration: BoxDecoration(
                color: _cerulean.withOpacity(0.18),
                borderRadius: BorderRadius.circular(4),
              ),
            ),

            // ════════════════════════════════════════════════════════
            // CHOOSE STEP
            // ════════════════════════════════════════════════════════
            if (_step == 'choose')
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Container(
                        width: 44, height: 44,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [_cerulean, _cyan],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.receipt_long_rounded,
                            color: Colors.white,
                            size: 22,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Add Receipt', style: TextStyle(
                            fontFamily: 'Georgia', fontSize: 20,
                            fontWeight: FontWeight.w900, color: _ink,
                            letterSpacing: -0.4)),
                          Text('Choose how to add', style: TextStyle(
                            fontSize: 12.5,
                            color: _inkLight.withOpacity(0.8))),
                        ],
                      ),
                    ]),
                    const SizedBox(height: 24),
                    _ChoiceOption(
                      icon: Icons.camera_alt_outlined,
                      label: 'Scan with Camera',
                      sub: 'Use your camera to capture a receipt',
                      accent: _cerulean, onTap: _pickFromCamera,
                    ),
                    const SizedBox(height: 10),
                    _ChoiceOption(
                      icon: Icons.image_outlined,
                      label: 'Upload from Gallery',
                      sub: 'Pick an existing photo from your gallery',
                      accent: _sandy, onTap: _pickFromGallery,
                    ),
                    const SizedBox(height: 10),
                    _ChoiceOption(
                      icon: Icons.edit_outlined,
                      label: 'Enter Manually',
                      sub: 'Type in the receipt details yourself',
                      accent: _cyan, onTap: _goToForm,
                    ),
                  ],
                ),
              ),

            // ════════════════════════════════════════════════════════
            // FORM STEP
            // ════════════════════════════════════════════════════════
            if (_step == 'form')
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    // ── Header ─────────────────────────────────────
                    Row(children: [
                      GestureDetector(
                        onTap: _goToChoose,
                        child: Container(
                          width: 38, height: 38,
                          decoration: BoxDecoration(
                            color: _cerulean.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: _cerulean.withOpacity(0.15), width: 1.2),
                          ),
                          child: const Icon(
                            Icons.arrow_back_ios_new_rounded,
                            color: _cerulean, size: 15),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        widget.existing != null ? 'Edit Receipt' : 'Receipt Details',
                        style: const TextStyle(
                          fontFamily: 'Georgia', fontSize: 20,
                          fontWeight: FontWeight.w900, color: _ink,
                          letterSpacing: -0.4)),
                    ]),

                    const SizedBox(height: 20),

                    // ── RECEIPT ICON PICKER ───────────────────────
                    _SectionLabel(label: 'Receipt Icon'),
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 68,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        itemCount: _receiptIcons.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 10),
                        itemBuilder: (_, i) {
                          final asset = _receiptIcons[i]['asset']!;
                          final sel   = _image == asset;
                          return GestureDetector(
                            onTap: () => setState(() {
                              _image = asset;
                              // Clear any attached image so the chosen icon shows
                              _pickedXFile = null;
                              _pickedBytes = null;
                              _pickedPath  = null;
                            }),
                            child: _IconPickerTile(asset: asset, selected: sel),
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 18),

                    // ── Attach Image ───────────────────────────────
                    _SectionLabel(label: 'Attach Image'),
                    const SizedBox(height: 10),
                    if (_pickedBytes == null)
                      GestureDetector(
                        onTap: () async {
                          await showModalBottomSheet(
                            context: context,
                            backgroundColor: Colors.transparent,
                            builder: (_) => Container(
                              padding: const EdgeInsets.fromLTRB(20, 20, 20, 36),
                              decoration: const BoxDecoration(
                                color: _cream,
                                borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(24)),
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 36, height: 4,
                                    margin: const EdgeInsets.only(bottom: 18),
                                    decoration: BoxDecoration(
                                      color: _cerulean.withOpacity(0.18),
                                      borderRadius: BorderRadius.circular(4)),
                                  ),
                                  ListTile(
                                    leading: Container(
                                      width: 42, height: 42,
                                      decoration: BoxDecoration(
                                        color: _sandy.withOpacity(0.12),
                                        borderRadius: BorderRadius.circular(12)),
                                      child: const Icon(Icons.image_outlined,
                                        color: _sandy, size: 20),
                                    ),
                                    title: const Text('Upload from Gallery',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 14, color: _ink)),
                                    subtitle: Text('Pick a photo from your gallery',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: _inkLight.withOpacity(0.8))),
                                    onTap: () {
                                      Navigator.pop(context);
                                      _pickFromGallery();
                                    },
                                  ),
                                  const SizedBox(height: 8),
                                  ListTile(
                                    leading: Container(
                                      width: 42, height: 42,
                                      decoration: BoxDecoration(
                                        color: _cerulean.withOpacity(0.10),
                                        borderRadius: BorderRadius.circular(12)),
                                      child: const Icon(Icons.camera_alt_outlined,
                                        color: _cerulean, size: 20),
                                    ),
                                    title: const Text('Take a Photo',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 14, color: _ink)),
                                    subtitle: Text('Use your camera',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: _inkLight.withOpacity(0.8))),
                                    onTap: () {
                                      Navigator.pop(context);
                                      _pickFromCamera();
                                    },
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          decoration: BoxDecoration(
                            color: _white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: _sandy.withOpacity(0.45),
                              width: 1.5,
                              strokeAlign: BorderSide.strokeAlignInside,
                            ),
                          ),
                          child: Column(children: [
                            Container(
                              width: 44, height: 44,
                              decoration: BoxDecoration(
                                color: _sandy.withOpacity(0.12),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.add_photo_alternate_outlined,
                                color: _sandy, size: 22),
                            ),
                            const SizedBox(height: 8),
                            const Text('Tap to attach image',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: _inkMid)),
                            const SizedBox(height: 3),
                            Text('Gallery or Camera',
                              style: TextStyle(
                                fontSize: 11.5,
                                color: _inkLight.withOpacity(0.75))),
                          ]),
                        ),
                      )
                    else ...[ 
                      ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: Stack(
                          children: [
                            _isSvgBytes(_pickedBytes!)
                              ? SvgPicture.memory(
                                  _pickedBytes!,
                                  height: 160,
                                  width: double.infinity,
                                  fit: BoxFit.contain,
                                )
                              : Image.memory(
                                  _pickedBytes!,
                                  height: 160,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                ),
                            Positioned(
                              top: 8, right: 8,
                              child: GestureDetector(
                                onTap: () => setState(() {
                                  _pickedXFile = null;
                                  _pickedBytes = null;
                                  _pickedPath  = null;
                                }),
                                child: Container(
                                  width: 30, height: 30,
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.55),
                                    shape: BoxShape.circle),
                                  child: const Icon(Icons.close_rounded,
                                    color: Colors.white, size: 16),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: _pickFromGallery,
                        child: Row(children: [
                          const Icon(Icons.swap_horiz_rounded,
                            size: 15, color: _cerulean),
                          const SizedBox(width: 5),
                          Text('Change image',
                            style: TextStyle(
                              fontSize: 12,
                              color: _cerulean.withOpacity(0.85),
                              fontWeight: FontWeight.w600)),
                        ]),
                      ),
                    ],

                    const SizedBox(height: 18),

                    // ── Text fields ────────────────────────────────
                    _field('Store / Merchant *',
                      (v) => setState(() => _store = v),
                      hint: 'e.g. SM Supermarket',
                      errorText: _storeError,
                      initialValue: _store.isEmpty ? null : _store),
                    _field('Amount (PHP) *',
                      (v) => setState(() => _amount = v),
                      type: TextInputType.number,
                      hint: '0.00',
                      errorText: _amountError,
                      initialValue: _amount.isEmpty ? null : _amount),
                    _field('Warranty Date',
                      (v) => setState(() => _warranty = v),
                      hint: 'YYYY-MM-DD', optional: true,
                      initialValue: _warranty.isEmpty ? null : _warranty),
                    _field('Notes',
                      (v) => setState(() => _notes = v),
                      optional: true,
                      initialValue: _notes.isEmpty ? null : _notes),

                    // ── Category chips ─────────────────────────────
                    _SectionLabel(label: 'Category'),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8, runSpacing: 8,
                      children: categories
                          .where((c) => c != 'All')
                          .map((c) {
                        final sel  = _category == c;
                        final icon = catIcons[c] ?? Icons.category_rounded;
                        return GestureDetector(
                          onTap: () => setState(() => _category = c),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 7),
                            decoration: BoxDecoration(
                              color: sel ? _cerulean : _white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: sel
                                    ? _cerulean
                                    : _cerulean.withOpacity(0.15),
                                width: sel ? 0 : 1.5),
                              boxShadow: sel
                                  ? [BoxShadow(
                                      color: _cerulean.withOpacity(0.25),
                                      blurRadius: 8,
                                      offset: const Offset(0, 3))]
                                  : [],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(icon,
                                  size: 14,
                                  color: sel ? _white : Colors.black),
                                const SizedBox(width: 5),
                                Text(c, style: TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: sel
                                      ? FontWeight.w700 : FontWeight.w500,
                                  color: sel ? _white : _inkMid)),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 18),

                    // ── Folder pills ───────────────────────────────
                    _SectionLabel(label: 'Folder'),
                    const SizedBox(height: 10),
                    Row(
                      children: folders
                          .where((f) => f != 'All')
                          .map((f) {
                        final sel  = _folder == f;
                        final icon = f == 'Personal'
                            ? Icons.home_rounded
                            : Icons.work_rounded;
                        return GestureDetector(
                          onTap: () => setState(() => _folder = f),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            margin: const EdgeInsets.only(right: 10),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 9),
                            decoration: BoxDecoration(
                              color: sel ? _cerulean : _white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: sel
                                    ? _cerulean
                                    : _cerulean.withOpacity(0.15),
                                width: sel ? 0 : 1.5),
                              boxShadow: sel
                                  ? [BoxShadow(
                                      color: _cerulean.withOpacity(0.25),
                                      blurRadius: 8,
                                      offset: const Offset(0, 3))]
                                  : [],
                            ),
                            child: Row(children: [
                              Icon(
                                icon,
                                size: 16,
                                color: sel ? Colors.white : Colors.black,
                              ),
                              const SizedBox(width: 6),
                              Text(f, style: TextStyle(
                                fontSize: 12.5,
                                fontWeight: sel
                                    ? FontWeight.w700 : FontWeight.w500,
                                color: sel ? _white : _inkMid)),
                            ]),
                          ),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 26),

                    // ── Save button ────────────────────────────────
                    GestureDetector(
                      onTap: _save,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [_cerulean, _cyan],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [BoxShadow(
                            color: _cerulean.withOpacity(0.35),
                            blurRadius: 16,
                            offset: const Offset(0, 6))],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(widget.existing != null ? Icons.edit_outlined : Icons.save_alt_rounded,
                              color: _white, size: 18),
                            const SizedBox(width: 8),
                            Text(widget.existing != null ? 'Update Receipt' : 'Save Receipt', style: const TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w800,
                              color: _white, letterSpacing: 0.2)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ]),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ICON PICKER TILE — SVG version
// ─────────────────────────────────────────────────────────────────────────────
class _IconPickerTile extends StatelessWidget {
  final String asset;
  final bool   selected;

  static const double _imgSize    = 60.0;
  static const double _ringStroke = 2.5;
  static const double _ringGap    = 2.0;

  const _IconPickerTile({required this.asset, required this.selected});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width : _imgSize,
      height: _imgSize,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          // ── Perfect circle SVG ──────────────────────────────────
          ClipOval(
            child: SvgPicture.asset(
              asset,
              width : _imgSize,
              height: _imgSize,
              fit: BoxFit.cover,
              placeholderBuilder: (_) => Container(
                width: _imgSize, height: _imgSize,
                decoration: const BoxDecoration(
                  color: Color(0x1A7A9BAA),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.broken_image_outlined,
                  size: 22, color: Color(0x807A9BAA)),
              ),
            ),
          ),

          // ── Selection ring: stroke only ─────────────────────────
          if (selected)
            Positioned.fill(
              child: CustomPaint(
                painter: _StrokeRingPainter(
                  color:       _cerulean,
                  strokeWidth: _ringStroke,
                  gap:         _ringGap,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _StrokeRingPainter extends CustomPainter {
  final Color  color;
  final double strokeWidth;
  final double gap;

  const _StrokeRingPainter({
    required this.color,
    required this.strokeWidth,
    required this.gap,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color       = color
      ..style       = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..isAntiAlias = true;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 + gap + strokeWidth / 2;
    canvas.drawCircle(center, radius, paint);
  }

  @override
  bool shouldRepaint(_StrokeRingPainter old) =>
      old.color != color ||
      old.strokeWidth != strokeWidth ||
      old.gap != gap;
}

// ─────────────────────────────────────────────────────────────────────────────
// SECTION LABEL
// ─────────────────────────────────────────────────────────────────────────────
class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Container(
        width: 3, height: 14,
        margin: const EdgeInsets.only(right: 8),
        decoration: BoxDecoration(
          color: _sandy, borderRadius: BorderRadius.circular(2)),
      ),
      Text(label, style: const TextStyle(
        fontSize: 12.5, fontWeight: FontWeight.w700,
        color: _inkMid, letterSpacing: 0.1)),
    ]);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// CHOICE OPTION TILE
// ─────────────────────────────────────────────────────────────────────────────
class _ChoiceOption extends StatelessWidget {
  final IconData     icon;
  final String       label, sub;
  final Color        accent;
  final VoidCallback onTap;

  const _ChoiceOption({
    required this.icon,
    required this.label,
    required this.sub,
    required this.accent,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: accent.withOpacity(0.14), width: 1.5),
          boxShadow: [BoxShadow(
            color: accent.withOpacity(0.07),
            blurRadius: 12,
            offset: const Offset(0, 4))],
        ),
        child: Row(children: [
          Container(
            width: 46, height: 46,
            decoration: BoxDecoration(
              color: accent.withOpacity(0.10),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: accent.withOpacity(0.18), width: 1),
            ),
            child: Icon(icon, color: accent, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(
                  fontWeight: FontWeight.w700, fontSize: 14, color: _ink)),
                const SizedBox(height: 2),
                Text(sub, style: TextStyle(
                  fontSize: 12, color: _inkLight.withOpacity(0.85))),
              ],
            ),
          ),
          Icon(Icons.arrow_forward_ios_rounded,
            size: 14, color: accent.withOpacity(0.40)),
        ]),
      ),
    );
  }
}