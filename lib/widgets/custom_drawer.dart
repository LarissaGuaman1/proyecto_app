import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Drawer(
        child: Center(child: Text("No hay usuario autenticado")),
      );
    }

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('users').doc(user.uid).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Drawer(
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const Drawer(
            child: Center(child: Text("No se encontraron datos del usuario")),
          );
        }

        final data = snapshot.data!.data() as Map<String, dynamic>;
        final String name = data['name'] ?? 'Usuario';
        final String email = data['email'] ?? 'Sin correo';
        final String? profileImage = data['profileImage'];
        final String role = data['role'] ?? 'user';

        return Drawer(
          child: Container(
            color: const Color(0xFFF5ECF7), // 💜 Fondo pastel
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                Container(
                  padding: const EdgeInsets.only(top: 40, bottom: 20),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFFE1BEE7), Color(0xFFD1C4E9)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: Colors.white,
                        child: ClipOval(
                          child: profileImage != null && profileImage.isNotEmpty
                              ? Image.network(
                                  profileImage,
                                  width: 80,
                                  height: 80,
                                  fit: BoxFit.cover,
                                )
                              : Image.asset(
                                  'assets/images/default_avatar.png',
                                  width: 80,
                                  height: 80,
                                  fit: BoxFit.cover,
                                ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF6A1B9A),
                        ),
                      ),
                      Text(
                        email,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF8E24AA),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        role.toUpperCase(),
                        style: const TextStyle(fontSize: 12, color: Color(0xFF6A1B9A)),
                      ),
                    ],
                  ),
                ),

                // 🌸 ITEMS DEL MENÚ · Pastel & cute
                _drawerItem(
                  icon: Icons.home,
                  text: "Inicio",
                  onTap: () => Navigator.pushNamed(context, '/home'),
                ),

                _drawerItem(
                  icon: Icons.person,
                  text: "Mi perfil",
                  onTap: () => Navigator.pushNamed(context, '/perfil'),
                ),

                _drawerItem(
                  icon: Icons.favorite,
                  text: "Mis diseños",
                  onTap: () => Navigator.pushNamed(context, '/misdisenos'),
                ),

                _drawerItem(
                  icon: Icons.contact_mail,
                  text: "Contactar",
                  onTap: () => Navigator.pushNamed(context, '/contactar'),
                ),

                _drawerItem(
                  icon: Icons.settings,
                  text: "Configuración",
                  onTap: () => Navigator.pushNamed(context, '/configuracion'),
                ),

                // Si eres admin puedes ver la pantalla de administración de usuarios (debes implementar /users)
                if (role == 'admin')
                  _drawerItem(
                    icon: Icons.admin_panel_settings,
                    text: "Administrar usuarios",
                    onTap: () => Navigator.pushNamed(context, '/users'),
                  ),

                const Divider(thickness: 1, color: Color(0xFFCE93D8)),

                _drawerItem(
                  icon: Icons.logout,
                  text: "Cerrar sesión",
                  color: Colors.pinkAccent,
                  onTap: () async {
                    await FirebaseAuth.instance.signOut();
                    if (context.mounted) {
                      Navigator.pushReplacementNamed(context, '/login');
                    }
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // 🌸 Widget cute para los items
  Widget _drawerItem({
    required IconData icon,
    required String text,
    Color color = const Color(0xFF8E24AA),
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: color, size: 28),
      title: Text(
        text,
        style: const TextStyle(
          fontSize: 17,
          color: Color(0xFF4A148C),
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: onTap,
    );
  }
}
