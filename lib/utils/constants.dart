import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Colors
const Color cBg        = Color(0xFFF7F5F2);
const Color cCard      = Color(0xFFFFFFFF);
const Color cPrimary   = Color(0xFF2D6A4F);
const Color cPrimaryLt = Color(0xFF52B788);
const Color cAccent    = Color(0xFFF4A261);
const Color cDanger    = Color(0xFFE76F51);
const Color cText      = Color(0xFF1B1B1B);
const Color cSub       = Color(0xFF6B7280);
const Color cBorder    = Color(0xFFE5E0D8);

// Categories
const List<String> categories = [
  'All', 'Groceries', 'Food & Dining',
  'Electronics', 'Utilities', 'Education', 'Others'
];

// Folders
const List<String> folders = ['All', 'Personal', 'Work'];

// Category colors
const Map<String, Color> catColors = {
  'Groceries'    : Color(0xFF52B788),
  'Food & Dining': Color(0xFFF4A261),
  'Electronics'  : Color(0xFF457B9D),
  'Utilities'    : Color(0xFFE9C46A),
  'Education'    : Color(0xFFA8DADC),
  'Others'       : Color(0xFFCDB4DB),
};

// Category icons (Material Icons, black)
const Map<String, IconData> catIcons = {
  'All'          : Icons.grid_view_rounded,
  'Groceries'    : Icons.shopping_cart_rounded,
  'Food & Dining': Icons.restaurant_rounded,
  'Electronics'  : Icons.devices_rounded,
  'Utilities'    : Icons.bolt_rounded,
  'Education'    : Icons.menu_book_rounded,
  'Others'       : Icons.category_rounded,
};

// ── Receipt SVG asset loaded as bytes (used as imageBytes for seed data) ──────
const String receiptSvgPath = 'assets/images/receipt.svg';

Uint8List? _receiptSvgBytes;
Future<Uint8List> loadReceiptSvgBytes() async {
  _receiptSvgBytes ??= (await rootBundle.load(receiptSvgPath)).buffer.asUint8List();
  return _receiptSvgBytes!;
}

// Seed receipts — imageBytes loaded async via initSeedReceipts()
List<Map<String, dynamic>> buildSeedReceipts(Uint8List imgBytes) => [
  { 'id': 1, 'store': 'SM Supermarket',     'amount': 1250.75, 'date': '2026-02-28', 'category': 'Groceries',     'warranty': null,         'image': 'assets/images/1.svg', 'folder': 'Personal', 'notes': 'Weekly groceries',    'imageBytes': imgBytes },
  { 'id': 2, 'store': 'Jollibee',           'amount': 320.00,  'date': '2026-03-01', 'category': 'Food & Dining', 'warranty': null,         'image': 'assets/images/2.svg', 'folder': 'Personal', 'notes': 'Family meal',          'imageBytes': imgBytes },
  { 'id': 3, 'store': 'Samsung Service',    'amount': 4500.00, 'date': '2026-01-15', 'category': 'Electronics',   'warranty': '2027-01-15', 'image': 'assets/images/3.svg', 'folder': 'Work',     'notes': 'Phone repair',         'imageBytes': imgBytes },
  { 'id': 4, 'store': 'Meralco',            'amount': 2100.00, 'date': '2026-03-05', 'category': 'Utilities',     'warranty': null,         'image': 'assets/images/4.svg', 'folder': 'Personal', 'notes': 'Electric bill',        'imageBytes': imgBytes },
  { 'id': 5, 'store': 'National Bookstore', 'amount': 875.50,  'date': '2026-02-20', 'category': 'Education',     'warranty': null,         'image': 'assets/images/5.svg', 'folder': 'Work',     'notes': 'Office supplies',      'imageBytes': imgBytes },
  { 'id': 6, 'store': 'Lazada',             'amount': 3200.00, 'date': '2026-02-10', 'category': 'Electronics',   'warranty': '2027-02-10', 'image': 'assets/images/3.svg', 'folder': 'Personal', 'notes': 'Keyboard',             'imageBytes': imgBytes },
  { 'id': 7, 'store': 'Bike Shop',          'amount': 154.06,  'date': '2026-03-19', 'category': 'Others',        'warranty': null,         'image': 'assets/images/8.svg', 'folder': 'Personal', 'notes': 'Brake cables + labor', 'imageBytes': imgBytes },
];