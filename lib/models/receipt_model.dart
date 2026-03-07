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

  int? get daysToWarranty {
    if (warranty == null) return null;
    final exp = DateTime.parse(warranty!);
    return exp.difference(DateTime.now()).inDays;
  }

  String get formattedAmount =>
      '₱${amount.toStringAsFixed(2).replaceAllMapped(
        RegExp(r'(\d)(?=(\d{3})+\.)'),
        (m) => '${m[1]},',
      )}';

  String get formattedDate {
    final d = DateTime.parse(date);
    const months = ['Jan','Feb','Mar','Apr','May','Jun',
                    'Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${months[d.month - 1]} ${d.day}, ${d.year}';
  }

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
