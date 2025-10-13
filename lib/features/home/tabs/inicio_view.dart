import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:math';

// Paquete para las acciones de deslizar (swipe)
import 'package:flutter_slidable/flutter_slidable.dart';

// Importar el widget del micrófono
import 'package:tesis/core/widgets/microphone_button.dart'; // Asegúrate que esta ruta es correcta

class InicioView extends StatefulWidget {
  const InicioView({super.key});

  @override
  State<InicioView> createState() => _InicioViewState();
}

class _InicioViewState extends State<InicioView> {
  final user = FirebaseAuth.instance.currentUser;
  late List<Map<String, dynamic>> goals;
  late List<Map<String, dynamic>> movements;
  double totalBalance = 0.0;
  double monthlyBudget = 2175.5; // presupuesto actual
  final double monthlyBudgetGoal = 3500.0;

  @override
  void initState() {
    super.initState();
    goals = [
      {'title': 'Vacaciones', 'current': 1200.0, 'total': 3000.0},
      {'title': 'MacBook Pro', 'current': 4800.0, 'total': 6000.0},
    ];

    movements = [
      {
        'title': "McDonald's",
        'amount': -40.0,
        'date': 'Hoy, 14:30',
        'category': 'Comida'
      },
      {
        'title': 'Electricidad',
        'amount': -40.0,
        'date': 'Ayer, 10:15',
        'category': 'Servicios'
      },
      {
        'title': 'Transferencia recibida',
        'amount': 500.0,
        'date': '24 May, 09:20',
        'category': 'Ingresos'
      },
      {
        'title': 'Supermercado',
        'amount': -40.0,
        'date': '23 May, 18:45',
        'category': 'Compras'
      },
    ];

    // Calcular el saldo inicial
    totalBalance = movements.fold(0.0, (sum, m) => sum + (m['amount'] as double));
  }

