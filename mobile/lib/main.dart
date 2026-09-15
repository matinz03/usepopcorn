import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'screens/home_screen.dart';
import 'services/omdb_api.dart';
import 'state/watched_store.dart';
import 'theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );
  runApp(const UsePopcornApp());
}

class UsePopcornApp extends StatefulWidget {
  const UsePopcornApp({super.key});

  @override
  State<UsePopcornApp> createState() => _UsePopcornAppState();
}

class _UsePopcornAppState extends State<UsePopcornApp> {
  final OmdbApi _api = OmdbApi();
  final WatchedStore _store = WatchedStore();

  @override
  void initState() {
    super.initState();
    _store.load();
  }

  @override
  void dispose() {
    _api.dispose();
    _store.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'usePopcorn',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      // Respect the OS font-size setting, but cap it so the densest rows stay
      // readable rather than overflowing.
      builder:
          (context, child) => MediaQuery.withClampedTextScaling(
            maxScaleFactor: 1.3,
            child: child!,
          ),
      home: HomeScreen(api: _api, store: _store),
    );
  }
}
