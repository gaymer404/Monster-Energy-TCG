import 'package:material_ui/material_ui.dart';

import '../models/tcg_card.dart';

const _rarityLabels = {
  Rarity.common: 'Common',
  Rarity.uncommon: 'Uncommon',
  Rarity.rare: 'Rare',
  Rarity.epic: 'Epic',
  Rarity.legendary: 'Legendary',
};

Color _legible(Color c) {
  final hsl = HSLColor.fromColor(c);
  return hsl.withLightness(hsl.lightness.clamp(0.0, 0.4)).toColor();
}

class CardView extends StatelessWidget {
  const CardView({super.key, required this.card, this.copies = 1});

  final TcgCard card;
  final int copies;

  @override
  Widget build(BuildContext context) {
    final light = Theme.of(context).brightness == Brightness.light;
    final accent = Color(card.flavor.color);
    // Pale accents (e.g. Ultra Zero) vanish on white, so darken them for text.
    final textAccent = light ? _legible(accent) : accent;
    final edge = light ? const Color(0xFFD5DAE0) : const Color(0xFF0B0D0B);
    final faceColor = light ? const Color(0xFFFAFBFC) : const Color(0xFF0E120E);
    return AspectRatio(
      aspectRatio: 5 / 7,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [accent, edge],
          ),
          boxShadow: [BoxShadow(color: accent.withValues(alpha: .35), blurRadius: 18)],
        ),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: faceColor,
            borderRadius: BorderRadius.circular(9),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      card.flavor.name.toUpperCase(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: light ? 'BarlowCondensed' : null,
                        fontSize: light ? 16 : null,
                        fontWeight: FontWeight.w800,
                        letterSpacing: .5,
                      ),
                    ),
                  ),
                  CircleAvatar(
                    radius: 13,
                    backgroundColor: accent,
                    child: Text('${card.energyCost}',
                        style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w800)),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: CustomPaint(
                    painter: _ClawPainter(textAccent, light: light),
                    child: const SizedBox.expand(),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _rarityLabels[card.rarity]!.toUpperCase(),
                style: TextStyle(color: textAccent, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1.2),
              ),
              const SizedBox(height: 4),
              Text.rich(
                TextSpan(children: [
                  TextSpan(text: '${card.abilityName}. ', style: const TextStyle(fontWeight: FontWeight.w700)),
                  TextSpan(text: card.abilityText, style: TextStyle(color: light ? Colors.black54 : Colors.white70)),
                ]),
                style: const TextStyle(fontSize: 11),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              const Divider(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _stat('ATK', card.attack),
                  _stat('DEF', card.defense),
                  _stat('SPD', card.speed),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('#${card.serial}', style: TextStyle(fontSize: 10, color: light ? Colors.black45 : Colors.white54)),
                  if (copies > 1)
                    Text('x$copies', style: TextStyle(fontSize: 11, color: textAccent, fontWeight: FontWeight.w800)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _stat(String label, int value) => Text('$label $value',
      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800));
}

class _ClawPainter extends CustomPainter {
  _ClawPainter(this.color, {required this.light});
  final Color color;
  final bool light;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: light
              ? const [Color(0xFFF4F6F8), Color(0xFFE3E7EB)]
              : const [Color(0xFF1A211A), Color(0xFF070907)],
        ).createShader(Offset.zero & size),
    );
    final paint = Paint()
      ..color = color.withValues(alpha: .55)
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * .08
      ..strokeCap = StrokeCap.round;
    for (var i = 0; i < 3; i++) {
      final x = size.width * (.3 + i * .2);
      canvas.drawLine(Offset(x + size.width * .1, size.height * .15),
          Offset(x - size.width * .1, size.height * .85), paint);
    }
  }

  @override
  bool shouldRepaint(_ClawPainter old) => old.color != color || old.light != light;
}
