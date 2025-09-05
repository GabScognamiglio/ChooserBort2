import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

void main() => runApp(ChooserBortApp());

class ChooserBortApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ChooserBort',
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: ThemeMode.system,
      home: ChooserBortPage(),
    );
  }
}

class ChooserBortPage extends StatefulWidget {
  @override
  _ChooserBortPageState createState() => _ChooserBortPageState();
}

class _ChooserBortPageState extends State<ChooserBortPage> {
  final Map<int, Offset> _fingers = {};
  int? _winner;
  bool _showWinnerText = false;
  Timer? _timer;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onPanDown: (details) => _addFinger(details.localPosition),
        onPanEnd: (_) => _removeFinger(),
        child: Stack(
          children: [
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GradientText(
                    'ChooserBort',
                    gradient: LinearGradient(colors: [Colors.purple, Colors.blue]),
                    style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 20),
                  Text(
                    _showWinnerText
                        ? 'te tocca bozzo'
                        : "Poggia er dito se t'aregge",
                    style: TextStyle(fontSize: 24, color: Theme.of(context).textTheme.bodyText1?.color),
                  ),
                ],
              ),
            ),
            ..._fingers.entries.map((entry) {
              final isWinner = _winner == entry.key;
              return Positioned(
                left: entry.value.dx - 25,
                top: entry.value.dy - 25,
                child: AnimatedContainer(
                  duration: Duration(milliseconds: 300),
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: isWinner ? Colors.green : Colors.red,
                    shape: BoxShape.circle,
                  ),
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  void _addFinger(Offset position) {
    if (_fingers.length >= 8) return; // massimo 8 dita
    final id = _fingers.length + 1;
    setState(() => _fingers[id] = position);
    _timer?.cancel();
    if (_fingers.length >= 2) {
      _timer = Timer(Duration(seconds: 3), _pickWinner);
    }
  }

  void _removeFinger() {
    setState(() {
      _fingers.clear();
      _winner = null;
      _showWinnerText = false;
    });
  }

  void _pickWinner() {
    if (_fingers.isEmpty) return;
    final keys = _fingers.keys.toList();
    final random = Random();
    final winnerIndex = random.nextInt(keys.length);
    setState(() {
      _winner = keys[winnerIndex];
      _fingers.removeWhere((key, _) => key != _winner); // rimuovi perdenti
      _showWinnerText = true;
    });

    Timer(Duration(seconds: 2), () {
      setState(() {
        _showWinnerText = false;
        _winner = null;
        _fingers.clear();
      });
    });
  }
}

/// Widget per testo con gradient
class GradientText extends StatelessWidget {
  final String text;
  final TextStyle style;
  final Gradient gradient;

  GradientText(this.text, {required this.gradient, required this.style});

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (bounds) => gradient.createShader(Rect.fromLTWH(0, 0, bounds.width, bounds.height)),
      child: Text(text, style: style.copyWith(color: Colors.white)),
    );
  }
}
