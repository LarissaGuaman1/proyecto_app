import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class FullScreenImage extends StatelessWidget {
  final String imagePath;
  final String designName;

  const FullScreenImage({
    super.key,
    required this.imagePath,
    required this.designName,
  });

  Future<void> enviarWhatsApp() async {
    final numero = "593960650877";
    final mensaje = Uri.encodeComponent(
      "Hola 💜 me gustaría algo parecido al diseño: $designName"
    );

    final url = "https://wa.me/$numero?text=$mensaje";

    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: InteractiveViewer(
                child: Image.asset(imagePath),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple[300],
                minimumSize: Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: enviarWhatsApp,
              child: Text(
                "Quiero algo parecido 💌",
                style: TextStyle(fontSize: 18),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
