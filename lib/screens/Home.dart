import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../widgets/ProductCard.dart';
import '../widgets/custom_drawer.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  User? currentUser;
  Map<String, dynamic>? userData;

  @override
  void initState() {
    super.initState();
    currentUser = FirebaseAuth.instance.currentUser;
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    if (currentUser != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser!.uid)
          .get();

      setState(() {
        userData = userDoc.data() as Map<String, dynamic>?;
      });
    }
  }

  /// -----------------------
  /// CRUD helpers (Firestore)
  /// -----------------------

  // Actualiza campos 'name' y 'email' en el documento del usuario (no Auth).
  Future<void> _updateUserDoc(String uid, String name, String email) async {
    await FirebaseFirestore.instance.collection('users').doc(uid).update({
      'name': name,
      'email': email,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // Elimina doc de Firestore y trata de eliminar la imagen asociada en Storage.
  Future<void> _deleteUserDoc(String uid) async {
    final storageRef = FirebaseStorage.instance.ref().child('profile_images/$uid.jpg');
    try {
      // intenta borrar la imagen (si existe)
      await storageRef.delete();
    } catch (e) {
      // si no existe, ignoramos (Storage lanzará excepción si no hay objeto).
      // print('No existe imagen para borrar: $e');
    }

    // borrar documento
    await FirebaseFirestore.instance.collection('users').doc(uid).delete();
  }

  // Muestra un diálogo para editar nombre / email
  Future<void> _showEditDialog(BuildContext context, String uid, String currentName, String currentEmail) async {
    final _nameController = TextEditingController(text: currentName);
    final _emailController = TextEditingController(text: currentEmail);
    bool _saving = false;

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(builder: (context, setStateDialog) {
        return AlertDialog(
          title: const Text('Editar usuario'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Nombre'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Correo'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: _saving ? null : () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.purple[200]),
              onPressed: _saving
                  ? null
                  : () async {
                      final newName = _nameController.text.trim();
                      final newEmail = _emailController.text.trim();
                      if (newName.isEmpty || newEmail.isEmpty || !newEmail.contains('@')) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Nombre o correo inválido'), backgroundColor: Colors.purple),
                        );
                        return;
                      }

                      setStateDialog(() => _saving = true);
                      try {
                        await _updateUserDoc(uid, newName, newEmail);
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Usuario actualizado'), backgroundColor: Colors.purple),
                          );
                        }
                        Navigator.pop(context);
                      } catch (e) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Error al actualizar: $e'), backgroundColor: Colors.red),
                          );
                        }
                        setStateDialog(() => _saving = false);
                      }
                    },
              child: _saving ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Text('Guardar'),
            )
          ],
        );
      }),
    );
  }

  // Confirm deletion dialog
  Future<void> _confirmAndDelete(BuildContext context, String uid, String name) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar usuario'),
        content: Text('¿Eliminar $name? Esto borrará su documento y la imagen (si existe). No elimina la cuenta de Auth.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _deleteUserDoc(uid);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Usuario eliminado'), backgroundColor: Colors.purple),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al eliminar: $e'), backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  /// -----------------------
  /// UI
  /// -----------------------
  @override
  Widget build(BuildContext context) {
    String name = userData?['name'] ?? 'Usuario';
    String profileUrl = userData?['profileImage'] ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Crea tu Magia 💕',
          style: TextStyle(fontFamily: 'Poppins'),
        ),
        backgroundColor: Colors.purple[200],
      ),
      drawer: const CustomDrawer(), // Drawer personalizado
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 25),
            // 🔹 Encabezado con saludo e imagen del usuario
            if (userData != null)
              Column(
                children: [
                  CircleAvatar(
                    radius: 45,
                    backgroundColor: Colors.purple[100],
                    backgroundImage: profileUrl.isNotEmpty
                        ? NetworkImage(profileUrl)
                        : const AssetImage('assets/images/default_avatar.png') as ImageProvider,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '¡Hola, $name 👋!',
                    style: const TextStyle(
                      fontSize: 20,
                      color: Colors.purple,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  const SizedBox(height: 18),
                ],
              ),

            // 🔹 Contenido principal (tarjetas de productos)
            Wrap(
              spacing: 16,
              runSpacing: 16,
              alignment: WrapAlignment.center,
              children: [
                ProductCard(
                  title: 'Amigurumi',
                  icon: Icons.toys,
                  width: 120,
                  height: 120,
                  onTap: () => Navigator.pushNamed(
                    context,
                    '/customize',
                    arguments: {'product': 'Amigurumi'},
                  ),
                ),
                ProductCard(
                  title: 'Pulsera',
                  icon: Icons.brush,
                  width: 120,
                  height: 120,
                  onTap: () => Navigator.pushNamed(
                    context,
                    '/customize',
                    arguments: {'product': 'Pulsera'},
                  ),
                ),
                ProductCard(
                  title: 'Papercraft',
                  icon: Icons.cut,
                  width: 120,
                  height: 120,
                  onTap: () => Navigator.pushNamed(
                    context,
                    '/customize',
                    arguments: {'product': 'Papercraft'},
                  ),
                ),
              ],
            ),

            const SizedBox(height: 30),

            // ---------------------------
            // PANEL CRUD: Usuarios (Firestore)
            // ---------------------------
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFFF8F2FA),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.purple.shade50),
                ),
                child: Column(
                  children: [
                    ListTile(
                      title: const Text('Administrar usuarios', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF6A1B9A))),
                      subtitle: const Text('Editar o eliminar documentos de la colección users'),
                      trailing: IconButton(
                        icon: const Icon(Icons.refresh),
                        onPressed: () {
                          fetchUserData();
                        },
                      ),
                    ),
                    const Divider(),

                    // StreamBuilder que lista usuarios de la colección 'users'
                    StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance.collection('users').orderBy('createdAt', descending: true).snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Center(child: CircularProgressIndicator(color: Colors.purple)),
                          );
                        }

                        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                          return const Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Text('No hay usuarios registrados.'),
                          );
                        }

                        final docs = snapshot.data!.docs;

                        return ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: docs.length,
                          separatorBuilder: (_, __) => const Divider(),
                          itemBuilder: (context, index) {
                            final doc = docs[index];
                            final data = doc.data() as Map<String, dynamic>;
                            final docName = data['name'] ?? 'Usuario';
                            final docEmail = data['email'] ?? '';
                            final docProfile = data['profileImage'] ?? '';

                            return ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Colors.purple[100],
                                backgroundImage: docProfile.isNotEmpty ? NetworkImage(docProfile) as ImageProvider : null,
                                child: docProfile.isEmpty ? const Icon(Icons.person, color: Colors.white) : null,
                              ),
                              title: Text(docName, style: const TextStyle(fontWeight: FontWeight.w600)),
                              subtitle: Text(docEmail),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    tooltip: 'Editar documento (Firestore)',
                                    icon: const Icon(Icons.edit, color: Colors.orange),
                                    onPressed: () => _showEditDialog(context, doc.id, docName, docEmail),
                                  ),
                                  IconButton(
                                    tooltip: 'Eliminar documento y su imagen en Storage',
                                    icon: const Icon(Icons.delete, color: Colors.redAccent),
                                    onPressed: () => _confirmAndDelete(context, doc.id, docName),
                                  ),
                                ],
                              ),
                              onTap: () {
                                // Al tocar, podemos navegar al profile del usuario si quieres
                                // por ahora solo mostramos detalles rápidos
                                showModalBottomSheet(
                                  context: context,
                                  builder: (_) => Container(
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            CircleAvatar(
                                              radius: 30,
                                              backgroundImage: docProfile.isNotEmpty ? NetworkImage(docProfile) as ImageProvider : null,
                                              backgroundColor: Colors.purple[100],
                                              child: docProfile.isEmpty ? const Icon(Icons.person, color: Colors.white) : null,
                                            ),
                                            const SizedBox(width: 12),
                                            Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(docName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                                Text(docEmail),
                                              ],
                                            )
                                          ],
                                        ),
                                        const SizedBox(height: 12),
                                        Text('ID: ${doc.id}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                                        const SizedBox(height: 12),
                                        Row(
                                          children: [
                                            ElevatedButton.icon(
                                              style: ElevatedButton.styleFrom(backgroundColor: Colors.purple[200]),
                                              onPressed: () {
                                                Navigator.pop(context);
                                                _showEditDialog(context, doc.id, docName, docEmail);
                                              },
                                              icon: const Icon(Icons.edit),
                                              label: const Text('Editar'),
                                            ),
                                            const SizedBox(width: 8),
                                            OutlinedButton.icon(
                                              onPressed: () {
                                                Navigator.pop(context);
                                                _confirmAndDelete(context, doc.id, docName);
                                              },
                                              icon: const Icon(Icons.delete, color: Colors.redAccent),
                                              label: const Text('Eliminar', style: TextStyle(color: Colors.redAccent)),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
