import 'package:flutter/material.dart';
import 'package:wasm_bug/picture/picture.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.red,
              Colors.blue,
              Colors.green,
            ],
          ),
        ),
        child: ListView(
          children: [
            Icon(Icons.ac_unit),
            Icon(Icons.abc),
            Icon(Icons.dangerous),
            Icon(Icons.safety_check),
            Icon(Icons.wallet_giftcard),
            Icon(Icons.zoom_in),
            Icon(Icons.cabin),
            Text('Test wasm bugs'),
            Picture('https://svgsilh.com/svg/1801287.svg'),
            Text(''),
            Row(
              children: [
                Text(''),
                Picture(
                  'https://interactivechaos.com/sites/default/files/2023-02/super_mario.png',
                ),
              ],
            ),
            Picture(
              'https://www.adobe.com/la/creativecloud/file-types/image/vector/media_1c070a728afcba5b699f323d35c21b1e7f54a8157.jpeg',
            ),
            Picture(
              'https://upload.wikimedia.org/wikipedia/commons/thumb/4/4f/SVG_Logo.svg/1200px-SVG_Logo.svg.png',
            ),
            Picture('https://cdn-icons-png.flaticon.com/512/29/29495.png'),
            Picture(
              'https://upload.wikimedia.org/wikipedia/commons/thumb/e/ec/Bitmap_VS_SVG_ru.svg/300px-Bitmap_VS_SVG_ru.svg.png',
            ),
            Picture('https://cdn-icons-png.flaticon.com/512/29/29080.png'),
            Picture('https://svgsilh.com/svg/2026667.svg'),
            Picture('https://svgsilh.com/svg/48018.svg'),
            Picture('https://svgsilh.com/svg/147901.svg'),
          ],
        ),
      ),
    );
  }
}
