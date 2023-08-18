import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:meatoz_delivery/screens/Login_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Meatoz Delivery Application',
      theme: _buildTheme(Brightness.light),
      home: LoginPage(),
    );
  }
}
ThemeData _buildTheme(brightness) {
  var baseTheme = ThemeData(brightness: brightness);

  return baseTheme.copyWith(
      textTheme: GoogleFonts.robotoCondensedTextTheme(baseTheme.textTheme),
      appBarTheme: AppBarTheme(backgroundColor: Colors.teal[900],
        centerTitle: true, elevation: 0,systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.black87,
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
        ),),focusColor: Colors.teal[900],primaryColor: Colors.teal[900]
  );
}