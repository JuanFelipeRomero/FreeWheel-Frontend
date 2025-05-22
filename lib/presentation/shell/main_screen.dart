import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:freewheel_frontend/data/services/auth_service.dart';
import 'package:freewheel_frontend/data/state/trip_state.dart';
import 'package:freewheel_frontend/presentation/screens/active_trip_screen.dart';
import 'package:freewheel_frontend/presentation/screens/driver_screen.dart';
import 'package:freewheel_frontend/presentation/screens/home_screen.dart';
import 'package:freewheel_frontend/presentation/screens/profile_screen.dart';
import 'package:freewheel_frontend/presentation/screens/search_trips_screen.dart';
import 'package:provider/provider.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  static const double _iconSize = 24.0;
  bool _isDriver = false;
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _checkDriverStatus();
  }

  Future<void> _checkDriverStatus() async {
    final isDriver = await _authService.isDriver();
    setState(() {
      _isDriver = isDriver;
    });
  }

  List<Widget> _getWidgetOptions(TripState tripState) {
    final List<Widget> options = [
      const HomeScreen(),
      const SearchTripsScreen(),
    ];

    // Add conductor screen only if user is a driver
    if (_isDriver) {
      options.add(const DriverScreen());
    }

    // Profile is always the last option
    options.add(const ProfileScreen());

    return options;
  }

  void _onItemTapped(int index, TripState tripState) {
    if (index == 0 && tripState.isTripActive && tripState.activeTrip != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ActiveTripScreen(trip: tripState.activeTrip!),
        ),
      );
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final tripState = Provider.of<TripState>(context);
    final List<Widget> widgetOptions = _getWidgetOptions(tripState);

    return Scaffold(
      body: Center(child: widgetOptions.elementAt(_selectedIndex)),

      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Colors.grey.shade600,
        selectedFontSize: 12.0,
        unselectedFontSize: 12.0,
        showSelectedLabels: true,
        showUnselectedLabels: false,
        type: BottomNavigationBarType.fixed,

        items: [
          BottomNavigationBarItem(
            icon: FaIcon(
              tripState.isTripActive
                  ? FontAwesomeIcons.route
                  : FontAwesomeIcons.house,
              size: _iconSize,
            ),
            label: tripState.isTripActive ? 'Viaje en curso' : 'Inicio',
          ),
          const BottomNavigationBarItem(
            icon: FaIcon(FontAwesomeIcons.magnifyingGlass, size: _iconSize),
            label: 'Buscar',
          ),

          // Conditionally add the conductor item if user is a driver
          if (_isDriver)
            const BottomNavigationBarItem(
              icon: FaIcon(FontAwesomeIcons.car, size: _iconSize),
              label: 'Conductor',
            ),

          const BottomNavigationBarItem(
            icon: FaIcon(FontAwesomeIcons.user, size: _iconSize),
            label: 'Perfil',
          ),
        ],

        currentIndex: _selectedIndex,
        onTap: (index) => _onItemTapped(index, tripState),
      ),
    );
  }
}

/*
// Placeholder for the conductor screen - you'll need to create this
class ConductorScreen extends StatelessWidget {
  const ConductorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Panel de Conductor'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              FontAwesomeIcons.car,
              size: 64,
              color: Colors.blue,
            ),
            const SizedBox(height: 24),
            const Text(
              'Panel de Conductor',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Aquí podrás gestionar tus viajes como conductor',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                // Add functionality to create a new trip
              },
              child: const Text('Crear nuevo viaje'),
            ),
          ],
        ),
      ),
    );
  }
}
*/
