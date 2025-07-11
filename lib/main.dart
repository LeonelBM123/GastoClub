import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:gastoclub/authGate.dart';
import 'package:gastoclub/pages/login_page.dart';
import 'firebase_options.dart';
import 'package:intl/date_symbol_data_local.dart';
void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('es', null);
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Gasto Club',
      theme: ThemeData(
        fontFamily: 'Inter',
        colorScheme: ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 6, 7, 88),brightness: Brightness.dark),
      ),
      home: const AuthGate(),
    );
  }
}

