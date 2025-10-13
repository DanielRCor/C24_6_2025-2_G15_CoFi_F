// Tab Grupos
import 'package:flutter/material.dart';
import 'create_group_page.dart';

class GruposView extends StatefulWidget {
  const GruposView({super.key});

  @override
  State<GruposView> createState() => _GruposViewState();
}

class _GruposViewState extends State<GruposView> {
  final List<String> _groups = [];

  Future<void> _onCreateGroupPressed() async {
    final result = await Navigator.of(
      context,
    ).push<String>(MaterialPageRoute(builder: (_) => const CreateGroupPage()));

    if (result != null && result.trim().isNotEmpty) {
      setState(() {
        _groups.add(result.trim());
      });
      // Mostrar confirmación
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Grupo "${result.trim()}" creado')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Título principal
          const Text(
            'Mis Grupos',
            style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 2),
          // Subtítulo
          const Text(
            'Gestiona tus gastos compartidos',
            style: TextStyle(
              fontSize: 16,
              color: Colors.black38,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 28),
          // Invitaciones pendientes
          const Text(
            'Invitaciones Pendientes',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 28),
          // Texto: Todavía no tienes invitaciones
          const Center(
            child: Text(
              'Todavía no tienes invitaciones',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
          const SizedBox(height: 40),
          // Botón Crear Nuevo Grupo
          Center(
            child: OutlinedButton.icon(
              onPressed: _onCreateGroupPressed,
              icon: Icon(Icons.add, color: Colors.orange[700]),
              label: const Text(
                'Crear Nuevo Grupo',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  fontSize: 16,
                ),
              ),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: Colors.orange.shade200, width: 1.4),
                minimumSize: const Size(260, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                backgroundColor: Colors.white,
                foregroundColor: Colors.orange,
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                textStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          const SizedBox(height: 40),
          // Mostrar lista de grupos o texto cuando no hay
          if (_groups.isEmpty)
            const Center(
              child: Text(
                'Todavía no tienes Grupos',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            )
          else
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Mis grupos creados',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _groups.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final name = _groups[index];
                    return Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        title: Text(
                          name,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: const Text('0 miembros • 0 gastos'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          // Acción futura: abrir detalles del grupo
                        },
                      ),
                    );
                  },
                ),
              ],
            ),
        ],
      ),
    );
  }
}
