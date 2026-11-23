import 'package:flutter_test/flutter_test.dart';
import 'package:monster_tcg/models/flavor.dart';
import 'package:monster_tcg/models/tcg_card.dart';
import 'package:monster_tcg/services/card_generator.dart';

void main() {
  final gen = CardGenerator();

  test('same flavor always yields the same card', () {
    for (final f in flavorCatalog) {
      final a = gen.generate(f);
      final b = gen.generate(f);
      expect([a.attack, a.defense, a.speed, a.energyCost, a.abilityName, a.serial],
          [b.attack, b.defense, b.speed, b.energyCost, b.abilityName, b.serial]);
    }
  });

  test('stats stay within bounds and rarity follows product line', () {
    for (final f in flavorCatalog) {
      final c = gen.generate(f);
      for (final s in [c.attack, c.defense, c.speed]) {
        expect(s, inInclusiveRange(10, 99));
      }
      expect(c.energyCost, inInclusiveRange(1, 5));
      expect(c.rarity, CardGenerator.baseRarity(f.line));
    }
    expect(gen.generate(flavorById('java-mean-bean')!).rarity, Rarity.legendary);
  });

  test('catalog ids are unique', () {
    expect(flavorCatalog.map((f) => f.id).toSet().length, flavorCatalog.length);
  });
}
