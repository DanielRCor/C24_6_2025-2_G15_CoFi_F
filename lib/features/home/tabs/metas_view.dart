// Tab Metas
// lib/features/home/tabs/metas_view.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/services/metas_service.dart';

class Goal {
  final String? id;
  final String title;
  final double saved;
  final double target;
  final DateTime targetDate;

  Goal({
    this.id,
    required this.title,
    required this.saved,
    required this.target,
    required this.targetDate,
  });

  double get progress => (target <= 0) ? 0 : (saved / target).clamp(0.0, 1.0);

  int get daysLeft => targetDate.difference(DateTime.now()).inDays;

  // Robust mapper from API response
  factory Goal.fromMap(Map<String, dynamic> m) {
    double _toDouble(dynamic v) {
      if (v == null) return 0.0;
      if (v is num) return v.toDouble();
      if (v is String) return double.tryParse(v.replaceAll(',', '.')) ?? 0.0;
      return 0.0;
    }

    DateTime _parseDate(dynamic v) {
      if (v == null) return DateTime.now();
      if (v is DateTime) return v;
      if (v is int) return DateTime.fromMillisecondsSinceEpoch(v);
      if (v is String) {
        try {
          return DateTime.parse(v);
        } catch (_) {
          // Try common formats via DateTime.tryParse
          return DateTime.tryParse(v) ?? DateTime.now();
        }
      }
      return DateTime.now();
    }

    final id = m['id']?.toString() ?? m['_id']?.toString();
    final title = (m['title'] ?? m['name'] ?? '') as String;
    final saved = _toDouble(
      m['currentAmount'] ?? m['saved'] ?? m['savedAmount'] ?? m['amountSaved'],
    );
    final target = _toDouble(
      m['targetAmount'] ?? m['target'] ?? m['goalAmount'],
    );
    final targetDate = _parseDate(
      m['targetDate'] ?? m['date'] ?? m['goalDate'],
    );

    return Goal(
      id: id,
      title: title,
      saved: saved,
      target: target,
      targetDate: targetDate,
    );
  }
}

class MetasView extends StatefulWidget {
  const MetasView({super.key});

  @override
  State<MetasView> createState() => _MetasViewState();
}

class _MetasViewState extends State<MetasView> {
  final List<Goal> _goals = [];
  final GoalService _service = GoalService();
  bool _isLoading = false;
  bool _isSaving = false;

  final _titleController = TextEditingController();
  final _targetController = TextEditingController();
  DateTime? _selectedDate;
  final _dateController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _targetController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  void _safeSetState(VoidCallback fn) {
    if (!mounted) return;
    setState(fn);
  }

  @override
  void initState() {
    super.initState();
    _loadGoals();
  }

