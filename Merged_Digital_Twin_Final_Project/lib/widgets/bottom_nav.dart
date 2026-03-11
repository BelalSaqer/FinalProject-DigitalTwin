import 'package:flutter/foundation.dart';

enum ScreenType {
  machines,
  dashboard,
  alerts,
  history,
  reports,
  profile,
}

class AppState extends ChangeNotifier {
  bool _isLoggedIn = false;
  bool get isLoggedIn => _isLoggedIn;

  ScreenType _current = ScreenType.machines;
  ScreenType get current => _current;

  String? _selectedMachineId;
  String? get selectedMachineId => _selectedMachineId;

  void login() {
    _isLoggedIn = true;
    _current = ScreenType.machines;
    _selectedMachineId = null;
    notifyListeners();
  }

  void logout() {
    _isLoggedIn = false;
    _current = ScreenType.machines;
    _selectedMachineId = null;
    notifyListeners();
  }

  void go(ScreenType screen) {
    if (screen == ScreenType.dashboard) {
      if (_selectedMachineId == null) return;
    }
    _current = screen;
    notifyListeners();
  }


  void selectMachine(String id) {
    _selectedMachineId = id;
    _current = ScreenType.dashboard;
    notifyListeners();
  }

  void backToMachines() {
    _current = ScreenType.machines;
    notifyListeners();
  }
}