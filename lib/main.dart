import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';

void main() => runApp(const MaterialApp(
  debugShowCheckedModeBanner: false,
  home: MemoryGrid(),
));

class MemoryGrid extends StatefulWidget {
  const MemoryGrid({super.key});
  @override
  State<MemoryGrid> createState() => _MemoryGridState();
}

class _MemoryGridState extends State<MemoryGrid> {
  final List<int> _sequence = [];
  final Random _random = Random();
  
  int _score = 0;
  int _playerIndex = 0;
  int? _highlightedIndex;
  bool _isShowing = false;
  bool _acceptingInput = false;

  @override
  void initState() {
    super.initState();
    _startNewGame();
  }

  void _startNewGame() {
    _sequence.clear();
    _score = 0;
    _nextRound();
  }

  void _nextRound() {
    setState(() {
      _acceptingInput = false;
      _isShowing = true;
      _playerIndex = 0;
    });
    
    // Добавляем новый случайный квадрат
    _sequence.add(_random.nextInt(9));
    
    // Показываем ТОЛЬКО последний добавленный квадрат
    _showNewSquare();
  }

  Future<void> _showNewSquare() async {
    final newIndex = _sequence.last;
    
    setState(() => _highlightedIndex = newIndex);
    await Future.delayed(const Duration(milliseconds: 300));
    setState(() => _highlightedIndex = null);
    
    await Future.delayed(const Duration(milliseconds: 100));
    
    setState(() {
      _isShowing = false;
      _acceptingInput = true;
    });
  }

  void _onTap(int index) {
    if (!_acceptingInput || _isShowing) return;
    
    if (index == _sequence[_playerIndex]) {
      // Правильно
      _playerIndex++;
      
      if (_playerIndex == _sequence.length) {
        // Вся последовательность пройдена
        setState(() => _score = _sequence.length);
        _nextRound();
      }
    } else {
      // Ошибка
      _resetGame();
    }
  }

  void _resetGame() {
    setState(() {
      _acceptingInput = false;
      _isShowing = false;
      _highlightedIndex = null;
    });
    _sequence.clear();
    _score = 0;
    _startNewGame();
  }

  Color _getColor(int index) {
    if (_highlightedIndex == index) {
      return Colors.white;
    }
    return Colors.grey.shade700;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Счёт
          Text(
            '$_score',
            style: const TextStyle(
              fontSize: 72,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 40),
          // Сетка 3x3
          Center(
            child: SizedBox(
              width: 300,
              height: 300,
              child: GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                ),
                itemCount: 9,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () => _onTap(index),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 50),
                      decoration: BoxDecoration(
                        color: _getColor(index),
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
