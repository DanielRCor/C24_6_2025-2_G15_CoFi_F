import 'package:flutter/material.dart';

class InicioView extends StatelessWidget {
  const InicioView({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 40),
            Text(
              '¡Hola, Carlos!',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const Text('Resumen de tus finanzas.'),
            const SizedBox(height: 20),
            _buildTotalBalanceCard(context),
            const SizedBox(height: 12),
            _buildMonthlyBudgetCard(context),
            const SizedBox(height: 20),
            _buildRecentMovements(),
            const SizedBox(height: 20),
            _buildSavingsGoals(context),
            const SizedBox(height: 20),
            _buildReports(),
          ],
        ),
      ),
    );
  }

  /// --- TARJETA DE SALDO TOTAL ---
  Widget _buildTotalBalanceCard(BuildContext context) {
    return GestureDetector(
      onTap: () => _showAddTransactionModal(context),
      child: Card(
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text('Saldo Total'),
              SizedBox(height: 8),
              Text(
                'S/ 2,580.75',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// --- TARJETA DE PRESUPUESTO ---
  Widget _buildMonthlyBudgetCard(BuildContext context) {
    return Card(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Presupuesto Mensual'),
                TextButton(
                  onPressed: () => _showEditBudgetModal(context),
                  child: const Text('Editar'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text('S/2,175.5 / 3,500'),
            const SizedBox(height: 8),
            const LinearProgressIndicator(value: 0.62),
            const SizedBox(height: 4),
            const Text('Queda S/1324.5     62% usado'),
          ],
        ),
      ),
    );
  }

  /// --- MOVIMIENTOS RECIENTES ---
  Widget _buildRecentMovements() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text(
          'Movimientos Recientes',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        _MovementItem(
          title: 'McDonald\'s',
          amount: -40,
          date: 'Hoy, 14:30',
          category: 'Comida',
        ),
        _MovementItem(
          title: 'Electricidad',
          amount: -40,
          date: 'Ayer, 10:15',
          category: 'Servicios',
        ),
        _MovementItem(
          title: 'Transferencia recibida',
          amount: 500,
          date: '24 May, 09:20',
          category: 'Ingresos',
        ),
        _MovementItem(
          title: 'Supermercado',
          amount: -40,
          date: '23 May, 18:45',
          category: 'Compras',
        ),
      ],
    );
  }

  /// --- METAS DE AHORRO ---
  Widget _buildSavingsGoals(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Metas de Ahorro',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            TextButton(
              onPressed: () => _showEditGoalsModal(context),
              child: const Text('Editar'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 120,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              _buildGoalCard('Vacaciones', 1200, 3000, 0.4, context),
              const SizedBox(width: 8),
              _buildGoalCard('MacBook Pro', 4800, 6000, 0.72, context),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildGoalCard(
      String title, double current, double total, double progress, BuildContext context) {
    return GestureDetector(
      onTap: () => _showGoalActionsModal(context, title),
      child: Card(
        child: Container(
          width: 200,
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title),
              const SizedBox(height: 8),
              Text('S/ ${current.toInt()} / ${total.toInt()}'),
              const SizedBox(height: 8),
              LinearProgressIndicator(value: progress),
              const SizedBox(height: 4),
              Text('${(progress * 100).toInt()}%'),
            ],
          ),
        ),
      ),
    );
  }

  /// --- REPORTES ---
  Widget _buildReports() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Reportes - Personal',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: Card(
                child: Container(
                  height: 150,
                  padding: const EdgeInsets.all(16),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Gastos de la semana',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Card(
                child: Container(
                  height: 150,
                  padding: const EdgeInsets.all(16),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Por categorías',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// --- ITEM ENHANCED PARA LISTA DE METAS ---
  Widget _buildGoalListItemEnhanced(String title, double current, double total, double progress) {
    return Card(
      child: ListTile(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('S/ ${current.toInt()} / ${total.toInt()}'),
            const SizedBox(height: 6),
            LinearProgressIndicator(value: progress),
            Text('${(progress * 100).toInt()}% completado'),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.edit, color: Colors.blue),
          onPressed: () {
            // TODO: editar meta
          },
        ),
      ),
    );
  }

  /// --- MODALES ---
  void _showAddTransactionModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Agregar Transacción',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              TextField(decoration: const InputDecoration(labelText: 'Descripción')),
              const SizedBox(height: 8),
              TextField(
                decoration: const InputDecoration(labelText: 'Monto', prefixText: 'S/ '),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 8),
              TextField(decoration: const InputDecoration(labelText: 'Categoría')),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                    child: const Text('Agregar Gasto'),
                  ),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                    child: const Text('Agregar Ingreso'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _showEditBudgetModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Editar Presupuesto Mensual',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              TextField(
                decoration: const InputDecoration(labelText: 'Nuevo presupuesto', prefixText: 'S/ '),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text('Guardar')),
            ],
          ),
        );
      },
    );
  }

  void _showEditGoalsModal(BuildContext context) {
    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.5,
          maxChildSize: 0.85,
          expand: false,
          builder: (_, controller) {
            return Container(
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                children: [
                  // Handle bar
                  Container(
                    margin: const EdgeInsets.only(top: 12, bottom: 8),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  // Title
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Metas de Ahorro',
                            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                        IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  // Content
                  Expanded(
                    child: ListView(
                      controller: controller,
                      padding: const EdgeInsets.all(20),
                      children: [
                        const Text('Metas Actuales',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 12),
                        _buildGoalListItemEnhanced('Vacaciones', 1200, 3000, 0.4),
                        const SizedBox(height: 8),
                        _buildGoalListItemEnhanced('MacBook Pro', 4800, 6000, 0.72),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showGoalActionsModal(BuildContext context, String goalTitle) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(goalTitle, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                    child: const Text('Agregar Ahorro'),
                  ),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                    child: const Text('Agregar Gasto'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

/// --- WIDGET DE MOVIMIENTOS ---
class _MovementItem extends StatelessWidget {
  final String title;
  final double amount;
  final String date;
  final String category;

  const _MovementItem({
    required this.title,
    required this.amount,
    required this.date,
    required this.category,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title),
      subtitle: Text('$date | $category'),
      trailing: Text(
        'S/ ${amount.toString()}',
        style: TextStyle(
          color: amount < 0 ? Colors.red : Colors.green,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
