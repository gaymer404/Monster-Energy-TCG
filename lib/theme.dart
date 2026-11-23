import 'package:material_ui/material_ui.dart';

import 'services/collection_db.dart';

enum AppThemeMode { dark, ultraWhite }

const monsterGreen = Color(0xFF7ED321);

final ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  scaffoldBackgroundColor: const Color(0xFF0B0D0B),
  colorScheme: ColorScheme.fromSeed(seedColor: monsterGreen, brightness: Brightness.dark),
  useMaterial3: true,
);

const _ultraFont = 'BarlowCondensed';
const _iceBlue = Color(0xFF8FD3FF);
const _silver = Color(0xFFC5CCD3);

TextTheme _ultraTextTheme() {
  final base = ThemeData(brightness: Brightness.light).textTheme;
  TextStyle? display(TextStyle? s) => s?.copyWith(fontFamily: _ultraFont, fontWeight: FontWeight.w800);
  return base.copyWith(
    headlineLarge: display(base.headlineLarge),
    headlineMedium: display(base.headlineMedium),
    headlineSmall: display(base.headlineSmall),
    titleLarge: display(base.titleLarge),
    titleMedium: display(base.titleMedium),
  );
}

/// Monster Ultra White look: white surfaces, silver outlines, icy-blue accents (no green),
/// Barlow Condensed headings.
final ThemeData ultraWhiteTheme = ThemeData(
  brightness: Brightness.light,
  textTheme: _ultraTextTheme(),
  scaffoldBackgroundColor: Colors.white,
  colorScheme: ColorScheme.fromSeed(
    seedColor: _iceBlue,
    brightness: Brightness.light,
  ).copyWith(
    primary: const Color(0xFF1F6FA3),
    onPrimary: Colors.white,
    surface: Colors.white,
    onSurface: const Color(0xFF0F1311),
    secondary: const Color(0xFF5B6B78),
    secondaryContainer: _iceBlue.withValues(alpha: .35),
    outline: _silver,
    outlineVariant: const Color(0xFFD9DEE3),
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.white,
    foregroundColor: Color(0xFF0F1311),
    surfaceTintColor: Colors.transparent,
    titleTextStyle: TextStyle(
      fontFamily: _ultraFont,
      fontWeight: FontWeight.w800,
      fontSize: 24,
      letterSpacing: .5,
      color: Color(0xFF0F1311),
    ),
  ),
  navigationBarTheme: NavigationBarThemeData(
    backgroundColor: Colors.white,
    surfaceTintColor: Colors.transparent,
    indicatorColor: _iceBlue.withValues(alpha: .35),
  ),
  useMaterial3: true,
);

class ThemeController extends ValueNotifier<AppThemeMode> {
  ThemeController(this._db, super.initial);

  final CollectionDb _db;

  static Future<ThemeController> load(CollectionDb db) async {
    final saved = await db.getSetting('theme');
    final mode = AppThemeMode.values.where((m) => m.name == saved).firstOrNull ?? AppThemeMode.dark;
    return ThemeController(db, mode);
  }

  ThemeData get themeData => value == AppThemeMode.ultraWhite ? ultraWhiteTheme : darkTheme;

  Future<void> toggle() {
    value = value == AppThemeMode.dark ? AppThemeMode.ultraWhite : AppThemeMode.dark;
    return _db.setSetting('theme', value.name);
  }
}

class ThemeToggleButton extends StatelessWidget {
  const ThemeToggleButton({super.key, required this.controller});

  final ThemeController controller;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AppThemeMode>(
      valueListenable: controller,
      builder: (_, mode, __) => IconButton(
        tooltip: mode == AppThemeMode.dark ? 'Switch to Ultra White theme' : 'Switch to dark theme',
        icon: Icon(mode == AppThemeMode.dark ? Icons.light_mode : Icons.dark_mode),
        onPressed: controller.toggle,
      ),
    );
  }
}
