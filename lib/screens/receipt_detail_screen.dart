import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../models/receipt_model.dart';
import '../services/csv_download_stub.dart'
    if (dart.library.html) '../services/csv_download_web.dart';

bool _isSvg(Uint8List bytes) {
  if (bytes.length < 5) return false;
  return String.fromCharCodes(bytes.take(5)).trimLeft().startsWith('<');
}

// ── Safe SVG icon: only loads asset paths starting with "assets/" ─────────────
Widget _safeIcon(String imagePath, double size, Color fallbackColor) {
  if (imagePath.startsWith('assets/')) {
    return SvgPicture.asset(
      imagePath,
      width: size, height: size,
      fit: BoxFit.cover,
      placeholderBuilder: (_) => _iconFallback(size, fallbackColor),
    );
  }
  return _iconFallback(size, fallbackColor);
}

Widget _iconFallback(double size, Color color) => Container(
  width: size, height: size,
  decoration: BoxDecoration(
    color: color.withOpacity(0.12),
    shape: BoxShape.circle,
  ),
  child: Icon(Icons.receipt_rounded, size: size * 0.4, color: color.withOpacity(0.5)),
);

// ── Vintage Hues Palette ─────────────────────────────────────────────────────
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

class ReceiptDetailScreen extends StatelessWidget {
  final Receipt receipt;
  final VoidCallback onBack;
  final ValueChanged<int> onDelete;
  final ValueChanged<Receipt>? onEdit;

