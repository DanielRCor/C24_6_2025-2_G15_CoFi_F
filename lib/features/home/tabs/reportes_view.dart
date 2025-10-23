import 'package:flutter/material.dart';
import 'dart:math';
import '../../../core/services/report_service.dart';

class ReportesView extends StatefulWidget {
  const ReportesView({super.key});

  @override
  State<ReportesView> createState() => _ReportesViewState();
}

class _ReportesViewState extends State<ReportesView> {
  // Estado para los toggles
  bool isPersonal = true;
  int periodo = 0; // 0: Semana, 1: Mes, 2: Año
  // ReportService
  final ReportService _reportService = ReportService();
  bool _loading = true;
  String? _error;
  Map<String, dynamic>? _generalReport;
  List<Map<String, dynamic>> _categories = [];
  bool _showEvolution = true;

  @override
  void initState() {
    super.initState();
    _loadReports();
  }

  Future<void> _loadReports() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    // Fetch general report
    try {
      final general = await _reportService.getGeneralReport();
      setState(() {
        _generalReport = general;
      });
    } catch (e) {
      // keep going, but record error
      setState(() {
        _error = (_error == null)
            ? 'Error al obtener reporte general: $e'
            : '$_error; reporte general: $e';
      });
    }

    // Fetch categories
    try {
      final categories = await _reportService.getCategoryReport();
      setState(() {
        _categories = categories;
      });
    } catch (e) {
      setState(() {
        // leave categories empty and record error
        _categories = [];
        _error = (_error == null)
            ? 'Error al obtener reporte por categoría: $e'
            : '$_error; categorías: $e';
      });
    }

    // Fetch monthly/evolution report to decide whether to show the evolution chart
    try {
      final monthly = await _reportService.getMonthlyReport();
      setState(() {
        _showEvolution = monthly.isNotEmpty;
      });
    } catch (e) {
      setState(() {
        // if monthly fails, hide evolution chart but keep UI
        _showEvolution = false;
        _error = (_error == null)
            ? 'Error al obtener reporte mensual: $e'
            : '$_error; mensual: $e';
      });
    }

