import 'package:material_ui/material_ui.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../models/flavor.dart';
import '../services/card_generator.dart';
import '../services/collection_db.dart';
import '../theme.dart';
import '../widgets/card_view.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({
    super.key,
    required this.db,
    required this.generator,
    required this.themeController,
  });

  final CollectionDb db;
  final CardGenerator generator;
  final ThemeController themeController;

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  final _controller = MobileScannerController(
    formats: const [BarcodeFormat.upcA, BarcodeFormat.upcE, BarcodeFormat.ean13, BarcodeFormat.ean8],
    detectionSpeed: DetectionSpeed.noDuplicates,
  );
  bool _busy = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _onDetect(BarcodeCapture capture) async {
    if (_busy) return;
    final code = capture.barcodes.map((b) => b.rawValue).whereType<String>().firstOrNull;
    if (code == null) return;
    _busy = true;
    try {
      var flavorId = await widget.db.flavorForBarcode(code);
      if (flavorId == null) {
        if (!mounted) return;
        final picked = await _pickFlavor(code);
        if (picked == null) return;
        await widget.db.linkBarcode(code, picked.id);
        flavorId = picked.id;
      }
      final flavor = flavorById(flavorId);
      if (flavor == null) return;
      final copies = await widget.db.addCard(flavorId);
      if (!mounted) return;
      await _showReveal(flavor, copies);
    } finally {
      _busy = false;
    }
  }

  Future<Flavor?> _pickFlavor(String code) {
    return showModalBottomSheet<Flavor>(
      context: context,
      showDragHandle: true,
      builder: (ctx) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Text('New barcode $code\nWhich flavor is this?',
                  style: Theme.of(ctx).textTheme.titleMedium),
            ),
            for (final f in flavorCatalog)
              ListTile(
                leading: CircleAvatar(backgroundColor: Color(f.color), radius: 10),
                title: Text(f.name),
                onTap: () => Navigator.pop(ctx, f),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _showReveal(Flavor flavor, int copies) {
    final card = widget.generator.generate(flavor);
    return showDialog<void>(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(copies == 1 ? 'New card!' : 'Duplicate (x$copies)',
                style: Theme.of(ctx).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 12),
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 1),
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeOutBack,
              builder: (_, t, child) => Transform.scale(scale: t, child: child),
              child: SizedBox(width: 260, child: CardView(card: card, copies: copies)),
            ),
            const SizedBox(height: 12),
            FilledButton(onPressed: () => Navigator.pop(ctx), child: const Text('Keep scanning')),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan a can'),
        actions: [ThemeToggleButton(controller: widget.themeController)],
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          MobileScanner(
            controller: _controller,
            onDetect: _onDetect,
            errorBuilder: (context, error, child) => Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  error.errorCode == MobileScannerErrorCode.permissionDenied
                      ? 'Camera access is needed to scan cans. Enable it for Monster TCG in your phone settings.'
                      : 'The camera is not available right now.',
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
          Center(
            child: Container(
              width: 280,
              height: 160,
              decoration: BoxDecoration(
                border: Border.all(color: Theme.of(context).colorScheme.primary, width: 3),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const Align(
            alignment: Alignment(0, .7),
            child: Text('Point the camera at the barcode on the can'),
          ),
        ],
      ),
    );
  }
}
