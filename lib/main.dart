import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show defaultTargetPlatform, TargetPlatform;
import 'package:provider/provider.dart'; // ✅ TAMBAHKAN INI
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite/sqflite.dart' as sqflite;
import 'package:intl/date_symbol_data_local.dart';

import 'package:postman/controllers/cartProvider.dart'; // ✅ TAMBAHKAN INI
import 'package:postman/views/History.dart';
import 'package:postman/views/cartscreen.dart';
import 'package:postman/views/login_view.dart';
import 'package:postman/views/register_user_view.dart';
import 'package:postman/views/dashboard.dart';
import 'package:postman/views/kelola_view.dart';
import 'package:postman/views/pesan_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi database untuk platform desktop
  if (defaultTargetPlatform == TargetPlatform.windows ||
      defaultTargetPlatform == TargetPlatform.linux ||
      defaultTargetPlatform == TargetPlatform.macOS) {
    sqfliteFfiInit();
    sqflite.databaseFactory = databaseFactoryFfi;
  }

  await initializeDateFormatting('id_ID', null);

  runApp(
    // ✅ WRAP dengan MultiProvider
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CartProvider()),
        // Tambahkan provider lain jika diperlukan di masa depan
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        initialRoute: '/login',
        routes: {
          '/': (context) => RegisterUserView(),
          '/login': (context) => LoginView(),
          '/dashboard': (context) => DashboardView(),
          '/kelola': (context) => ProductView(),
          '/pesan': (context) => PesanView(),
          '/cartScreen': (context) => CartScreen(),
          '/history': (context) => HistoryView(),
        },
      ),
    ),
  );
}