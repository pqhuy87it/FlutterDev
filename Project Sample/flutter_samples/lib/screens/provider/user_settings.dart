import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class UserSettings extends ChangeNotifier {
  String _name = 'John Doe';
  int _age = 30;
  ThemeMode _theme = ThemeMode.light;

  String get name => _name;
  int get age => _age;
  ThemeMode get theme => _theme;

  void changeName(String newName) {
    _name = newName;
    notifyListeners();
  }

  void celebrateBirthday() {
    _age++;
    notifyListeners();
  }

  void toggleTheme() {
    _theme = _theme == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }
}