import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class Contactar extends StatefulWidget {
  @override
  State<Contactar> createState() => _ContactarState();
}

class _ContactarState extends State<Contactar> {
  final TextEditingController nameCtrl = TextEditingController();
  final TextEditingController emailCtrl = TextEditingController();
  final TextEditingController messageCtrl = TextEditingController();

  // 📲 Función corregida para enviar WhatsApp
  Future<void> sendToWhatsApp() async {
    final String name = nameCtrl.text.trim();
    final String email = emailCtrl.text.trim();
    final String message = messageCtrl.text.trim();

    const String phone = "593960650877";

    final String whatsappMessage =
        "Hola, soy $name.\nCorreo: $email\n\nMensaje:\n$message";

    final Uri url = Uri.parse(
      "https://wa.me/$phone?text=${Uri.encodeComponent(whatsappMessage)}",
    );

    try {
      bool launched = await launchUrl(
        url,
        mode: LaunchMode.externalApplication,
      );

      if (!launched) {
        throw Exception("No se pudo abrir WhatsApp");
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Contactar'),
        backgroundColor: Colors.purple[200],
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              'Contáctanos 💌',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.purple[800],
              ),
            ),
            SizedBox(height: 20),

            // ✏ Nombre
            TextField(
              controller: nameCtrl,
              decoration: InputDecoration(
                labelText: 'Tu nombre',
                filled: true,
                fillColor: Colors.purple[50],
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),

            SizedBox(height: 10),

            // ✉ Correo
            TextField(
              controller: emailCtrl,
              decoration: InputDecoration(
                labelText: 'Correo electrónico',
                filled: true,
                fillColor: Colors.purple[50],
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),

            SizedBox(height: 10),

            // 💬 Mensaje
            TextField(
              controller: messageCtrl,
              maxLines: 5,
              decoration: InputDecoration(
                labelText: 'Mensaje',
                filled: true,
                fillColor: Colors.purple[50],
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),

            SizedBox(height: 20),

            // 📲 BOTÓN WHATSAPP
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple[200],
                minimumSize: Size(double.infinity, 50),
              ),
              onPressed: sendToWhatsApp,
              child: Text('Enviar por WhatsApp'),
            ),
          ],
        ),
      ),
    );
  }
}
