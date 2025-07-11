import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gastoclub/mobile/auth_service.dart';
import 'package:gastoclub/pallete.dart';
import 'package:gastoclub/pages/home_page.dart';
class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  //Logica
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final usernameController = TextEditingController();
  final passwordConfirmationController = TextEditingController();
  //Creacion del widget
  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    usernameController.dispose();
    passwordConfirmationController.dispose();
    super.dispose();
  }

  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colores.paleta[0],
        body: SingleChildScrollView(
          child: Container(
            margin: EdgeInsets.all(15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text("Empieza a tomar el control de tu dinero💸",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 45),),
                SizedBox(height: 20,),
                Center(child: SvgPicture.asset('assets/logos_svg/registerclub.svg',width: 300,fit: BoxFit.scaleDown,)),
                SizedBox(height: 20,),
                Text("Registrate aquí", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),),
                SizedBox(height: 10,),
                TextField(
                          controller: usernameController,
                          obscureText: false,
                          decoration: InputDecoration(
                            labelText: 'Nombre Completo',
                            labelStyle: TextStyle(color: const Color.fromARGB(255, 255, 255, 255)),
                            hintStyle: TextStyle(color: const Color.fromARGB(255, 255, 255, 255)),
                            prefixIcon: Icon(Icons.perm_identity, color: const Color.fromARGB(255, 255, 255, 255)),
                            filled: true,
                            fillColor: Colores.paleta[1],
                            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: BorderSide(color: const Color.fromARGB(99, 255, 255, 255)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: BorderSide(color: const Color.fromARGB(255, 238, 238, 238), width: 2)
                            ),
                          ),
                          style: TextStyle(color: Colors.white),
                          keyboardType: TextInputType.emailAddress,
                        ),
                SizedBox(height: 15,),
                TextField(
                          controller: emailController,
                          obscureText: false,
                          decoration: InputDecoration(
                            labelText: 'Correo Electronico',
                            labelStyle: TextStyle(color: const Color.fromARGB(255, 255, 255, 255)),
                            // hintText: 'Murcielago123',
                            hintStyle: TextStyle(color: const Color.fromARGB(255, 255, 255, 255)),
                            prefixIcon: Icon(Icons.alternate_email, color: const Color.fromARGB(255, 255, 255, 255)),
                            filled: true,
                            fillColor: Colores.paleta[1],
                            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: BorderSide(color: const Color.fromARGB(99, 255, 255, 255)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: BorderSide(color: const Color.fromARGB(255, 238, 238, 238), width: 2)
                            ),
                          ),
                          style: TextStyle(color: Colors.white),
                          keyboardType: TextInputType.emailAddress,
                        ),
                SizedBox(height: 15,),
                TextField(
                          controller: passwordController,
                          obscureText: true,
                          decoration: InputDecoration(
                            labelText: 'Contraseña',
                            labelStyle: TextStyle(color: const Color.fromARGB(255, 255, 255, 255)),
                            // hintText: 'Murcielago123',
                            hintStyle: TextStyle(color: const Color.fromARGB(255, 255, 255, 255)),
                            prefixIcon: Icon(Icons.lock, color: const Color.fromARGB(255, 255, 255, 255)),
                            filled: true,
                            fillColor: Colores.paleta[1],
                            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: BorderSide(color: const Color.fromARGB(99, 255, 255, 255)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: BorderSide(color: const Color.fromARGB(255, 238, 238, 238), width: 2)
                            ),
                          ),
                          style: TextStyle(color: Colors.white),
                          keyboardType: TextInputType.emailAddress,
                        ),
                SizedBox(height: 15,),
                TextField(
                          controller: passwordConfirmationController,
                          obscureText: true,
                          decoration: InputDecoration(
                            labelText: 'Confirmar Contraseña',
                            labelStyle: TextStyle(color: const Color.fromARGB(255, 255, 255, 255)),
                            // hintText: 'Murcielago123',
                            hintStyle: TextStyle(color: const Color.fromARGB(255, 255, 255, 255)),
                            prefixIcon: Icon(Icons.lock, color: const Color.fromARGB(255, 255, 255, 255)),
                            filled: true,
                            fillColor: Colores.paleta[1],
                            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: BorderSide(color: const Color.fromARGB(99, 255, 255, 255)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: BorderSide(color: const Color.fromARGB(255, 238, 238, 238), width: 2)
                            ),
                          ),
                          style: TextStyle(color: Colors.white),
                          keyboardType: TextInputType.emailAddress,
                        ),
                SizedBox(height: 20,),
                TextButton(
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
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
                    child: Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: "Siguiente",
                            style: TextStyle(fontSize: 16, color: Colores.paleta[6]),
                          ),
                          WidgetSpan(
                            child: Icon(
                              Icons.arrow_right_sharp,
                              size: 18,
                              color: Colores.paleta[6],
                            ),
                          ),
                        ],
                      ),
                    ),
                    onPressed: () async {
                      final exito = await authService.value.registerWithEmailAndPassword(
                        emailController.text.trim(), 
                        passwordController.text.trim(), 
                        usernameController.text.trim()
                      );
                      print(exito);
                      if (exito != null) {
                        Navigator.pop(context); // Vuelve si todo salió bien
                      } else {
                        // Muestra un error o SnackBar
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Error al registrar usuario"))
                        );
                      }
                    }
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}