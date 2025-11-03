import 'package:flutter/material.dart';

class Summary extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Recibir los argumentos de Preview
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final String product = args['product'];
    final Color color = args['color'];
    final String material = args['material'];
    final double size = args['size'];

    return Scaffold(
      appBar: AppBar(
        title: Text('Resumen del pedido'),
        backgroundColor: Colors.purple[200],
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Card(
              color: Colors.purple[50],
              child: ListTile(
                leading: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                title: Text('$product personalizado'),
                subtitle: Text(
                    'Color: ${color.toString()}\nMaterial: $material\nTamaño: ${size.toInt()} cm\nPrecio: \$8.50'),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.purple[200]),
              onPressed: () {
                Navigator.pushNamed(context, '/confirmation');
              },
              child: Text('Enviar por WhatsApp'),
            ),
            SizedBox(height: 10),
            OutlinedButton(
              style: OutlinedButton.styleFrom(backgroundColor: Colors.purple[50]),
              onPressed: () {},
              child: Text('Guardar diseño'),
            ),
          ],
        ),
      ),
    );
  }
}
