import 'dart:async';

import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

enum _TimerStatus { idle, running, paused }

class TimerScreen extends StatefulWidget {
  const TimerScreen({Key? key}) : super(key: key);

  @override
  State<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen> {
  final TextEditingController _totalMinutesController =
      TextEditingController(text: '5');
  final TextEditingController _intervalOneController =
      TextEditingController(text: '1');
  final TextEditingController _intervalTwoController =
      TextEditingController(text: '4');

  final TextEditingController _singleTotalMinutesController =
      TextEditingController(text: '3');
  final TextEditingController _singleIntervalController =
      TextEditingController(text: '1');

  final TextEditingController _strategicMinutesController =
      TextEditingController(text: '1');

  Timer? _mainTimer;
  Timer? _singleIntervalTimer;
  Timer? _strategicTimer;

  final AudioPlayer _intervalPlayer = AudioPlayer();
  final AudioPlayer _completionPlayer = AudioPlayer();

  int _mainRemainingSeconds = 5 * 60;
  int _mainElapsedSeconds = 0;
  _TimerStatus _mainStatus = _TimerStatus.idle;
  List<int> _intervalCuesSeconds = [];

  int _singleRemainingSeconds = 3 * 60;
  int _singleElapsedSeconds = 0;
  _TimerStatus _singleStatus = _TimerStatus.idle;
  int _singleIntervalCueSeconds = 60;

  int _strategicRemainingSeconds = 60;
  int _strategicElapsedSeconds = 0;
  _TimerStatus _strategicStatus = _TimerStatus.idle;

  @override
  void dispose() {
    _mainTimer?.cancel();
    _singleIntervalTimer?.cancel();
    _strategicTimer?.cancel();
    _intervalPlayer.dispose();
    _completionPlayer.dispose();
    _totalMinutesController.dispose();
    _intervalOneController.dispose();
    _intervalTwoController.dispose();
    _singleTotalMinutesController.dispose();
    _singleIntervalController.dispose();
    _strategicMinutesController.dispose();
    super.dispose();
  }

  void _startMainTimer() {
    final int? totalMinutes = int.tryParse(_totalMinutesController.text);
    final int? intervalOne = int.tryParse(_intervalOneController.text);
    final int? intervalTwo = int.tryParse(_intervalTwoController.text);

    if (totalMinutes == null || totalMinutes <= 0) {
      _showSnack('Please enter a valid total time (minutes).');
      return;
    }

    if (intervalOne == null ||
        intervalTwo == null ||
        intervalOne <= 0 ||
        intervalTwo <= 0) {
      _showSnack('Please enter valid interval times (minutes).');
      return;
    }

    if (intervalOne >= totalMinutes || intervalTwo >= totalMinutes) {
      _showSnack('Intervals must be less than the total time.');
      return;
    }

    final cues = [intervalOne * 60, intervalTwo * 60]..sort();

    _mainTimer?.cancel();
    setState(() {
      _mainStatus = _TimerStatus.running;
      _mainRemainingSeconds = totalMinutes * 60;
      _mainElapsedSeconds = 0;
      _intervalCuesSeconds = cues;
    });

    _mainTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _mainRemainingSeconds = (_mainRemainingSeconds - 1).clamp(0, 1000000);
        _mainElapsedSeconds++;
      });

      if (_intervalCuesSeconds.contains(_mainElapsedSeconds)) {
        _playIntervalSound();
        _showSnack('Interval reached at ${_formatTime(_mainElapsedSeconds)}');
      }

