class Receipt {
  final int     id;
  final String  store;
  final double  amount;
  final String  date;
  final String  category;
  final String? warranty;
  final String  image;
  final String  folder;
  final String  notes;

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
  });

  // ── Safe date parser ──────────────────────────────────────────────────────
  // Handles both "2026-01-25" (ISO) and "January 25, 2026" (legacy seed data)
  static DateTime? _parseDate(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    // Try ISO first (the normal path)
    try {
      return DateTime.parse(raw.split('T')[0]);
    } catch (_) {}
    // Fallback: parse "Month DD, YYYY"
    try {
      const months = {
        'january': 1,  'february': 2,  'march': 3,     'april': 4,
        'may': 5,      'june': 6,      'july': 7,      'august': 8,
        'september': 9,'october': 10,  'november': 11, 'december': 12,
      };
      final parts = raw.replaceAll(',', '').split(' ');
      final month = months[parts[0].toLowerCase()];
      final day   = int.parse(parts[1]);
      final year  = int.parse(parts[2]);
      if (month != null) return DateTime(year, month, day);
    } catch (_) {}
    return null;
  }

  // ── Warranty ──────────────────────────────────────────────────────────────
  int? get daysToWarranty {
    if (warranty == null) return null;
    final exp = _parseDate(warranty);
    if (exp == null) return null;
    return exp.difference(DateTime.now()).inDays;
  }

  // ── Formatting ────────────────────────────────────────────────────────────
  String get formattedAmount =>
      '₱${amount.toStringAsFixed(2).replaceAllMapped(
        RegExp(r'(\d)(?=(\d{3})+\.)'),
        (m) => '${m[1]},',
      )}';

  String get formattedDate {
    final d = _parseDate(date);
    if (d == null) return date; // fallback: show raw string
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[d.month - 1]} ${d.day}, ${d.year}';
  }

  // ── Serialisation ─────────────────────────────────────────────────────────
  factory Receipt.fromMap(Map<String, dynamic> m) => Receipt(
    id       : m['id'],
    store    : m['store'],
    amount   : (m['amount'] as num).toDouble(),
    date     : m['date'],
    category : m['category'],
    warranty : m['warranty'],
    image    : m['image'],
    folder   : m['folder'],
    notes    : m['notes'] ?? '',
  );
}