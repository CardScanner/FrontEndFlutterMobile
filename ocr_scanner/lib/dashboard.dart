import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ocr_scanner/home.dart';
import 'package:ocr_scanner/login.dart';

class Dashboard extends StatefulWidget {
  Dashboard({Key? key}) : super(key: key);

  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: 750,
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                color: Color.fromARGB(255, 153, 70, 40),
                boxShadow: [
                  BoxShadow(
                      blurRadius: 10, color: Colors.black, offset: Offset(1, 5))
                ],
                borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(80),
                    bottomRight: Radius.circular(20)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    SizedBox(
                      height: 100,
                    ),
                    Image.asset('assets/logoOCR.png',
                        width: 150, height: 150),
                    SizedBox(
                      height: 20,
                    ),
                    Text("Dashboard",
                        style: GoogleFonts.pacifico(
                          fontWeight: FontWeight.bold,
                          fontSize: 50,
                          color: Colors.white,
                        )),
                    SizedBox(
                      height: 30,
                    ),
                    Center(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => Home()),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          onPrimary: const Color.fromARGB(
                              255, 82, 32, 14), // Couleur de fond du bouton
                          primary: Colors.white,
                          minimumSize: Size(double.infinity,
                              50), // Couleur du texte du bouton
                        ),
                        child: Text('Scan Id card'),
                      ),
                    ),
                    SizedBox(
                      height: 30,
                    ),
                    Center(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => Login()),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          onPrimary: const Color.fromARGB(
                              255, 82, 32, 14), // Couleur de fond du bouton
                          primary: Colors.white,
                          minimumSize: Size(double.infinity,
                              50), // Couleur du texte du bouton
                        ),
                        child: Text('Log out'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
