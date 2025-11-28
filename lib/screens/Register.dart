import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/foundation.dart';
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

  Uint8List? webImage;
  XFile? pickedFile;

  bool isLoading = false;

  //------------------------------------------------
  // 📌 SELECCIONAR IMAGEN
  //------------------------------------------------
  Future<void> pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      final bytes = await image.readAsBytes();
      setState(() {
        webImage = bytes;
        pickedFile = image;
      });
    }
  }

  //------------------------------------------------
  // 📌 SUBIR IMAGEN (WEB + ANDROID)
  //------------------------------------------------
  Future<String?> uploadProfileImage(String uid) async {
    if (pickedFile == null && webImage == null) {
      print("⚠ No hay imagen seleccionada.");
      return null;
    }

    try {
      // Detectar extensión real
      String ext = pickedFile != null
          ? pickedFile!.name.split('.').last
          : 'jpg';

      final ref = FirebaseStorage.instance
          .ref()
          .child('profile_images/$uid.$ext');

      UploadTask uploadTask;

      if (kIsWeb) {
        // Para Web
        uploadTask = ref.putData(
          webImage!,
          SettableMetadata(contentType: 'image/$ext'),
        );
      } else {
        // Para Android
        final File file = File(pickedFile!.path);

        if (!await file.exists()) {
          print("❌ ERROR: archivo no existe en Android");
          return null;
        }

        uploadTask = ref.putFile(
          file,
          SettableMetadata(contentType: 'image/$ext'),
        );
      }

      final snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();

    } catch (e) {
      print("❌ Error subiendo imagen: $e");
      return null;
    }
  }

  //------------------------------------------------
  // 📌 REGISTRAR USUARIO
  //------------------------------------------------
  Future<void> registerUser() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    try {
      print("🔵 Creando usuario...");

      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      final uid = userCredential.user!.uid;

      print("🟣 Subiendo imagen...");
      String? profileUrl = await uploadProfileImage(uid);

      print("🟢 Guardando datos en Firestore...");

      await _firestore.collection('users').doc(uid).set({
        'uid': uid,
        'name': name,
        'email': email,
        'profileImage': profileUrl ?? '',
        'role': 'user',
        'createdAt': DateTime.now(),
        'lastLogin': DateTime.now(),
      });

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

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));

      print("❌ FirebaseAuthException: ${e.code}");
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));

      print("❌ Error general: $e");
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  //------------------------------------------------
  // 📌 UI
  //------------------------------------------------
  @override
  Widget build(BuildContext context) {
    final imageWidget = webImage != null
        ? CircleAvatar(radius: 50, backgroundImage: MemoryImage(webImage!))
        : const CircleAvatar(
            radius: 50,
            backgroundColor: Color(0xFFE1BEE7),
            child: Icon(Icons.person, size: 50, color: Colors.white),
          );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Registrarse'),
        backgroundColor: Colors.purple[200],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                GestureDetector(
                  onTap: pickImage,
                  child: imageWidget,
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
                  onChanged: (val) => email = val,
                  validator: (val) =>
                      val != null && val.contains('@')
                          ? null
                          : 'Correo inválido',
                ),
                const SizedBox(height: 16),

                TextFormField(
                  decoration: const InputDecoration(labelText: 'Contraseña'),
                  obscureText: true,
                  onChanged: (val) => password = val,
                  validator: (val) =>
                      val != null && val.length >= 6
                          ? null
                          : 'Mínimo 6 caracteres',
                ),
                const SizedBox(height: 24),

                ElevatedButton(
                  onPressed: isLoading ? null : registerUser,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple[200],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Registrarse'),
                ),

                TextButton(
                  onPressed: () =>
                      Navigator.pushReplacementNamed(context, '/login'),
                  child: const Text('¿Ya tienes cuenta? Inicia sesión'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
