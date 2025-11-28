import 'package:flutter/material.dart';
import 'FullScreenImage.dart';

class MisDisenos extends StatelessWidget {
  final List<Map<String, dynamic>> disenos = [
    {
      'imagenes': [
        'assets/disenos/personalizado15cm_1.jpeg',
        'assets/disenos/personalizado15cm_2.jpeg',
      ],
      'nombre': 'Bastonera personalizada',
      'descripcion': 'Es uno de los personalizados de 15cm',
      'precio': 18,
    },
    {
      'imagenes': [
        'assets/disenos/ramo1.jpeg',
        'assets/disenos/ramo2.jpeg',
        'assets/disenos/ramo3.jpeg',
      ],
      'nombre': 'Ramo totalmente tejido',
      'descripcion': 'Hecho con lana bambino',
      'precio': 35,
    },
    {
      'imagenes': [
        'assets/disenos/llaveros1.jpeg',
        'assets/disenos/llaveros2.jpeg',
        'assets/disenos/llaveros3.jpeg',
        'assets/disenos/llaveros4.jpeg',
      ],
      'nombre': 'Llaveros tejidos',
      'descripcion': 'Modelos variados tejidos a crochet',
      'precio': 10,
    }
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mis Diseños'),
        backgroundColor: Colors.purple[400],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView.builder(
          itemCount: disenos.length,
          itemBuilder: (context, index) {
            final item = disenos[index];

            return Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              color: Colors.purple[50],
              margin: EdgeInsets.only(bottom: 20),
              elevation: 5,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // ---- CARRUSEL CON TOQUE PARA FULLSCREEN ----
                    SizedBox(
                      height: 220,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: PageView(
                          children: item['imagenes']
                              .map<Widget>(
                                (img) => GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => FullScreenImage(
                                          imagePath: img,
                                          designName: item['nombre'],
                                        ),
                                      ),
                                    );
                                  },
                                  child: Image.asset(
                                    img,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                      ),
                    ),

                    SizedBox(height: 16),

                    Text(
                      item['nombre'],
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.purple[800],
                      ),
                    ),

                    SizedBox(height: 8),

                    Text(
                      item['descripcion'],
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.purple[700],
                      ),
                    ),

                    SizedBox(height: 12),

                    Text(
                      '\$${item['precio'].toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.purple[900],
                      ),
                    ),

                    SizedBox(height: 16),

                    // ---- BOTÓN MORADO ----
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple[400],
                        foregroundColor: Colors.white,
                        padding:
                            EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        // Puedes programar que haga algo
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Interesada en ${item['nombre']}'),
                          ),
                        );
                      },
                      child: Text("Me interesa"),
                    )
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
