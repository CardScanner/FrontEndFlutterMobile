import 'package:flutter/material.dart';
import 'package:ocr_scanner/home.dart';
import 'package:ocr_scanner/login.dart';


/*void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return  MaterialApp(
        title: 'Image to Text Converter',
        theme: ThemeData(primarySwatch:Colors.blue, 
        ),
        home: Home(),
    );
  }
}*/
void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: Login(),
  ));
}