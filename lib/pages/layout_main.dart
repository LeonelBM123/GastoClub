import 'package:gastoclub/pages/club.dart';
import 'package:gastoclub/pages/home_page.dart';
import 'package:flutter/material.dart';
import 'package:gastoclub/pages/perfil.dart';
import 'package:gastoclub/pallete.dart';
class LayoutMain extends StatefulWidget {
  const LayoutMain({super.key});

  @override
  State<LayoutMain> createState() => _LayoutMainState();
}

class _LayoutMainState extends State<LayoutMain> {
  int _selectedIndex = 0; // 1. Variable de estado

  // 2. Lista de las pantallas
  static const List<Widget> _widgetOptions = <Widget>[
    HomePage(), // El contenido de la pestaña Inicio
    Club(),       // La pantalla para la pestaña Club
    Perfil(),     // La pantalla para la pestaña Perfil
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index; // 4. Actualiza el índice al tocar
    });
  }
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Center(
          child: _widgetOptions.elementAt(_selectedIndex), // 3. Muestra la pantalla seleccionada
        ),
        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: Colores.paleta[1],
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Inicio',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.groups_3),
              label: 'Club',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Perfil',
            ),
          ],
          currentIndex: _selectedIndex, // Usa la variable de estado
          selectedItemColor: Colors.amber[800], // Opcional: color para el ítem activo
          // selectedItemColor: Colores.paleta[0], // Opcional: color para el ítem activo
          onTap: _onItemTapped, // Llama a la función para cambiar de estado
        ),
      ),
    );
  }
}