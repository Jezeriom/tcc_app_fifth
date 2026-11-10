import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

import 'core/constants/app_theme.dart';
import 'providers/inventory_provider.dart';
import 'views/main_navigation_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb) {
    databaseFactory = databaseFactoryFfiWeb;
  }
  await initializeDateFormatting('es', null);
  runApp(const InventoryApp());
}

class InventoryApp extends StatelessWidget {
  const InventoryApp({super.key});

  @override
  Widget build(BuildContext context) => MultiProvider(
    providers: [ChangeNotifierProvider(create: (_) => InventoryProvider())],
    child: MaterialApp(
      title: 'Inventario',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const MainNavigationScreen(),
    ),
  );
}

