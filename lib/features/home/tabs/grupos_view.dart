// Tab Grupos
import 'package:flutter/material.dart';
import '../../../core/services/group_service.dart';
import 'group_detail_page.dart';

class GruposView extends StatefulWidget {
  const GruposView({super.key});

  @override
  State<GruposView> createState() => _GruposViewState();
}

class _GruposViewState extends State<GruposView> {
  final List<Map<String, dynamic>> _groups = [];
  final GroupService _groupService = GroupService();
  bool _isLoading = false;
  String? _error;

  Future<void> _onCreateGroupPressed() async {
    await _showCreateGroupDialog();
  }

  Future<void> _showCreateGroupDialog() async {
    final TextEditingController controller = TextEditingController();
    final formKey = GlobalKey<FormState>();

    final created = await showDialog<String?>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Crear Nuevo Grupo'),
          content: Form(
            key: formKey,
            child: TextFormField(
              controller: controller,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'Nombre del grupo',
                hintText: 'Ej. Viaje con amigos',
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) {
                  return 'Ingresa un nombre válido';
                }
                return null;
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(null),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState?.validate() ?? false) {
                  Navigator.of(context).pop(controller.text.trim());
                }
              },
              child: const Text('Crear'),
            ),
          ],
        );
      },
    );

    if (created != null && created.isNotEmpty) {
      // Attempt to create group via API
      setState(() => _isLoading = true);
      try {
        final resp = await _groupService.createGroup(name: created);
        // Assume API returns created group with 'name' or 'id' fields
        final name = resp['name'] ?? created;
        if (!mounted) return;
        setState(() {
          _groups.insert(0, {'name': name});
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Grupo "$name" creado')));
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error al crear grupo: $e')));
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchGroups();
  }

  Future<void> _fetchGroups() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final data = await _groupService.getUserGroups();
      // Expecting a List of group objects; map to names
      final groups = <Map<String, dynamic>>[];
      for (final item in data) {
        if (item is Map<String, dynamic>) {
          groups.add(item);
        } else if (item is Map) {
          groups.add(Map<String, dynamic>.from(item));
        }
      }
      if (!mounted) return;
      setState(() {
        _groups.clear();
        _groups.addAll(groups);
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
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
          if (_isLoading) const Center(child: CircularProgressIndicator()),
          if (_error != null) ...[
            const SizedBox(height: 12),
            Center(child: Text('Error:')),
            Center(child: Text(_error!)),
            const SizedBox(height: 12),
          ],
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
                    final group = _groups[index];
                    final name = group['name']?.toString() ?? 'Grupo';
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
                          final id =
                              group['id']?.toString() ??
                              group['_id']?.toString();
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => GroupDetailPage(
                                groupId: id,
                                groupData: group,
                              ),
                            ),
                          );
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