      if (_mainRemainingSeconds <= 0) {
        _playCompletionSound();
        _showSnack('Final time reached');
        _stopMainTimer();
      }
    });
  }

  void _pauseMainTimer() {
    _mainTimer?.cancel();
    setState(() {
      _mainStatus = _TimerStatus.paused;
    });
  }

  void _resumeMainTimer() {
    if (_mainRemainingSeconds <= 0) return;
    setState(() {
      _mainStatus = _TimerStatus.running;
    });

    _mainTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _mainRemainingSeconds = (_mainRemainingSeconds - 1).clamp(0, 1000000);
        _mainElapsedSeconds++;
      });

      if (_intervalCuesSeconds.contains(_mainElapsedSeconds)) {
        _playIntervalSound();
        _showSnack('Interval reached at ${_formatTime(_mainElapsedSeconds)}');
      }

      if (_mainRemainingSeconds <= 0) {
        _playCompletionSound();
        _showSnack('Final time reached');
        _stopMainTimer();
      }
    });
  }

  void _stopMainTimer() {
    _mainTimer?.cancel();
    setState(() {
      _mainStatus = _TimerStatus.idle;
    });
  }

  void _resetMainTimer() {
    _mainTimer?.cancel();
    final totalMinutes = int.tryParse(_totalMinutesController.text) ?? 5;
    setState(() {
      _mainStatus = _TimerStatus.idle;
      _mainRemainingSeconds = totalMinutes * 60;
      _mainElapsedSeconds = 0;
    });
  }

  void _startStrategicTimer() {
    final int? totalMinutes = int.tryParse(_strategicMinutesController.text);
    if (totalMinutes == null || totalMinutes <= 0) {
      _showSnack('Please enter a valid strategic time (minutes).');
      return;
    }

    _strategicTimer?.cancel();
    setState(() {
      _strategicStatus = _TimerStatus.running;
      _strategicRemainingSeconds = totalMinutes * 60;
      _strategicElapsedSeconds = 0;
    });

    _strategicTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _strategicRemainingSeconds =
            (_strategicRemainingSeconds - 1).clamp(0, 1000000);
        _strategicElapsedSeconds++;
      });

      if (_strategicRemainingSeconds <= 0) {
        _playCompletionSound();
        _showSnack('Strategic time finished');
        _stopStrategicTimer();
      }
    });
  }

  void _pauseStrategicTimer() {
    _strategicTimer?.cancel();
    setState(() {
      _strategicStatus = _TimerStatus.paused;
    });
  }

  void _resumeStrategicTimer() {
    if (_strategicRemainingSeconds <= 0) return;
    setState(() {
      _strategicStatus = _TimerStatus.running;
    });

    _strategicTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _strategicRemainingSeconds =
            (_strategicRemainingSeconds - 1).clamp(0, 1000000);
        _strategicElapsedSeconds++;
      });

      if (_strategicRemainingSeconds <= 0) {
        _playCompletionSound();
        _showSnack('Strategic time finished');
        _stopStrategicTimer();
      }
    });
  }

  void _stopStrategicTimer() {
    _strategicTimer?.cancel();
    setState(() {
      _strategicStatus = _TimerStatus.idle;
    });
  }

  void _resetStrategicTimer() {
    _strategicTimer?.cancel();
    final totalMinutes = int.tryParse(_strategicMinutesController.text) ?? 1;
    setState(() {
      _strategicStatus = _TimerStatus.idle;
      _strategicRemainingSeconds = totalMinutes * 60;
      _strategicElapsedSeconds = 0;
    });
  }

  void _startSingleIntervalTimer() {
    final int? totalMinutes =
        int.tryParse(_singleTotalMinutesController.text.trim());
    final int? intervalMinutes =
        int.tryParse(_singleIntervalController.text.trim());

    if (totalMinutes == null || totalMinutes <= 0) {
      _showSnack('Please enter a valid total time (minutes).');
      return;
    }

    if (intervalMinutes == null || intervalMinutes <= 0) {
      _showSnack('Please enter a valid interval time (minutes).');
      return;
    }

    if (intervalMinutes >= totalMinutes) {
      _showSnack('Interval must be less than the total time.');
      return;
    }

    _singleIntervalTimer?.cancel();
    setState(() {
      _singleStatus = _TimerStatus.running;
      _singleRemainingSeconds = totalMinutes * 60;
      _singleElapsedSeconds = 0;
      _singleIntervalCueSeconds = intervalMinutes * 60;
    });

    _singleIntervalTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _singleRemainingSeconds =
            (_singleRemainingSeconds - 1).clamp(0, 1000000);
        _singleElapsedSeconds++;
      });

      if (_singleElapsedSeconds == _singleIntervalCueSeconds) {
        _playIntervalSound();
        _showSnack('Interval reached at ${_formatTime(_singleElapsedSeconds)}');
      }

      if (_singleRemainingSeconds <= 0) {
        _playCompletionSound();
        _showSnack('Final time reached');
        _stopSingleIntervalTimer();
      }
    });
  }

  void _pauseSingleIntervalTimer() {
    _singleIntervalTimer?.cancel();
    setState(() {
      _singleStatus = _TimerStatus.paused;
    });
  }

  void _resumeSingleIntervalTimer() {
    if (_singleRemainingSeconds <= 0) return;
    setState(() {
      _singleStatus = _TimerStatus.running;
    });

    _singleIntervalTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _singleRemainingSeconds =
            (_singleRemainingSeconds - 1).clamp(0, 1000000);
        _singleElapsedSeconds++;
      });

      if (_singleElapsedSeconds == _singleIntervalCueSeconds) {
        _playIntervalSound();
        _showSnack('Interval reached at ${_formatTime(_singleElapsedSeconds)}');
      }

      if (_singleRemainingSeconds <= 0) {
        _playCompletionSound();
        _showSnack('Final time reached');
        _stopSingleIntervalTimer();
      }
    });
  }

  void _stopSingleIntervalTimer() {
    _singleIntervalTimer?.cancel();
    setState(() {
      _singleStatus = _TimerStatus.idle;
    });
  }

  void _resetSingleIntervalTimer() {
    _singleIntervalTimer?.cancel();
    final totalMinutes = int.tryParse(_singleTotalMinutesController.text) ?? 3;
    setState(() {
      _singleStatus = _TimerStatus.idle;
      _singleRemainingSeconds = totalMinutes * 60;
      _singleElapsedSeconds = 0;
    });
  }

  Future<void> _playIntervalSound() async {
    try {
      await _intervalPlayer.play(AssetSource('sounds/interval_alert.mp3'));
    } catch (e) {
      debugPrint('Error playing interval sound: $e');
    }
  }

  Future<void> _playCompletionSound() async {
    try {
      await _completionPlayer.play(AssetSource('sounds/completion_alert.mp3'));
    } catch (e) {
      debugPrint('Error playing completion sound: $e');
    }
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  String _formatTime(int totalSeconds) {
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Timer'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTimerCard(
              title: 'Main Speaking Timer',
              description:
                  'Set total time and two interval cues. Alerts fire at each interval and on completion.',
              totalController: _totalMinutesController,
              intervalOneController: _intervalOneController,
              intervalTwoController: _intervalTwoController,
              remainingSeconds: _mainRemainingSeconds,
              status: _mainStatus,
              onStart: _startMainTimer,
              onPause: _pauseMainTimer,
              onResume: _resumeMainTimer,
              onReset: _resetMainTimer,
            ),
            const SizedBox(height: 20),
            _buildTimerCard(
              title: 'Rebuttal Timer',
              description:
                  'One interval cue between start and finish. Default 3 minutes with alert at 1 minute.',
              totalController: _singleTotalMinutesController,
              intervalOneController: _singleIntervalController,
              remainingSeconds: _singleRemainingSeconds,
              status: _singleStatus,
              onStart: _startSingleIntervalTimer,
              onPause: _pauseSingleIntervalTimer,
              onResume: _resumeSingleIntervalTimer,
              onReset: _resetSingleIntervalTimer,
              singleInterval: true,
              accentColor: Colors.teal,
            ),
            const SizedBox(height: 20),
            _buildTimerCard(
              title: 'Strategic Time',
              description:
                  'Single countdown (no intervals). Default 1 minute for strategy preparation.',
              totalController: _strategicMinutesController,
              remainingSeconds: _strategicRemainingSeconds,
              status: _strategicStatus,
              onStart: _startStrategicTimer,
              onPause: _pauseStrategicTimer,
              onResume: _resumeStrategicTimer,
              onReset: _resetStrategicTimer,
              hideIntervals: true,
              accentColor: Colors.purple,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimerCard({
    required String title,
    required String description,
    required TextEditingController totalController,
    required int remainingSeconds,
    required _TimerStatus status,
    required VoidCallback onStart,
    required VoidCallback onPause,
    required VoidCallback onResume,
    required VoidCallback onReset,
    TextEditingController? intervalOneController,
    TextEditingController? intervalTwoController,
    bool hideIntervals = false,
    bool singleInterval = false,
    Color accentColor = Colors.orange,
  }) {
    final String buttonLabel;
    final VoidCallback buttonAction;

    switch (status) {
      case _TimerStatus.running:
        buttonLabel = 'Pause';
        buttonAction = onPause;
        break;
      case _TimerStatus.paused:
        buttonLabel = 'Resume';
        buttonAction = onResume;
        break;
      case _TimerStatus.idle:
      default:
        buttonLabel = 'Start';
        buttonAction = onStart;
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: accentColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.timer, color: accentColor, size: 26),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: totalController,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'monospace'),
                    textAlign: TextAlign.center,
                    decoration: InputDecoration(
                      labelText: 'Total',
                      labelStyle: const TextStyle(fontSize: 12),
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 16, horizontal: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                if (!hideIntervals) ...[
                  if (singleInterval)
                    Expanded(
                      child: TextFormField(
                        controller: intervalOneController,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'monospace'),
                        textAlign: TextAlign.center,
                        decoration: InputDecoration(
                          labelText: 'Interval',
                          labelStyle: const TextStyle(fontSize: 12),
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 16, horizontal: 12),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    )
                  else ...[
                    Expanded(
                      child: TextFormField(
                        controller: intervalOneController,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'monospace'),
                        textAlign: TextAlign.center,
                        decoration: InputDecoration(
                          labelText: 'Int 1',
                          labelStyle: const TextStyle(fontSize: 12),
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 16, horizontal: 12),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextFormField(
                        controller: intervalTwoController,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'monospace'),
                        textAlign: TextAlign.center,
                        decoration: InputDecoration(
                          labelText: 'Int 2',
                          labelStyle: const TextStyle(fontSize: 12),
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 16, horizontal: 12),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(width: 8),
                ],
                _buildRemainingChip(remainingSeconds, accentColor),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: buttonAction,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accentColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      buttonLabel,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: onReset,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: accentColor,
                      side: BorderSide(color: accentColor, width: 2),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Reset',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRemainingChip(int remainingSeconds, Color accentColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: accentColor.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: accentColor.withOpacity(0.3), width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'TIME',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.5,
              color: accentColor.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _formatTime(remainingSeconds),
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: accentColor,
              fontFamily: 'monospace',
              letterSpacing: 2,
            ),
          ),
        ],
      ),
    );
  }
}
