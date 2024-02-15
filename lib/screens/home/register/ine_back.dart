import 'dart:io';
import 'package:be_fast/screens/home/register/driver_license.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class INEBackScreen extends StatefulWidget {
  const INEBackScreen({super.key});

  @override
  State<INEBackScreen> createState() => _INEBackScreenState();
}

class _INEBackScreenState extends State<INEBackScreen> {
  final ImagePicker _picker = ImagePicker();
  XFile? _image;
  bool _imageSelected = false;

  Future<void> _pickImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
          source: ImageSource.gallery,
          maxWidth: 1000,
          maxHeight: 1000,
          imageQuality: 50);
      if (pickedFile != null) {
        setState(() {
          _image = pickedFile;
          _imageSelected = true;
        });
      }
    } catch (e) {
      debugPrint("_pickImage: $e");
    }
  }

  void _continue() {
    Navigator.push(context,
        MaterialPageRoute(builder: (_) => const DriverLicenseScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Container(
              margin: const EdgeInsets.all(30),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_image != null)
                    Image.file(File(_image!.path))
                  else
                    const Image(
                      image: AssetImage('assets/ine_back.png'),
                    ),
                  const SizedBox(height: 50),
                  const Text(
                    'INE',
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text(
                    'Agrega una foto de tu INE mostrando la cara trasera.',
                    style: TextStyle(
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _imageSelected ? _continue : _pickImage,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        backgroundColor: Colors.blue,
                      ),
                      child: Text(
                        _imageSelected ? 'Continuar' : 'Agregar foto',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
