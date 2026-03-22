import 'package:flutter/material.dart';
import '../main.dart' show MainApp;
import '../screens/receipt_detail_screen.dart';
import '../models/receipt_model.dart';

// ── ROUTE CONSTANTS — Milestone 1 ──────────────────────────────────────────
class AppRoutes {
  AppRoutes._();

  // Dito nakadefine yung unique paths ng bawat screen
  static const String main          = '/main';
  static const String receiptDetail = '/receipt-detail';
}

// ── ARGUMENT MODELS — Milestone 2 ──────────────────────────────────────────
class ReceiptDetailArgs {
  final Receipt       receipt;
  final VoidCallback  onBack;
  final ValueChanged<int> onDelete;
  final ValueChanged<Receipt>? onEdit;

  const ReceiptDetailArgs({
    required this.receipt,
    required this.onBack,
    required this.onDelete,
    this.onEdit,
  });
}

// ── ROUTE FACTORY — Milestone 3 ────────────────────────────────────────────
Route<dynamic> generateRoute(RouteSettings settings) {
  switch (settings.name) {

    // Main Shell ng app (Home, Folders, etc.)
    case AppRoutes.main:
      return _fadeRoute(const MainApp(), settings);

    // Kapag pinindot yung specific receipt, ito yung lalabas
    case AppRoutes.receiptDetail:
      final args = settings.arguments as ReceiptDetailArgs;
      return _slideRoute(
        ReceiptDetailScreen(
          receipt: args.receipt,
          onBack: args.onBack,
          onDelete: args.onDelete,
          onEdit: args.onEdit,
        ),
        settings,
      );

    default:
      return MaterialPageRoute(builder: (_) => const _NotFoundScreen());
  }
}

// ── TRANSITION HELPERS ──────────────────────────────────────────────────────

// Fade effect para sa main navigation transitions
PageRouteBuilder<dynamic> _fadeRoute(Widget page, RouteSettings settings) =>
    PageRouteBuilder(
      settings: settings,
      pageBuilder: (_, __, ___) => page,
      transitionsBuilder: (_, anim, __, child) =>
          FadeTransition(opacity: anim, child: child),
      transitionDuration: const Duration(milliseconds: 250),
    );

// Slide effect na galing sa gilid (parang native iOS feel)
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

// Fallback screen kapag may maling route name na tinawag
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
