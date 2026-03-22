import 'dart:typed_data';

class Receipt {
  final int id;
  final String store;
  final double amount;
  final String date;
  final String category;
  final String? warranty;
  final String image;
  final String folder;
  final String notes;
  final Uint8List? imageBytes;

  Receipt({
    required this.id,
    required this.store,
    required this.amount,
    required this.date,
    required this.category,
    this.warranty,
    required this.image,
    required this.folder,
    required this.notes,
    this.imageBytes,
  });

  // Hahandle nito ang ISO format at custom date strings like "January 01 2024"
  static DateTime? _parseDate(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    
    try {
      return DateTime.parse(raw.split('T')[0]);
    } catch (_) {}

    try {
      const months = {
        'january': 1, 'february': 2, 'march': 3, 'april': 4,
        'may': 5, 'june': 6, 'july': 7, 'august': 8,
        'september': 9, 'october': 10, 'november': 11, 'december': 12,
      };
      final parts = raw.replaceAll(',', '').split(' ');
      final month = months[parts[0].toLowerCase()];
      final day = int.parse(parts[1]);
      final year = int.parse(parts[2]);
      if (month != null) return DateTime(year, month, day);
    } catch (_) {}
    
    return null;
  }

  bool get hasWarranty => warranty != null && warranty!.isNotEmpty;

  int get daysUntilExpiry {
    final exp = _parseDate(warranty);
    if (exp == null) return -1;
    return exp.difference(DateTime.now()).inDays;
  }

  /// Alias used across screens — returns null when no warranty is set,
  /// otherwise returns the number of days until (or since) expiry.
  int? get daysToWarranty {
    if (!hasWarranty) return null;
    return daysUntilExpiry;
  }

  // Adds Peso sign and commas sa amount
  String get formattedAmount =>
      '₱${amount.toStringAsFixed(2).replaceAllMapped(
            RegExp(r'(\d)(?=(\d{3})+\.)'),
            (m) => '${m[1]},',
          )}';

  String get formattedDate {
    final d = _parseDate(date);
    if (d == null) return date;
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[d.month - 1]} ${d.day}, ${d.year}';
  }

  // ── fromMap — Milestone 2 ──────────────────────────────────────────────────
  factory Receipt.fromMap(Map<String, dynamic> m) => Receipt(
        id: m['id'],
        store: m['store'],
        amount: (m['amount'] as num).toDouble(),
        date: m['date'],
        category: m['category'],
        warranty: m['warranty'],
        image: m['image'],
        folder: m['folder'],
        notes: m['notes'] ?? '',
        imageBytes: m['image_bytes'] as Uint8List?,
      );

  // ── fromJson — Milestone 3 ────────────────────────────────────────────────
  factory Receipt.fromJson(Map<String, dynamic> json) => Receipt(
        id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
        store: json['store'] ?? '',
        amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
        date: json['date'] ?? '',
        category: json['category'] ?? 'Others',
        warranty: json['warranty'],
        image: json['image'] ?? '',
        folder: json['folder'] ?? 'Personal',
        notes: json['notes'] ?? '',
      );

  Map<String, dynamic> toMap() => {
        'id': id, 'store': store, 'amount': amount,
        'date': date, 'category': category, 'warranty': warranty,
        'image': image, 'folder': folder, 'notes': notes,
        'image_bytes': imageBytes,
      };
}
