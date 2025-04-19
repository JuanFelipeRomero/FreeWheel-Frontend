import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart'; // Importa el paquete intl

// 1. Cambia a StatefulWidget
class SearchTripsScreen extends StatefulWidget {
  const SearchTripsScreen({super.key});

  @override
  // 2. Crea el State
  State<SearchTripsScreen> createState() => _SearchTripsScreenState();
}

// 3. Define la clase State
class _SearchTripsScreenState extends State<SearchTripsScreen> {
  // --- Variables de Estado ---
  DateTime? _selectedDate; // Para guardar la fecha seleccionada (nullable)
  int _numberOfSeats =
      1; // Para guardar el número de asientos (con valor inicial)
  // --- Fin Variables de Estado ---

  // 4. Mueve el método build aquí dentro
  @override
  Widget build(BuildContext context) {
    // Obtener colores del tema actual
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;
    final surfaceColor =
        theme
            .colorScheme
            .surface; // Puedes usar surface directamente si quieres

    // Formateador de fecha (requiere el paquete intl)
    // Asegúrate de añadir 'intl: ^latest' a tu pubspec.yaml y correr 'flutter pub get'
    final DateFormat dateFormatter = DateFormat('dd/MM/yyyy');

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Buscar viajes',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
        ),
        backgroundColor: theme.colorScheme.surface, // Usar surface del tema
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
              title: 'Lugar de origen',
              onTap: () {
                print('Abrir selector de Origen');
                // Aquí llamarías a la lógica para seleccionar el origen
              },
            ),

            // Destino
            _buildInputField(
              context: context,
              icon: FontAwesomeIcons.locationDot,
              title: 'Lugar de destino',
              onTap: () {
                print('Abrir selector de Destino');
              },
            ),

            // --- Fecha ---
            _buildInputField(
              context: context,
              icon: FontAwesomeIcons.calendar,
              title: 'Fecha',
              // Muestra la fecha seleccionada o el placeholder
              displayValue:
                  _selectedDate == null
                      ? 'DD/MM/AAAA' // Placeholder si no hay fecha
                      : dateFormatter.format(
                        _selectedDate!,
                      ), // Fecha formateada
              textColor:
                  _selectedDate == null
                      ? Colors.grey.shade500
                      : null, // Color gris para placeholder
              onTap: () async {
                // <--- Marcar como async
                print('Abrir selector de Fecha');
                // Lógica para mostrar un DatePicker y obtener el resultado
                final DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate:
                      _selectedDate ??
                      DateTime.now(), // Usa fecha seleccionada o hoy
                  firstDate: DateTime.now(), // No permitir fechas pasadas
                  lastDate: DateTime.now().add(
                    const Duration(days: 365),
                  ), // Límite de un año
                  builder: (context, child) {
                    // Para aplicar el tema correctamente al picker
                    return Theme(
                      data: Theme.of(context).copyWith(
                        colorScheme: Theme.of(context).colorScheme.copyWith(
                          primary: primaryColor, // Color primario del picker
                        ),
                      ),
                      child: child!,
                    );
                  },
                );

                // Si el usuario seleccionó una fecha (no canceló)
                if (pickedDate != null) {
                  // Actualiza el estado con la nueva fecha
                  setState(() {
                    _selectedDate = pickedDate;
                  });
                }
              },
            ),
            // --- Fin Fecha ---

            // --- Numero de asientos ---
            _buildInputField(
              context: context,
              icon: FontAwesomeIcons.users,
              title: 'Número de asientos',
              // Muestra el número de asientos actual
              displayValue: _numberOfSeats.toString(),
              onTap: () async {
                // Llama a la función que muestra el diálogo
                final int? selectedSeats = await _showSeatSelectorDialog();
                // Si el usuario seleccionó un número (no canceló)
                if (selectedSeats != null) {
                  // Actualiza el estado con el nuevo número
                  setState(() {
                    _numberOfSeats = selectedSeats;
                  });
                }
              },
            ),

            // --- Fin Numero de asientos ---
            const Spacer(), // Empuja el botón al final
            // Botón de búsqueda
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  // Lógica para buscar viajes usando _selectedDate y _numberOfSeats
                  if (_selectedDate != null) {
                    print(
                      'Buscando viaje para el ${dateFormatter.format(_selectedDate!)} con $_numberOfSeats asientos',
                    );
                  } else {
                    print('Por favor selecciona una fecha');
                    // Podrías mostrar un mensaje al usuario aquí
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white, // Color del texto en el botón
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

  // 5. Mueve el método _buildInputField aquí dentro
  //    (Modificado para aceptar displayValue y textColor opcionales)
  Widget _buildInputField({
    required BuildContext context,
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    String? displayValue, // Valor a mostrar (fecha formateada, número asientos)
    Color? textColor, // Para cambiar color del texto (ej. placeholder gris)
    Widget?
    trailing, // Mantenemos trailing por si acaso, pero priorizamos displayValue
  }) {
    final theme = Theme.of(context);
    final defaultTextColor = theme.colorScheme.onSurface.withOpacity(0.9);

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
        color: theme.colorScheme.surface, // Color de fondo del contenedor
        boxShadow: [
          BoxShadow(
            // color: theme.shadowColor.withOpacity(0.1), // Sombra más sutil
            color: Colors.grey.withOpacity(0.1), // Sombra más sutil
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      margin: const EdgeInsets.only(bottom: 18), // Reducir un poco el margen
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: ListTile(
          leading: Icon(
            icon,
            color: theme.colorScheme.primary,
            size: 20,
          ), // Icono más pequeño
          title: Text(
            title,
            style: TextStyle(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
              fontSize: 15, // Tamaño de fuente ligeramente menor
            ),
          ),
          trailing:
              displayValue != null
                  ? Text(
                    displayValue,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color:
                          textColor ??
                          defaultTextColor, // Usa color provisto o default
                    ),
                  )
                  : trailing, // Usa el trailing original si no hay displayValue
        ),
      ),
    );
  }

  // --- Método para mostrar el diálogo del selector de asientos ---
  Future<int?> _showSeatSelectorDialog() async {
    // Guarda el valor actual para poder restaurarlo si cancelan
    int currentSelection = _numberOfSeats;
    return showDialog<int>(
      // Especifica que el diálogo devuelve un int?
      context: context,
      builder: (BuildContext context) {
        // Usa StatefulBuilder para que el contenido del diálogo pueda actualizarse
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Número de asientos'),
              content: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  IconButton(
                    icon: const Icon(Icons.remove_circle_outline),
                    onPressed:
                        currentSelection >
                                1 // No permitir menos de 1 asiento
                            ? () {
                              setDialogState(() {
                                // Actualiza solo el estado del diálogo
                                currentSelection--;
                              });
                            }
                            : null, // Deshabilita el botón si es 1
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  SizedBox(
                    width: 40, // Ancho fijo para el número
                    child: Text(
                      '$currentSelection',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline),
                    onPressed:
                        currentSelection <
                                8 // Limitar a 8 asientos (o el límite que quieras)
                            ? () {
                              setDialogState(() {
                                // Actualiza solo el estado del diálogo
                                currentSelection++;
                              });
                            }
                            : null, // Deshabilita si llega al límite
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ],
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('Cancelar'),
                  onPressed: () {
                    Navigator.of(
                      context,
                    ).pop(null); // Devuelve null al cancelar
                  },
                ),
                TextButton(
                  child: const Text('Aceptar'),
                  onPressed: () {
                    Navigator.of(
                      context,
                    ).pop(currentSelection); // Devuelve el valor seleccionado
                  },
                ),
              ],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ), // Bordes redondeados para el diálogo
            );
          },
        );
      },
    );
  }

  // --- Fin método selector de asientos ---
}
