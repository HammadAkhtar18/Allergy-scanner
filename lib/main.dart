import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'models/restrictions.dart';
import 'screens/scanner_screen.dart';
import 'screens/settings_screen.dart';
import 'services/restriction_store.dart';

void main() {
  runApp(const AllergyScannerApp());
}

class AllergyScannerApp extends StatefulWidget {
  const AllergyScannerApp({super.key});

  @override
  State<AllergyScannerApp> createState() => _AllergyScannerAppState();
}

class _AllergyScannerAppState extends State<AllergyScannerApp> {
  final RestrictionStore _store = RestrictionStore();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<String>>(
      future: _store.loadRestrictions(),
      builder: (context, snapshot) {
        final restrictions = snapshot.data ?? [];
        return ChangeNotifierProvider(
          create: (_) => RestrictionsModel(initialRestrictions: restrictions),
          child: MaterialApp(
            title: 'Allergy Scanner',
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
              useMaterial3: true,
            ),
            routes: {
              '/': (_) => const ScannerScreen(),
              SettingsScreen.routeName: (_) => SettingsScreen(store: _store),
            },
          ),
        );
      },
    );
  }
}
