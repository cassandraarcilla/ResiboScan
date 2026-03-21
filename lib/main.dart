import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'models/exchange_rate_model.dart';
import 'services/api_service.dart';
import 'models/receipt_model.dart';
import 'routes/app_routes.dart';
import 'screens/home_screen.dart';
import 'screens/folders_screen.dart';
import 'screens/expenses_screen.dart';
import 'screens/alerts_screen.dart';
import 'widgets/bottom_nav.dart';
import 'widgets/scan_modal.dart';
import 'services/database_service.dart';

const _cerulean = Color(0xFF2D728F);
const _cyan     = Color(0xFF3B8EA5);
const _vanilla  = Color(0xFFF5EE9E);
const _sandy    = Color(0xFFF49E4C);
const _cream    = Color(0xFFFDF8EC);
const _white    = Color(0xFFFFFFFF);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: _white,
    systemNavigationBarIconBrightness: Brightness.dark,
  ));
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
        colorScheme: ColorScheme.fromSeed(seedColor: _cerulean),
        scaffoldBackgroundColor: _cream,
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      home: const SplashScreen(),
      onGenerateRoute: generateRoute,
    );
  }
}

// ── Splash ────────────────────────────────────────────────────────────────────
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  double _progress = 0;

  late final AnimationController _fadeCtrl;
  late final AnimationController _scaleCtrl;
  late final AnimationController _floatCtrl;
  late final Animation<double>   _fadeAnim;
  late final Animation<double>   _scaleAnim;
  late final Animation<double>   _floatAnim;

  @override
  void initState() {
    super.initState();
    _fadeCtrl  = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));
    _fadeAnim  = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _scaleCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _scaleAnim = Tween<double>(begin: 0.7, end: 1.0)
        .animate(CurvedAnimation(parent: _scaleCtrl, curve: Curves.elasticOut));
    _floatCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 2200))
      ..repeat(reverse: true);
    _floatAnim = Tween<double>(begin: -6, end: 6)
        .animate(CurvedAnimation(parent: _floatCtrl, curve: Curves.easeInOut));

    _fadeCtrl.forward();
    _scaleCtrl.forward();
    _startLoading();
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    _scaleCtrl.dispose();
    _floatCtrl.dispose();
    super.dispose();
  }

  void _startLoading() async {
    for (int i = 0; i <= 100; i += 3) {
      await Future.delayed(const Duration(milliseconds: 38));
      if (mounted) setState(() => _progress = i.toDouble());
    }
    await Future.delayed(const Duration(milliseconds: 300));
    if (mounted) Navigator.pushReplacementNamed(context, AppRoutes.main);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: Container(
        width: double.infinity, height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft, end: Alignment.bottomRight,
            stops: [0.0, 0.45, 1.0],
            colors: [Color(0xFF0F3547), _cerulean, _cyan])),
        child: Stack(children: [
          Positioned(top: -size.width * 0.3, right: -size.width * 0.2,
            child: Container(width: size.width * 0.75, height: size.width * 0.75,
              decoration: BoxDecoration(shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.045)))),
          Positioned(bottom: -size.width * 0.25, left: -size.width * 0.15,
            child: Container(width: size.width * 0.65, height: size.width * 0.65,
              decoration: BoxDecoration(shape: BoxShape.circle,
                color: _vanilla.withOpacity(0.06)))),
          FadeTransition(
            opacity: _fadeAnim,
            child: Center(
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                AnimatedBuilder(
                  animation: _floatAnim,
                  builder: (_, child) => Transform.translate(
                    offset: Offset(0, _floatAnim.value), child: child),
                  child: ScaleTransition(
                    scale: _scaleAnim,
                    child: Container(
                      width: 100, height: 100,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.13),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(color: Colors.white.withOpacity(0.22), width: 1.5),
                        boxShadow: [BoxShadow(
                          color: _cerulean.withOpacity(0.4), blurRadius: 40, offset: const Offset(0, 16))]),
                      alignment: Alignment.center,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(26),
                        child: Image.asset('assets/images/logo.png', width: 64, height: 64, fit: BoxFit.contain)),
                    ),
                  ),
                ),
                const SizedBox(height: 28),
                ScaleTransition(
                  scale: _scaleAnim,
                  child: RichText(
                    text: const TextSpan(
                      style: TextStyle(fontFamily: 'Georgia', fontSize: 36,
                        fontWeight: FontWeight.w900, letterSpacing: -0.5, height: 1.0),
                      children: [
                        TextSpan(text: 'Resibo', style: TextStyle(color: _white)),
                        TextSpan(text: 'Scan',   style: TextStyle(color: _vanilla)),
                      ]),
                  ),
                ),
                const SizedBox(height: 8),
                Text('Receipt Scanner & Organizer',
                  style: TextStyle(color: _vanilla.withOpacity(0.60),
                    fontSize: 13.5, fontWeight: FontWeight.w400, letterSpacing: 0.3)),
                const SizedBox(height: 52),
                SizedBox(
                  width: 220,
                  child: Column(children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: _progress / 100,
                        backgroundColor: Colors.white.withOpacity(0.12),
                        valueColor: const AlwaysStoppedAnimation<Color>(_sandy),
                        minHeight: 5)),
                    const SizedBox(height: 10),
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      Text(_label(_progress), style: TextStyle(
                        color: _vanilla.withOpacity(0.50), fontSize: 11, letterSpacing: 0.2)),
                      Text('${_progress.toInt()}%', style: TextStyle(
                        color: _vanilla.withOpacity(0.55), fontSize: 11, fontWeight: FontWeight.w600)),
                    ]),
                  ]),
                ),
                const SizedBox(height: 60),
                Text('by ResiboScan Team',
                  style: TextStyle(color: Colors.white.withOpacity(0.22), fontSize: 11, letterSpacing: 0.5)),
              ]),
            ),
          ),
        ]),
      ),
    );
  }

  String _label(double p) {
    if (p < 30) return 'Starting up...';
    if (p < 60) return 'Loading data...';
    if (p < 90) return 'Almost ready...';
    return 'Ready!';
  }
}

