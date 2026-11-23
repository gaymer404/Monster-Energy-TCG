import 'package:material_ui/material_ui.dart';

import '../models/flavor.dart';
import '../models/tcg_card.dart';
import '../services/card_generator.dart';
import '../services/collection_db.dart';
import '../theme.dart';
import '../widgets/card_view.dart';

class CollectionScreen extends StatelessWidget {
  const CollectionScreen({
    super.key,
    required this.db,
    required this.generator,
    required this.themeController,
  });

  final CollectionDb db;
  final CardGenerator generator;
  final ThemeController themeController;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Collection'),
        actions: [ThemeToggleButton(controller: themeController)],
      ),
      body: FutureBuilder<List<OwnedCard>>(
        future: db.collection(),
        builder: (context, snap) {
          if (!snap.hasData) return const Center(child: CircularProgressIndicator());
          final owned = snap.data!;
          if (owned.isEmpty) {
            return _EmptyCollection(light: Theme.of(context).brightness == Brightness.light);
          }
          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 5 / 7,
            ),
            itemCount: owned.length,
            itemBuilder: (_, i) {
              final flavor = flavorById(owned[i].flavorId);
              if (flavor == null) return const SizedBox.shrink();
              final TcgCard card = generator.generate(flavor);
              return CardView(card: card, copies: owned[i].copies);
            },
          );
        },
      ),
    );
  }
}

class _EmptyCollection extends StatelessWidget {
  const _EmptyCollection({required this.light});

  final bool light;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (light)
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.asset(
                  'docs/banner-ultra-white.png',
                  cacheWidth: 900,
                  semanticLabel: 'A phone scanning a white can while a trading card appears',
                ),
              ),
            if (light) const SizedBox(height: 16),
            const Text('No cards yet. Scan a can to get started.'),
          ],
        ),
      ),
    );
  }
}
