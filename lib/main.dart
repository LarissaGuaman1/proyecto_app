import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:proyecto/firebase_options_web.dart';
import 'package:proyecto/screens/MisDise%C3%B1os.dart';

import 'screens/Login.dart';
import 'screens/Register.dart';
import 'screens/Home.dart';
import 'screens/Customize.dart';
import 'screens/Summary.dart';
import 'screens/Confirmation.dart';
import 'screens/Contactar.dart';
import 'screens/Configuracion.dart';
import 'screens/CerrarSesion.dart';
import 'screens/Preview.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(DanaheApp());
}

class DanaheApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Danahe’s Magical Crafts",
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.purple,
        scaffoldBackgroundColor: const Color(0xFFFFF7F0),
        fontFamily: 'Poppins',
      ),
      initialRoute: '/login',
      onGenerateRoute: (settings) {
        final args = settings.arguments;

        switch (settings.name) {
          case '/login':
            return MaterialPageRoute(builder: (_) => Login());
          case '/register':
            return MaterialPageRoute(builder: (_) => Register());
          case '/home':
            return MaterialPageRoute(builder: (_) => Home());
          case '/customize':
            if (args is Map<String, dynamic>) {
              final product = args['product'] ?? '';
              return MaterialPageRoute(
                  builder: (_) => Customize(product: product));
            }
            return _errorRoute('Error al abrir Customize');
          case '/preview':
            if (args is Map<String, dynamic>) {
              return MaterialPageRoute(
                  builder: (_) => Preview(
                        product: args['product'] ?? '',
                        color: args['color'] ?? Colors.purple,
                        character: args['character'] ?? '',
                        size: args['size'] ?? 0,
                      ));
            }
            return _errorRoute('Error al abrir Preview');
          case '/summary':
            if (args is Map<String, dynamic>) {
              return MaterialPageRoute(
                builder: (_) => Summary(
                  product: args['product'] ?? '',
                  color: args['color'] ?? Colors.purple,
                  material: args['material'] ?? 'Lana bambino',
                  size: (args['size'] ?? 0).toDouble(),
                  character: args['character'] ?? '',
                ),
              );
            }
            return _errorRoute('Error al abrir Summary');
          case '/confirmation':
            return MaterialPageRoute(builder: (_) => Confirmation());
          case '/misdisenos':
            return MaterialPageRoute(builder: (_) => MisDisenos());
          case '/contactar':
            return MaterialPageRoute(builder: (_) => Contactar());
          case '/configuracion':
            return MaterialPageRoute(builder: (_) => Configuracion());
          case '/cerrarsesion':
            return MaterialPageRoute(builder: (_) => CerrarSesion());
          default:
            return _errorRoute('Ruta desconocida: ${settings.name}');
        }
      },
    );
  }

  Route _errorRoute(String message) {
    return MaterialPageRoute(
      builder: (_) => Scaffold(
        backgroundColor: const Color(0xFFFFF7F0),
        appBar: AppBar(
          backgroundColor: Colors.purple[200],
          title: const Text('Error'),
        ),
        body: Center(
          child: Text(
            message,
            style: const TextStyle(
              color: Colors.purple,
              fontSize: 18,
              fontFamily: 'Poppins',
            ),
          ),
        ),
      ),
    );
  }
}
