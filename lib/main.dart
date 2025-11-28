import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:proyecto/firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';

// 🔹 Pantallas
import 'screens/Login.dart';
import 'screens/Register.dart';
import 'screens/Home.dart';
import 'screens/Customize.dart';
import 'screens/Summary.dart';
import 'screens/Confirmation.dart';
import 'screens/Contactar.dart';
import 'screens/Configuracion.dart';
import 'screens/CerrarSesion.dart';
import 'screens/MisDiseños.dart';
import 'screens/Preview.dart';
import 'screens/profile_page.dart';

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

      // 🔥 Manejo automático de sesión
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasData) {
            return const Home();
          } else {
            return const Login();
          }
        },
      ),

      onGenerateRoute: (settings) {
        final args = settings.arguments;

        switch (settings.name) {
          case '/login':
            return MaterialPageRoute(builder: (_) => const Login());

          case '/register':
            return MaterialPageRoute(builder: (_) => const Register());

          case '/home':
            return MaterialPageRoute(builder: (_) => const Home());

          case '/customize':
            if (args is Map<String, dynamic>) {
              return MaterialPageRoute(
                builder: (_) => Customize(product: args['product']),
              );
            }
            return _error("Error: No se pudo abrir Customize");

          case '/preview':
            if (args is Map<String, dynamic>) {
              return MaterialPageRoute(
                builder: (_) => Preview(
                  product: args['product'],
                  color: args['color'],
                  character: args['character'],
                  size: args['size'],
                ),
              );
            }
            return _error("Error al abrir Preview");

          case '/summary':
            if (args is Map<String, dynamic>) {
              return MaterialPageRoute(
                builder: (_) => Summary(
                  product: args['product'],
                  color: args['color'],
                  material: args['material'],
                  size: args['size'],
                  character: args['character'],
                ),
              );
            }
            return _error("Error en Summary");

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

          case '/perfil':
            return MaterialPageRoute(builder: (_) => const ProfilePage());

          default:
            return _error("Ruta no encontrada");
        }
      },
    );
  }

  Route _error(String message) {
    return MaterialPageRoute(
      builder: (_) => Scaffold(
        appBar: AppBar(title: const Text("Error")),
        body: Center(child: Text(message)),
      ),
    );
  }
}
