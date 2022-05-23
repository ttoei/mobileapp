import 'dart:io';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import 'package:http/http.dart' as http;

import 'utils/palette.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Receipt App',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Palette.background,
      ),
      home: const MyHomePage(title: 'Receipt Digitization'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  File? image;
  bool loading = false;
  String result = '';
  Widget spinner = const Center(
    widthFactor: 1,
    child: SpinKitThreeBounce(
      color: Colors.white,
      size: 20,
    ),
  );

  _getImage({String type = 'gallery'}) async {
    XFile? pickedFile = await ImagePicker().pickImage(
      source: type == 'gallery' ? ImageSource.gallery : ImageSource.camera,
      maxWidth: 1800,
      maxHeight: 1800,
    );

    if (pickedFile != null) {
      setState(() {
        image = File(pickedFile.path);
      });
    } else {
      setState(() {
        image = null;
      });
    }
  }

  _process() async {
    if (loading) {
      return;
    }

    setState(() {
      loading = true;
    });

    final image = this.image;

    if (image != null) {
      final url = Uri.parse(
          'http://localhost:5000/scan');

      final request = http.MultipartRequest('POST', url);

      request.files.add(
          await http.MultipartFile.fromPath(
              'image',
              image.path
          )
      );

      final response = await request.send();
      final respStr = await response.stream.bytesToString();
      final resultStr = json.decode(respStr)['result'].join();

      setState(() {
        result = resultStr;
        loading = false;
      });

    } else {
      setState(() {
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(
          widget.title,
          style: TextStyle(color: Palette.background.shade800),
        ),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Invoke "debug painting" (press "p" in the console, choose the
          // "Toggle Debug Paint" action from the Flutter Inspector in Android
          // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
          // to see the wireframe for each widget.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            image != null
                ? Image.file(
                    image!,
                    height: 200,
                  )
                : const Card(
                    child: SizedBox(
                      width: 200,
                      height: 200,
                      child: Align(
                        alignment: Alignment.center,
                        child: Text("Please Select Image"),
                      ),
                    ),
                  ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.all(16.0),
                    primary: Palette.background.shade800,
                    textStyle: const TextStyle(fontSize: 18),
                  ),
                  onPressed: _getImage,
                  child: Column(
                    // Replace with a Row for horizontal icon + text
                    children: <Widget>[
                      Icon(Icons.image, color: Palette.background.shade800),
                      const Text("Gallery")
                    ],
                  ),
                ),
                TextButton(
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.all(16.0),
                    primary: Palette.background.shade800,
                    textStyle: const TextStyle(fontSize: 18),
                  ),
                  onPressed: () => {_getImage(type: 'camera')},
                  child: Column(
                    // Replace with a Row for horizontal icon + text
                    children: <Widget>[
                      Icon(Icons.camera, color: Palette.background.shade800),
                      const Text("Camera")
                    ],
                  ),
                ),
              ],
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  primary: const Color(0xff1BAFBF),
                  fixedSize: const Size(100, 50)),
              onPressed: _process,
              child: loading
                  ? spinner
                  : const Text(
                      'Process',
                      style: TextStyle(color: Colors.white),
                    ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Text(result),
            )
          ],
        ),
      ),
    );
  }
}
