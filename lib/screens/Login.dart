import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isLoading = false;

  Future<void> loginUser() async {
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Por favor ingresa correo y contraseña'),
          backgroundColor: Colors.purple[200],
        ),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );
      // Redirige a Home
      Navigator.pushReplacementNamed(context, '/home');
    } on FirebaseAuthException catch (e) {
      String message = '';
      if (e.code == 'user-not-found') {
        message = 'Usuario no encontrado';
      } else if (e.code == 'wrong-password') {
        message = 'Contraseña incorrecta';
      } else {
        message = 'Error: ${e.message}';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.purple[200],
        ),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF7F0),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                "/src/flutter/examples/Cuarto/proyecto/lib/assets/images/logo.png", 
                height: 120,
              ),
              const SizedBox(height: 30),
              TextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'Correo electrónico',
                  filled: true,
                  fillColor: Colors.purple[50],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Contraseña',
                  filled: true,
                  fillColor: Colors.purple[50],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: isLoading ? null : loginUser,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple[200],
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: isLoading
                          ? const CircularProgressIndicator(
                              color: Colors.white,
                            )
                          : const Text('Ingresar', style: TextStyle(fontSize: 18)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/register');
                      },
                      style: OutlinedButton.styleFrom(
                        backgroundColor: Colors.purple[50],
                        minimumSize: const Size(double.infinity, 50),
                        side: BorderSide(color: Colors.purple.shade200),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Registrar', style: TextStyle(fontSize: 18)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Salir de la app'),
                      content: const Text('¿Seguro que quieres salir?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancelar'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text(
                            'Salir',
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    ),
                  );
                },
                child: Text(
                  'Salir',
                  style: TextStyle(color: Colors.purple[400]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
