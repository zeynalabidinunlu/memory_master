// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:math';

import 'package:flutter/material.dart';

import 'package:memory_card/model/game_model.dart';

class GameView extends StatefulWidget {
  final Difficulty difficulty;
  final GameConFig config;
  const GameView({super.key, required this.difficulty, required this.config});

  @override
  State<GameView> createState() => _GameViewState();
}

class _GameViewState extends State<GameView> with TickerProviderStateMixin {
  List<GameCard> cards = [];
  List<int> flippedCards = [];
  int moves = 0;
  int matches = 0;
  bool canFlip = true;
  bool gameStarted = false;
  DateTime? gameStartTime;
  late AnimationController _flipController;
  late AnimationController _matchController;
  late AnimationController _wrongController;

  final List<String> symbols = [
    '🍎',
    '🍌',
    '🍇',
    '🍉',
    '🍓',
    '🍒',
    '🍊',
    '🍍',
    '🥝',
    '🥥',
    '🥑',
    '🍑',
    '🍈',
    '🍋',
    '🍅',
    '🥭',
  ];

  @override
  void initState() {
    super.initState();
    _initControllers();
    _initGame();
  }

  void _initControllers() {
    _flipController = AnimationController(
      duration: Duration(milliseconds: 200),
      vsync: this,
    );
    _matchController = AnimationController(
      duration: Duration(milliseconds: 500),
      vsync: this,
    );
    _wrongController = AnimationController(
      duration: Duration(milliseconds: 100),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _flipController.dispose();
    _matchController.dispose();
    _wrongController.dispose();
    super.dispose();
  }

  void _initGame() {
    cards.clear();
    flippedCards.clear();
    moves = 0;
    matches = 0;
    canFlip = true;
    gameStarted = false;
    gameStartTime = null;

    List<String> gameSymbols = symbols.take(widget.config.pairs).toList();
    List<String> cardPairs = [...gameSymbols, ...gameSymbols];
    int totalCards = widget.config.gridSize * widget.config.gridSize;
    while (cardPairs.length < totalCards) {
      cardPairs.add('⭐');
    }

    cardPairs.shuffle(Random());
    for (var i = 0; i < totalCards; i++) {
      cards.add(GameCard(id: i, symbol: cardPairs[i]));
    }
    setState(() {});
  }

  void _flipCard(int index) {
    if (!canFlip ||
        cards[index].isFlipped ||
        cards[index].isMatched ||
        cards[index].isAnimating ||
        flippedCards.length >= 2) {
      return;
    }
    if (!gameStarted) {
      gameStarted = true;
      gameStartTime = DateTime.now();
    }
    setState(() {
      cards[index].isFlipped = true;
      cards[index].isAnimating = true;
      flippedCards.add(index);
    });
    _flipController.forward().then((_) {
      _flipController.reset();
      cards[index].isAnimating = false;
    });
    if (flippedCards.length == 2) {
      moves++;
      _checkForMatch();
    }
  }

  void _checkForMatch() {
    canFlip = false;
    Future.delayed(Duration(milliseconds: 500), () {
      if (!mounted) return;

      int firstIndex = flippedCards[0];
      int secondIndex = flippedCards[1];
      if (cards[firstIndex].symbol == cards[secondIndex].symbol) {
        setState(() {
          cards[firstIndex].isMatched = true;
          cards[secondIndex].isMatched = true;
          matches++;
        });
        _matchController.forward().then((_) {
          if (mounted) _matchController.reset();
        });
        if (matches == widget.config.pairs) {
          _showWinDialog();
        }
      } else {
        _wrongController.forward().then((_) {
          if (mounted) {
            _wrongController.reset();
            setState(() {
              cards[firstIndex].isFlipped = false;
              cards[secondIndex].isFlipped = false;
            });
          }
        });
      }
      if (mounted) {
        flippedCards.clear();
        canFlip = true;
      }
    });
  }

  String _getGameTime() {
    if (gameStartTime == null) return '00:00';
    final duration = DateTime.now().difference(gameStartTime!);
    final minutes = duration.inMinutes.toString().padLeft(2, '0');
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  void _showWinDialog() {
    final gameTime = _getGameTime();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Color(0xFF1A1A2E),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Column(
            children: [
              Text('🎉', style: TextStyle(fontSize: 50)),
              SizedBox(height: 10),
              Text(
                'Tebrikler!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          content: Container(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildStatRow(
                  'Zorunluk Seviyesi:',
                  widget.config.name,
                  widget.config.color,
                ),
                _buildStatRow('Oyun Süresi:', gameTime, widget.config.color),
                _buildStatRow(
                  'Hareket Sayısı:',
                  moves.toString(),
                  Colors.orange,
                ),
                _buildStatRow(
                  'Eşleşme Sayısı:',
                  '$matches/${widget.config.pairs}',
                  Colors.green,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.pop(context); // Go back to the menu
              },
              child: Text(
                'Menüye Dön',
                style: TextStyle(color: Colors.white70),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _initGame();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: widget.config.color,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text('Tekrar Oyna'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatRow(String label, String value, Color color) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.white70)),
          Text(
            value,
            style: TextStyle(color: color, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF16213E), Color(0xFF0F3460), Color(0xFF533483)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.all(20),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: Icon(Icons.arrow_back, color: Colors.white),
                    ),
                    Expanded(
                      child: Text(
                        '${widget.config.name} ',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: _initGame,
                      icon: Icon(Icons.refresh, color: Colors.white),
                    ),
                  ],
                ),
              ),
              Container(
                margin: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.1),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatCard(
                      'Zaman',
                      _getGameTime(),
                      Colors.blue,
                      Icons.timer,
                    ),
                    _buildStatCard(
                      'Hareket',
                      moves.toString(),
                      Colors.orange,
                      Icons.touch_app,
                    ),
                    _buildStatCard(
                      'Eşleşme',
                      '$matches/${widget.config.pairs}',
                      Colors.green,
                      Icons.check_circle,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: widget.config.gridSize,
                      crossAxisSpacing: 8.0,
                      mainAxisSpacing: 8.0,
                    ),
                    itemCount: cards.length,
                    itemBuilder: (context, index) {
                      return _buildCard(index);
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    Color color,
    IconData icon,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 30, color: color),
        ),
        SizedBox(height: 5),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        SizedBox(height: 5),
        Text(title, style: TextStyle(fontSize: 16, color: Colors.white70)),
      ],
    );
  }

  Widget _buildCard(int index) {
    GameCard card = cards[index];
    bool showFront = card.isFlipped || card.isMatched;
    return GestureDetector(
      onTap: () => _flipCard(index),
      child: AnimatedBuilder(
        animation: Listenable.merge([_matchController, _wrongController]),
        builder: (context, child) {
          double scale = 1.0;
          double shake = 0.0;

          if (card.isMatched) {
            scale = 1.0 + (_matchController.value * 0.15);
          }
          if (flippedCards.contains(index) && !card.isMatched) {
            shake = _wrongController.value * 5;
          }
          return Transform.translate(
            offset: Offset(shake, 0),
            child: Transform.scale(
              scale: scale,
              child: AnimatedContainer(
                duration: Duration(milliseconds: 300),
                decoration: BoxDecoration(
                  gradient: showFront
                      ? (card.isMatched
                            ? LinearGradient(
                                colors: [
                                  Colors.green[400]!,
                                  Colors.green[600]!,
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              )
                            : LinearGradient(
                                colors: [Colors.white, Colors.grey[600]!],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ))
                      : LinearGradient(
                          colors: [
                            widget.config.color.withValues(alpha: 0.8),
                            widget.config.color.withValues(alpha: 0.6),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 10,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: Center(
                  child: showFront
                      ? Text(
                          card.symbol,
                          style: TextStyle(
                            fontSize: widget.config.gridSize == 3
                                ? 70
                                : widget.config.gridSize == 4
                                ? 50
                                : 40,
                          ),
                        )
                      : Icon(
                          color: Colors.white.withValues(alpha: 0.8),
                          Icons.question_mark,
                          size: widget.config.gridSize == 3
                              ? 70
                              : widget.config.gridSize == 4
                              ? 50
                              : 40,
                        ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
