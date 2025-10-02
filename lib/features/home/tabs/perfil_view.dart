import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PerfilView extends StatelessWidget {
  const PerfilView({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 40),
            const Text(
              'Mi Perfil',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const Text(
              'Gestiona tu información personal.',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            _buildProfilePhotoSection(user),
            const SizedBox(height: 24),
            _buildPersonalInfoSection(user),
            const SizedBox(height: 24),
            _buildLogoutButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildProfilePhotoSection(User? user) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Foto de perfil',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Text(
              'Personaliza tu imagen de usuario',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.grey[300],
                    backgroundImage: user?.photoURL != null
                        ? NetworkImage(user!.photoURL!)
                        : null,
                    child: user?.photoURL == null
                        ? const Icon(Icons.person, size: 50, color: Colors.grey)
                        : null,
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () {
                      // Aquí puedes agregar lógica para cambiar foto
                    },
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.grey[200],
                    ),
                    child: const Text('Cambiar imagen'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPersonalInfoSection(User? user) {
    final nameController = TextEditingController(text: user?.displayName ?? '');
    final emailController = TextEditingController(text: user?.email ?? '');

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Información personal',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Text(
              'Actualiza tus datos personales',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            _buildTextField('Nombre completo', nameController),
            const SizedBox(height: 12),
            _buildTextField(
              'Correo Electrónico',
              emailController,
              enabled: false,
            ), // No editable
            const SizedBox(height: 12),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  // Aquí puedes agregar lógica para actualizar nombre o teléfono
                  print('Guardando cambios...');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Guardar cambios'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    bool enabled = true,
  }) {
    return TextField(
      controller: controller,
      enabled: enabled,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return Center(
      child: ElevatedButton(
        onPressed: () async {
          await FirebaseAuth.instance.signOut();
          Navigator.pushReplacementNamed(context, '/login');
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
        ),
        child: const Text('Cerrar sesión'),
      ),
    );
  }
}