// ── Main App Shell ────────────────────────────────────────────────────────────
class MainApp extends StatefulWidget {
  const MainApp({super.key});
  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> with SingleTickerProviderStateMixin {
  int _tab = 0;
  List<Receipt> _receipts = [];
  bool _loading = true;

  ExchangeRate? _exchangeRate;
  bool _rateLoading = true;
  String? _rateError;

  late final AnimationController _fadeCtrl;
  late final Animation<double>   _fadeAnim;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 250))
      ..value = 1.0;
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _loadReceipts();
    _loadRates();
  }

  @override
  void dispose() { _fadeCtrl.dispose(); super.dispose(); }

  // ── Data loading ──────────────────────────────────────────────────────────

  Future<void> _loadReceipts() async {
    if (mounted) setState(() => _loading = true);
    try {
      final list = await DatabaseService.instance.getAllReceipts();
      if (mounted) setState(() { _receipts = list; _loading = false; });
    } catch (e) {
      if (mounted) setState(() { _receipts = []; _loading = false; });
    }
  }

  Future<void> _loadRates() async {
    if (mounted) setState(() { _rateLoading = true; _rateError = null; });
    try {
      final rate = await ApiService.fetchExchangeRates();
      if (mounted) setState(() { _exchangeRate = rate; _rateLoading = false; });
    } on ApiException catch (e) {
      if (mounted) setState(() { _rateError = e.message; _rateLoading = false; });
    } catch (e) {
      if (mounted) setState(() { _rateError = e.toString(); _rateLoading = false; });
    }
  }

  // ── CRUD ──────────────────────────────────────────────────────────────────

  Future<void> _addReceipt(Receipt r) async {
    await DatabaseService.instance.insertReceipt(r);
    if (mounted) setState(() => _receipts.insert(0, r));
  }

  Future<void> _editReceipt(Receipt updated) async {
    await DatabaseService.instance.updateReceipt(updated);
    if (mounted) setState(() {
      final idx = _receipts.indexWhere((r) => r.id == updated.id);
      if (idx != -1) _receipts[idx] = updated;
    });
  }

  Future<void> _deleteReceipt(int id) async {
    await DatabaseService.instance.deleteReceipt(id);
    if (mounted) setState(() => _receipts.removeWhere((r) => r.id == id));
  }

  // ── Navigation ────────────────────────────────────────────────────────────

  void _switchTab(int i) async {
    if (i == _tab) return;
    await _fadeCtrl.reverse();
    if (mounted) setState(() => _tab = i);
    _fadeCtrl.forward();
  }

  void _openScanModal({Receipt? existing}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      useRootNavigator: true,
      builder: (_) => Padding(
        padding: MediaQuery.of(context).viewInsets,
        child: ScanModal(
          existing: existing,
          onSave: (r) {
            if (existing != null) {
              _editReceipt(r);
            } else {
              _addReceipt(r);
            }
          },
        ),
      ),
    );
  }

  void _viewReceipt(Receipt r) {
    Navigator.pushNamed(
      context,
      AppRoutes.receiptDetail,
      arguments: ReceiptDetailArgs(
        receipt : r,
        onBack  : () => Navigator.pop(context),
        onDelete: (id) {
          _deleteReceipt(id);
          Navigator.pop(context);
        },
        onEdit: (receipt) {
          // Close detail, open edit modal
          Navigator.pop(context);
          _openScanModal(existing: receipt);
        },
      ),
    );
  }

  // ── Simulation toggles ────────────────────────────────────────────────────

  void _toggleError() {
    setState(() {
      ApiService.simulateError = !ApiService.simulateError;
      ApiService.simulateNoNet = false;
    });
    _loadRates();
  }

  void _toggleNoNet() {
    setState(() {
      ApiService.simulateNoNet = !ApiService.simulateNoNet;
      ApiService.simulateError = false;
    });
    _loadRates();
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));

    if (_loading) {
      return Scaffold(
        backgroundColor: _cream,
        body: Center(
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Image.asset('assets/images/logo.png', width: 72, height: 72),
            const SizedBox(height: 28),
            const CircularProgressIndicator(color: _cerulean, strokeWidth: 3),
            const SizedBox(height: 20),
            Text('Loading your receipts...',
              style: TextStyle(color: _cerulean.withOpacity(0.75),
                fontSize: 14, fontWeight: FontWeight.w500)),
          ]),
        ),
      );
    }

    final screens = [
      HomeScreen(
        receipts      : _receipts,
        onView        : _viewReceipt,
        onDelete      : _deleteReceipt,
        exchangeRate  : _exchangeRate,
        rateLoading   : _rateLoading,
        rateError     : _rateError,
        onRefreshRate : _loadRates,
        simulateError : ApiService.simulateError,
        onToggleError : _toggleError,
        simulateNoNet : ApiService.simulateNoNet,
        onToggleNoNet : _toggleNoNet,
      ),
      FoldersScreen(receipts: _receipts, onView: _viewReceipt, onDelete: _deleteReceipt),
      ExpensesScreen(receipts: _receipts),
      AlertsScreen(receipts: _receipts),
    ];

    return Scaffold(
      backgroundColor: _cream,
      body: FadeTransition(opacity: _fadeAnim, child: screens[_tab]),
      bottomNavigationBar: BottomNavBar(
        activeIndex: _tab,
        onTap      : _switchTab,
        onScan     : () => _openScanModal(),
      ),
    );
  }
}
