import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class Confirmation extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.asset("/src/flutter/examples/Cuarto/proyecto/lib/assets/lottie/success.json", width: 150),
            SizedBox(height: 20),
            Text(
              '¡Pedido enviado con éxito!',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.purple[800]),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 10),
            Text(
              'Danahe te contactará pronto 💕',
              style: TextStyle(fontSize: 16, color: Colors.purple[600]),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.purple[200]),
              onPressed: () {
                Navigator.pushNamedAndRemoveUntil(
                    context, '/home', (route) => false);
              },
              child: Text('Volver al inicio'),
            ),
          ],
        ),
      ),
    );
  }
}
