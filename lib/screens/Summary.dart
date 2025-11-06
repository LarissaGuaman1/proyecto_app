import 'package:flutter/material.dart';

class Summary extends StatelessWidget {
  final String product;
  final Color color;
  final String material;
  final double size;
  final String character;

  const Summary({
    super.key,
    required this.product,
    required this.color,
    required this.material,
    required this.size,
    required this.character,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Resumen del pedido'),
        backgroundColor: Colors.purple[200],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
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
                  'Color: ${color.toString()}\n'
                  'Material: $material\n'
                  'Tamaño: ${size.toInt()} cm\n'
                  'Personaje: ${character.isEmpty ? "Ninguno" : character}\n'
                  'Precio: \$8.50',
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.purple[200]),
              onPressed: () {
                Navigator.pushNamed(context, '/confirmation');
              },
              child: const Text('Enviar por WhatsApp'),
            ),
            const SizedBox(height: 10),
            OutlinedButton(
              style: OutlinedButton.styleFrom(backgroundColor: Colors.purple[50]),
              onPressed: () {},
              child: const Text('Guardar diseño'),
            ),
          ],
        ),
      ),
    );
  }
}
