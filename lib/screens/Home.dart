import 'package:flutter/material.dart';
import '../widgets/ProductCard.dart';

class Home extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Crea tu Magia 💕'),
        backgroundColor: Colors.purple[200],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.purple[100]),
              child: Column(
                children: [
                  Image.asset("/src/flutter/examples/Cuarto/proyecto/lib/assets/images/logo.png", height: 60),
                  SizedBox(height: 10),
                  Text(
                    'Danahe’s Magical Crafts 💖',
                    style: TextStyle(color: Colors.purple[800], fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: Icon(Icons.home, color: Colors.purple[400]),
              title: Text('Inicio'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: Icon(Icons.favorite, color: Colors.purple[400]),
              title: Text('Mis diseños'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/misdisenos');
              },
            ),
            ListTile(
              leading: Icon(Icons.chat, color: Colors.purple[400]),
              title: Text('Contactar'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/contactar');
              },
            ),
            ListTile(
              leading: Icon(Icons.settings, color: Colors.purple[400]),
              title: Text('Configuración'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/configuracion');
              },
            ),
            ListTile(
              leading: Icon(Icons.logout, color: Colors.purple[400]),
              title: Text('Cerrar sesión'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushReplacementNamed(context, '/cerrarsesion');
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
                Navigator.pushNamed(context, '/customize', arguments: {'product': 'Amigurumi'});
              },
            ),
            ProductCard(
              title: 'Pulsera',
              icon: Icons.brush,
              width: 120,
              height: 120,
              onTap: () {
                Navigator.pushNamed(context, '/customize', arguments: {'product': 'Pulsera'});
              },
            ),
            ProductCard(
              title: 'Papercraft',
              icon: Icons.cut,
              width: 120,
              height: 120,
              onTap: () {
                Navigator.pushNamed(context, '/customize', arguments: {'product': 'Papercraft'});
              },
            ),
          ],
        ),
      ),
    );
  }
}
