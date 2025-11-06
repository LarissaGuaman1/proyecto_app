import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../widgets/ProductCard.dart';
import 'dart:io';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  User? currentUser;
  Map<String, dynamic>? userData;

  @override
  void initState() {
    super.initState();
    currentUser = FirebaseAuth.instance.currentUser;
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    if (currentUser != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser!.uid)
          .get();

      setState(() {
        userData = userDoc.data() as Map<String, dynamic>?;
      });
    }
  }

  Future<void> logout() async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    String name = userData?['name'] ?? 'Usuario';
    String email = userData?['email'] ?? '';
    String profilePath = userData?['profileImage'] ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Crea tu Magia 💕'),
        backgroundColor: Colors.purple[200],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              decoration: BoxDecoration(color: Colors.purple[100]),
              accountName: Text(
                name,
                style: TextStyle(color: Colors.purple),
              ),
              accountEmail: Text(
                email,
                style: TextStyle(color: Colors.purple[800]),
              ),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.purple[50],
                backgroundImage:
                    profilePath.isNotEmpty ? FileImage(File(profilePath)) : null,
                child: profilePath.isEmpty
                    ? Icon(Icons.person, size: 40, color: Colors.purple)
                    : null,
              ),
            ),
            ListTile(
              leading: Icon(Icons.home, color: Colors.purple[400]),
              title: const Text('Inicio'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: Icon(Icons.favorite, color: Colors.purple[400]),
              title: const Text('Mis diseños'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/misdisenos');
              },
            ),
            ListTile(
              leading: Icon(Icons.chat, color: Colors.purple[400]),
              title: const Text('Contactar'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/contactar');
              },
            ),
            ListTile(
              leading: Icon(Icons.settings, color: Colors.purple[400]),
              title: const Text('Configuración'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/configuracion');
              },
            ),
            ListTile(
              leading: Icon(Icons.logout, color: Colors.purple[400]),
              title: const Text('Cerrar sesión'),
              onTap: () {
                logout();
              },
            ),
          ],
        ),
      ),
      body: Center(
        child: Wrap(
          spacing: 16,
          runSpacing: 16,
          alignment: WrapAlignment.center,
          children: [
            ProductCard(
              title: 'Amigurumi',
              icon: Icons.toys,
              width: 120,
              height: 120,
              onTap: () {
                Navigator.pushNamed(context, '/customize',
                    arguments: {'product': 'Amigurumi'});
              },
            ),
            ProductCard(
              title: 'Pulsera',
              icon: Icons.brush,
              width: 120,
              height: 120,
              onTap: () {
                Navigator.pushNamed(context, '/customize',
                    arguments: {'product': 'Pulsera'});
              },
            ),
            ProductCard(
              title: 'Papercraft',
              icon: Icons.cut,
              width: 120,
              height: 120,
              onTap: () {
                Navigator.pushNamed(context, '/customize',
                    arguments: {'product': 'Papercraft'});
              },
            ),
          ],
        ),
      ),
    );
  }
}
