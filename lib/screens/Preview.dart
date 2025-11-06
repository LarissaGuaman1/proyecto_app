import 'package:flutter/material.dart';

class Preview extends StatelessWidget {
  final String product;
  final Color color;
  final String character;
  final int size;

  const Preview({
    super.key,
    required this.product,
    required this.color,
    required this.character,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8E8FF), // Fondo pastel suave 💜
      appBar: AppBar(
        title: Text(
          'Vista previa de $product',
          style: const TextStyle(fontFamily: 'Poppins', color: Colors.white),
        ),
        backgroundColor: Colors.purple[200],
        elevation: 4,
        shadowColor: Colors.purpleAccent.withOpacity(0.3),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagen o vista del producto
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                color: color.withOpacity(0.6),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.purple.withOpacity(0.2),
                    blurRadius: 10,
                    spreadRadius: 3,
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  product,
                  style: const TextStyle(
                    fontSize: 24,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 25),

            // Información del pedido
            Card(
              color: Colors.white,
              elevation: 3,
              shadowColor: Colors.purple.withOpacity(0.2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('🧵 Producto: $product',
                        style: const TextStyle(fontFamily: 'Poppins')),
                    const SizedBox(height: 6),
                    Text('🎨 Color elegido: ${color.toString()}',
                        style: const TextStyle(fontFamily: 'Poppins')),
                    const SizedBox(height: 6),
                    Text(
                      '✨ Personaje: ${character.isEmpty ? "Ninguno" : character}',
                      style: const TextStyle(fontFamily: 'Poppins'),
                    ),
                    const SizedBox(height: 6),
                    Text('📏 Tamaño: $size cm',
                        style: const TextStyle(fontFamily: 'Poppins')),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 40),

            // Botón Confirmar
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple[200],
                  padding:
                      const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  elevation: 4,
                ),
                onPressed: () {
                  // Navegación segura con argumentos válidos
                  Navigator.pushNamed(
                    context,
                    '/summary',
                    arguments: {
                      'product': product,
                      'color': color,
                      'material': 'Lana bambino',
                      'size': size.toDouble(),
                      'character': character,
                    },
                  );
                },
                child: const Text(
                  'Confirmar pedido 💖',
                  style: TextStyle(
                    fontSize: 18,
                    fontFamily: 'Poppins',
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
