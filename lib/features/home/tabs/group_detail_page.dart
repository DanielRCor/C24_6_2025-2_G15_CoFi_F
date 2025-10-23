import 'package:flutter/material.dart';
import '../../../core/services/group_service.dart';

class GroupDetailPage extends StatefulWidget {
  final String? groupId;
  final Map<String, dynamic>? groupData;

  const GroupDetailPage({super.key, required this.groupId, this.groupData});

  @override
  State<GroupDetailPage> createState() => _GroupDetailPageState();
}

class _GroupDetailPageState extends State<GroupDetailPage> {
  final GroupService _groupService = GroupService();
  bool _isLoading = false;
  String? _error;
  List<Map<String, dynamic>> _members = [];
  Map<String, dynamic>? _groupDetail;

  @override
  void initState() {
    super.initState();
    _loadDetail();
  }

  Future<void> _loadDetail() async {
    if (widget.groupId == null) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final detail = await _groupService.getGroupDetail(widget.groupId!);
      final members = await _groupService.getGroupMembers(widget.groupId!);
      final parsed = <Map<String, dynamic>>[];
      for (final m in members) {
        if (m is Map<String, dynamic>)
          parsed.add(m);
        else if (m is Map)
          parsed.add(Map<String, dynamic>.from(m));
      }
      if (!mounted) return;
      setState(() {
        _groupDetail = detail;
        _members = parsed;
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

  Future<void> _inviteMember() async {
    final emailController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    final result = await showDialog<String?>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Invitar miembro'),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: emailController,
            decoration: const InputDecoration(labelText: 'Email'),
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'Ingresa un email';
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
                Navigator.of(context).pop(emailController.text.trim());
              }
            },
            child: const Text('Invitar'),
          ),
        ],
      ),
    );

    if (result == null) return;
    setState(() => _isLoading = true);
    try {
      await _groupService.inviteMember(
        groupId: widget.groupId!,
        inviteeEmail: result,
      );
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Invitación enviada')));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error invitando: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _changeRole(String memberId) async {
    final roles = ['member', 'admin'];
    String? newRole = roles.first;
    final result = await showDialog<String?>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Cambiar rol'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: roles.map((r) {
            return RadioListTile<String>(
              value: r,
              groupValue: newRole,
              title: Text(r),
              onChanged: (v) => newRole = v,
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(null),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(newRole),
            child: const Text('Guardar'),
          ),
        ],
      ),
    );

    if (result == null) return;
    setState(() => _isLoading = true);
    try {
      await _groupService.updateMemberRole(memberId: memberId, newRole: result);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Rol actualizado')));
      _loadDetail();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error actualizando rol: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteMember(String memberId) async {
    final confirm = await showDialog<bool?>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Eliminar miembro'),
        content: const Text('¿Eliminar este miembro del grupo?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirm != true) return;
    setState(() => _isLoading = true);
    try {
      await _groupService.deleteMember(memberId);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Miembro eliminado')));
      _loadDetail();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error eliminando miembro: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _leaveGroup() async {
    final confirm = await showDialog<bool?>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Salir del grupo'),
        content: const Text('¿Estás seguro que quieres salir del grupo?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Salir'),
          ),
        ],
      ),
    );

    if (confirm != true) return;
    setState(() => _isLoading = true);
    try {
      await _groupService.leaveGroup(widget.groupId!);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Has salido del grupo')));
      Navigator.of(context).pop();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error saliendo del grupo: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.groupData?['name'] ?? _groupDetail?['name'] ?? 'Grupo';
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          IconButton(
            onPressed: _inviteMember,
            icon: const Icon(Icons.person_add),
          ),
          IconButton(
            onPressed: _leaveGroup,
            icon: const Icon(Icons.exit_to_app),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(child: Text('Error: $_error'))
          : RefreshIndicator(
              onRefresh: _loadDetail,
              child: ListView(
                padding: const EdgeInsets.all(12),
                children: [
                  if (_groupDetail != null) ...[
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _groupDetail!['name'] ?? 'Grupo',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(_groupDetail!['description'] ?? ''),
                          ],
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  const Text(
                    'Miembros',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  ..._members.map((m) {
                    final memberId =
                        m['id']?.toString() ?? m['_id']?.toString() ?? '';
                    final memberName = m['name'] ?? m['email'] ?? 'Miembro';
                    final role = m['role'] ?? 'member';
                    return Card(
                      child: ListTile(
                        title: Text(memberName.toString()),
                        subtitle: Text('Rol: $role'),
                        trailing: PopupMenuButton<String>(
                          onSelected: (v) async {
                            if (v == 'role') {
                              await _changeRole(memberId);
                            } else if (v == 'delete') {
                              await _deleteMember(memberId);
                            }
                          },
                          itemBuilder: (_) => const [
                            PopupMenuItem(
                              value: 'role',
                              child: Text('Cambiar rol'),
                            ),
                            PopupMenuItem(
                              value: 'delete',
                              child: Text('Eliminar'),
                            ),
                          ],
                        ),
                      ),
                    );
                    }),
                ],
              ),
            ),
    );
  }
}
