import 'package:flutter/material.dart';

class ReportesView extends StatefulWidget {
  const ReportesView({super.key});

  @override
  State<ReportesView> createState() => _ReportesViewState();
}

class _ReportesViewState extends State<ReportesView> {
  // Estado para los toggles
  bool isPersonal = true;
  int periodo = 0; // 0: Semana, 1: Mes, 2: Año

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 36),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Encabezado y botón de Categorias
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Reportes',
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Financieros',
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
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
                constraints: const BoxConstraints(minHeight: 38, minWidth: 100),
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
                constraints: const BoxConstraints(minHeight: 38, minWidth: 76),
                onPressed: (index) {
                  setState(() {
                    periodo = index;
                  });
                },
                children: const [
                  Text('Semana', style: TextStyle(fontWeight: FontWeight.w500)),
                  Text('Mes', style: TextStyle(fontWeight: FontWeight.w500)),
                  Text('Año', style: TextStyle(fontWeight: FontWeight.w500)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 48),
          // Mensaje de "Todavía no tienes reportes Financieros"
          const Center(
            child: Text(
              'Todavía no tienes reportes Financieros',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ),
        ],
      ),
    );
  }
}
