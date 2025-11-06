import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final _formKey = GlobalKey<FormState>();
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  String name = '';
  String email = '';
  String password = '';
  File? profileImage;

  bool isLoading = false;

  Future<void> pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        profileImage = File(pickedFile.path);
      });
    }
  }

  Future<String?> uploadProfileImage(String uid) async {
    if (profileImage == null) return null;

    final ref = FirebaseStorage.instance
        .ref()
        .child('profile_images')
        .child('$uid.jpg');

    await ref.putFile(profileImage!);
    return await ref.getDownloadURL();
  }

  Future<void> registerUser() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      isLoading = true;
    });

    try {
      // Crear usuario con Firebase Auth
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
          email: email.trim(), password: password.trim());
      final uid = userCredential.user!.uid;

      // Subir imagen de perfil si existe
      String? profileUrl = await uploadProfileImage(uid);

      // Guardar datos en Firestore
      await _firestore.collection('users').doc(uid).set({
        'name': name,
        'email': email,
        'profileImage': profileUrl ?? '',
      });

      // Ir a Home
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/home');
      }
    } on FirebaseAuthException catch (e) {
      String message = 'Error al registrarse';
      if (e.code == 'email-already-in-use') {
        message = 'El correo ya está registrado';
      } else if (e.code == 'weak-password') {
        message = 'La contraseña es muy débil';
      }
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(message)));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registrarse')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                GestureDetector(
                  onTap: pickImage,
                  child: CircleAvatar(
                    radius: 50,
                    backgroundImage:
                        profileImage != null ? FileImage(profileImage!) : null,
                    child: profileImage == null
                        ? const Icon(Icons.person, size: 50)
                        : null,
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Nombre'),
                  onChanged: (val) => name = val,
                  validator: (val) =>
                      val == null || val.isEmpty ? 'Ingresa tu nombre' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Correo'),
                  keyboardType: TextInputType.emailAddress,
                  onChanged: (val) => email = val,
                  validator: (val) =>
                      val == null || !val.contains('@') ? 'Correo inválido' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Contraseña'),
                  obscureText: true,
                  onChanged: (val) => password = val,
                  validator: (val) =>
                      val == null || val.length < 6 ? 'Mínimo 6 caracteres' : null,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: isLoading ? null : registerUser,
                  child: isLoading
                      ? const CircularProgressIndicator(
                          color: Colors.white,
                        )
                      : const Text('Registrarse'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, '/login');
                  },
                  child: const Text('¿Ya tienes cuenta? Inicia sesión'),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