    setState(() {
      _loading = false;
    });
  }

  String _formatCurrency(dynamic value) {
    try {
      final numVal = (value ?? 0) as num;
      return 'S/ ${numVal.toStringAsFixed(0)}';
    } catch (_) {
      return 'S/ 0';
    }
  }

  @override
  Widget build(BuildContext context) {
    // Local shortcuts
    final isLoading = _loading;
    final error = _error;
    final general = _generalReport;
    final categories = _categories;

    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // We always render the main UI; if there are backend errors, show a compact banner
    final banner = (error != null)
        ? MaterialBanner(
            content: const Text('Hubo problemas cargando algunos reportes.'),
            leading: const Icon(Icons.error_outline, color: Colors.red),
            actions: [
              TextButton(
                onPressed: () {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text(error)));
                },
                child: const Text('Detalles'),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    _error = null; // dismiss banner
                  });
                },
                child: const Text('Cerrar'),
              ),
            ],
          )
        : null;

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Banner de error si existe
            if (banner != null) banner,

            // Encabezado y botón de Categorias
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Reportes',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Financieros',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                // Botón Categorías
                OutlinedButton.icon(
                  onPressed: () {},
                  icon: Icon(Icons.category, color: Colors.green[700]),
                  label: const Text(
                    'Categorías',
                    style: TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.green.shade300),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 22),
            const Text(
              'Análisis detallado de tus finanzas',
              style: TextStyle(fontSize: 16, color: Colors.black54),
            ),
            const SizedBox(height: 32),
            // Selector de Vista: Personal / Grupos
            Row(
              children: [
                const Text(
                  'Vista:',
                  style: TextStyle(fontSize: 16, color: Colors.black87),
                ),
                const SizedBox(width: 18),
                ToggleButtons(
                  isSelected: [isPersonal, !isPersonal],
                  borderRadius: BorderRadius.circular(22),
                  selectedColor: Colors.white,
                  color: Colors.black87,
                  fillColor: Colors.green,
                  borderColor: Colors.green,
                  selectedBorderColor: Colors.green,
                  constraints: const BoxConstraints(
                    minHeight: 38,
                    minWidth: 100,
                  ),
                  onPressed: (index) {
                    setState(() {
                      isPersonal = index == 0;
                    });
                  },
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.person, size: 20),
                        SizedBox(width: 6),
                        Text(
                          'Personal',
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.groups, size: 20),
                        SizedBox(width: 6),
                        Text(
                          'Grupos',
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 28),
            // Selector de Periodo: Semana / Mes / Año
            Row(
              children: [
                const Text(
                  'Periodo:',
                  style: TextStyle(fontSize: 16, color: Colors.black87),
                ),
                const SizedBox(width: 18),
                ToggleButtons(
                  isSelected: [periodo == 0, periodo == 1, periodo == 2],
                  borderRadius: BorderRadius.circular(22),
                  selectedColor: Colors.white,
                  color: Colors.black87,
                  fillColor: Colors.green,
                  borderColor: Colors.green,
                  selectedBorderColor: Colors.green,
                  constraints: const BoxConstraints(
                    minHeight: 38,
                    minWidth: 76,
                  ),
                  onPressed: (index) {
                    setState(() {
                      periodo = index;
                    });
                  },
                  children: const [
                    Text(
                      'Semana',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    Text('Mes', style: TextStyle(fontWeight: FontWeight.w500)),
                    Text('Año', style: TextStyle(fontWeight: FontWeight.w500)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 32),
            // Mock estático de reportes: métricas, gráfico de barras, pie chart y resumen
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Row de métricas
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _metricCard(
                      'Gastos',
                      _formatCurrency(general?['expenses'] ?? 0),
                      Colors.redAccent,
                    ),
                    _metricCard(
                      'Ingresos',
                      _formatCurrency(general?['income'] ?? 0),
                      Colors.green,
                    ),
                    _metricCard(
                      'Balance',
                      _formatCurrency(general?['balance'] ?? 0),
                      Colors.green.shade700,
                    ),
                  ],
                ),
                const SizedBox(height: 18),

                // Tabs simulados (Resumen / Análisis)
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'Resumen General',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Opacity(
                        opacity: 0.8,
                        child: Text('Análisis Detallado'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),

                // Card: Evolución (mock gráfico de barras y línea)
                if (_showEvolution)
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Evolución Diaria - Personal',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Ingresos vs Gastos en el último año',
                            style: TextStyle(color: Colors.black54),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            height: 110,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: List.generate(12, (i) {
                                // barras rojas de ejemplo
                                final heights = [
                                  40,
                                  60,
                                  55,
                                  70,
                                  50,
                                  80,
                                  45,
                                  60,
                                  75,
                                  50,
                                  65,
                                  90,
                                ];
                                return Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 4,
                                    ),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Container(
                                          height: heights[i].toDouble(),
                                          decoration: BoxDecoration(
                                            color: Colors.redAccent,
                                            borderRadius: BorderRadius.circular(
                                              6,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          _shortMonth(i),
                                          style: const TextStyle(
                                            fontSize: 10,
                                            color: Colors.black54,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Text(
                      'No hay datos suficientes para mostrar la evolución (aún no hay periodo completado).',
                      style: TextStyle(color: Colors.black54),
                    ),
                  ),
                const SizedBox(height: 14),

                // Card: Pie chart mock + distribución
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Distribución por Categorías',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Tus gastos organizados por categoría',
                          style: TextStyle(color: Colors.black54),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            // Pie chart segmentado (estático)
                            SizedBox(
                              width: 90,
                              height: 90,
                              child: _StaticPieChart(
                                values: categories.isNotEmpty
                                    ? categories
                                          .map<double>(
                                            (c) =>
                                                ((c['percentage'] ?? 0) as num)
                                                    .toDouble(),
                                          )
                                          .toList()
                                    : const [30, 20, 23, 14, 13],
                                colors: const [
                                  Colors.red,
                                  Colors.blue,
                                  Colors.green,
                                  Colors.orange,
                                  Colors.purple,
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),
                            // Legend
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  for (
                                    var i = 0;
                                    i <
                                        (categories.isNotEmpty
                                            ? categories.length
                                            : 5);
                                    i++
                                  )
                                    _LegendItem(
                                      color: [
                                        Colors.red,
                                        Colors.blue,
                                        Colors.green,
                                        Colors.orange,
                                        Colors.purple,
                                      ][i % 5],
                                      text: categories.isNotEmpty
                                          ? '${categories[i]['name']}: ${categories[i]['percentage']}%'
                                          : [
                                              'Comida: 30%',
                                              'Transporte: 20%',
                                              'Servicios: 23%',
                                              'Compras: 14%',
                                              'Entretenimiento: 13%',
                                            ][i],
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                // Card: Resumen por Categorías (progreso)
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Resumen por Categorías',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 12),
                        _categoryRow('Alimentación', 'S/ 120', 0.4, Colors.red),
                        const SizedBox(height: 8),
                        _categoryRow('Suministros', 'S/ 90', 0.3, Colors.blue),
                        const SizedBox(height: 8),
                        _categoryRow('Decoración', 'S/ 60', 0.2, Colors.orange),
                        const SizedBox(height: 8),
                        _categoryRow('Tecnología', 'S/ 30', 0.1, Colors.green),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ], // end inner Column children
            ), // end inner Column
          ], // end outer Column children
        ), // end outer Column
      ), // end Padding
    ); // end SingleChildScrollView
  }

  // Helper: tarjeta de métrica
  Widget _metricCard(String title, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        margin: const EdgeInsets.symmetric(horizontal: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 6,
              offset: Offset(0, 2),
            ),
          ],
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: TextStyle(color: Colors.black54, fontSize: 12)),
            const SizedBox(height: 6),
            Text(
              value,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper: abreviatura de mes
  String _shortMonth(int index) {
    const months = [
      'Ene',
      'Feb',
      'Mar',
      'Abr',
      'May',
      'Jun',
      'Jul',
      'Ago',
      'Sep',
      'Oct',
      'Nov',
      'Dic',
    ];
    return months[index % 12];
  }

  // Helper: fila de categoría con progreso
  Widget _categoryRow(
    String title,
    String amount,
    double progress,
    Color color,
  ) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
              const SizedBox(height: 6),
              LinearProgressIndicator(
                value: progress,
                color: color,
                backgroundColor: color.withOpacity(0.2),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Text(amount, style: const TextStyle(fontWeight: FontWeight.w600)),
      ],
    );
  }
}

// Legend item widget (const constructor so it can be used in const lists)
class _LegendItem extends StatelessWidget {
  final Color color;
  final String text;
  const _LegendItem({Key? key, required this.color, required this.text})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          const SizedBox(width: 8),
          Text(text, style: const TextStyle(fontSize: 13)),
        ],
      ),
    );
  }
}

