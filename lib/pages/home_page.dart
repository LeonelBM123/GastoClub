import 'package:flutter/material.dart';
import 'package:gastoclub/pallete.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colores.paleta[0],
        appBar: AppBar(
          backgroundColor: Colores.paleta[0],
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: EdgeInsets.only(top: 10, left: 5, right: 5),
                child: const Text(
                  'Hola, Leonel!',
                  style: TextStyle(fontSize: 25, fontWeight: FontWeight.w700),
                ),
              ),
              Container(
                child: const Text(
                  'Aquí está tu resumen financiero',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Color.fromARGB(145, 208, 208, 208),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            IconButton(
              onPressed: () {},
              icon: Icon(Icons.person),
              iconSize: 40,
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.only(left: 15, right: 15),
            child: Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: 20),
                  StateCard(),
                  SizedBox(height: 20),
                  Text(
                    'Categorias Principales',
                    style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                  ),
                  Container(
                    width: 300,
                    height: 250,
                    child: GridView.count(
                      shrinkWrap: true, // Ajusta la altura al contenido
                      physics: NeverScrollableScrollPhysics(),
                      crossAxisCount: 3,
                      crossAxisSpacing: 10, // Espacio horizontal entre ítems
                      mainAxisSpacing: 10, // Espacio vertical entre ítems
                      padding: EdgeInsets.all(10),
                      children: List.generate(6, (index) {
                        return Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: const Color.fromARGB(163, 255, 255, 255),
                          ),
                          child: Center(
                            child: Text(
                              'Item $index',
                              style: TextStyle(color: Colors.black),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Gastos Recientes',
                    style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                  ),
                  Container(height: 500),
                ],
              ),
            ),
          ),
        ),
        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: Colores.paleta[5],
          currentIndex: 0,
          onTap: (index) {
            // Lógica para cambiar de página
          },
          items: [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
            BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Buscar'),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
          ],
        ),
      ),
    );
  }
}

class StateCard extends StatelessWidget {
  const StateCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colores.paleta[1],
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colores.paleta[1], // Color de la sombra
            offset: Offset(4, 4), // Desplazamiento X e Y
            blurRadius: 10, // Desenfoque
            spreadRadius: 0, // Expansión
          ),
        ],
      ),
      height: 150,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "Gastos este mes:",
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 20,
              color: Color.fromARGB(154, 238, 238, 238),
            ),
          ),
          Text(
            "230.32 Bs",
            style: TextStyle(fontSize: 35, fontWeight: FontWeight.w700),
          ),
          Text.rich(
            TextSpan(
              children: [
                WidgetSpan(
                  child: Icon(
                    Icons.arrow_outward,
                    size: 15,
                    color: Colors.green,
                  ),
                ),
                TextSpan(
                  text: "+12% vs el anterior mes",
                  style: TextStyle(fontSize: 15, color: Colors.green),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
