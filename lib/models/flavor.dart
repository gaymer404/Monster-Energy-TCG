enum Line { original, ultra, juice, rehab, java }

class Flavor {
  const Flavor({
    required this.id,
    required this.name,
    required this.line,
    required this.color,
    required this.caffeineMg,
    required this.sugarG,
    required this.calories,
  });

  final String id;
  final String name;
  final Line line;
  final int color; // ARGB
  final int caffeineMg; // per 16 fl oz can
  final int sugarG;
  final int calories;
}

/// Starter catalog with approximate 16 fl oz nutrition values. Barcodes are not
/// hard-coded; the user links them to a flavor on first scan.
const List<Flavor> flavorCatalog = [
  Flavor(id: 'original', name: 'Monster Energy', line: Line.original, color: 0xFF7ED321, caffeineMg: 160, sugarG: 54, calories: 210),
  Flavor(id: 'ultra-zero', name: 'Ultra Zero', line: Line.ultra, color: 0xFFE8E8E8, caffeineMg: 150, sugarG: 0, calories: 10),
  Flavor(id: 'ultra-paradise', name: 'Ultra Paradise', line: Line.ultra, color: 0xFF2ED1B5, caffeineMg: 150, sugarG: 0, calories: 10),
  Flavor(id: 'ultra-violet', name: 'Ultra Violet', line: Line.ultra, color: 0xFF8E5CC9, caffeineMg: 150, sugarG: 0, calories: 10),
  Flavor(id: 'ultra-red', name: 'Ultra Red', line: Line.ultra, color: 0xFFD9262C, caffeineMg: 150, sugarG: 0, calories: 10),
  Flavor(id: 'mango-loco', name: 'Mango Loco', line: Line.juice, color: 0xFFF5A623, caffeineMg: 160, sugarG: 54, calories: 220),
  Flavor(id: 'pipeline-punch', name: 'Pipeline Punch', line: Line.juice, color: 0xFFFF6F91, caffeineMg: 160, sugarG: 54, calories: 220),
  Flavor(id: 'khaotic', name: 'Khaotic', line: Line.juice, color: 0xFFFF8C1A, caffeineMg: 160, sugarG: 54, calories: 220),
  Flavor(id: 'rehab-peach', name: 'Rehab Peach Tea', line: Line.rehab, color: 0xFFFFB07A, caffeineMg: 160, sugarG: 20, calories: 80),
  Flavor(id: 'java-mean-bean', name: 'Java Mean Bean', line: Line.java, color: 0xFF6B4226, caffeineMg: 188, sugarG: 31, calories: 200),
];

Flavor? flavorById(String id) {
  for (final f in flavorCatalog) {
    if (f.id == id) return f;
  }
  return null;
}
