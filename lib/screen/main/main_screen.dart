import 'package:curved_navigation_bar/curved_navigation_bar.dart';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:news_app/screen/api_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  List<Widget> screen = [ScreenApi()];

  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Color(0xFF00BFFF),
      body: screen[selectedIndex],
      bottomNavigationBar: CurvedNavigationBar(
        backgroundColor: Colors.white,
        // color: Color(0xFF00BFFF),
        index: selectedIndex,
        onTap: (int index) {
          setState(() {
            selectedIndex = index;
          });
        },
        items: [
          Icon(Icons.home, size: 28, color: Colors.red[400]),
          Icon(Icons.person, size: 28, color: Colors.red[400]),
          Icon(Icons.favorite, size: 28, color: Colors.red[400]),
        ],
      ),
    );
  }
}
