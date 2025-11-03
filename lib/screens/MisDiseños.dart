import 'package:flutter/material.dart';

class MisDisenos extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mis diseños'),
        backgroundColor: Colors.purple[200],
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: ListView(
          children: [
            Card(
              color: Colors.purple[50],
              child: ListTile(
                leading: Icon(Icons.toys, color: Colors.purple[400]),
                title: Text('Amigurumi 🌸'),
                subtitle: Text('Color: Lila\nMaterial: Hilo elástico\nTamaño: 18 cm'),
              ),
            ),
            Card(
              color: Colors.purple[50],
              child: ListTile(
                leading: Icon(Icons.brush, color: Colors.purple[400]),
                title: Text('Pulsera ✨'),
                subtitle: Text('Color: Azul\nMaterial: Cuentas brillantes\nTamaño: 20 cm'),
              ),
            ),
            Card(
              color: Colors.purple[50],
              child: ListTile(
                leading: Icon(Icons.cut, color: Colors.purple[400]),
                title: Text('Papercraft 🦋'),
                subtitle: Text('Color: Rosa\nMaterial: Papel especial\nTamaño: 22 cm'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
