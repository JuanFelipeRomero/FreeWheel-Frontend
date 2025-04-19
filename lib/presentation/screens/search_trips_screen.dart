import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class SearchTripsScreen extends StatelessWidget {
  const SearchTripsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Obtener colores del tema actual
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;
    final surfaceColor = theme.colorScheme.surface;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Buscar viajes',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
        ),
        backgroundColor: surfaceColor,
        foregroundColor: theme.colorScheme.onSurface,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
        child: Column(
          children: [
            // Origen
            _buildInputField(
              context: context,
              icon: FontAwesomeIcons.locationDot,
              title: 'Desde',
              onTap: () {
                print('Abrir selector de Origen');
                // Aquí llamarías a la lógica para seleccionar el origen
              },
            ),

            // Destino
            _buildInputField(
              context: context,
              icon: FontAwesomeIcons.locationDot,
              title: 'Hasta',
              onTap: () {
                print('Abrir selector de Destino');
              },
            ),

            // Fecha
            _buildInputField(
              context: context,
              icon: FontAwesomeIcons.calendar,
              title: 'Fecha',
              trailing: Text(
                'DD/MM/AAAA',
                style: TextStyle(color: Colors.grey.shade500),
              ),
              onTap: () {
                print('Abrir selector de Fecha');
                // Lógica para mostrar un DatePicker
                showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                  builder: (context, child) {
                    return Theme(
                      data: Theme.of(context).copyWith(
                        colorScheme: Theme.of(
                          context,
                        ).colorScheme.copyWith(primary: primaryColor),
                      ),
                      child: child!,
                    );
                  },
                );
              },
            ),

            // Numero de asientos
            _buildInputField(
              context: context,
              icon: FontAwesomeIcons.users,
              title: 'Número de asientos',
              trailing: const Text('1'),
              onTap: () {
                print('Abrir selector de Asientos');
                // Aquí llamarías a la lógica para seleccionar el número de asientos
              },
            ),

            const Spacer(),

            // Botón de búsqueda
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  // Lógica para buscar viajes
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Buscar viajes',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField({
    required BuildContext context,
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Widget? trailing,
  }) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: ListTile(
          leading: Icon(icon, color: theme.colorScheme.primary),
          title: Text(
            title,
            style: TextStyle(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              fontSize: 16,
            ),
          ),
          trailing: trailing,
        ),
      ),
    );
  }
}
