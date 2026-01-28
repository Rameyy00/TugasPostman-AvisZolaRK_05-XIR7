import 'package:flutter/material.dart';
import 'package:postman/views/login_view.dart';
import 'package:postman/views/register_user_view.dart';
import 'package:postman/views/dashboard.dart';
import 'package:postman/views/kelola_view.dart';
import 'package:postman/views/pesan_view.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID', null);

  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/login',
      routes: {
        '/': (context) => RegisterUserView(),
        '/login': (context) => LoginView(),
        '/dashboard': (context) => DashboardView(),
        '/kelola': (context) => KelolaView(),
        '/pesan': (context) => PesanView(),
      },
    ),
  );
}
