import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gastoclub/mobile/auth_service.dart';
import 'package:gastoclub/pages/home_page.dart';
import 'package:gastoclub/pages/layout_main.dart';
import 'package:gastoclub/pages/register_page.dart';
import 'package:gastoclub/pallete.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool isLoading = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (authService.value.getCurrentUser() != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
      );
    }
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colores.paleta[0],
        body: SingleChildScrollView(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                SizedBox(width: 100, height: 130),
                SvgPicture.asset(
                  'assets/logos_svg/gastoclub_logo.svg',
                  width: 250,
                ),
                SizedBox(height: 40),
                Text(
                  'Gasto Club',
                  style: TextStyle(
                    fontSize: 50,
                    fontFamily: 'Inter-Bold',
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 25),
                SizedBox(
                  width: 350,
                  child: TextField(
                    controller: emailController,
                    decoration: InputDecoration(
                      labelText: 'Correo electrónico',
                      labelStyle: TextStyle(
                        color: const Color.fromARGB(255, 255, 255, 255),
                      ),
                      // hintText: 'ejemplo@correo.com',
                      hintStyle: TextStyle(
                        color: const Color.fromARGB(255, 255, 255, 255),
                      ),
                      prefixIcon: Icon(
                        Icons.email,
                        color: const Color.fromARGB(255, 255, 255, 255),
                      ),
                      filled: true,
                      fillColor: Colores.paleta[1],
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: const Color.fromARGB(100, 255, 255, 255),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: const Color.fromARGB(255, 238, 238, 238),
                          width: 2,
                        ),
                      ),
                    ),
                    style: TextStyle(color: Colors.white),
                    keyboardType: TextInputType.emailAddress,
                  ),
                ),
                SizedBox(height: 25),
                SizedBox(
                  width: 350,
                  child: TextField(
                    obscureText: true,
                    controller: passwordController,
                    decoration: InputDecoration(
                      labelText: 'Contraseña',
                      labelStyle: TextStyle(
                        color: const Color.fromARGB(255, 255, 255, 255),
                      ),
                      // hintText: 'Murcielago123',
                      hintStyle: TextStyle(
                        color: const Color.fromARGB(255, 255, 255, 255),
                      ),
                      prefixIcon: Icon(
                        Icons.lock,
                        color: const Color.fromARGB(255, 255, 255, 255),
                      ),
                      filled: true,
                      fillColor: Colores.paleta[1],
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: const Color.fromARGB(99, 255, 255, 255),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: const Color.fromARGB(255, 238, 238, 238),
                          width: 2,
                        ),
                      ),
                    ),
                    style: TextStyle(color: Colors.white),
                    keyboardType: TextInputType.emailAddress,
                  ),
                ),
                SizedBox(height: 25),
                TextButton(
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 14,
                    ),
                    backgroundColor: Colores.paleta[1],
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  child: Text('Iniciar Sesion'),
                  onPressed: () async {
                    await authService.value.signInWithEmailAndPassword(
                      emailController.text.trim(),
                      passwordController.text.trim(),
                    );
                    if (authService.value.getCurrentUser() != null) {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => HomePage()),
                      );
                    }
                  },
                ),
                SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 60,
                      height: 1.5,
                      color: Colores.paleta[6].withOpacity(0.2),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      child: Text(
                        'ó',
                        style: TextStyle(fontSize: 16, color: Colors.white54),
                      ),
                    ),
                    Container(
                      width: 60,
                      height: 1.5,
                      color: Colores.paleta[6].withOpacity(0.2),
                    ),
                  ],
                ),
                TextButton(
                  onPressed: () async {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => RegisterPage()),
                    );
                  },
                  child: Text('Registrate'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
