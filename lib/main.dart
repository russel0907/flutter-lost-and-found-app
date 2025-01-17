import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';

const supabaseUrl = 'https://gehaaanmpozoabzjptbp.supabase.co';
const supabaseKey = String.fromEnvironment('SUPABASE_KEY');

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Ensure SUPABASE_KEY is provided
  if (supabaseKey.isEmpty) {
    throw Exception(
        'SUPABASE_KEY is not defined. Use --dart-define to provide it.');
  }

  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseKey,
  );

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

    if (photo != null) {
      setState(() {
        _image = photo;
      });

      // Convert XFile to Uint8List
      final Uint8List bytes = await photo.readAsBytes();

      // Create a temporary file to pass to Supabase upload
      final tempDir = await getTemporaryDirectory();
      final tempFile =
          File('${tempDir.path}/${DateTime.now().millisecondsSinceEpoch}.jpg');
      await tempFile.writeAsBytes(bytes);

      try {
        // Upload to Supabase Storage
        final fileName = DateTime.now().millisecondsSinceEpoch.toString();
        final response = await Supabase.instance.client.storage
            .from('found-items') // Replace with your Supabase bucket name
            .upload('images/$fileName.jpg', tempFile);

        print('Image uploaded successfully: $response');

        // Get public URL of the uploaded image
        final imageUrl = Supabase.instance.client.storage
            .from('found-items')
            .getPublicUrl('images/$fileName.jpg');

        print('Public URL: $imageUrl');
      } catch (e) {
        print('Error uploading image: $e');
      }
    }

    print('Image path: ${_image?.path}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                  ? () async {
                      final fileName =
                          DateTime.now().millisecondsSinceEpoch.toString();

                      try {
                        // Convert XFile to File
                        final tempDir = await getTemporaryDirectory();
                        final tempFile = File('${tempDir.path}/$fileName.jpg');
                        await tempFile.writeAsBytes(
                            await File(_image!.path).readAsBytes());

                        // Upload to Supabase Storage
                        final response = await Supabase.instance.client.storage
                            .from(
                                'found-items') // Replace 'found-items' with your bucket name
                            .upload('images/$fileName.jpg', tempFile);

                        print(response);

                        // Retrieve the public URL of the uploaded image
                        final imageUrl = Supabase.instance.client.storage
                            .from('found-items')
                            .getPublicUrl('images/$fileName.jpg');

                        // Save image URL to database
                        await Supabase.instance.client
                            .from(
                                'found_reports') // Replace 'found_reports' with your table name
                            .insert({
                          'image_url': imageUrl,
                          'description': 'Found item',
                        });

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Image submitted successfully!')),
                        );
                      } catch (e) {
                        print('Error submitting data: $e');
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error: $e')),
                        );
                      }
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.greenAccent,
              ),
              child: const Text('Submit'),
            )
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
