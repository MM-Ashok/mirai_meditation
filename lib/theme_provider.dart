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
  );

  List<ThemeData> get themes => [
        lightTheme,
        darkTheme,
        redTheme,
        greenTheme,
        blueTheme,
      ];
}
