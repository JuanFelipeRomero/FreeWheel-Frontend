import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:freewheel_frontend/data/models/place_models.dart';
import 'package:freewheel_frontend/data/services/create_trip_service.dart';
import 'package:freewheel_frontend/data/services/auth_service.dart';
import 'package:freewheel_frontend/presentation/screens/place_search_screen.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

class CreateTripScreen extends StatefulWidget {
  const CreateTripScreen({super.key});
  @override
  State<CreateTripScreen> createState() => _CreateTripScreenState();
}

class _CreateTripScreenState extends State<CreateTripScreen> {
  final _uuid = const Uuid();
  final String kGoogleApiKey = dotenv.env['GOOGLE_API_KEY'] ?? "";
  PlaceResult? _originResult;
  PlaceResult? _destinationResult;

  // Removed conductorId text field and controller
  DateTime? _selectedDate;
  TimeOfDay? _selectedStartTime;
  TimeOfDay? _selectedEndTime;
  final TextEditingController _fechaController = TextEditingController();
  final TextEditingController _horaInicioController = TextEditingController();
  final TextEditingController _precioAsientoController = TextEditingController();
  final TextEditingController _asientosDisponiblesController = TextEditingController();

  bool _isLoading = false;
  final CreateTripService _createTripService = CreateTripService();
  final AuthService _authService = AuthService();

  Future<void> _handlePlaceSelection({required bool isOrigin}) async {
    if (kGoogleApiKey.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Google API key not configured.')),
      );
      return;
    }
    final sessionToken = _uuid.v4();
    final PlaceResult? result = await Navigator.push<PlaceResult>(
      context,
      MaterialPageRoute(
        builder: (context) => PlaceSearchScreen(sessionToken: sessionToken),
      ),
    );
    if (result != null) {
      setState(() {
        if (isOrigin) {
          _originResult = result;
        } else {
          _destinationResult = result;
        }
      });
    }
  }

  Future<void> _selectDate() async {
    final DateTime now = DateTime.now();
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );
    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
        _fechaController.text = DateFormat('yyyy-MM-dd').format(pickedDate);
      });
    }
  }

  Future<void> _selectTime({required bool isStart}) async {
    final TimeOfDay initialTime = TimeOfDay.now();
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: isStart ? (_selectedStartTime ?? initialTime) : (_selectedEndTime ?? initialTime),
    );
    if (pickedTime != null) {
      setState(() {
        if (isStart) {
          _selectedStartTime = pickedTime;
          _horaInicioController.text = _formatTimeOfDay(pickedTime);
        }
      });
    }
  }

  String _formatTimeOfDay(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  // dart
  Future<void> _showPriceDialog() async {
    int? enteredPrice;
    final TextEditingController priceController = TextEditingController(
      text: _precioAsientoController.text,
    );
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Precio por asiento'),
        content: TextField(
          controller: priceController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(hintText: 'Precio'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              final value = int.tryParse(priceController.text);
              if (value == null || value < 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('El precio debe ser mayor a 0')),
                );
              } else {
                enteredPrice = value;
                Navigator.of(context).pop();
              }
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
    if (enteredPrice != null) {
      setState(() {
        _precioAsientoController.text = enteredPrice.toString();
      });
    }
  }

  // dart
  Future<void> _showSeatSelectorDialog() async {
    // Get the current selection or default to 1
    int currentSelection = int.tryParse(_asientosDisponiblesController.text) ?? 1;
    final int? selectedSeats = await showDialog<int>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Número de asientos'),
              content: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  IconButton(
                    icon: const Icon(Icons.remove_circle_outline),
                    onPressed: currentSelection > 1
                        ? () {
                      setDialogState(() {
                        currentSelection--;
                      });
                    }
                        : null,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  SizedBox(
                    width: 40,
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
                    onPressed: currentSelection < 8
                        ? () {
                      setDialogState(() {
                        currentSelection++;
                      });
                    }
                        : null,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ],
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('Cancelar'),
                  onPressed: () {
                    Navigator.of(context).pop(null);
                  },
                ),
                TextButton(
                  child: const Text('Aceptar'),
                  onPressed: () {
                    Navigator.of(context).pop(currentSelection);
                  },
                ),
              ],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
            );
          },
        );
      },
    );
    if (selectedSeats != null) {
      setState(() {
        _asientosDisponiblesController.text = selectedSeats.toString();
      });
    }
  }

  void _submitTrip() async {
    if (_originResult == null || _destinationResult == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Debes seleccionar un origen y un destino')),
      );
      return;
    }
    if (_fechaController.text.isEmpty ||
        _horaInicioController.text.isEmpty ||
        _precioAsientoController.text.isEmpty ||
        _asientosDisponiblesController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Completa todos los campos')),
      );
      return;
    }


    setState(() {
      _isLoading = true;
    });
    final userData = await _authService.getUserData();
    final conductorId = userData?['conductorId'];
    if (conductorId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Conductor ID not available.')),
      );
      setState(() {
        _isLoading = false;
      });
      return;
    }
    final response = await _createTripService.createTrip(
      conductorId: conductorId.toString(),
      fecha: _fechaController.text,
      horaInicio: _horaInicioController.text,
      horaFin: null,
      precioAsiento: double.tryParse(_precioAsientoController.text) ?? 0,
      asientosDisponibles: int.tryParse(_asientosDisponiblesController.text) ?? 0,
      direccionOrigen: _originResult!.description,
      latitudOrigen: _originResult!.lat!,
      longitudOrigen: _originResult!.lng!,
      direccionDestino: _destinationResult!.description,
      latitudDestino: _destinationResult!.lat!,
      longitudDestino: _destinationResult!.lng!,
      estado: 'por iniciar',
    );

    // Console log showing the complete response
    print("Complete response -> success: ${response.success}, message: ${response.message}");

    setState(() {
      _isLoading = false;
    });
    if (response.success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Viaje publicado exitosamente')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ocurrio un error en la pulbicacion del viaje')),
      );
    }
  }

