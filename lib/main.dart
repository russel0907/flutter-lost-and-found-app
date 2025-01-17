import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
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
      body: SizedBox(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(
                width: MediaQuery.of(context).size.width * 0.2,
                height: MediaQuery.of(context).size.height * 0.2,
                'assets/logo/logo.png'),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const LostPage(title: 'Laman HILANG'),
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.all(16.0),
                color: Colors.redAccent,
                margin: const EdgeInsets.symmetric(vertical: 8.0),
                child: const Text(
                  'HILANG',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const FoundPage(title: 'Laman JUMPA'),
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.all(16.0),
                color: Colors.greenAccent,
                margin: const EdgeInsets.symmetric(vertical: 8.0),
                child: const Text(
                  'JUMPA',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class LostPage extends StatelessWidget {
  const LostPage({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          'Selamat datang ke $title!',
          style: const TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}

class FoundPage extends StatefulWidget {
  const FoundPage({super.key, required this.title});

  final String title;

  @override
  State<FoundPage> createState() => _FoundPageState();
}

class _FoundPageState extends State<FoundPage> {
  XFile? _image; // Store the captured image
  final ImagePicker _picker = ImagePicker(); // Image picker instance

  Future<void> _activateCamera() async {
    final XFile? photo = await _picker.pickImage(source: ImageSource.camera);
    setState(() {
      _image = photo; // Store the image in the state
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Display the captured image or a placeholder
            _image != null
                ? Image.file(
                    File(_image!.path),
                    width: MediaQuery.of(context).size.width * 0.8,
                    height: MediaQuery.of(context).size.height * 0.4,
                  )
                : const Text(
                    'No image captured.',
                    style: TextStyle(fontSize: 18),
                  ),
            const SizedBox(height: 20),
            // Submit button
            ElevatedButton(
              onPressed: _image != null
                  ? () {
                      // Handle submit action here
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Image submitted!'),
                        ),
                      );
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.greenAccent,
              ),
              child: const Text('Submit'),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _activateCamera,
        backgroundColor: Colors.blueAccent,
        child: const Icon(Icons.camera_alt),
      ),
    );
  }
}
