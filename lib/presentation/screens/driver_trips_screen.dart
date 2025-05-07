import 'package:flutter/material.dart';

class DriverTripsScreen extends StatefulWidget {
  @override
  _DriverTripsScreenState createState() => _DriverTripsScreenState();
}

class _DriverTripsScreenState extends State<DriverTripsScreen> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mis viajes'),)
    );
  }
}