// dart
  Widget _buildInputField({
    required BuildContext context,
    IconData? icon,
    String? title,
    required Widget child,
    VoidCallback? onTap,
  }) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      margin: const EdgeInsets.only(bottom: 18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
          child: Row(
            children: [
              if (icon != null) ...[
                Icon(icon, color: theme.colorScheme.primary, size: 20),
                const SizedBox(width: 16),
              ],
              if (title != null)
                Expanded(
                  flex: 2,
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                ),
              Expanded(
                flex: 3,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: child,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final DateFormat dateFormatter = DateFormat('yyyy-MM-dd');
    return Scaffold(
      appBar: AppBar(title: const Text('Publicar viaje')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildInputField(
              context: context,
              icon: FontAwesomeIcons.calendar,
              title: 'Fecha',
              child: Text(
                _selectedDate == null ? 'DD/MM/AAAA' : dateFormatter.format(_selectedDate!),
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: _selectedDate == null ? Colors.grey.shade500 : Colors.black,
                ),
              ),
              onTap: _selectDate,
            ),
            _buildInputField(
              context: context,
              icon: FontAwesomeIcons.clock,
              title: 'Hora Inicio',
              child: Text(
                _selectedStartTime == null ? 'HH:mm' : _selectedStartTime!.format(context),
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: _selectedStartTime == null ? Colors.grey.shade500 : Colors.black,
                ),
              ),
              onTap: () => _selectTime(isStart: true),
            ),

            _buildInputField(
              context: context,
              icon: FontAwesomeIcons.dollarSign,
              title: 'Precio Asiento',
              child: Text(
                _precioAsientoController.text.isEmpty ? '0' : _precioAsientoController.text + " cop",
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: _precioAsientoController.text.isEmpty ? Colors.grey.shade500 : Colors.black,
                ),
              ),
              onTap: _showPriceDialog,
            ),
            _buildInputField(
              context: context,
              icon: FontAwesomeIcons.users,
              title: 'Asientos Disponibles',
              child: Text(
                _asientosDisponiblesController.text.isEmpty
                    ? '1'
                    : _asientosDisponiblesController.text,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: _asientosDisponiblesController.text.isEmpty
                      ? Colors.grey.shade500
                      : Colors.black,
                ),
              ),
              onTap: _showSeatSelectorDialog,
            ),
            _buildInputField(
              context: context,
              icon: FontAwesomeIcons.locationDot,
              title: 'Origen', // no title
              child: Text(
                _originResult == null ? 'Selecciona el origen' : _originResult!.description,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: _originResult == null ? Colors.grey.shade500 : Colors.black,
                ),
              ),
              onTap: () => _handlePlaceSelection(isOrigin: true),
            ),

            _buildInputField(
              context: context,
              icon: FontAwesomeIcons.locationDot,
              title: 'Destino', // no title
              child: Text(
                _destinationResult == null ? 'Selecciona el destino' : _destinationResult!.description,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: _destinationResult == null ? Colors.grey.shade500 : Colors.black,
                ),
              ),
              onTap: () => _handlePlaceSelection(isOrigin: false),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,

              child: ElevatedButton(
                onPressed: _isLoading ? null : _submitTrip,
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(
                    Colors.blueAccent,
                  ),
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  minimumSize: MaterialStateProperty.all<Size>(
                    // Added minimum size like in register screen
                    const Size(250, 50),
                  ),
                ),
                child: const Text('Publicar viaje', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}