// Static pie chart widget
class _StaticPieChart extends StatelessWidget {
  final List<double> values;
  final List<Color> colors;
  const _StaticPieChart({Key? key, required this.values, required this.colors})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _PiePainter(values: values, colors: colors),
      size: Size.infinite,
    );
  }
}

class _PiePainter extends CustomPainter {
  final List<double> values;
  final List<Color> colors;
  _PiePainter({required this.values, required this.colors});

  @override
  void paint(Canvas canvas, Size size) {
    final total = values.fold(0.0, (a, b) => a + b);
    final rect = Offset.zero & size;
    final center = rect.center;
    final radius = (size.shortestSide) / 2;

    var startRadian = -pi / 2; // start at top
    final paint = Paint()..style = PaintingStyle.fill;

    for (var i = 0; i < values.length; i++) {
      final sweepRadian = (values[i] / total) * 2 * pi;
      paint.color = colors[i % colors.length];
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startRadian,
        sweepRadian,
        true,
        paint,
      );

      // draw separator line
      final separatorPaint = Paint()
        ..color = Colors.white.withOpacity(0.9)
        ..strokeWidth = 1.5
        ..style = PaintingStyle.stroke;
      final p1 = center;
      final p2 = Offset(
        center.dx + radius * cos(startRadian),
        center.dy + radius * sin(startRadian),
      );
      canvas.drawLine(p1, p2, separatorPaint);

      startRadian += sweepRadian;
    }

    // draw inner subtle border
    final borderPaint = Paint()
      ..color = Colors.black.withOpacity(0.04)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawCircle(center, radius, borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
