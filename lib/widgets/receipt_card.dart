import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../models/receipt_model.dart';
import '../utils/constants.dart';

// Safe SVG loader — only uses SvgPicture.asset for actual asset paths
Widget _safeCardIcon(String imagePath, double size, Color fallbackColor) {
  if (imagePath.startsWith('assets/')) {
    return SvgPicture.asset(
      imagePath,
      width: size, height: size,
      fit: BoxFit.cover,
      placeholderBuilder: (_) => Icon(
        Icons.receipt_rounded, size: size * 0.5,
        color: fallbackColor.withOpacity(0.5)),
    );
  }
  return Icon(Icons.receipt_rounded,
    size: size * 0.5, color: fallbackColor.withOpacity(0.5));
}

// ── Vintage Hues Palette ─────────────────────────────────────────────────────
const _cerulean    = Color(0xFF2D728F);
const _sandy       = Color(0xFFF49E4C);
const _brick       = Color(0xFFAB3428);
const _white       = Color(0xFFFFFFFF);
const _ink         = Color(0xFF0F2027);
const _inkMid      = Color(0xFF2C4A55);
const _inkLight    = Color(0xFF7A9BAA);

class ReceiptCard extends StatelessWidget {
  final Receipt receipt;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const ReceiptCard({
    super.key,
    required this.receipt,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final color = catColors[receipt.category] ?? _inkLight;
    final days  = receipt.daysToWarranty;

    final bool warrantyCritical = days != null && days > 0 && days <= 30;
    final bool warrantyExpired  = days != null && days <= 0;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: _white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: warrantyCritical
                ? _brick.withOpacity(0.18)
                : color.withOpacity(0.12),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.07),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(children: [

            // ── Circular icon: always SVG, photo overlay if present ─
            SizedBox(
              width: 54, height: 54,
              child: Stack(
                children: [
                  // SVG category icon always shown as base
                  ClipOval(
                    child: SvgPicture.asset(
                      receipt.image.startsWith('assets/')
                          ? receipt.image
                          : 'assets/images/8.svg',
                      width: 54, height: 54,
                      fit: BoxFit.cover,
                      placeholderBuilder: (_) => Container(
                        width: 54, height: 54,
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.12),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.receipt_rounded,
                          size: 24, color: color.withOpacity(0.5)),
                      ),
                    ),
                  ),
                  // If a photo was attached, show it as a small overlay
                  if (receipt.imageBytes != null)
                    Positioned(
                      right: 0, bottom: 0,
                      child: Container(
                        width: 22, height: 22,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: _white, width: 1.5),
                        ),
                        child: ClipOval(
                          child: Image.memory(
                            receipt.imageBytes!,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(width: 13),

            // ── Info ───────────────────────────────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    receipt.store,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14.5,
                      color: _ink,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Row(children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.10),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        receipt.category,
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w600,
                          color: color,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      receipt.formattedDate,
                      style: TextStyle(
                        fontSize: 11,
                        color: _inkLight.withOpacity(0.8),
                      ),
                    ),
                  ]),
                  if (warrantyCritical) ...[
                    const SizedBox(height: 5),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: _brick.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '⏰ Warranty: ${days}d left',
                        style: const TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w600,
                          color: _brick,
                        ),
                      ),
                    ),
                  ],
                  if (warrantyExpired) ...[
                    const SizedBox(height: 5),
                    Text(
                      'Warranty expired',
                      style: TextStyle(
                        fontSize: 10.5,
                        color: _inkLight.withOpacity(0.7),
                      ),
                    ),
                  ],
                  if (!warrantyCritical && !warrantyExpired &&
                      days != null && days > 30) ...[
                    const SizedBox(height: 5),
                    Text(
                      '✔ ${days}d warranty left',
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w600,
                        color: _cerulean.withOpacity(0.8),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(width: 8),

            // ── Amount + Delete ────────────────────────────────────
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  receipt.formattedAmount,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                    color: _cerulean,
                    fontFamily: 'Georgia',
                  ),
                ),
                const SizedBox(height: 6),
                GestureDetector(
                  onTap: onDelete,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: _brick.withOpacity(0.07),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.delete_outline_rounded,
                      size: 15,
                      color: _brick,
                    ),
                  ),
                ),
              ],
            ),
          ]),
        ),
      ),
    );
  }
}