import 'package:flutter/material.dart';
import 'package:proyecto/screens/MisDise%C3%B1os.dart';
import 'screens/Login.dart';
import 'screens/Home.dart';
import 'screens/Customize.dart';
import 'screens/Preview.dart';
import 'screens/Summary.dart';
import 'screens/Confirmation.dart';
import 'screens/Contactar.dart';
import 'screens/Configuracion.dart';
import 'screens/CerrarSesion.dart';

void main() {
  runApp(DanaheApp());
}

class DanaheApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Danahe’s Magical Crafts",
      theme: ThemeData(
        primarySwatch: Colors.purple,
        scaffoldBackgroundColor: Color(0xFFFFF7F0),
        fontFamily: 'Poppins',
      ),
      debugShowCheckedModeBanner: false,
      initialRoute: '/login',
      routes: {
        '/login': (context) => Login(),
        '/home': (context) => Home(),
        '/customize': (context) => Customize(product: ''),
        '/preview': (context) => Preview(),
        '/summary': (context) => Summary(),
        '/confirmation': (context) => Confirmation(),
        '/misdisenos': (context) => MisDisenos(),
        '/contactar': (context) => Contactar(),
        '/configuracion': (context) => Configuracion(),
        '/cerrarsesion': (context) => CerrarSesion(),
      },
    );
  }
}
