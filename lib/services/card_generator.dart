import 'dart:math';

import '../models/flavor.dart';
import '../models/tcg_card.dart';

/// Deterministic card generation: the same flavor always yields the same card,
/// so only the flavor id and copy count need to be persisted.
class CardGenerator {
  static const _abilities = <Line, List<(String, String)>>{
    Line.original: [
      ('Claw Slash', 'Deal damage equal to ATK. Gain +1 SPD this turn.'),
      ('Green Surge', 'Draw a card. Your next attack deals +10.'),
    ],
    Line.ultra: [
      ('Zero Chill', 'Ignore the first 10 damage you take each turn.'),
      ('Crisp Burst', 'Deal ATK damage; it cannot be blocked by DEF below 40.'),
    ],
    Line.juice: [
      ('Fruit Frenzy', 'Heal 20 and deal 10 to the opponent.'),
      ('Loco Mix', 'Copy the ability of your last played card.'),
    ],
    Line.rehab: [
      ('Smooth Recovery', 'Restore 30 HP and remove one negative effect.'),
    ],
    Line.java: [
      ('Mean Bean Jolt', 'Skip your draw; deal double ATK next turn.'),
    ],
  };

  static Rarity baseRarity(Line line) => switch (line) {
        Line.rehab => Rarity.common,
        Line.ultra => Rarity.uncommon,
        Line.original => Rarity.rare,
        Line.juice => Rarity.epic,
        Line.java => Rarity.legendary,
      };

  TcgCard generate(Flavor f) {
    final rng = Random(fnv1a(f.id));
    final rarity = baseRarity(f.line);
    final tier = rarity.index;

    int stat(int base) => (base + tier * 5 + rng.nextInt(10)).clamp(10, 99);

    final attack = stat(20 + f.caffeineMg ~/ 4);
    final defense = stat(f.sugarG == 0 ? 55 : 55 - f.sugarG ~/ 3);
    final speed = stat(30 + f.caffeineMg ~/ 8);
    final cost = (1 + f.calories ~/ 60).clamp(1, 5);

    final options = _abilities[f.line]!;
    final ability = options[rng.nextInt(options.length)];
    final serial = (fnv1a('${f.id}#serial') % 10000).toString().padLeft(4, '0');

    return TcgCard(
      flavor: f,
      rarity: rarity,
      attack: attack,
      defense: defense,
      speed: speed,
      energyCost: cost,
      abilityName: ability.$1,
      abilityText: ability.$2,
      serial: serial,
    );
  }

  // String.hashCode is not guaranteed stable across runs/platforms.
  static int fnv1a(String s) {
    var h = 0x811c9dc5;
    for (final c in s.codeUnits) {
      h ^= c;
      h = (h * 0x01000193) & 0xFFFFFFFF;
    }
    return h;
  }
}
