import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:iconsax/iconsax.dart';
import 'dart:async';
import '../providers/user_provider.dart';
import '../utils/theme.dart';

class PomodoroTimer extends StatefulWidget {
  const PomodoroTimer({super.key});

  @override
  State<PomodoroTimer> createState() => _PomodoroTimerState();
}

class _PomodoroTimerState extends State<PomodoroTimer> {
  Timer? _timer;
  int _remainingSeconds = 25 * 60; // 25 minutes by default
  bool _isRunning = false;
  bool _isBreak = false;

  final int _workDuration = 25 * 60; // 25 minutes
  final int _shortBreakDuration = 5 * 60; // 5 minutes
  final int _longBreakDuration = 15 * 60; // 15 minutes

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    setState(() {
      _isRunning = true;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_remainingSeconds > 0) {
          _remainingSeconds--;
        } else {
          _completeSession();
        }
      });
    });
  }

  void _pauseTimer() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
    });
  }

  void _resetTimer() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
      _remainingSeconds = _isBreak ? _shortBreakDuration : _workDuration;
    });
  }

  void _completeSession() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
    });

    if (!_isBreak) {
      // Work session completed
      Provider.of<UserProvider>(context, listen: false).addPomodoroSession(25);
      _showCompletionDialog('Session de travail terminée !', 'Bravo ! Prenez une pause bien méritée.');
      
      setState(() {
        _isBreak = true;
        _remainingSeconds = _shortBreakDuration;
      });
    } else {
      // Break completed
      _showCompletionDialog('Pause terminée !', 'Prêt pour une nouvelle session ?');
      
      setState(() {
        _isBreak = false;
        _remainingSeconds = _workDuration;
      });
    }
  }

  void _showCompletionDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  double get _progress {
    final totalDuration = _isBreak ? _shortBreakDuration : _workDuration;
    return 1 - (_remainingSeconds / totalDuration);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.textSecondary.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              _isBreak ? 'Temps de pause' : 'Session de travail',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _isBreak 
                  ? 'Détendez-vous et rechargez vos batteries'
                  : 'Concentrez-vous sur votre tâche',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 40),
            Center(
              child: SizedBox(
                width: 250,
                height: 250,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 250,
                      height: 250,
                      child: CircularProgressIndicator(
                        value: _progress,
                        strokeWidth: 8,
                        backgroundColor: AppTheme.textSecondary.withOpacity(0.1),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          _isBreak ? AppTheme.accentColor : AppTheme.primaryColor,
                        ),
                      ),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _isBreak ? Iconsax.coffee : Iconsax.timer,
                          size: 48,
                          color: _isBreak ? AppTheme.accentColor : AppTheme.primaryColor,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _formatTime(_remainingSeconds),
                          style: Theme.of(context).textTheme.displayMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: _resetTimer,
                  icon: const Icon(Iconsax.refresh),
                  label: const Text('Reset'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.textSecondary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _isRunning ? _pauseTimer : _startTimer,
                  icon: Icon(_isRunning ? Iconsax.pause : Iconsax.play),
                  label: Text(_isRunning ? 'Pause' : 'Start'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isBreak ? AppTheme.accentColor : AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Consumer<UserProvider>(
              builder: (context, userProvider, child) {
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.backgroundColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: [
                          Text(
                            '${userProvider.pomodoroCount}',
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryColor,
                            ),
                          ),
                          Text(
                            'Sessions',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        width: 1,
                        height: 40,
                        color: AppTheme.textSecondary.withOpacity(0.2),
                      ),
                      Column(
                        children: [
                          Text(
                            '${userProvider.todayFocusMinutes}',
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppTheme.accentColor,
                            ),
                          ),
                          Text(
                            'Minutes',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}