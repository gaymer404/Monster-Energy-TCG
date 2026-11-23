import 'package:material_ui/material_ui.dart';

import 'screens/collection_screen.dart';
import 'screens/scan_screen.dart';
import 'services/card_generator.dart';
import 'services/collection_db.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final db = await CollectionDb.open();
  runApp(MonsterTcgApp(db: db));
}

class MonsterTcgApp extends StatelessWidget {
  const MonsterTcgApp({super.key, required this.db});

  final CollectionDb db;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Monster TCG',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0B0D0B),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF7ED321),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: Home(db: db),
    );
  }
}

class Home extends StatefulWidget {
  const Home({super.key, required this.db});
  final CollectionDb db;

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final _generator = CardGenerator();
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      ScanScreen(db: widget.db, generator: _generator),
      // Key forces a reload of the collection each time the tab is opened.
      CollectionScreen(key: UniqueKey(), db: widget.db, generator: _generator),
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
