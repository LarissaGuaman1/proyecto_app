import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final user = FirebaseAuth.instance.currentUser!;
  Map<String, dynamic>? userData;
  bool isLoading = true;
  bool saving = false;

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
    setState(() {
      userData = doc.data();
      isLoading = false;
    });
  }

  /// Seleccionar y subir imagen al storage, luego actualizar Firestore
  Future<void> _uploadImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() => saving = true);
      try {
        final file = File(pickedFile.path);
        final storageRef = FirebaseStorage.instance.ref().child('profile_images/${user.uid}.jpg');
        await storageRef.putFile(file);
        final url = await storageRef.getDownloadURL();

        await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
          'profileImage': url,
          'lastUpdated': DateTime.now(),
        });

        setState(() {
          userData?['profileImage'] = url;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Foto actualizada')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error subiendo la imagen: $e')),
        );
      } finally {
        setState(() => saving = false);
      }
    }
  }

  /// Editar nombre (UI dialog)
  Future<void> _editName() async {
    final controller = TextEditingController(text: userData?['name'] ?? '');
    final res = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Editar nombre'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'Nombre'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Guardar')),
        ],
      ),
    );

    if (res == true) {
      final newName = controller.text.trim();
      if (newName.isEmpty) return;
      setState(() => saving = true);
      try {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
          'name': newName,
          'lastUpdated': DateTime.now(),
        });
        setState(() => userData?['name'] = newName);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Nombre actualizado')));
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      } finally {
        setState(() => saving = false);
      }
    }
  }

  /// Reautenticar con contraseña (necesaria para cambios sensibles)
  Future<bool> _reauthenticateWithPassword(String password) async {
    try {
      final cred = EmailAuthProvider.credential(email: user.email ?? '', password: password);
      await user.reauthenticateWithCredential(cred);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Cambiar correo (actualiza Auth y Firestore)
  Future<void> _changeEmail() async {
    final emailController = TextEditingController(text: user.email ?? '');
    final passController = TextEditingController();
    bool needPassword = false;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(builder: (context, setSt) {
        return AlertDialog(
          title: const Text('Cambiar correo'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: emailController, decoration: const InputDecoration(labelText: 'Nuevo correo')),
              const SizedBox(height: 8),
              if (needPassword)
                // ignore: dead_code
                TextField(controller: passController, obscureText: true, decoration: const InputDecoration(labelText: 'Contraseña actual (requerida)')),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
            ElevatedButton(
              onPressed: () async {
                final newEmail = emailController.text.trim();
                if (newEmail.isEmpty) return;
                Navigator.pop(context, true);
              },
              child: const Text('Actualizar'),
            ),
          ],
        );
      }),
    );

    if (result != true) return;
    final newEmail = emailController.text.trim();
    if (newEmail == (user.email ?? '')) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('El correo es el mismo')));
      return;
    }

    setState(() => saving = true);
    try {
      // Intentar actualizar directamente
      await user.updateEmail(newEmail);
      // actualizar en Firestore
      await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
        'email': newEmail,
        'lastUpdated': DateTime.now(),
      });

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Correo actualizado')));
      // Refrescar userData y user (no se puede forzar FirebaseAuth.currentUser() a actualizar email cached; pero en la práctica ya debe reflejarse)
      await fetchUserData();
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        // pedir contraseña para reautenticar
        final pw = await _askForPassword();
        if (pw == null) {
          setState(() => saving = false);
          return;
        }
        final ok = await _reauthenticateWithPassword(pw);
        if (!ok) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Reautenticación fallida')));
          setState(() => saving = false);
          return;
        }
        // reintentar
        try {
          await user.updateEmail(newEmail);
          await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
            'email': newEmail,
            'lastUpdated': DateTime.now(),
          });
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Correo actualizado')));
          await fetchUserData();
        } catch (e2) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error actualizando correo: $e2')));
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: ${e.message}')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() => saving = false);
    }
  }

  /// Mostrar dialog para pedir contraseña (reautenticación)
  Future<String?> _askForPassword() async {
    final controller = TextEditingController();
    final res = await showDialog<String?>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reautenticación'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Por seguridad ingresa tu contraseña actual:'),
            TextField(controller: controller, obscureText: true, decoration: const InputDecoration(labelText: 'Contraseña')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, null), child: const Text('Cancelar')),
          ElevatedButton(onPressed: () => Navigator.pop(context, controller.text), child: const Text('Enviar')),
        ],
      ),
    );
    return res;
  }

  /// Cambiar contraseña
  Future<void> _changePassword() async {
    final passController = TextEditingController();
    final newPassController = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cambiar contraseña'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: passController, obscureText: true, decoration: const InputDecoration(labelText: 'Contraseña actual')),
            const SizedBox(height: 8),
            TextField(controller: newPassController, obscureText: true, decoration: const InputDecoration(labelText: 'Nueva contraseña (mín 6)')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          ElevatedButton(onPressed: () {
            if ((newPassController.text).length < 6) return;
            Navigator.pop(context, true);
          }, child: const Text('Cambiar')),
        ],
      ),
    );

    if (result != true) return;

    setState(() => saving = true);
    try {
      // intentar reautenticando primero con la contraseña actual
      final ok = await _reauthenticateWithPassword(passController.text);
      if (!ok) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Contraseña actual incorrecta')));
        setState(() => saving = false);
        return;
      }
      await user.updatePassword(newPassController.text.trim());
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Contraseña actualizada')));
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        final pw = await _askForPassword();
        if (pw == null) {
          setState(() => saving = false);
          return;
        }
        final ok2 = await _reauthenticateWithPassword(pw);
        if (!ok2) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Reautenticación fallida')));
          setState(() => saving = false);
          return;
        }
        try {
          await user.updatePassword(newPassController.text.trim());
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Contraseña actualizada')));
        } catch (e2) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e2')));
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: ${e.message}')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() => saving = false);
    }
  }

  /// Eliminar la cuenta del usuario actual: elimina storage, firestore doc, y Auth user (si requiere reauth pedirá)
  Future<void> _deleteAccount() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar cuenta'),
        content: const Text('¿Seguro quieres eliminar tu cuenta? Se eliminarán tus datos. Esta acción no se puede deshacer.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Eliminar')),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => saving = true);
    try {
      // borrar imagen en Storage (si existe)
      try {
        final ref = FirebaseStorage.instance.ref().child('profile_images/${user.uid}.jpg');
        await ref.delete();
      } catch (_) {
        // ignore if not exists
      }

      // borrar doc de Firestore
      await FirebaseFirestore.instance.collection('users').doc(user.uid).delete();

      // borrar cuenta Auth (puede requerir reautenticación)
      try {
        await user.delete();
      } on FirebaseAuthException catch (e) {
        if (e.code == 'requires-recent-login') {
          final pw = await _askForPassword();
          if (pw == null) {
            setState(() => saving = false);
            return;
          }
          final ok = await _reauthenticateWithPassword(pw);
          if (!ok) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Reautenticación fallida')));
            setState(() => saving = false);
            return;
          }
          // reintentar delete
          await user.delete();
        } else {
          throw e;
        }
      }

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Cuenta eliminada')));
      // redirigir al login (ya no hay usuario)
      if (context.mounted) {
        Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error eliminando cuenta: $e')));
    } finally {
      setState(() => saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: Colors.purple)),
      );
    }

    final name = userData?['name'] ?? 'Usuario';
    final email = userData?['email'] ?? user.email ?? '';
    final profileUrl = userData?['profileImage'] ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil del usuario'),
        backgroundColor: Colors.purple[200],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: _uploadImage,
                child: CircleAvatar(
                  radius: 70,
                  backgroundColor: Colors.purple[50],
                  backgroundImage: profileUrl.isNotEmpty
                      ? NetworkImage(profileUrl)
                      : const AssetImage('assets/images/default_avatar.png') as ImageProvider,
                  child: profileUrl.isEmpty
                      ? const Icon(Icons.person, size: 70, color: Colors.purple)
                      : null,
                ),
              ),
              const SizedBox(height: 20),
              Text(name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              Text(email, style: const TextStyle(fontSize: 16, color: Colors.grey)),
              const SizedBox(height: 20),

              // Botones de acciones (editar nombre, cambiar correo, cambiar contraseña, eliminar cuenta)
              Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: [
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple[200],
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    ),
                    onPressed: saving ? null : _editName,
                    icon: const Icon(Icons.edit),
                    label: const Text('Editar nombre'),
                  ),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple[200],
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    ),
                    onPressed: saving ? null : _changeEmail,
                    icon: const Icon(Icons.email),
                    label: const Text('Cambiar correo'),
                  ),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple[200],
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    ),
                    onPressed: saving ? null : _changePassword,
                    icon: const Icon(Icons.lock),
                    label: const Text('Cambiar contraseña'),
                  ),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    ),
                    onPressed: saving ? null : _deleteAccount,
                    icon: const Icon(Icons.delete),
                    label: const Text('Eliminar cuenta'),
                  ),
                ],
              ),
              if (saving) const SizedBox(height: 16),
              if (saving) const CircularProgressIndicator(color: Colors.purple),
            ],
          ),
        ),
      ),
    );
  }
}
