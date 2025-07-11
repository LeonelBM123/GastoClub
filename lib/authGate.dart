import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gastoclub/pages/layout_main.dart';
import 'package:gastoclub/pages/login_page.dart';
import 'package:gastoclub/pages/home_page.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(), // escucha cambios
      builder: (context, snapshot) {
        // Mientras espera datos, muestra una pantalla de carga
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // Si hay usuario autenticado
        if (snapshot.hasData) {
          return const LayoutMain();
        } else {
          return const LoginPage();
        }
      },
    );
  }
}
