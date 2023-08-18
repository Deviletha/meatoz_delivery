import 'package:floating_bottom_navigation_bar/floating_bottom_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:meatoz_delivery/screens/completed.dart';
import 'package:meatoz_delivery/screens/pending.dart';
import 'package:meatoz_delivery/screens/summary.dart';

class BottomNav extends StatefulWidget {
  const BottomNav({Key? key}) : super(key: key);

  @override
  State<BottomNav> createState() => _BottomNavState();
}

class _BottomNavState extends State<BottomNav> {
  int selectindex = 0;

  List body = <Widget>[
    const Pending(),
    Completed(),
    Summary(),
  ];

  void onitemtapped(int index) {
    setState(() {
      selectindex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      bottomNavigationBar: FloatingNavbar(
        onTap: onitemtapped,
        currentIndex: selectindex,
        selectedBackgroundColor: Colors.green.shade50,
        iconSize: 15,
        fontSize: 15,
        backgroundColor: Colors.green.shade200,
        elevation: 0,
        items: [
          FloatingNavbarItem(title: "Pending", icon: Icons.ac_unit_outlined),
          FloatingNavbarItem(title: "Completed", icon: Icons.ac_unit_outlined),
          FloatingNavbarItem(title: "Summary", icon: Icons.ac_unit_outlined),
        ],
      ),
      body: body.elementAt(selectindex),
    );
  }
}
