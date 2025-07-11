import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gastoclub/mobile/auth_service.dart';
import 'package:gastoclub/pallete.dart'; // Asegúrate de que la ruta sea correcta

class Perfil extends StatelessWidget {
  const Perfil({super.key});

  @override
  Widget build(BuildContext context) {
    final user = authService.value;
    final userEmail = (user?.getCurrentUser()?.email ?? 'email@ejemplo.com').toString();

    return Scaffold(
      backgroundColor: Colores.paleta[0],
      appBar: AppBar(
        title: const Text('Mi Perfil', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colores.paleta[1],
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            FutureBuilder<String?>(
              future: user.getNombre(FirebaseAuth.instance.currentUser!.uid),
              builder: (context, snapshot) {
                final userName = (snapshot.data ?? 'Nombre de Usuario').toString();
                return _buildProfileHeader(userName, userEmail);
              },
            ),
            const SizedBox(height: 30),

            // --- SECCIÓN DE AJUSTES DE CUENTA ---
            _buildSectionTitle('Ajustes de la Cuenta'),
            _buildOptionsCard([
              _buildOptionTile(
                icon: Icons.person_outline,
                title: 'Editar Perfil',
                onTap: () {
                  // Lógica para navegar a la pantalla de edición de perfil
                },
              ),
              _buildOptionTile(
                icon: Icons.lock_outline,
                title: 'Cambiar Contraseña',
                onTap: () {
                  // Lógica para mostrar diálogo de cambio de contraseña
                },
              ),
            ]),
            const SizedBox(height: 20),

            // --- SECCIÓN DE PREFERENCIAS ---
            _buildSectionTitle('Preferencias'),
            _buildOptionsCard([
              _buildOptionTile(
                icon: Icons.notifications_none,
                title: 'Notificaciones',
                onTap: () {
                  // Lógica para la pantalla de notificaciones
                },
              ),
              _buildOptionTile(
                icon: Icons.color_lens_outlined,
                title: 'Apariencia',
                subtitle: 'Tema Oscuro', // Ejemplo de subtítulo
                onTap: () {
                  // Lógica para cambiar el tema
                },
              ),
            ]),
            const SizedBox(height: 40),

            // --- BOTÓN DE CERRAR SESIÓN ---
            ElevatedButton.icon(
              onPressed: () {
                FirebaseAuth.instance.signOut();
                // Lógica para cerrar sesión
              },
              icon: const Icon(Icons.logout),
              label: const Text('Cerrar Sesión'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colores.paleta[2].withOpacity(0.8),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 15),

            // --- BOTÓN DE ELIMINAR CUENTA ---
            TextButton(
              onPressed: () {
                // Lógica para mostrar diálogo de confirmación de borrado
              },
              child: const Text(
                'Eliminar cuenta',
                style: TextStyle(color: Colors.redAccent),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- WIDGETS AUXILIARES PARA CONSTRUIR LA UI ---

  Widget _buildProfileHeader(String name, String email) {
    return Column(
      children: [
        const CircleAvatar(
          radius: 50,
          backgroundColor: Color(0xFF4EF037),
          child: Icon(
            Icons.person,
            size: 60,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          name,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          email,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Text(
        title,
        style: TextStyle(
          color: Colors.white.withOpacity(0.9),
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildOptionsCard(List<Widget> children) {
    return Card(
      color: Colores.paleta[1],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Column(
        children: children,
      ),
    );
  }

  Widget _buildOptionTile({
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.white70),
      title: Text(title, style: const TextStyle(color: Colors.white, fontSize: 16)),
      subtitle: subtitle != null
          ? Text(subtitle, style: const TextStyle(color: Colors.white54))
          : null,
      trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.white54),
      onTap: onTap,
    );
  }
}