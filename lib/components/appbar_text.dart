import 'package:flutter/material.dart';

class AppText extends StatelessWidget {
  const AppText({
    required this.text,
    super.key,
  });
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: TextAlign.center,
      style: TextStyle(fontSize: 20, color: Colors.white,fontWeight: FontWeight.bold),
    );
  }
}
