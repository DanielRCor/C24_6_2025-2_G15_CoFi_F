// Tab Metas
// lib/features/home/tabs/metas_view.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Goal {
  final String title;
  final double saved;
  final double target;
  final DateTime targetDate;

  Goal({
    required this.title,
    required this.saved,
    required this.target,
    required this.targetDate,
  });

  double get progress => (target <= 0) ? 0 : (saved / target).clamp(0.0, 1.0);

  int get daysLeft => targetDate.difference(DateTime.now()).inDays;
}

class MetasView extends StatefulWidget {
  const MetasView({super.key});

  @override
  State<MetasView> createState() => _MetasViewState();
}

class _MetasViewState extends State<MetasView> {
  final List<Goal> _goals = [
    Goal(
      title: 'Vacaciones en la playa',
      saved: 1200,
      target: 3000,
      targetDate: DateTime(2026, 1, 1),
    ),
    Goal(
      title: 'MacBook Pro',
      saved: 4800,
      target: 6000,
      targetDate: DateTime(2025, 7, 1),
    ),
    Goal(
      title: 'Fondo de Emergencia',
      saved: 3600,
      target: 12000,
      targetDate: DateTime(2026, 3, 1),
    ),
  ];

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
                ElevatedButton(onPressed: () {}, child: const Text('Ahorrar')),
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
                    setState(() {
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
                  onPressed: () {
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

                    if (editingGoal != null && index != null) {
                      final updated = Goal(
                        title: title,
                        saved: editingGoal.saved,
                        target: target,
                        targetDate: _selectedDate!,
                      );
                      setState(() {
                        _goals[index] = updated;
                      });
                    } else {
                      final newGoal = Goal(
                        title: title,
                        saved: 0,
                        target: target,
                        targetDate: _selectedDate!,
                      );
                      setState(() {
                        _goals.add(newGoal);
                      });
                    }

                    Navigator.pop(context);
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
