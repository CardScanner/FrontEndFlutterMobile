import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:ocr_scanner/dashboard.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'Model/ocr.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:open_file/open_file.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String result = '';
  File? image;
  ImagePicker? imagePicker;

  List<String> labelList = [
    'Prenom',
    'Nom',
    'Lieu de naissance',
    'Date de naissance',
    'Date de validite',
    'Id'
  ];

  @override
  void initState() {
    super.initState();
    imagePicker = ImagePicker();
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Succès"),
          content: Text("Les données ont été enregistrées avec succès."),
          actions: <Widget>[
            TextButton(
              child: Text("OK"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<OcrModel> createOcr(OcrModel ocr) async {
    final response = await http.post(
      Uri.parse('http://192.168.1.135:8888/SERVICE-OCR/create'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(ocr.toJson()),
    );
    if (response.statusCode == 201) {
      return OcrModel.fromJson(json.decode(response.body));
    } else {
      throw Exception('Erreur de creation');
    }
  }

  Future<OcrModel> fetchOCR(String documentId) async {
    final response = await http.get(Uri.parse(
        'https://192.168.1.135:8888/SERVICE-OCR/get?documentId=${documentId}'));
    if (response.statusCode == 200) {
      dynamic jsonOcr = json.decode(response.body);
      OcrModel ocr = OcrModel.fromJson(jsonOcr);
      return ocr;
    } else {
      throw Exception('Erreur de chagement');
    }
  }

  Future<void> saveDataAsPdf(String documentId, String extractedData) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Center(
            child: pw.Text(extractedData),
          );
        },
      ),
    );

    final output = await getTemporaryDirectory();
    final file = File("${output.path}/$documentId.pdf");
    await file.writeAsBytes(await pdf.save());

    // Ouvrir le fichier PDF dans le navigateur
    final Uint8List bytes = file.readAsBytesSync();
    final tempDir = await getTemporaryDirectory();
    final tempPath = tempDir.path;
    final tempFile =
        await File('$tempPath/$documentId.pdf').writeAsBytes(bytes);

    final String path = tempFile.path;
    try {
      await OpenFile.open(path);
    } catch (e) {
      print('Error opening PDF: $e');
    }
  }

  pickImageFromGallery() async {
    XFile pickedFile =
        (await imagePicker!.pickImage(source: ImageSource.gallery))!;
    image = File(pickedFile.path);

    setState(() {
      performImageLabeling();
    });
  }

  pickImageFromCamera() async {
    XFile pickedFile =
        (await imagePicker!.pickImage(source: ImageSource.camera))!;
    image = File(pickedFile.path);

    setState(() {
      performImageLabeling();
    });
  }

  performImageLabeling() async {
    final inputImage = InputImage.fromFile(image!);
    final textDetector = GoogleMlKit.vision.textRecognizer();
    final RecognizedText recognisedText =
        await textDetector.processImage(inputImage);

    String result = '';
    List<int> allowedLines = [3, 4, 6, 8, 9, 11];
    int currentLine = 1;

    for (TextBlock block in recognisedText.blocks) {
      final String txt = block.text;

      for (TextLine line in block.lines) {
        if (allowedLines.contains(currentLine)) {
          for (TextElement element in line.elements) {
            result += "${element.text} ";
          }
          result += "\n\n";
        }
        currentLine++;
      }
    }

    setState(() {
      this.result = result;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/back.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          children: [
            const SizedBox(
              width: 100,
            ),
            Container(
              height: 460,
              width: 290,
              margin: const EdgeInsets.only(top: 20),
              padding: const EdgeInsets.only(left: 28, bottom: 5, right: 25),
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: result.split('\n\n').asMap().entries.map((entry) {
                      int index = entry.key;
                      if (index < labelList.length) {
                        String text = entry.value;
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              labelList[index],
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            TextField(
                              controller: TextEditingController(text: text),
                              maxLines: null,
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.symmetric(
                                    vertical: 1, horizontal: 30),
                              ),
                              style: const TextStyle(fontSize: 10),
                              textAlign: TextAlign.justify,
                            ),
                          ],
                        );
                      } else {
                        return Container(); // Ou tout autre widget de remplacement
                      }
                    }).toList(),
                  ),
                ),
              ),
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/note.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            // Positioned(
            // bottom: 20,
            // right: 100,
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    OcrModel ocr = OcrModel(
                      document_id: '', // Remplacer par l'ID du document extrait
                      extractdata:
                          result, // Utiliser les données extraites de l'image
                    );
                    createOcr(ocr).then((value) {
                      _showSuccessDialog(); // Afficher la boîte de dialogue de succès
                    }).catchError((error) {
                      throw Exception('Erreur de chagement'+ error);
                    });
                    // saveDataAsPdf(ocr.document_id, ocr.extractdata);
                  },
                  style: ElevatedButton.styleFrom(
                    onPrimary: const Color.fromARGB(
                        255, 82, 32, 14), // Couleur de fond du bouton
                    primary: Colors.white,
                    // Couleur du texte du bouton
                  ),
                  child: Text('Submit'),
                ),
                SizedBox(width: 20),
                ElevatedButton(
                  onPressed: () {
                    OcrModel ocr = OcrModel(
                      document_id: '', // Remplacer par l'ID du document extrait
                      extractdata:
                          result, // Utiliser les données extraites de l'image
                    );
                    //createOcr(ocr);
                    saveDataAsPdf(ocr.document_id, ocr.extractdata);
                  },
                  style: ElevatedButton.styleFrom(
                    onPrimary: const Color.fromARGB(
                        255, 82, 32, 14), // Couleur de fond du bouton
                    primary: Colors.white, // Couleur du texte du bouton
                  ),
                  child: Text('Telecharger Pdf'),
                ),
                SizedBox(width: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => Dashboard()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    onPrimary: Color.fromARGB(255, 91, 38, 19),
                    primary: Colors.white, // Couleur du texte du bouton
                  ),
                  child: Text('Go to dash'),
                ),
              ],
            ),
            //),
            Container(
              margin: const EdgeInsets.only(top: 2, right: 170),
              child: Stack(
                children: [
                  Stack(
                    children: [
                      Center(
                        child: Image.asset(
                          'assets/pin.png',
                          height: 260,
                          width: 250,
                        ),
                      ),
                    ],
                  ),
                  Center(
                    child: TextButton(
                      onPressed: () {
                        pickImageFromGallery();
                      },
                      onLongPress: () {
                        pickImageFromCamera();
                      },
                      child: Container(
                        margin: const EdgeInsets.only(top: 25),
                        child: image != null
                            ? Image.file(
                                image!,
                                width: 190,
                                height: 192,
                                fit: BoxFit.fill,
                              )
                            : Container(
                                width: 240,
                                height: 200,
                                child: const Icon(
                                  Icons.camera_enhance_sharp,
                                  size: 100,
                                  color: Colors.grey,
                                ),
                              ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
