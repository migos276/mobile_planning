import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserProvider with ChangeNotifier {
  int _pomodoroCount = 0;
  int _todayFocusMinutes = 0;
  List<String> _todayAffirmations = [];

  int get pomodoroCount => _pomodoroCount;
  int get todayFocusMinutes => _todayFocusMinutes;
  List<String> get todayAffirmations => _todayAffirmations;

  UserProvider() {
    _loadUserStats();
  }

  Future<void> _loadUserStats() async {
    final prefs = await SharedPreferences.getInstance();
    _pomodoroCount = prefs.getInt('pomodoro_count') ?? 0;
    _todayFocusMinutes = prefs.getInt('today_focus_minutes') ?? 0;
    _todayAffirmations = prefs.getStringList('today_affirmations') ?? [];
    notifyListeners();
  }

  Future<void> addPomodoroSession(int minutes) async {
    _pomodoroCount++;
    _todayFocusMinutes += minutes;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('pomodoro_count', _pomodoroCount);
    await prefs.setInt('today_focus_minutes', _todayFocusMinutes);
    
    notifyListeners();
  }

  Future<void> addAffirmation(String affirmation) async {
    if (!_todayAffirmations.contains(affirmation)) {
      _todayAffirmations.add(affirmation);
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('today_affirmations', _todayAffirmations);
      
      notifyListeners();
    }
  }

  List<String> get defaultAffirmations => [
    'Je suis capable de grandes choses',
    'Chaque jour, je deviens plus confiante',
    'Mes idées ont de la valeur',
    'Je mérite le succès',
    'Je suis fière de mes progrès',
    'Ma voix compte et mérite d\'être entendue',
    'Je relève les défis avec courage',
    'Je crois en mes capacités',
  ];
}