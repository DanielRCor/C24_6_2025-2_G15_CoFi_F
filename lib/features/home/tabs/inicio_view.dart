import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:math';
import 'dart:async';
import 'package:cofi/core/services/home_service.dart';
import 'package:cofi/core/services/metas_service.dart';
import 'package:cofi/core/services/transaction_service.dart';

// Paquete para las acciones de deslizar (swipe)
import 'package:flutter_slidable/flutter_slidable.dart';

// Importar el widget del micrófono
import 'package:cofi/core/widgets/microphone_button.dart'; // Asegúrate que esta ruta es correcta

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
  double monthlyBudget = 0.0; // monto gastado o usado en el mes
  double monthlyBudgetGoal = 0.0; // presupuesto total del mes
  bool isLoading = true;
  String? error;
  List<Map<String, dynamic>> accounts = [];
  List<Map<String, dynamic>> categories = [];
  String? selectedAccountId;

  @override
  void initState() {
    super.initState();
    _loadHomeData();
    // Start a periodic poll to refresh home data every 8 seconds
    _startPolling();
    // Iniciar vacía; será llenado desde el backend
    goals = [];

    // inicia vacío; será llenado desde el backend
    movements = [];
    totalBalance = 0.0;
  }

  Timer? _pollTimer;

  void _startPolling({int seconds = 8}) {
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(Duration(seconds: seconds), (t) async {
      // only poll when view is mounted and visible
      if (!mounted) return;
      try {
        await _loadHomeData();
      } catch (_) {
        // ignore poll errors silently
      }
    });
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  void _safeSetState(VoidCallback fn) {
    if (!mounted) return;
    setState(fn);
  }

  double _toDouble(dynamic v) {
    if (v == null) return 0.0;
    if (v is double) return v;
    if (v is int) return v.toDouble();
    if (v is num) return v.toDouble();
    if (v is String) {
      final parsed = double.tryParse(v);
      if (parsed != null) return parsed;
      final intParsed = int.tryParse(v);
      if (intParsed != null) return intParsed.toDouble();
    }
    return 0.0;
  }

  String _formatDisplayDate(dynamic dateRaw) {
    // Accepts DateTime or ISO strings or custom strings; returns like "18 octubre, 2:50"
    DateTime dt;
    if (dateRaw == null)
      dt = DateTime.now();
    else if (dateRaw is DateTime)
      dt = dateRaw;
    else if (dateRaw is String) {
      // Try to parse ISO first
      final parsed = DateTime.tryParse(dateRaw);
      if (parsed != null) {
        dt = parsed.toLocal();
      } else {
        // fallback: try to extract numbers, else use now
        dt = DateTime.now();
      }
    } else {
      dt = DateTime.now();
    }

    final months = [
      'enero',
      'febrero',
      'marzo',
      'abril',
      'mayo',
      'junio',
      'julio',
      'agosto',
      'septiembre',
      'octubre',
      'noviembre',
      'diciembre',
    ];

    final day = dt.day;
    final monthName = months[dt.month - 1];
    final hour = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final minute = dt.minute.toString().padLeft(2, '0');
    // Using 24-hour would be: '${dt.hour}:${minute}' but user example uses 2:50 (12h)
    return '$day $monthName, $hour:$minute';
  }

  Future<void> _loadHomeData() async {
    _safeSetState(() {
      isLoading = true;
      error = null;
    });

    try {
      final data = await HomeService.getHomeData();

      // Mapear accounts. Solo reemplazar si el backend devolvió datos.
      final accountsData = data['accounts'] as List<dynamic>? ?? [];
      if (accountsData.isNotEmpty) {
        final newAccounts = accountsData
            .map((a) {
              return {
                'id': (a['id'] ?? '').toString(),
                'name': (a['name'] ?? 'Cuenta').toString(),
                'balance': _toDouble(a['balance']),
                'currency': (a['currency'] ?? 'PEN').toString(),
              };
            })
            .cast<Map<String, dynamic>>()
            .where((a) => (a['id'] as String).isNotEmpty)
            .toList();

        accounts = newAccounts;
        // Mantener la cuenta seleccionada si ya existe, sino seleccionar la primera
        selectedAccountId =
            selectedAccountId ??
            (accounts.isNotEmpty ? accounts.first['id'] as String? : null);
      }

      // Mapear budgets -> por ahora no usado

      // Mapear categories (solo si el backend devolvió categorías)
      final categoriesData = data['categories'] as List<dynamic>? ?? [];
      if (categoriesData.isNotEmpty) {
        categories = categoriesData
            .map((c) {
              return {
                'id': c['id'] ?? c['_id'],
                'name': c['name'] ?? c['title'] ?? 'Otros',
                'type': c['type'] ?? 'expense',
              };
            })
            .cast<Map<String, dynamic>>()
            .toList();
      }

      // Mapear transactions (solo si el backend devolvió datos). Evitar sobrescribir
      // movimientos existentes con una lista vacía por errores transitorios.
      final transactionsData = data['transactions'] as List<dynamic>? ?? [];
      if (transactionsData.isNotEmpty) {
        final newMovements = transactionsData
            .map((t) {
              final type = (t['type'] ?? 'expense').toString().toLowerCase();
              final rawAmount = t['amount'];
              final parsedAmount = _toDouble(rawAmount);
              // Ensure amount sign reflects the type
              final amount = type == 'income'
                  ? parsedAmount.abs()
                  : -parsedAmount.abs();
              final rawDate = t['occurredAt'] ?? t['createdAt'] ?? t['date'];
              final displayDate = _formatDisplayDate(rawDate);

              return {
                'id': t['id'] ?? t['_id'] ?? t['transactionId'],
                // backend uses 'note' for extra text
                'amount': amount,
                'title': t['note'] ?? t['description'] ?? t['title'] ?? '',
                'type': type,
                'date': displayDate,
                // si la transacción incluye un objeto category, preferir su nombre
                'category': (t['category'] is Map)
                    ? (t['category']['name'] ?? 'Otros')
                    : (t['category'] ?? t['categoryId'] ?? 'Otros'),
                'categoryId': (t['category'] is Map)
                    ? (t['category']['id'] ?? t['category']['_id'])
                    : (t['categoryId'] ?? t['category'] ?? null),
              };
            })
            .cast<Map<String, dynamic>>()
            .toList();

        movements = newMovements;

        totalBalance = movements.fold(
          0.0,
          (sum, m) => sum + _toDouble(m['amount']),
        );

        // Initialize monthlyBudget as the sum of expenses (absolute value)
        monthlyBudget = movements.fold(0.0, (sum, m) {
          final amt = _toDouble(m['amount']);
          return sum + (amt < 0 ? amt.abs() : 0.0);
        });
      }

      // Mapear metas (goals)
      // Obtener metas directamente desde el servicio de metas (/savings)
      try {
        final goalService = GoalService();
        final fetchedGoals = await goalService.getGoals();
        if (fetchedGoals.isNotEmpty) {
          final mapped = fetchedGoals
              .map((g) {
                return {
                  'title': g['title'] ?? g['name'] ?? 'Meta',
                  'current': _toDouble(
                    g['currentAmount'] ??
                        g['saved'] ??
                        g['amountSaved'] ??
                        g['current'] ??
                        0,
                  ),
                  'total': _toDouble(
                    g['targetAmount'] ??
                        g['target'] ??
                        g['goalAmount'] ??
                        g['amount'] ??
                        0,
                  ),
                };
              })
              .cast<Map<String, dynamic>>()
              .toList();

          goals = mapped;
        } else {
          // No reemplazar metas existentes si la respuesta está vacía
        }
      } catch (_) {
        // Si falla la petición de metas, conservar las metas cargadas previamente
      }

      // Si no tiene metas, dejamos una lista vacía (la UI mostrará mensaje)

      _safeSetState(() {
        isLoading = false;
      });
    } catch (e) {
      _safeSetState(() {
        isLoading = false;
        error = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final nombre = user?.displayName ?? 'Usuario';
    // Calcular totalBalance preferiendo balances de cuentas si existen
    if (accounts.isNotEmpty) {
      totalBalance = accounts.fold(
        0.0,
        (sum, a) => sum + ((a['balance'] as double?) ?? 0.0),
      );
    } else {
      totalBalance = movements.fold(
        0.0,
        (sum, m) => sum + (m['amount'] as double),
      );
    }

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 40),
            Text(
              '¡Hola, $nombre!',
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              'Resumen de tus finanzas',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            // account selector + total card
            if (isLoading)
              const Center(child: CircularProgressIndicator())
            else if (error != null)
              Column(
                children: [
                  Text(
                    'Error: $error',
                    style: const TextStyle(color: Colors.red),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: _loadHomeData,
                    child: const Text('Reintentar'),
                  ),
                ],
              )
            else ...[
              if (accounts.isNotEmpty)
                DropdownButtonFormField<String>(
                  value: selectedAccountId,
                  decoration: const InputDecoration(labelText: 'Cuenta'),
                  items: accounts
                      .map(
                        (a) => DropdownMenuItem<String>(
                          value: (a['id'] ?? '').toString(),
                          child: Text((a['name'] ?? 'Cuenta').toString()),
                        ),
                      )
                      .toList(),
                  onChanged: (v) {
                    _safeSetState(() {
                      selectedAccountId = v;
                    });
                  },
                ),
              const SizedBox(height: 8),
              _buildTotalBalanceCard(context),
            ],
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
                    Icon(
                      Icons.arrow_upward,
                      color: Colors.green.shade700,
                      size: 14,
                    ),
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
                  onPressed: () =>
                      _showAddTransactionModal(context, isIncome: true),
                  backgroundColor: Colors.green.shade500,
                  icon: Icons.arrow_upward,
                  label: 'Ingreso',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: CustomActionButton(
                  onPressed: () =>
                      _showAddTransactionModal(context, isIncome: false),
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
    final progress = (monthlyBudgetGoal > 0)
        ? (monthlyBudget / monthlyBudgetGoal).clamp(0.0, 1.0)
        : 0.0;
    final remaining = monthlyBudgetGoal - monthlyBudget;
    final percentUsed = (progress * 100).toInt();

    return GestureDetector(
      onTap: () => _showBudgetModal(context),
      child: Container(
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
      ),
    );
  }

  void _showBudgetModal(BuildContext context) {
    final controller = TextEditingController(
      text: monthlyBudgetGoal > 0 ? monthlyBudgetGoal.toStringAsFixed(2) : '',
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
            top: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Establecer Presupuesto Mensual',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: controller,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: InputDecoration(
                  labelText: 'Presupuesto mensual (S/)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: CustomActionButton(
                  onPressed: () {
                    final value = double.tryParse(controller.text) ?? 0.0;
                    _safeSetState(() {
                      monthlyBudgetGoal = value;
                    });
                    Navigator.pop(ctx);
                    if (mounted)
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Presupuesto mensual guardado: S/ ${value.toStringAsFixed(2)}',
                          ),
                          backgroundColor: Colors.blue,
                        ),
                      );
                  },
                  backgroundColor: Colors.blue.shade500,
                  icon: Icons.save,
                  label: 'Guardar Presupuesto',
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
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
                      _deleteMovement(context, index);
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
        if (goals.isEmpty)
          Container(
            height: cardHeight,
            alignment: Alignment.center,
            child: Text(
              'No tienes metas de ahorro. Crea tu primera meta para empezar a ahorrar.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600]),
            ),
          )
        else
          SizedBox(
            height: cardHeight,
            child: PageView.builder(
              controller: PageController(viewportFraction: 1.0),
              itemCount: goals.length,
              itemBuilder: (context, index) {
                final g = goals[index];
                final double total = (g['total'] ?? 0.0) as double;
                final double current = (g['current'] ?? 0.0) as double;
                final double progress = (total > 0)
                    ? (current / total).clamp(0.0, 1.0)
                    : 0.0;
                return _buildGoalCard(
                  g['title'] ?? 'Meta',
                  current,
                  total,
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
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
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
                  Text(
                    '$percent%',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// --- FUNCIÓN PARA ELIMINAR UN MOVIMIENTO ---
  void _deleteMovement(BuildContext parentContext, int index) {
    final deletedMovement = movements[index];
    final id = deletedMovement['id'] as String?;

    showDialog(
      context: parentContext,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Eliminar movimiento'),
        content: const Text(
          '¿Estás seguro de que deseas eliminar este movimiento?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              try {
                if (id != null) {
                  await TransactionService.deleteTransaction(id);
                }

                if (!mounted) return;

                _safeSetState(() {
                  final double amount = _toDouble(deletedMovement['amount']);
                  totalBalance -= amount;
                  if (amount < 0) {
                    monthlyBudget -= amount.abs();
                  }
                  movements.removeAt(index);
                });
                if (mounted)
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Movimiento eliminado correctamente'),
                      backgroundColor: Colors.red,
                    ),
                  );
                // refresh to reflect backend state
                if (mounted) await _loadHomeData();
              } catch (e) {
                if (mounted)
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error eliminando: $e'),
                      backgroundColor: Colors.orange,
                    ),
                  );
              }
            },
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  /// --- MODAL PARA EDITAR UN MOVIMIENTO ---
  void _showEditTransactionModal(BuildContext context, int index) {
    final originalMovement = movements[index];
    final double originalAmount = originalMovement['amount'];

    final montoController = TextEditingController(
      text: originalAmount.abs().toStringAsFixed(2),
    );
    final descripcionController = TextEditingController(
      text: originalMovement['title'],
    );

    // categorias vienen del backend; se usa id como valor y name para mostrar
    final categorias = categories;
    String categoriaSeleccionada = '';
    // intentar mapear category existente a id
    final origCat = originalMovement['category'];
    if (origCat is String) {
      // buscar por name
      final found = categories.firstWhere(
        (c) =>
            (c['name'] ?? '').toString().toLowerCase() == origCat.toLowerCase(),
        orElse: () => {},
      );
      if (found.isNotEmpty)
        categoriaSeleccionada = (found['id'] ?? '').toString();
    } else if (origCat is Map && origCat['id'] != null) {
      categoriaSeleccionada = origCat['id'].toString();
    } else if (origCat != null) {
      categoriaSeleccionada = origCat.toString();
    }
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
                left: 16,
                right: 16,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
                top: 20,
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
                      labelText: 'Monto',
                      prefixText: 'S/ ',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                    ),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    autofocus: true,
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
                    value: categoriaSeleccionada.isEmpty
                        ? null
                        : categoriaSeleccionada,
                    decoration: InputDecoration(
                      labelText: 'Categoría',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                    ),
                    items: categorias
                        .map(
                          (c) => DropdownMenuItem<String>(
                            value: (c['id'] ?? '').toString(),
                            child: Text((c['name'] ?? 'Otros').toString()),
                          ),
                        )
                        .toList(),
                    onChanged: (v) {
                      setModalState(() {
                        categoriaSeleccionada = v ?? '';
                      });
                    },
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: CustomActionButton(
                      onPressed: () async {
                        final newMonto =
                            double.tryParse(montoController.text) ?? 0.0;
                        if (newMonto <= 0 ||
                            descripcionController.text.trim().isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Por favor, completa todos los campos',
                              ),
                              backgroundColor: Colors.orange,
                            ),
                          );
                          return;
                        }

                        final id = originalMovement['id'] as String?;
                        final newAmount = isIncome ? newMonto : -newMonto;

                        try {
                          if (id != null) {
                            final updated =
                                await TransactionService.updateTransaction(
                                  id: id,
                                  amount: newAmount,
                                  type: isIncome ? 'income' : 'expense',
                                  note: descripcionController.text.trim(),
                                  categoryId: categoriaSeleccionada,
                                );

                            _safeSetState(() {
                              final amountDifference =
                                  newAmount - originalAmount;
                              totalBalance += amountDifference;

                              if (originalAmount < 0)
                                monthlyBudget -= originalAmount.abs();
                              if (!isIncome) monthlyBudget += newMonto;

                              final rawDate =
                                  updated['occurredAt'] ?? updated['createdAt'];

                              movements[index] = {
                                'id': updated['id'] ?? updated['_id'] ?? id,
                                'title': descripcionController.text.trim(),
                                'amount': newAmount,
                                'date': _formatDisplayDate(
                                  rawDate ?? _formatDate(),
                                ),
                                'category':
                                    (categories.firstWhere(
                                      (c) =>
                                          (c['id'] ?? '').toString() ==
                                          categoriaSeleccionada,
                                      orElse: () => {},
                                    )['name']) ??
                                    categoriaSeleccionada,
                                'categoryId': categoriaSeleccionada,
                              };
                            });
                          } else {
                            // If no id, just update locally
                            _safeSetState(() {
                              final amountDifference =
                                  newAmount - originalAmount;
                              totalBalance += amountDifference;
                              movements[index] = {
                                'title': descripcionController.text.trim(),
                                'amount': newAmount,
                                'date': _formatDate(),
                                'category':
                                    (categories.firstWhere(
                                      (c) =>
                                          (c['id'] ?? '').toString() ==
                                          categoriaSeleccionada,
                                      orElse: () => {},
                                    )['name']) ??
                                    categoriaSeleccionada,
                                'categoryId': categoriaSeleccionada,
                              };
                            });
                          }

                          Navigator.pop(context);
                          if (mounted)
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  '✓ Movimiento actualizado correctamente',
                                ),
                                backgroundColor: Colors.blue,
                                duration: Duration(seconds: 2),
                              ),
                            );
                          // refresh data from backend after update
                          if (mounted) await _loadHomeData();
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Error actualizando: $e'),
                              backgroundColor: Colors.orange,
                            ),
                          );
                        }
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

    final categorias = categories;
    String categoriaSeleccionada = categorias.isNotEmpty
        ? (categorias.first['id'] ?? '').toString()
        : '';

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
                  Text(
                    goal['title'],
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
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
                    value: categoriaSeleccionada.isEmpty
                        ? null
                        : categoriaSeleccionada,
                    decoration: InputDecoration(
                      labelText: 'Categoría',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                    ),
                    items: categorias
                        .map(
                          (c) => DropdownMenuItem<String>(
                            value: (c['id'] ?? '').toString(),
                            child: Text((c['name'] ?? 'Otros').toString()),
                          ),
                        )
                        .toList(),
                    onChanged: (v) {
                      setModalState(() {
                        categoriaSeleccionada = v ?? '';
                      });
                    },
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: CustomActionButton(
                          onPressed: () {
                            final monto =
                                double.tryParse(montoController.text) ?? 0.0;
                            setState(() {
                              goal['current'] = (goal['current'] + monto).clamp(
                                0,
                                goal['total'],
                              );
                              totalBalance += monto;

                              movements.insert(0, {
                                'title': descripcionController.text.isEmpty
                                    ? goal['title']
                                    : descripcionController.text,
                                'amount': monto,
                                'date': _formatDate(),
                                'category':
                                    (categories.firstWhere(
                                      (c) =>
                                          (c['id'] ?? '').toString() ==
                                          categoriaSeleccionada,
                                      orElse: () => {},
                                    )['name']) ??
                                    categoriaSeleccionada,
                                'categoryId': categoriaSeleccionada,
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
                            final monto =
                                double.tryParse(montoController.text) ?? 0.0;
                            _safeSetState(() {
                              goal['current'] = max(0, goal['current'] - monto);
                              totalBalance -= monto;
                              monthlyBudget += monto;

                              movements.insert(0, {
                                'title': descripcionController.text.isEmpty
                                    ? goal['title']
                                    : descripcionController.text,
                                'amount': -monto,
                                'date': _formatDate(),
                                'category':
                                    (categories.firstWhere(
                                      (c) =>
                                          (c['id'] ?? '').toString() ==
                                          categoriaSeleccionada,
                                      orElse: () => {},
                                    )['name']) ??
                                    categoriaSeleccionada,
                                'categoryId': categoriaSeleccionada,
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
  void _showAddTransactionModal(
    BuildContext context, {
    required bool isIncome,
  }) {
    final montoController = TextEditingController();
    final descripcionController = TextEditingController();

    final categorias = categories;
    String categoriaSeleccionada = isIncome
        ? (categorias.firstWhere(
                    (c) => (c['type'] ?? 'income') == 'income',
                    orElse: () =>
                        (categorias.isNotEmpty ? categorias.first : {}),
                  )['id'] ??
                  '')
              .toString()
        : (categorias.isNotEmpty
              ? (categorias.first['id'] ?? '').toString()
              : '');

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
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
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
                    value: categoriaSeleccionada.isEmpty
                        ? null
                        : categoriaSeleccionada,
                    decoration: InputDecoration(
                      labelText: 'Categoría',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                    ),
                    items: categorias
                        .map(
                          (c) => DropdownMenuItem<String>(
                            value: (c['id'] ?? '').toString(),
                            child: Text((c['name'] ?? 'Otros').toString()),
                          ),
                        )
                        .toList(),
                    onChanged: (v) {
                      setModalState(() {
                        categoriaSeleccionada = v ?? '';
                      });
                    },
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: CustomActionButton(
                      onPressed: () async {
                        final monto =
                            double.tryParse(montoController.text) ?? 0.0;

                        if (monto <= 0) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Por favor ingresa un monto válido',
                              ),
                              backgroundColor: Colors.orange,
                            ),
                          );
                          return;
                        }

                        if (descripcionController.text.trim().isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Por favor ingresa una descripción',
                              ),
                              backgroundColor: Colors.orange,
                            ),
                          );
                          return;
                        }

                        // llamar al backend para crear transacción (backend crea/encuentra cuenta principal)
                        try {
                          final amount = isIncome ? monto : -monto;
                          final createdResp =
                              await TransactionService.createTransaction(
                                amount: monto,
                                type: isIncome ? 'income' : 'expense',
                                note: descripcionController.text.trim(),
                                categoryId: categoriaSeleccionada,
                              );

                          // backend devuelve { message, transaction, newBalance }
                          final created =
                              createdResp['transaction'] ?? createdResp;
                          final newBalanceRaw = createdResp['newBalance'];
                          final newBalance = newBalanceRaw != null
                              ? _toDouble(newBalanceRaw)
                              : null;

                          _safeSetState(() {
                            // si backend devuelve newBalance, usarlo; si no, actualizar localmente
                            if (newBalance != null)
                              totalBalance = newBalance;
                            else
                              totalBalance += amount;

                            if (!isIncome) monthlyBudget += monto;

                            final rawDate = created != null
                                ? (created['occurredAt'] ??
                                      created['createdAt'])
                                : null;

                            movements.insert(0, {
                              'id': created != null
                                  ? (created['id'] ??
                                        created['_id'] ??
                                        created['transactionId'])
                                  : null,
                              'title': descripcionController.text.trim(),
                              'amount': amount,
                              'date': _formatDisplayDate(
                                rawDate ?? _formatDate(),
                              ),
                              'category':
                                  (categories.firstWhere(
                                    (c) =>
                                        (c['id'] ?? '').toString() ==
                                        categoriaSeleccionada,
                                    orElse: () => {},
                                  )['name']) ??
                                  categoriaSeleccionada,
                              'categoryId': categoriaSeleccionada,
                            });
                          });

                          Navigator.pop(context);

                          if (mounted)
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  isIncome
                                      ? '✓ Ingreso agregado correctamente'
                                      : '✓ Gasto registrado correctamente',
                                ),
                                backgroundColor: isIncome
                                    ? Colors.green
                                    : Colors.red,
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          // refresh data from backend after creation
                          if (mounted) await _loadHomeData();
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Error creando transacción: $e'),
                              backgroundColor: Colors.orange,
                            ),
                          );
                        }
                      },
                      backgroundColor: isIncome
                          ? Colors.green.shade500
                          : Colors.red.shade500,
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 0,
      ),
      icon: Icon(icon, size: 18),
      label: Text(
        label,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
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
    Key? key,
    required this.title,
    required this.amount,
    required this.date,
    required this.category,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isNegative = amount < 0;
    return ListTile(
      title: Text(title.isEmpty ? category : title),
      subtitle: Text('$date | $category'),
      trailing: Text(
        'S/ ${amount.toStringAsFixed(2)}',
        style: TextStyle(
          color: isNegative ? Colors.red : Colors.green,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
