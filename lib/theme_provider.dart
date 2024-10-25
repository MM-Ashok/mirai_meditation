import 'package:flutter/material.dart';

class ThemeProvider with ChangeNotifier {
  ThemeData _selectedTheme;

  ThemeProvider() : _selectedTheme = lightTheme;

  ThemeData get selectedTheme => _selectedTheme;

  void setTheme(ThemeData theme) {
    _selectedTheme = theme;
    notifyListeners();
  }

   // Method to get the name of the current theme
  String get currentThemeName {
    if (_selectedTheme == lightTheme) {
      return 'Light Theme';
    } else if (_selectedTheme == darkTheme) {
      return 'Dark Theme';
    } else if (_selectedTheme == redTheme) {
      return 'Red Theme';
    } else if (_selectedTheme == greenTheme) {
      return 'Green Theme';
    } else if (_selectedTheme == blueTheme) {
      return 'Blue Theme';
    }
    return 'Unknown Theme';
  }

  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: Colors.white,
    colorScheme: const ColorScheme.light(
      primary: Colors.grey,
      secondary: Colors.blueGrey,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.grey,
      foregroundColor: Colors.white,
    ),
    scaffoldBackgroundColor: const Color(0xFFd8d6d6),
    cardColor: const Color(0XFFa5a2a2),
    textTheme: const TextTheme(
      displayLarge: TextStyle(color: Color(0XFFffffff)),  // Large headline color
      titleLarge: TextStyle(color: Color(0XFFffffff),fontSize: 20,fontWeight: FontWeight.bold), // Smaller heading color
      bodyLarge: TextStyle(color: Color(0XFFffffff)),  // Primary body text color
      bodyMedium: TextStyle(color: Color(0XFFffffff)), // Secondary body text color
    ),
  );

  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: Colors.grey[900]!,
    colorScheme: ColorScheme.dark(
      primary: Colors.grey[900]!,
      secondary: Colors.redAccent,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.grey[900]!,
      foregroundColor: Colors.white,
    ),
    scaffoldBackgroundColor: const Color.fromARGB(255, 156, 157, 158),
    cardColor: const Color.fromARGB(255, 165, 166, 167),
    textTheme: const TextTheme(
      displayLarge: TextStyle(color: Colors.black),  // Large headline color
      titleLarge: TextStyle(color: Colors.black87,fontSize: 20,fontWeight: FontWeight.bold), // Smaller heading color
      bodyLarge: TextStyle(color: Colors.black54),  // Primary body text color
      bodyMedium: TextStyle(color: Colors.black45), // Secondary body text color
    ),
  );

  static final ThemeData redTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: Colors.red,
    colorScheme: const ColorScheme.light(
      primary: Colors.red,
      secondary: Colors.redAccent,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.red,
      foregroundColor: Colors.white,
    ),
    scaffoldBackgroundColor: const Color.fromARGB(255, 207, 113, 100),
    cardColor: const Color.fromARGB(255, 230, 133, 104),
    textTheme: const TextTheme(
      displayLarge: TextStyle(color: Colors.black),  // Large headline color
      titleLarge: TextStyle(color: Colors.black87,fontSize: 20,fontWeight: FontWeight.bold), // Smaller heading color
      bodyLarge: TextStyle(color: Colors.black54),  // Primary body text color
      bodyMedium: TextStyle(color: Colors.black45), // Secondary body text color
    ),
  );

  static final ThemeData greenTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: Colors.green,
    colorScheme: const ColorScheme.light(
      primary: Colors.green,
      secondary: Colors.greenAccent,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.green,
      foregroundColor: Colors.white,
    ),
    scaffoldBackgroundColor: const Color.fromARGB(255, 73, 201, 84),
    cardColor: const Color.fromARGB(255, 74, 219, 122),
    textTheme: const TextTheme(
      displayLarge: TextStyle(color: Colors.black),  // Large headline color
      titleLarge: TextStyle(color: Colors.black87,fontSize: 20,fontWeight: FontWeight.bold), // Smaller heading color
      bodyLarge: TextStyle(color: Colors.black54),  // Primary body text color
      bodyMedium: TextStyle(color: Colors.black45), // Secondary body text color
    ),
  );

  static final ThemeData blueTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: Colors.blue,
    colorScheme: const ColorScheme.light(
      primary: Colors.blue,
      secondary: Colors.blueAccent,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.blue,
      foregroundColor: Colors.white,
    ),
    scaffoldBackgroundColor: const Color.fromARGB(255, 123, 198, 235),
    cardColor: const Color.fromARGB(255, 128, 170, 197),
    textTheme: const TextTheme(
      displayLarge: TextStyle(color: Color.fromARGB(255, 255, 16, 16)),  // Large headline color
      titleLarge: TextStyle(color: Color.fromARGB(244, 245, 22, 22),fontSize: 20,fontWeight: FontWeight.bold), // Smaller heading color
      bodyLarge: TextStyle(color: Color.fromARGB(228, 236, 15, 15)),  // Primary body text color
      bodyMedium: TextStyle(color: Color.fromARGB(115, 236, 28, 28)), // Secondary body text color
    ),
  );

  List<ThemeData> get themes => [
        lightTheme,
        // darkTheme,
        // redTheme,
        // greenTheme,
        // blueTheme,
      ];
}
