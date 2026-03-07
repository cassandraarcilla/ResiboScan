import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'utils/constants.dart';
import 'models/receipt_model.dart';
import 'screens/home_screen.dart';
import 'screens/folders_screen.dart';
import 'screens/expenses_screen.dart';
import 'screens/alerts_screen.dart';
import 'screens/receipt_detail_screen.dart';
import 'widgets/bottom_nav.dart';
import 'widgets/scan_modal.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(statusBarColor: Colors.transparent),
  );
  runApp(const ResiboScanApp());
}

class ResiboScanApp extends StatelessWidget {
  const ResiboScanApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ResiboScan',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: cPrimary),
        scaffoldBackgroundColor: cBg,
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      home: const SplashScreen(),
    );
  }
}

// ── SPLASH SCREEN ─────────────────────────────────────────────────────────────
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  double _progress = 0;

  @override
  void initState() {
    super.initState();
    _startLoading();
  }

  void _startLoading() async {
    for (int i = 0; i <= 100; i += 4) {
      await Future.delayed(const Duration(milliseconds: 40));
      if (mounted) setState(() => _progress = i.toDouble());
    }
    await Future.delayed(const Duration(milliseconds: 300));
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MainApp()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: cPrimary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('🧾', style: TextStyle(fontSize: 64)),
            const SizedBox(height: 16),
            const Text('ResiboScan',
              style: TextStyle(
                fontFamily: 'Georgia',
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 1,
              )),
            const SizedBox(height: 8),
            Text('Receipt Scanner & Organizer',
              style: TextStyle(
                color: Colors.white.withOpacity(0.7), fontSize: 14)),
            const SizedBox(height: 32),
            SizedBox(
              width: 200,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: _progress / 100,
                  backgroundColor: Colors.white.withOpacity(0.2),
                  valueColor: const AlwaysStoppedAnimation<Color>(cAccent),
                  minHeight: 4,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text('${_progress.toInt()}%',
              style: TextStyle(
                color: Colors.white.withOpacity(0.5), fontSize: 12)),
          ],
        ),
      ),
    );
  }
}

// ── MAIN APP ──────────────────────────────────────────────────────────────────
class MainApp extends StatefulWidget {
  const MainApp({super.key});
  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  int _tab = 0;
  Receipt? _viewing;
  List<Receipt> _receipts = seedReceipts.map(Receipt.fromMap).toList();

  void _addReceipt(Receipt r) => setState(() => _receipts.insert(0, r));
  void _delReceipt(int id)    => setState(() => _receipts.removeWhere((r) => r.id == id));

  @override
  Widget build(BuildContext context) {
    final screens = [
      HomeScreen(
        receipts: _receipts,
        onView: (r) => setState(() => _viewing = r),
        onDelete: _delReceipt,
      ),
      FoldersScreen(
        receipts: _receipts,
        onView: (r) => setState(() => _viewing = r),
        onDelete: _delReceipt,
      ),
      ExpensesScreen(receipts: _receipts),
      AlertsScreen(receipts: _receipts),
    ];

    return Scaffold(
      backgroundColor: cBg,
      body: _viewing != null
          ? ReceiptDetailScreen(
              receipt: _viewing!,
              onBack: () => setState(() => _viewing = null),
              onDelete: (id) {
                _delReceipt(id);
                setState(() => _viewing = null);
              },
            )
          : screens[_tab],
      bottomNavigationBar: _viewing != null
          ? null
          : BottomNavBar(
              activeIndex: _tab,
              onTap: (i) => setState(() => _tab = i),
              onScan: () => showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (_) => ScanModal(onSave: _addReceipt),
              ),
            ),
    );
  }
}
