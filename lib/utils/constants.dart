import 'package:flutter/material.dart';

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

// Seed receipts
final List<Map<String, dynamic>> seedReceipts = [
  { 'id': 1, 'store': 'SM Supermarket',     'amount': 1250.75, 'date': '2026-02-28', 'category': 'Groceries',     'warranty': null,         'image': '🛒', 'folder': 'Personal', 'notes': 'Weekly groceries' },
  { 'id': 2, 'store': 'Jollibee',           'amount': 320.00,  'date': '2026-03-01', 'category': 'Food & Dining', 'warranty': null,         'image': '🍔', 'folder': 'Personal', 'notes': 'Family meal' },
  { 'id': 3, 'store': 'Samsung Service',    'amount': 4500.00, 'date': '2026-01-15', 'category': 'Electronics',   'warranty': '2027-01-15', 'image': '📱', 'folder': 'Work',     'notes': 'Phone repair' },
  { 'id': 4, 'store': 'Meralco',            'amount': 2100.00, 'date': '2026-03-05', 'category': 'Utilities',     'warranty': null,         'image': '💡', 'folder': 'Personal', 'notes': 'Electric bill' },
  { 'id': 5, 'store': 'National Bookstore', 'amount': 875.50,  'date': '2026-02-20', 'category': 'Education',     'warranty': null,         'image': '📚', 'folder': 'Work',     'notes': 'Office supplies' },
  { 'id': 6, 'store': 'Lazada',             'amount': 3200.00, 'date': '2026-02-10', 'category': 'Electronics',   'warranty': '2027-02-10', 'image': '💻', 'folder': 'Personal', 'notes': 'Keyboard' },
];