  @override
  Widget build(BuildContext context) {
    final nombre = user?.displayName ?? 'Usuario';

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 40),
            Text('¡Hola, $nombre!',
                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text('Resumen de tus finanzas',
                style: TextStyle(fontSize: 16, color: Colors.grey[600])),
            const SizedBox(height: 24),
            _buildTotalBalanceCard(context),
            const SizedBox(height: 16),
            _buildMonthlyBudgetCard(context),
            const SizedBox(height: 24),
            _buildRecentMovements(),
            const SizedBox(height: 20),
            _buildSavingsGoals(context),
            const SizedBox(height: 20),
            _buildReports(),
            const SizedBox(height: 80),
          ],
        ),
      ),
      floatingActionButton: const MicrophoneButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  /// --- TARJETA DE SALDO TOTAL (DISEÑO MEJORADO) ---
  Widget _buildTotalBalanceCard(BuildContext context) {
    // Calcular porcentaje de cambio (simulado)
    final percentageChange = 8.2;
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Saldo Total',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'S/ ${totalBalance.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.arrow_upward, 
                        color: Colors.green.shade700, size: 14),
                    const SizedBox(width: 2),
                    Text(
                      '${percentageChange.toStringAsFixed(1)}%',
                      style: TextStyle(
                        color: Colors.green.shade700,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: CustomActionButton(
                  onPressed: () => _showAddTransactionModal(context, isIncome: true),
                  backgroundColor: Colors.green.shade500,
                  icon: Icons.arrow_upward,
                  label: 'Ingreso',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: CustomActionButton(
                  onPressed: () => _showAddTransactionModal(context, isIncome: false),
                  backgroundColor: Colors.red.shade500,
                  icon: Icons.arrow_downward,
                  label: 'Gasto',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// --- TARJETA DE PRESUPUESTO (DISEÑO MEJORADO) ---
  Widget _buildMonthlyBudgetCard(BuildContext context) {
    final progress = (monthlyBudget / monthlyBudgetGoal).clamp(0.0, 1.0);
    final remaining = monthlyBudgetGoal - monthlyBudget;
    final percentUsed = (progress * 100).toInt();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Presupuesto Mensual',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              Text(
                'S/ ${monthlyBudget.toStringAsFixed(2)} / S/ ${monthlyBudgetGoal.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: SizedBox(
              height: 12,
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.blue.shade100,
                valueColor: AlwaysStoppedAnimation<Color>(
                  progress > 0.8 ? Colors.orange : Colors.green.shade500,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Queda S/ ${remaining.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '$percentUsed% usado',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// --- MOVIMIENTOS RECIENTES (CON SWIPE ACTIONS) ---
  Widget _buildRecentMovements() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Movimientos Recientes',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: movements.length,
          itemBuilder: (context, index) {
            final movement = movements[index];
            return Slidable(
              key: Key(movement['title'] + movement['date']),

              startActionPane: ActionPane(
                motion: const DrawerMotion(),
                children: [
                  SlidableAction(
                    onPressed: (context) {
                      _showEditTransactionModal(context, index);
                    },
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    icon: Icons.edit,
                    label: 'Editar',
                  ),
                ],
              ),

              endActionPane: ActionPane(
                motion: const DrawerMotion(),
                children: [
                  SlidableAction(
                    onPressed: (context) {
                      _deleteMovement(index);
                    },
                    backgroundColor: const Color(0xFFFE4A49),
                    foregroundColor: Colors.white,
                    icon: Icons.delete,
                    label: 'Eliminar',
                  ),
                ],
              ),
              
              child: _MovementItem(
                title: movement['title'],
                amount: movement['amount'],
                date: movement['date'],
                category: movement['category'],
              ),
            );
          },
        ),
      ],
    );
  }

  /// --- METAS DE AHORRO ---
  Widget _buildSavingsGoals(BuildContext context) {
    const double cardHeight = 130.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Metas de Ahorro',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: cardHeight,
          child: PageView.builder(
            controller: PageController(viewportFraction: 1.0),
            itemCount: goals.length,
            itemBuilder: (context, index) {
              final g = goals[index];
              final double progress = (g['current'] / g['total']).toDouble();
              return _buildGoalCard(
                g['title'],
                g['current'],
                g['total'],
                progress,
                index,
                context,
                cardHeight,
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildGoalCard(
    String title,
    double current,
    double total,
    double progress,
    int index,
    BuildContext context, [
    double cardHeight = 130,
  ]) {
    final cardWidth = MediaQuery.of(context).size.width - 32;
    final percent = (progress * 100).clamp(0, 100).round();

    return GestureDetector(
      onTap: () => _showGoalFormModal(context, index),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 2,
        child: Container(
          width: cardWidth,
          height: cardHeight,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(
                'S/ ${current.toInt()} / ${total.toInt()}',
                style: TextStyle(color: Colors.grey[600], fontSize: 12.5),
              ),
              const SizedBox(height: 6),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: SizedBox(
                        height: 10,
                        child: LinearProgressIndicator(
                          value: progress.toDouble(),
                          color: Colors.green,
                          backgroundColor: Colors.lightBlue[100],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text('$percent%',
                      style: const TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 13)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// --- FUNCIÓN PARA ELIMINAR UN MOVIMIENTO ---
  void _deleteMovement(int index) {
    setState(() {
      final deletedMovement = movements[index];
      final double amount = deletedMovement['amount'];

      totalBalance -= amount;
      if (amount < 0) {
        monthlyBudget -= amount.abs();
      }

      movements.removeAt(index);
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Movimiento eliminado correctamente'),
        backgroundColor: Colors.red,
      ),
    );
  }

  /// --- MODAL PARA EDITAR UN MOVIMIENTO ---
  void _showEditTransactionModal(BuildContext context, int index) {
    final originalMovement = movements[index];
    final double originalAmount = originalMovement['amount'];

    final montoController = TextEditingController(text: originalAmount.abs().toStringAsFixed(2));
    final descripcionController = TextEditingController(text: originalMovement['title']);

    final categorias = [ 'Comida', 'Servicios', 'Transporte', 'Ingresos', 'Compras', 'Entretenimiento', 'Salud', 'Educación', 'Otros' ];
    String categoriaSeleccionada = originalMovement['category'];
    final bool isIncome = originalAmount >= 0;

    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 16, right: 16,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20, top: 20
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Editar Movimiento',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: montoController,
                    decoration: InputDecoration(
                        labelText: 'Monto', prefixText: 'S/ ',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        filled: true, fillColor: Colors.grey.shade50),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    autofocus: true,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: descripcionController,
                    decoration: InputDecoration(
                        labelText: 'Descripción',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        filled: true, fillColor: Colors.grey.shade50),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: categoriaSeleccionada,
                    decoration: InputDecoration(
                        labelText: 'Categoría',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        filled: true, fillColor: Colors.grey.shade50),
                    items: categorias.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                    onChanged: (v) {
                      setModalState(() {
                        categoriaSeleccionada = v!;
                      });
                    },
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: CustomActionButton(
                      onPressed: () {
                        final newMonto = double.tryParse(montoController.text) ?? 0.0;
                        if (newMonto <= 0 || descripcionController.text.trim().isEmpty) {
                           ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Por favor, completa todos los campos'), backgroundColor: Colors.orange),
                           );
                          return;
                        }

                        setState(() {
                          final newAmount = isIncome ? newMonto : -newMonto;
                          final amountDifference = newAmount - originalAmount;

                          totalBalance += amountDifference;

                          if (originalAmount < 0) monthlyBudget -= originalAmount.abs();
                          if (!isIncome) monthlyBudget += newMonto;
                          
                          movements[index] = {
                            'title': descripcionController.text.trim(),
                            'amount': newAmount,
                            'date': _formatDate(),
                            'category': categoriaSeleccionada,
                          };
                        });
                        
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('✓ Movimiento actualizado correctamente'),
                            backgroundColor: Colors.blue,
                            duration: Duration(seconds: 2),
                          ),
                        );
                      },
                      backgroundColor: Colors.blue.shade500,
                      icon: Icons.check,
                      label: 'Guardar Cambios',
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

  /// --- MODAL PARA AGREGAR O RETIRAR EN METAS ---
  void _showGoalFormModal(BuildContext context, int index) {
    final goal = goals[index];
    final montoController = TextEditingController();
    final descripcionController = TextEditingController();

    final categorias = [
      'Comida',
      'Servicios',
      'Transporte',
      'Ingresos',
      'Otros'
    ];
    String categoriaSeleccionada = categorias.first;

    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
                top: 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(goal['title'],
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  TextField(
                    controller: montoController,
                    decoration: InputDecoration(
                      labelText: 'Monto',
                      prefixText: 'S/ ',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: descripcionController,
                    decoration: InputDecoration(
                      labelText: 'Descripción',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: categoriaSeleccionada,
                    decoration: InputDecoration(
                      labelText: 'Categoría',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                    ),
                    items: categorias
                        .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                        .toList(),
                    onChanged: (v) {
                      setModalState(() {
                        categoriaSeleccionada = v!;
                      });
                    },
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: CustomActionButton(
                          onPressed: () {
                            final monto = double.tryParse(montoController.text) ?? 0.0;
                            setState(() {
                              goal['current'] = (goal['current'] + monto).clamp(0, goal['total']);
                              totalBalance += monto;

                              movements.insert(0, {
                                'title': descripcionController.text.isEmpty
                                    ? goal['title']
                                    : descripcionController.text,
                                'amount': monto,
                                'date': _formatDate(),
                                'category': categoriaSeleccionada
                              });
                            });
                            Navigator.pop(context);
                          },
                          backgroundColor: Colors.green.shade500,
                          icon: Icons.add,
                          label: 'Agregar Ahorro',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: CustomActionButton(
                          onPressed: () {
                            final monto = double.tryParse(montoController.text) ?? 0.0;
                            setState(() {
                              goal['current'] = max(0, goal['current'] - monto);
                              totalBalance -= monto;
                              monthlyBudget += monto;

                              movements.insert(0, {
                                'title': descripcionController.text.isEmpty
                                    ? goal['title']
                                    : descripcionController.text,
                                'amount': -monto,
                                'date': _formatDate(),
                                'category': categoriaSeleccionada
                              });
                            });
                            Navigator.pop(context);
                          },
                          backgroundColor: Colors.red.shade500,
                          icon: Icons.remove,
                          label: 'Retirar Monto',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  /// --- MODAL PARA AGREGAR INGRESO O GASTO ---
  void _showAddTransactionModal(BuildContext context, {required bool isIncome}) {
    final montoController = TextEditingController();
    final descripcionController = TextEditingController();

    final categorias = [
      'Comida',
      'Servicios',
      'Transporte',
      'Ingresos',
      'Compras',
      'Entretenimiento',
      'Salud',
      'Educación',
      'Otros'
    ];
    String categoriaSeleccionada = isIncome ? 'Ingresos' : categorias.first;

    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
                top: 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        isIncome ? Icons.arrow_upward : Icons.arrow_downward,
                        color: isIncome ? Colors.green : Colors.red,
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        isIncome ? 'Agregar Ingreso' : 'Agregar Gasto',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: montoController,
                    decoration: InputDecoration(
                      labelText: 'Monto',
                      prefixText: 'S/ ',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                    ),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    autofocus: true,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: descripcionController,
                    decoration: InputDecoration(
                      labelText: 'Descripción',
                      hintText: 'Ej: Compra en supermercado',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: categoriaSeleccionada,
                    decoration: InputDecoration(
                      labelText: 'Categoría',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                    ),
                    items: categorias
                        .map((c) => DropdownMenuItem(
                              value: c,
                              child: Text(c),
                            ))
                        .toList(),
                    onChanged: (v) {
                      setModalState(() {
                        categoriaSeleccionada = v!;
                      });
                    },
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: CustomActionButton(
                      onPressed: () {
                        final monto = double.tryParse(montoController.text) ?? 0.0;
                        
                        if (monto <= 0) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Por favor ingresa un monto válido'),
                              backgroundColor: Colors.orange,
                            ),
                          );
                          return;
                        }

                        if (descripcionController.text.trim().isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Por favor ingresa una descripción'),
                              backgroundColor: Colors.orange,
                            ),
                          );
                          return;
                        }

                        setState(() {
                          final amount = isIncome ? monto : -monto;
                          
                          totalBalance += amount;
                          
                          if (!isIncome) {
                            monthlyBudget += monto;
                          }

                          movements.insert(0, {
                            'title': descripcionController.text.trim(),
                            'amount': amount,
                            'date': _formatDate(),
                            'category': categoriaSeleccionada,
                          });
                        });

                        Navigator.pop(context);

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              isIncome
                                  ? '✓ Ingreso agregado correctamente'
                                  : '✓ Gasto registrado correctamente',
                            ),
                            backgroundColor: isIncome ? Colors.green : Colors.red,
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      },
                      backgroundColor: isIncome ? Colors.green.shade500 : Colors.red.shade500,
                      icon: Icons.check,
                      label: isIncome ? 'Confirmar Ingreso' : 'Confirmar Gasto',
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

  String _formatDate() {
    final now = DateTime.now();
    return '${now.day}/${now.month}, ${now.hour}:${now.minute.toString().padLeft(2, '0')}';
  }

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
                      Text(
                        'Gastos de la semana',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
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
                      Text(
                        'Por categorías',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
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
}

// ============================================
// WIDGET REUTILIZABLE: CustomActionButton
// ============================================
class CustomActionButton extends StatelessWidget {
  final VoidCallback onPressed;
  final Color backgroundColor;
  final IconData icon;
  final String label;

  const CustomActionButton({
    super.key,
    required this.onPressed,
    required this.backgroundColor,
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 0,
      ),
      icon: Icon(icon, size: 18),
      label: Text(
        label,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 15,
        ),
      ),
    );
  }
}

// ============================================
// WIDGET PARA ITEM DE MOVIMIENTO
// ============================================
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
        'S/ ${amount.toStringAsFixed(2)}',
        style: TextStyle(
          color: amount < 0 ? Colors.red : Colors.green,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}