  const ReceiptDetailScreen({
    super.key,
    required this.receipt,
    required this.onBack,
    required this.onDelete,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;
    final days   = receipt.daysToWarranty;

    final bool hasWarranty      = receipt.warranty != null;
    final bool warrantyExpired  = hasWarranty && (days != null && days <= 0);
    final bool warrantyCritical = hasWarranty && days != null && days > 0 && days <= 30;

    return Scaffold(
      backgroundColor: _cream,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── HERO HEADER ──────────────────────────────────────────────
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
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 20, 20, 22),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(children: [
                              GestureDetector(
                                onTap: onBack,
                                child: Container(
                                  width: 40, height: 40,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.16),
                                    borderRadius: BorderRadius.circular(13),
                                    border: Border.all(
                                      color: Colors.white.withOpacity(0.24),
                                      width: 1.2,
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.arrow_back_ios_new_rounded,
                                    color: _white, size: 16),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Receipt Detail',
                                      style: TextStyle(
                                        color: _vanilla.withOpacity(0.72),
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      )),
                                    const SizedBox(height: 2),
                                    Text(receipt.store,
                                      style: const TextStyle(
                                        color: _white, fontSize: 20,
                                        fontWeight: FontWeight.w900,
                                        fontFamily: 'Georgia',
                                        letterSpacing: -0.4,
                                      ),
                                      overflow: TextOverflow.ellipsis),
                                  ],
                                ),
                              ),
                            ]),
                            const SizedBox(height: 18),
                            Row(children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Amount',
                                    style: TextStyle(
                                      color: _vanilla.withOpacity(0.55),
                                      fontSize: 10.5)),
                                  const SizedBox(height: 3),
                                  Text(receipt.formattedAmount,
                                    style: const TextStyle(
                                      fontFamily: 'Georgia',
                                      color: _vanilla, fontSize: 30,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: -0.8, height: 1.0)),
                                ],
                              ),
                              const Spacer(),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  _HeaderPill(
                                    label: receipt.category,
                                    bgColor: Colors.white.withOpacity(0.14),
                                    textColor: _vanilla,
                                  ),
                                  const SizedBox(height: 5),
                                  _HeaderPillWithIcon(
                                    icon: Icons.folder_rounded,
                                    label: receipt.folder,
                                    bgColor: Colors.white.withOpacity(0.10),
                                    textColor: _vanilla.withOpacity(0.75),
                                  ),
                                ],
                              ),
                            ]),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 22, 16, 110),
            sliver: SliverList(
              delegate: SliverChildListDelegate([

                // ── RECEIPT IMAGE / ICON ─────────────────────────────
                _ReceiptImageCard(receipt: receipt),

                const SizedBox(height: 20),

                // ── WARRANTY BANNER ──────────────────────────────────
                if (hasWarranty) ...[
                  _WarrantyBanner(
                    warrantyDate: receipt.warranty!.split('T')[0],
                    days        : days,
                    isExpired   : warrantyExpired,
                    isCritical  : warrantyCritical,
                  ),
                  const SizedBox(height: 16),
                ],

                // ── DETAILS CARD ─────────────────────────────────────
                Container(
                  decoration: BoxDecoration(
                    color: _white,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(
                      color: _cerulean.withOpacity(0.10), width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: _cerulean.withOpacity(0.06),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(18, 16, 18, 4),
                        child: Row(children: [
                          Container(
                            width: 4, height: 18,
                            margin: const EdgeInsets.only(right: 10),
                            decoration: BoxDecoration(
                              color: _sandy,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          const Text('Receipt Details',
                            style: TextStyle(
                              fontFamily: 'Georgia', fontSize: 15,
                              fontWeight: FontWeight.w700, color: _ink)),
                        ]),
                      ),
                      const SizedBox(height: 4),
                      _DetailRow(label: 'Store',    value: receipt.store),
                      _DetailRow(label: 'Amount',   value: receipt.formattedAmount),
                      _DetailRow(label: 'Date',     value: receipt.formattedDate),
                      _DetailRow(label: 'Category', value: receipt.category),
                      _DetailRow(label: 'Folder',   value: receipt.folder),
                      _DetailRow(
                        label: 'Notes',
                        value: receipt.notes.isEmpty ? '—' : receipt.notes,
                        isLast: !hasWarranty,
                      ),
                      if (hasWarranty)
                        _DetailRow(
                          label: 'Warranty',
                          value: receipt.warranty!.split('T')[0] +
                              (days != null && days > 0
                                  ? ' (${days}d left)'
                                  : ' (Expired)'),
                          isLast: true,
                          valueColor: warrantyExpired
                              ? _inkLight
                              : warrantyCritical ? _brick : _cerulean,
                        ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // ── ACTION BUTTONS ────────────────────────────────────
                Row(children: [
                  Expanded(
                    child: _ActionButton(
                      icon : Icons.edit_outlined,
                      label: 'Edit',
                      color: _cerulean,
                      onTap: () => onEdit?.call(receipt),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _ActionButton(
                      icon : Icons.download_outlined,
                      label: 'Export',
                      color: _sandy,
                      onTap: () => _exportCsv(context, receipt),
                    ),
                  ),
                  const SizedBox(width: 10),
                  _DeleteButton(onTap: () => onDelete(receipt.id)),
                ]),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// CSV EXPORT — cross-platform (web uses anchor trick, mobile uses share/snackbar)
// ─────────────────────────────────────────────────────────────────────────────
void _exportCsv(BuildContext context, Receipt r) {
  try {
    final rows = [
      ['Field', 'Value'],
      ['Store',    r.store],
      ['Amount',   r.formattedAmount],
      ['Date',     r.formattedDate],
      ['Category', r.category],
      ['Folder',   r.folder],
      ['Notes',    r.notes.isEmpty ? '—' : r.notes],
      ['Warranty', r.warranty ?? '—'],
    ];
    final csv = rows.map((row) =>
      row.map((cell) => '"${cell.replaceAll('"', '""')}"').join(',')
    ).join('\n');
    downloadCsv(csv, '${r.store.replaceAll(' ', '_')}_receipt.csv');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Receipt exported as CSV'),
        backgroundColor: Color(0xFF2D728F),
        behavior: SnackBarBehavior.floating,
      ),
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Export failed: $e'), backgroundColor: Colors.red.shade700),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Receipt image card — full-width photo or SVG icon, tap to zoom
// ─────────────────────────────────────────────────────────────────────────────
class _ReceiptImageCard extends StatelessWidget {
  final Receipt receipt;
  const _ReceiptImageCard({required this.receipt});

  @override
  Widget build(BuildContext context) {
    final bool hasPhoto = receipt.imageBytes != null && receipt.imageBytes!.isNotEmpty;

    return GestureDetector(
      onTap: hasPhoto
          ? () => _ZoomViewer.show(context, receipt.imageBytes!)
          : null,
      child: Container(
        width: double.infinity,
        height: 200,
        decoration: BoxDecoration(
          color: _vanillaSoft,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: _vanilla.withOpacity(0.5), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: _sandy.withOpacity(0.10),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: Stack(
            fit: StackFit.expand,
            children: [

              // ── Background: receipt image (SVG or raster) ────────
              if (hasPhoto)
                _isSvg(receipt.imageBytes!)
                  ? SvgPicture.memory(
                      receipt.imageBytes!,
                      fit: BoxFit.contain,
                    )
                  : Image.memory(
                      receipt.imageBytes!,
                      fit: BoxFit.cover,
                    )
              else
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SvgPicture.asset(
                        receipt.image.startsWith('assets/')
                            ? receipt.image
                            : 'assets/images/8.svg',
                        width: 140, height: 140,
                        fit: BoxFit.contain,
                        placeholderBuilder: (_) => Container(
                          width: 140, height: 140,
                          decoration: const BoxDecoration(
                            color: Color(0x1A7A9BAA),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.receipt_rounded,
                            size: 56, color: _inkLight),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 4),
                        decoration: BoxDecoration(
                          color: _sandy.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          receipt.formattedDate,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: _inkMid,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              // ── SVG category icon badge (bottom-left, always) ─────
              Positioned(
                bottom: 10, left: 10,
                child: Container(
                  decoration: BoxDecoration(
                    color: _white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: SvgPicture.asset(
                      receipt.image.startsWith('assets/')
                          ? receipt.image
                          : 'assets/images/8.svg',
                      width: 44, height: 44,
                      fit: BoxFit.cover,
                      placeholderBuilder: (_) => Container(
                        width: 44, height: 44,
                        color: _vanillaSoft,
                        child: const Icon(Icons.receipt_rounded,
                          size: 20, color: _inkLight),
                      ),
                    ),
                  ),
                ),
              ),

              // ── Date badge (bottom-right, photo only) ─────────────
              if (hasPhoto)
                Positioned(
                  bottom: 10, right: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.50),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      receipt.formattedDate,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),

              // ── Zoom hint (top-right, photo only) ─────────────────
              if (hasPhoto)
                Positioned(
                  top: 10, right: 10,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.40),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.zoom_in_rounded,
                      color: Colors.white, size: 16),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Full-screen zoom viewer
// ─────────────────────────────────────────────────────────────────────────────
class _ZoomViewer {
  static void show(BuildContext context, Uint8List bytes) {
    final size = MediaQuery.of(context).size;
    showDialog(
      context: context,
      barrierColor: Colors.black87,
      barrierDismissible: true,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.zero,
        child: SizedBox(
          width: size.width,
          height: size.height,
          child: Stack(
            children: [
              Positioned.fill(
                child: InteractiveViewer(
                  minScale: 0.5,
                  maxScale: 5.0,
                  child: Center(
                    child: _isSvg(bytes)
                      ? SvgPicture.memory(bytes, fit: BoxFit.contain)
                      : Image.memory(bytes, fit: BoxFit.contain),
                  ),
                ),
              ),
              Positioned(
                top: MediaQuery.of(context).padding.top + 12,
                right: 16,
                child: GestureDetector(
                  onTap: () => Navigator.pop(ctx),
                  child: Container(
                    width: 36, height: 36,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.20),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withOpacity(0.30), width: 1),
                    ),
                    child: const Icon(Icons.close_rounded,
                      color: Colors.white, size: 18),
                  ),
                ),
              ),
              Positioned(
                bottom: 30, left: 0, right: 0,
                child: Center(
                  child: Text('Pinch to zoom · Tap outside to close',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.55),
                      fontSize: 12,
                    )),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeaderPill extends StatelessWidget {
  final String label;
  final Color bgColor, textColor;
  const _HeaderPill({
    required this.label,
    required this.bgColor,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.18), width: 1),
      ),
      child: Text(label, style: TextStyle(
        fontSize: 11.5, fontWeight: FontWeight.w600, color: textColor)),
    );
  }
}

class _HeaderPillWithIcon extends StatelessWidget {
  final IconData icon;
  final String   label;
  final Color    bgColor, textColor;
  const _HeaderPillWithIcon({
    required this.icon,
    required this.label,
    required this.bgColor,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.18), width: 1),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 12, color: textColor),
        const SizedBox(width: 5),
        Text(label, style: TextStyle(
          fontSize: 11.5, fontWeight: FontWeight.w600, color: textColor)),
      ]),
    );
  }
}

class _WarrantyBanner extends StatelessWidget {
  final String warrantyDate;
  final int?   days;
  final bool   isExpired, isCritical;
  const _WarrantyBanner({
    required this.warrantyDate,
    required this.days,
    required this.isExpired,
    required this.isCritical,
  });

  @override
  Widget build(BuildContext context) {
    final Color    accentColor = isExpired
        ? _inkLight
        : isCritical ? _brick : _cerulean;

    final IconData icon = isExpired
        ? Icons.warning_rounded
        : isCritical
            ? Icons.circle
            : Icons.check_circle_rounded;

    final String title = isExpired
        ? 'Warranty Expired'
        : isCritical
            ? 'Expiring in $days days!'
            : 'Active Warranty · $days days remaining';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: accentColor.withOpacity(0.07),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: accentColor.withOpacity(0.25), width: 1.5),
      ),
      child: Row(children: [
        Container(
          width: 40, height: 40,
          decoration: BoxDecoration(
            color: accentColor.withOpacity(0.12),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Icon(icon, color: accentColor, size: 20),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: accentColor,
              )),
              Text('Expires: $warrantyDate', style: TextStyle(
                fontSize: 11.5,
                color: accentColor.withOpacity(0.70),
              )),
            ],
          ),
        ),
      ]),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label, value;
  final bool   isLast;
  final Color? valueColor;
  const _DetailRow({
    required this.label,
    required this.value,
    this.isLast  = false,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
      decoration: BoxDecoration(
        border: isLast ? null : Border(
          bottom: BorderSide(
            color: _cerulean.withOpacity(0.07), width: 1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(
            fontSize: 13, color: _inkLight)),
          const SizedBox(width: 16),
          Flexible(
            child: Text(value,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
                color: valueColor ?? _inkMid,
              )),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData     icon;
  final String       label;
  final Color        color;
  final VoidCallback onTap;
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(
            color: color.withOpacity(0.30),
            blurRadius: 12,
            offset: const Offset(0, 5),
          )],
        ),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(icon, color: _white, size: 16),
          const SizedBox(width: 6),
          Text(label, style: const TextStyle(
            color: _white,
            fontWeight: FontWeight.w700,
            fontSize: 13.5,
          )),
        ]),
      ),
    );
  }
}

class _DeleteButton extends StatelessWidget {
  final VoidCallback onTap;
  const _DeleteButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        decoration: BoxDecoration(
          color: _brick.withOpacity(0.10),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _brick.withOpacity(0.22), width: 1.5),
        ),
        child: const Icon(
          Icons.delete_outline_rounded, color: _brick, size: 20),
      ),
    );
  }
}
