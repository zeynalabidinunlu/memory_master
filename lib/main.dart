import 'package:flutter/material.dart';
import 'package:memory_card/presentation/menu/menu_view.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Hafıza Kartı Oyunu',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        fontFamily: 'Arial',
        scaffoldBackgroundColor: Color(0xFF1a1a2E),
      ),
      home: MenuView(),
    );
  }
}
