import 'package:flutter/material.dart';

class Preview extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Recibir los argumentos enviados desde Customize
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final String product = args['product'];
    final Color color = args['color'];
    final String material = args['material'];
    final double size = args['size'];

    return Scaffold(
      appBar: AppBar(
        title: Text('Vista previa'),
        backgroundColor: Colors.purple[200],
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Text(
                    'Producto: $product\nMaterial: $material\nTamaño: ${size.toInt()} cm',
                    style: TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                OutlinedButton(
                  style: OutlinedButton.styleFrom(backgroundColor: Colors.purple[50]),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('Editar'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.purple[200]),
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      '/summary',
                      arguments: {
                        'product': product,
                        'color': color,
                        'material': material,
                        'size': size,
                      },
                    );
                  },
                  child: Text('Confirmar diseño 💌'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
