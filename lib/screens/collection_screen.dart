import 'package:material_ui/material_ui.dart';

import '../models/flavor.dart';
import '../models/tcg_card.dart';
import '../services/card_generator.dart';
import '../services/collection_db.dart';
import '../widgets/card_view.dart';

class CollectionScreen extends StatelessWidget {
  const CollectionScreen({super.key, required this.db, required this.generator});

  final CollectionDb db;
  final CardGenerator generator;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Collection')),
      body: FutureBuilder<List<OwnedCard>>(
        future: db.collection(),
        builder: (context, snap) {
          if (!snap.hasData) return const Center(child: CircularProgressIndicator());
          final owned = snap.data!;
          if (owned.isEmpty) {
            return const Center(child: Text('No cards yet. Scan a can to get started.'));
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
