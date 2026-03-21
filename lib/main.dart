import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'models/exchange_rate_model.dart';
import 'services/api_service.dart';
import 'utils/constants.dart';
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
        splashColor: _cerulean.withOpacity(0.08),
        highlightColor: _cerulean.withOpacity(0.04),
      ),
      home: const SplashScreen(),
      onGenerateRoute: generateRoute,
    );
  }
}

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

  late final Animation<double> _fadeAnim;
  late final Animation<double> _scaleAnim;
  late final Animation<double> _floatAnim;

  @override
  void initState() {
    super.initState();

    _fadeCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900));
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);

    _scaleCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800));
    _scaleAnim = Tween<double>(begin: 0.7, end: 1.0).animate(
        CurvedAnimation(parent: _scaleCtrl, curve: Curves.elasticOut));

    _floatCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 2200))
      ..repeat(reverse: true);
    _floatAnim = Tween<double>(begin: -6, end: 6).animate(
        CurvedAnimation(parent: _floatCtrl, curve: Curves.easeInOut));

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
    await Future.delayed(const Duration(milliseconds: 400));
    if (mounted) {
      Navigator.pushReplacementNamed(context, AppRoutes.main);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            stops: [0.0, 0.45, 1.0],
            colors: [Color(0xFF0F3547), _cerulean, _cyan],
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: -size.width * 0.3,
              right: -size.width * 0.2,
              child: Container(
                width: size.width * 0.75,
                height: size.width * 0.75,
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.045)),
              ),
            ),
            Positioned(
              bottom: -size.width * 0.25,
              left: -size.width * 0.15,
              child: Container(
                width: size.width * 0.65,
                height: size.width * 0.65,
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _vanilla.withOpacity(0.06)),
              ),
            ),
            FadeTransition(
              opacity: _fadeAnim,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AnimatedBuilder(
                      animation: _floatAnim,
                      builder: (_, child) => Transform.translate(
                          offset: Offset(0, _floatAnim.value), child: child),
                      child: ScaleTransition(
                        scale: _scaleAnim,
                        child: Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.13),
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(
                                color: Colors.white.withOpacity(0.22),
                                width: 1.5),
                            boxShadow: [
                              BoxShadow(
                                  color: _cerulean.withOpacity(0.4),
                                  blurRadius: 40,
                                  offset: const Offset(0, 16)),
                            ],
                          ),
                          alignment: Alignment.center,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(26),
                            child: Image.asset(
                              'assets/images/logo.png',
                              width: 64,
                              height: 64,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),
                    ScaleTransition(
                      scale: _scaleAnim,
                      child: RichText(
                        text: const TextSpan(
                          style: TextStyle(
                              fontFamily: 'Georgia',
                              fontSize: 36,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -0.5,
                              height: 1.0),
                          children: [
                            TextSpan(
                                text: 'Resibo',
                                style: TextStyle(color: _white)),
                            TextSpan(
                                text: 'Scan',
                                style: TextStyle(color: _vanilla)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Receipt Scanner & Organizer',
                      style: TextStyle(
                          color: _vanilla.withOpacity(0.60),
                          fontSize: 13.5,
                          fontWeight: FontWeight.w400,
                          letterSpacing: 0.3),
                    ),
                    const SizedBox(height: 52),
                    SizedBox(
                      width: 220,
                      child: Column(children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: LinearProgressIndicator(
                            value: _progress / 100,
                            backgroundColor: Colors.white.withOpacity(0.12),
                            valueColor:
                                const AlwaysStoppedAnimation<Color>(_sandy),
                            minHeight: 5,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(_progressLabel(_progress),
                                style: TextStyle(
                                    color: _vanilla.withOpacity(0.50),
                                    fontSize: 11,
                                    letterSpacing: 0.2)),
                            Text('${_progress.toInt()}%',
                                style: TextStyle(
                                    color: _vanilla.withOpacity(0.55),
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ]),
                    ),
                    const SizedBox(height: 60),
                    Text(
                      'by ResiboScan Team',
                      style: TextStyle(
                          color: Colors.white.withOpacity(0.22),
                          fontSize: 11,
                          letterSpacing: 0.5),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _progressLabel(double p) {
    if (p < 30) return 'Starting up...';
    if (p < 60) return 'Loading data...';
    if (p < 90) return 'Almost ready...';
    return 'Ready!';
  }
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});
  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> with SingleTickerProviderStateMixin {
  int _tab = 0;
  List<Receipt> _receipts = [];
  bool _receiptsLoading = true;

  ExchangeRate? _exchangeRate;
  bool _rateLoading = true;
  String? _rateError;

  late final AnimationController _tabFadeCtrl;
  late final Animation<double> _tabFadeAnim;

  @override
  void initState() {
    super.initState();
    _tabFadeCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 250))
      ..value = 1.0;
    _tabFadeAnim =
        CurvedAnimation(parent: _tabFadeCtrl, curve: Curves.easeOut);

    _loadReceipts();
    _loadExchangeRates();
  }

  Future<void> _loadReceipts() async {
    setState(() => _receiptsLoading = true);
    try {
      final receipts = await DatabaseService.instance.getAllReceipts();
      if (mounted) {
        setState(() => _receipts = receipts);
      }
    } catch (e) {
      // SQLite unavailable (e.g. Flutter Web) — fall back to seed data
      if (mounted) {
        try {
          final imgBytes = await loadReceiptSvgBytes();
          setState(() {
            _receipts = buildSeedReceipts(imgBytes).map(Receipt.fromMap).toList();
          });
        } catch (_) {
          setState(() {
            _receipts = buildSeedReceipts(Uint8List(0)).map(Receipt.fromMap).toList();
          });
        }
      }
    } finally {
      if (mounted) setState(() => _receiptsLoading = false);
    }
  }

  Future<void> _loadExchangeRates() async {
    setState(() {
      _rateLoading = true;
      _rateError = null;
    });
    try {
      final rate = await ApiService.fetchExchangeRates();
      if (mounted) {
        setState(() {
          _exchangeRate = rate;
          _rateLoading = false;
        });
      }
    } on ApiException catch (e) {
      if (mounted) {
        setState(() {
          _rateError = e.message;
          _rateLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _rateError = e.toString();
          _rateLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _tabFadeCtrl.dispose();
    super.dispose();
  }

  void _toggleErrorSimulation() {
    setState(() {
      ApiService.simulateError = !ApiService.simulateError;
      ApiService.simulateNoNet = false; // turn off the other one
    });
    _loadExchangeRates();
  }

  void _toggleNoNetSimulation() {
    setState(() {
      ApiService.simulateNoNet = !ApiService.simulateNoNet;
      ApiService.simulateError = false; // turn off the other one
    });
    _loadExchangeRates();
  }

  Future<void> _delReceipt(int id) async {
    await DatabaseService.instance.deleteReceipt(id);
    setState(() => _receipts.removeWhere((r) => r.id == id));
  }

  void _switchTab(int i) async {
    if (i == _tab) return;
    await _tabFadeCtrl.reverse();
    setState(() => _tab = i);
    _tabFadeCtrl.forward();
  }

  Future<void> _addReceipt(Receipt r) async {
    await DatabaseService.instance.insertReceipt(r);
    setState(() => _receipts.insert(0, r));
  }

  Future<void> _editReceipt(Receipt updated) async {
    await DatabaseService.instance.updateReceipt(updated);
    setState(() {
      final idx = _receipts.indexWhere((r) => r.id == updated.id);
      if (idx != -1) _receipts[idx] = updated;
    });
  }

  void _viewReceipt(Receipt r) {
    Navigator.pushNamed(
      context,
      AppRoutes.receiptDetail,
      arguments: ReceiptDetailArgs(
        receipt:  r,
        onBack:   () => Navigator.pop(context),
        onDelete: (id) {
          _delReceipt(id);
          Navigator.pop(context);
        },
        onEdit: (receipt) {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            useRootNavigator: true,
            builder: (_) => ScanModal(
              existing: receipt,
              onSave: (updated) {
                _editReceipt(updated);
                // Pop the detail screen so user sees updated receipt in list
                Navigator.pop(context);
              },
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));

    if (_receiptsLoading) {
      return Scaffold(
        backgroundColor: _cream,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/logo.png',
                width: 72,
                height: 72,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 28),
              const CircularProgressIndicator(
                color: _cerulean,
                strokeWidth: 3,
              ),
              const SizedBox(height: 20),
              Text(
                'Loading your receipts...',
                style: TextStyle(
                  color: _cerulean.withOpacity(0.75),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final screens = [
      HomeScreen(
          receipts: _receipts,
          onView: _viewReceipt,
          onDelete: _delReceipt,
          exchangeRate: _exchangeRate,
          rateLoading: _rateLoading,
          rateError: _rateError,
          onRefreshRate: _loadExchangeRates,
          simulateError: ApiService.simulateError,
          onToggleError: _toggleErrorSimulation,
          simulateNoNet: ApiService.simulateNoNet,
          onToggleNoNet: _toggleNoNetSimulation),
      FoldersScreen(
          receipts: _receipts, onView: _viewReceipt, onDelete: _delReceipt),
      ExpensesScreen(receipts: _receipts),
      AlertsScreen(receipts: _receipts),
    ];

    return Scaffold(
      backgroundColor: _cream,
      body: FadeTransition(
        opacity: _tabFadeAnim,
        child: screens[_tab],
      ),
      bottomNavigationBar: BottomNavBar(
        activeIndex: _tab,
        onTap: _switchTab,
        onScan: () => showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          useRootNavigator: true,
          builder: (_) => ScanModal(onSave: _addReceipt),
        ),
      ),
    );
  }
}