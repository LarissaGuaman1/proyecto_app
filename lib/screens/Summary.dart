import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

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

  // 📲 Enviar WhatsApp
  Future<void> sendWhatsApp() async {
    const String phone = "593960650877";

    final String message =
        "Hola! Quiero hacer un pedido personalizado ❤️\n"
        "Producto: $product\n"
        "Color: $color\n"
        "Material: $material\n"
        "Tamaño: ${size.toInt()} cm\n"
        "Personaje: ${character.isEmpty ? "Ninguno" : character}\n";

    final String url =
        "https://wa.me/$phone?text=${Uri.encodeComponent(message)}";

    await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
  }

  // 💾 Guardar diseño en Firestore
  Future<void> saveDesign(BuildContext context) async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Debes iniciar sesión para guardar el diseño")),
      );
      return;
    }

    try {
      await FirebaseFirestore.instance.collection('designs').add({
        'uid': user.uid,
        'product': product,
        'color': color.value,
        'material': material,
        'size': size,
        'character': character,
        'createdAt': DateTime.now(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Diseño guardado 💖"),
          backgroundColor: Colors.purple[200],
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error al guardar: $e")),
      );
    }
  }

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
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 3,
              child: ListTile(
                leading: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                title: Text(
                  '$product personalizado',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.purple[900],
                  ),
                ),
                subtitle: Text(
                  'Color: $color\n'
                  'Material: $material\n'
                  'Tamaño: ${size.toInt()} cm\n'
                  'Personaje: ${character.isEmpty ? "Ninguno" : character}\n',
                ),
              ),
            ),

            const SizedBox(height: 25),

            // 🌙 BOTÓN WHATSAPP (MORADO PASTEL)
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple[300],
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 55),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onPressed: sendWhatsApp,
              child: const Text(
                'Enviar por WhatsApp 💬',
                style: TextStyle(fontSize: 16),
              ),
            ),

            const SizedBox(height: 14),

            // 🌙 BOTÓN GUARDAR DISEÑO (MORADO PASTEL)
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple[400],
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 55),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onPressed: () => saveDesign(context),
              child: const Text(
                'Guardar diseño 💜',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
