import 'package:flutter/material.dart';
import 'package:memory_card/model/game_model.dart';
import 'package:memory_card/presentation/game/game_view.dart';

class MenuView extends StatelessWidget {
  MenuView({super.key});
  final Map<Difficulty, GameConFig> configs = {
    Difficulty.easy: GameConFig(
      gridSize: 3,
      pairs: 4,
      name: 'Kolay',
      color: Colors.green,
      icon: Icons.sentiment_very_satisfied,
    ),
    Difficulty.medium: GameConFig(
      gridSize: 4,
      pairs: 8,
      name: 'Orta',
      color: Colors.orange,
      icon: Icons.sentiment_satisfied,
    ),
    Difficulty.difficult: GameConFig(
      gridSize: 5,
      pairs: 12,
      name: 'Zor',
      color: Colors.redAccent,
      icon: Icons.sentiment_very_dissatisfied,
    ),
  };

  @override
  Widget build(BuildContext context) {
    //  final size = MediaQuery.of(context).size;
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
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  margin: EdgeInsets.only(bottom: 60),
                  child: Column(
                    children: [
                      Image.asset('assets/image/brain.png', fit: BoxFit.cover),
                      SizedBox(height: 20),
                      Text(
                        'Hafıza Ustası',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'Hafıza yeteneğini test et !!',
                        style: TextStyle(fontSize: 18, color: Colors.white70),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 40),
                  child: Column(
                    children: Difficulty.values.map((difficulty) {
                      final config = configs[difficulty]!;
                      return Container(
                        margin: EdgeInsets.only(bottom: 20),
                        width: double.infinity,
                        child: _buildDifficultyButton(
                          context,
                          difficulty,
                          config,
                        ),
                      );
                    }).toList(),
                  ),
                ),
                SizedBox(height: 40),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 40),
                  child: Text(
                    'Zorluk seviyesini seçin',
                    style: TextStyle(fontSize: 20, color: Colors.white70),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDifficultyButton(
    BuildContext context,
    Difficulty difficulty,
    GameConFig config,
  ) {
    String description = '';
    switch (difficulty) {
      case Difficulty.easy:
        description = '3x3 Grid - 4 Eşleşme - Yeni Başlayanlar için';
        break;
      case Difficulty.medium:
        description = '4x4 Grid - 8 Eşleşme - Orta Seviye';
        break;
      case Difficulty.difficult:
        description = '5x5 Grid - 12 Eşleşme - Zorlu Seviye';
        break;
    }
    return ElevatedButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                GameView(difficulty: difficulty, config: config),
          ),
        );
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: config.color.withValues(alpha: 0.2),
        foregroundColor: Colors.white,
        padding: EdgeInsets.all(20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
          side: BorderSide(color: config.color, width: 2),
        ),
        elevation: 0,
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: config.color.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(config.icon, size: 30, color: config.color),
          ),
          SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  config.name,
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 5),
                Text(
                  description,
                  style: TextStyle(fontSize: 14, color: Colors.white70),
                ),
              ],
            ),
          ),
          Icon(Icons.arrow_forward_ios, color: config.color, size: 20),
        ],
      ),
    );
  }
}
