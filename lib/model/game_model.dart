// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';

enum Difficulty { easy, medium, difficult }

class GameConFig {
  final int gridSize;
  final int pairs;
  final String name;
  final Color color;
  final IconData icon;
  GameConFig({
    required this.gridSize,
    required this.pairs,
    required this.name,
    required this.color,
    required this.icon,
  });
}

class GameCard {
  final int id;
  final String symbol;
  bool isFlipped;
  bool isMatched;
  bool isAnimating;
  GameCard({
    required this.id,
    required this.symbol,
    this.isFlipped = false,
    this.isMatched = false,
    this.isAnimating = false,
  });

}

