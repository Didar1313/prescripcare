import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../bottomNavigationBarItem/bookMark.dart';
import '../bottomNavigationBarItem/home.dart';
import '../bottomNavigationBarItem/profile.dart';

class BottomNavigation extends StatefulWidget {
  const BottomNavigation({super.key});

  @override
  State<BottomNavigation> createState() => _BottomNavigationState();
}

class _BottomNavigationState extends State<BottomNavigation> {
  final _items = [Home(), Favorite(), Profile()]; // Include History widget
  int _selectedIndex = 0;


  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.blue[800],
        selectedItemColor: Colors.white,
        elevation: 0,
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home, size: 30),
            label: "Home",
            backgroundColor: Colors.blue[500],
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bookmark_border, size: 30),
            label: "Bookmark",
            backgroundColor: Colors.blue[500],
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person, size: 30),
            label: "Profile",
            backgroundColor: Colors.blue[500],
          ),

        ],
      ),
      body: _items[_selectedIndex],
    );
  }


}
