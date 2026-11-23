import 'flavor.dart';

enum Rarity { common, uncommon, rare, epic, legendary }

class TcgCard {
  const TcgCard({
    required this.flavor,
    required this.rarity,
    required this.attack,
    required this.defense,
    required this.speed,
    required this.energyCost,
    required this.abilityName,
    required this.abilityText,
    required this.serial,
  });

  final Flavor flavor;
  final Rarity rarity;
  final int attack;
  final int defense;
  final int speed;
  final int energyCost;
  final String abilityName;
  final String abilityText;
  final String serial;
}
