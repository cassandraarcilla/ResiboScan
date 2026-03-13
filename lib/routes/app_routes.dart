import 'package:flutter/material.dart';
import '../main.dart' show MainApp;
import '../screens/receipt_detail_screen.dart';
import '../models/receipt_model.dart';

// ─────────────────────────────────────────────────────────────────────────────
// ROUTE CONSTANTS
// ─────────────────────────────────────────────────────────────────────────────
class AppRoutes {
  AppRoutes._();

  /// Main app shell (tabs + bottom nav)
  static const String main          = '/main';

  /// Receipt detail – pushed on top of the shell
  static const String receiptDetail = '/receipt-detail';
}

// ─────────────────────────────────────────────────────────────────────────────
// ARGUMENT MODELS
// ─────────────────────────────────────────────────────────────────────────────

class ReceiptDetailArgs {
  final Receipt       receipt;
  final VoidCallback  onBack;
  final ValueChanged<int> onDelete;

  const ReceiptDetailArgs({
    required this.receipt,
    required this.onBack,
    required this.onDelete,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// ROUTE FACTORY  (used by MaterialApp.onGenerateRoute)
// ─────────────────────────────────────────────────────────────────────────────
Route<dynamic> generateRoute(RouteSettings settings) {
  switch (settings.name) {

    // ── Main shell ──────────────────────────────────────────────────────────
    case AppRoutes.main:
      return _fadeRoute(const MainApp(), settings);

    // ── Receipt detail (slides in from the right) ────────────────────────
    case AppRoutes.receiptDetail: {
      final args = settings.arguments as ReceiptDetailArgs;
      return _slideRoute(
        ReceiptDetailScreen(
          receipt:  args.receipt,
          onBack:   args.onBack,
          onDelete: args.onDelete,
        ),
        settings,
      );
    }

    // ── 404 fallback ────────────────────────────────────────────────────────
    default:
      return _fadeRoute(const _NotFoundScreen(), settings);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// TRANSITION HELPERS
// ─────────────────────────────────────────────────────────────────────────────

PageRouteBuilder<dynamic> _fadeRoute(Widget page, RouteSettings settings) =>
    PageRouteBuilder(
      settings: settings,
      pageBuilder: (_, __, ___) => page,
      transitionsBuilder: (_, anim, __, child) =>
          FadeTransition(opacity: anim, child: child),
      transitionDuration: const Duration(milliseconds: 250),
    );

PageRouteBuilder<dynamic> _slideRoute(Widget page, RouteSettings settings) =>
    PageRouteBuilder(
      settings: settings,
      pageBuilder: (_, __, ___) => page,
      transitionsBuilder: (_, anim, __, child) => SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(1, 0),
          end: Offset.zero,
        ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOutCubic)),
        child: child,
      ),
      transitionDuration: const Duration(milliseconds: 320),
    );

// ─────────────────────────────────────────────────────────────────────────────
// 404 SCREEN
// ─────────────────────────────────────────────────────────────────────────────
class _NotFoundScreen extends StatelessWidget {
  const _NotFoundScreen();

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Center(
          child: Text(
            'Route not found',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
      );
}
