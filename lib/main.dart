import 'package:material_ui/material_ui.dart';

import 'screens/collection_screen.dart';
import 'screens/scan_screen.dart';
import 'services/card_generator.dart';
import 'services/collection_db.dart';
import 'theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final db = await CollectionDb.open();
  final themeController = await ThemeController.load(db);
  runApp(MonsterTcgApp(db: db, themeController: themeController));
}

class MonsterTcgApp extends StatelessWidget {
  const MonsterTcgApp({super.key, required this.db, required this.themeController});

  final CollectionDb db;
  final ThemeController themeController;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AppThemeMode>(
      valueListenable: themeController,
      builder: (_, __, ___) => MaterialApp(
        title: 'Monster TCG',
        debugShowCheckedModeBanner: false,
        theme: themeController.themeData,
        home: Home(db: db, themeController: themeController),
      ),
    );
  }
}

class Home extends StatefulWidget {
  const Home({super.key, required this.db, required this.themeController});
  final CollectionDb db;
  final ThemeController themeController;

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final _generator = CardGenerator();
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      ScanScreen(db: widget.db, generator: _generator, themeController: widget.themeController),
      // Key forces a reload of the collection each time the tab is opened.
      CollectionScreen(
        key: UniqueKey(),
        db: widget.db,
        generator: _generator,
        themeController: widget.themeController,
      ),
    ];
    return Scaffold(
      body: IndexedStack(index: _tab, children: pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: (i) => setState(() => _tab = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.qr_code_scanner), label: 'Scan'),
          NavigationDestination(icon: Icon(Icons.style), label: 'Collection'),
        ],
      ),
    );
  }
}