  Future<void> _loadGoals() async {
    _safeSetState(() {
      _isLoading = true;
    });
    try {
      final data = await _service.getGoals();
      _safeSetState(() {
        _goals.clear();
        _goals.addAll(data.map((e) => Goal.fromMap(e)).toList());
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error cargando metas: ${e.toString()}')),
        );
      }
    } finally {
      _safeSetState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 40),
            const Text(
              'Metas de Ahorro',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const Text('Visualiza y gestiona tus objetivos financieros'),
            const SizedBox(height: 24),
            _buildSummaryCards(),
            const SizedBox(height: 24),
            _buildNewGoalButton(context),
            const SizedBox(height: 24),
            const Text(
              'Tus metas activas',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildGoalsList(),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCards() {
    // simple aggregated values
    final totalSaved = _goals.fold<double>(0, (p, e) => p + e.saved);
    final nearest = _goals.isEmpty
        ? null
        : _goals.reduce((a, b) => a.daysLeft < b.daysLeft ? a : b);

    return Row(
      children: [
        Expanded(
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Meta más cercana',
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    nearest != null ? nearest.title : '-',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    nearest != null
                        ? '${nearest.daysLeft} días restantes'
                        : '-',
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Total Ahorrado',
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'S/ ${totalSaved.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text('en ${_goals.length} metas activas'),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNewGoalButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () => _showGoalModal(context),
        icon: const Icon(Icons.add),
        label: const Text('Crear nueva Meta'),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          side: const BorderSide(color: Colors.blue),
        ),
      ),
    );
  }

  Widget _buildGoalsList() {
    if (_isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 24.0),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_goals.isEmpty) {
      return const Text('No tienes metas activas');
    }

    return Column(
      children: List.generate(_goals.length * 2 - 1, (i) {
        final index = i ~/ 2;
        if (i.isOdd) return const SizedBox(height: 12);
        final g = _goals[index];
        return _buildGoalCardFromModel(g, index);
      }),
    );
  }

  Widget _buildGoalCardFromModel(Goal g, int index) {
    final formattedDate = DateFormat.yMMMMd().format(g.targetDate);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.bookmark_outline),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        g.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        formattedDate,
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${(g.progress * 100).toInt()}% ',
                    style: const TextStyle(color: Colors.blue),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(value: g.progress),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'S/ ${g.saved.toStringAsFixed(0)} ahorrados',
                  style: const TextStyle(color: Colors.grey),
                ),
                Text(
                  'Meta: S/ ${g.target.toStringAsFixed(0)}',
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
            if (g.daysLeft <= 30) ...[
              const SizedBox(height: 8),
              Text(
                'Faltan ${g.daysLeft} días',
                style: const TextStyle(color: Colors.orange),
              ),
            ],
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () =>
                      _showGoalModal(context, editingGoal: g, index: index),
                  child: const Text('Editar'),
                ),
                const SizedBox(width: 8),
                TextButton(
                  onPressed: () async {
                    // Confirm delete
                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Eliminar meta'),
                        content: const Text(
                          '¿Estás seguro que deseas eliminar esta meta?',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, false),
                            child: const Text('Cancelar'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, true),
                            child: const Text('Eliminar'),
                          ),
                        ],
                      ),
                    );

                    if (confirmed == true) {
                      if (g.id == null) {
                        _safeSetState(() {
                          _goals.removeAt(index);
                        });
                        return;
                      }
                      try {
                        _safeSetState(() {
                          _isSaving = true;
                        });
                        await _service.deleteGoal(g.id!);
                        _safeSetState(() {
                          _goals.removeAt(index);
                        });
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Meta eliminada')),
                          );
                        }
                      } catch (e) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Error eliminando meta: ${e.toString()}',
                              ),
                            ),
                          );
                        }
                      } finally {
                        _safeSetState(() {
                          _isSaving = false;
                        });
                      }
                    }
                  },
                  child: const Text(
                    'Eliminar',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () async {
                    final amountController = TextEditingController();
                    final confirmed = await showModalBottomSheet<bool>(
                      context: context,
                      isScrollControlled: true,
                      builder: (ctx) {
                        return Padding(
                          padding: EdgeInsets.only(
                            bottom: MediaQuery.of(ctx).viewInsets.bottom,
                            left: 16,
                            right: 16,
                            top: 16,
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Agregar Ahorro',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 12),
                              TextField(
                                controller: amountController,
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                      decimal: true,
                                    ),
                                decoration: const InputDecoration(
                                  labelText: 'Monto a ahorrar',
                                  prefixText: 'S/ ',
                                  border: OutlineInputBorder(),
                                ),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(ctx, false),
                                    child: const Text('Cancelar'),
                                  ),
                                  const SizedBox(width: 8),
                                  ElevatedButton(
                                    onPressed: () => Navigator.pop(ctx, true),
                                    child: const Text('Agregar'),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                            ],
                          ),
                        );
                      },
                    );

                    if (confirmed != true) return;

                    final text = amountController.text.trim();
                    final amount = double.tryParse(text.replaceAll(',', '.'));
                    if (amount == null || amount <= 0) {
                      if (mounted)
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Ingresa un monto válido'),
                          ),
                        );
                      return;
                    }

                    // find index and goal
                    final gIndex = index;
                    if (gIndex < 0 || gIndex >= _goals.length) return;
                    final g = _goals[gIndex];

                    _safeSetState(() {
                      _isSaving = true;
                    });

                    try {
                      final newSaved = (g.saved) + amount;
                      if (g.id != null) {
                        // Update backend (DB field: currentAmount)
                        await _service.updateGoal(g.id!, {
                          'currentAmount': newSaved,
                        });
                      }

                      // Update local model regardless
                      final updated = Goal(
                        id: g.id,
                        title: g.title,
                        saved: newSaved,
                        target: g.target,
                        targetDate: g.targetDate,
                      );
                      _safeSetState(() {
                        _goals[gIndex] = updated;
                      });

                      if (mounted)
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Ahorro agregado')),
                        );
                    } catch (e) {
                      if (mounted)
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Error al agregar ahorro: ${e.toString()}',
                            ),
                          ),
                        );
                    } finally {
                      _safeSetState(() {
                        _isSaving = false;
                      });
                    }
                  },
                  child: const Text('Ahorrar'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showGoalModal(BuildContext context, {Goal? editingGoal, int? index}) {
    // Prefill controllers when editing
    if (editingGoal != null) {
      _titleController.text = editingGoal.title;
      _targetController.text = editingGoal.target.toStringAsFixed(0);
      _selectedDate = editingGoal.targetDate;
      _dateController.text = DateFormat.yMMMMd().format(editingGoal.targetDate);
    } else {
      _titleController.clear();
      _targetController.clear();
      _dateController.clear();
      _selectedDate = null;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                editingGoal != null ? 'Editar meta' : 'Crear nueva meta',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Nombre de la meta',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _targetController,
                decoration: const InputDecoration(
                  labelText: 'Monto objetivo',
                  border: OutlineInputBorder(),
                  prefixText: 'S/ ',
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: () async {
                  final now = DateTime.now();
                  final picked = await showDatePicker(
                    context: context,
                    initialDate:
                        _selectedDate ?? now.add(const Duration(days: 7)),
                    firstDate: now,
                    lastDate: DateTime(now.year + 5),
                  );
                  if (picked != null) {
                    _safeSetState(() {
                      _selectedDate = picked;
                      _dateController.text = DateFormat.yMMMMd().format(picked);
                    });
                  }
                },
                child: AbsorbPointer(
                  child: TextField(
                    controller: _dateController,
                    decoration: InputDecoration(
                      labelText: 'Fecha objetivo',
                      border: const OutlineInputBorder(),
                      suffixIcon: const Icon(Icons.calendar_today),
                      hintText: 'Selecciona una fecha',
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSaving
                      ? null
                      : () async {
                          final title = _titleController.text.trim();
                          final targetText = _targetController.text.trim();
                          final target = double.tryParse(
                            targetText.replaceAll(',', '.'),
                          );

                          if (title.isEmpty ||
                              target == null ||
                              _selectedDate == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Por favor completa todos los campos válidos',
                                ),
                              ),
                            );
                            return;
                          }

                          _safeSetState(() {
                            _isSaving = true;
                          });

                          try {
                            if (editingGoal != null &&
                                index != null &&
                                editingGoal.id != null) {
                              final data = {
                                'title': title,
                                'targetAmount': target,
                                'targetDate': _selectedDate!.toIso8601String(),
                              };
                              await _service.updateGoal(editingGoal.id!, data);
                              // Update local model
                              final updated = Goal(
                                id: editingGoal.id,
                                title: title,
                                saved: editingGoal.saved,
                                target: target,
                                targetDate: _selectedDate!,
                              );
                              _safeSetState(() {
                                _goals[index] = updated;
                              });
                              if (mounted)
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Meta actualizada'),
                                  ),
                                );
                            } else {
                              final created = await _service.createGoal(
                                title: title,
                                targetAmount: target,
                                targetDate: _selectedDate,
                              );
                              // Convert response and add
                              final newGoal = Goal.fromMap(created);
                              _safeSetState(() {
                                _goals.add(newGoal);
                              });
                              if (mounted)
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Meta creada')),
                                );
                            }
                            Navigator.pop(context);
                          } catch (e) {
                            if (mounted)
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Error guardando meta: ${e.toString()}',
                                  ),
                                ),
                              );
                          } finally {
                            _safeSetState(() {
                              _isSaving = false;
                            });
                          }
                        },
                  child: Text(
                    editingGoal != null ? 'Guardar cambios' : 'Crear Meta',
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }
}
