import 'package:flutter/material.dart';
import 'package:freewheel_frontend/presentation/shell/main_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  await dotenv.load(fileName: ".env");
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FreeWheel',
      theme: ThemeData(
        colorScheme: ColorScheme(
          primary: const Color(0xFF2196F3), // Azul como color principal
          onPrimary: Colors.white,
          secondary: const Color(0xFF64B5F6), // Azul más claro como secundario
          onSecondary: Colors.white,
          surface: Colors.white,
          onSurface: Colors.black,
          error: Colors.red,
          onError: Colors.white,
          brightness: Brightness.light,
        ),
        // Colores adicionales para elementos de la UI
        cardColor: Colors.white,
        dividerColor: const Color(0xFFE0E0E0), // Gris claro para divisores
        shadowColor: Colors.black.withOpacity(0.1),
        // Botones y componentes interactivos
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2196F3),
            foregroundColor: Colors.white,
          ),
        ),
        // Componentes de texto
        textTheme: TextTheme(
          titleLarge: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
          bodyLarge: TextStyle(color: Colors.black87),
          bodyMedium: TextStyle(color: Colors.black87),
        ),
        useMaterial3: true,
        fontFamily: GoogleFonts.roboto().fontFamily,
      ),
      home: const MainScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
