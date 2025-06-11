import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gastoclub/pallete.dart';

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  @override
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
                SizedBox(height: 25,),
                Center(child: SvgPicture.asset('assets/logos_svg/registerclub.svg',width: 350,fit: BoxFit.scaleDown,)),
                SizedBox(height: 20,),
                Text("Registrate aquí", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),),
                SizedBox(height: 15,),
                TextField(
                          obscureText: true,
                          decoration: InputDecoration(
                            labelText: 'Nombre Completo',
                            labelStyle: TextStyle(color: const Color.fromARGB(255, 255, 255, 255)),
                            // hintText: 'Murcielago123',
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
                          obscureText: true,
                          decoration: InputDecoration(
                            labelText: 'Correo',
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
                    child: Text('Registrarme'),
                    onPressed: () async {
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