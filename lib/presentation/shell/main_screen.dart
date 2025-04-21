import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:freewheel_frontend/presentation/screens/home_screen.dart';
import 'package:freewheel_frontend/presentation/screens/profile_screen.dart';
import 'package:freewheel_frontend/presentation/screens/search_trips_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  static const double _iconSize = 24.0;

  static const List<Widget> _widgetOptions = <Widget>[
    HomeScreen(),
    SearchTripsScreen(),
    ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: _widgetOptions.elementAt(_selectedIndex)),

      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Colors.grey.shade600,
        selectedFontSize: 12.0,
        unselectedFontSize: 12.0,
        showSelectedLabels: true,
        showUnselectedLabels: false,
        type: BottomNavigationBarType.fixed,

        // --- Ítems de la Barra ---
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: FaIcon(
              FontAwesomeIcons.house,
              size: _iconSize,
            ), // Icono normal
            label: 'Inicio', // Texto debajo del icono
          ),
          BottomNavigationBarItem(
            icon: FaIcon(FontAwesomeIcons.magnifyingGlass, size: _iconSize),
            label: 'Buscar',
          ),
          BottomNavigationBarItem(
              icon: FaIcon(
                FontAwesomeIcons.user,
                size: _iconSize,
            ),
            label: 'Perfil',
          )
        ],

        // --- Funcionalidad ---
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
