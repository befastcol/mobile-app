import 'dart:io';
import 'package:be_fast/api/users.dart';
import 'package:be_fast/screens/home/register/waiting_approval.dart';
import 'package:be_fast/utils/user_session.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class DriverLicenseScreen extends StatefulWidget {
  final XFile? ineFront;
  final XFile? ineBack;

  const DriverLicenseScreen(
      {super.key, required this.ineFront, required this.ineBack});

  @override
  State<DriverLicenseScreen> createState() => _DriverLicenseScreenState();
}

class _DriverLicenseScreenState extends State<DriverLicenseScreen> {
  final ImagePicker _picker = ImagePicker();
  XFile? _image;
  bool _isLoading = false; // Variable para controlar el indicador de carga

  Future<void> _pickImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1000,
        maxHeight: 1000,
        imageQuality: 50,
      );
      if (pickedFile != null) {
        setState(() {
          _image = pickedFile;
        });
      }
    } catch (e) {
      debugPrint("_pickImage: $e");
    }
  }

  Future<String?> _uploadFile(XFile file, String path) async {
    try {
      final ref = FirebaseStorage.instance.ref().child(path);
      final result = await ref.putFile(File(file.path));
      return await result.ref.getDownloadURL();
    } catch (e) {
      debugPrint("_uploadFile: $e");
      return null;
    }
  }

  Future<void> _continue() async {
    try {
      setState(() => _isLoading = true);

      final ineFrontUrl = await _uploadFile(
          widget.ineFront!, 'ineFront/${widget.ineFront!.name}');
      final ineBackUrl =
          await _uploadFile(widget.ineBack!, 'ineBack/${widget.ineBack!.name}');
      final licenseUrl =
          await _uploadFile(_image!, 'driverLicense/${_image!.name}');

      String? userId = await UserSession.getUserId();
      await UsersAPI().updateUserDocuments(
          userId: userId,
          ineFront: ineFrontUrl,
          ineBack: ineBackUrl,
          license: licenseUrl);

      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const WaitingApprovalScreen()),
          (_) => false,
        );
      }
    } catch (e) {
      print("Error uploading: $e");
    } finally {
      setState(() => _isLoading = false);
    }
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
                      image: AssetImage('assets/license.png'),
                    ),
                  const SizedBox(height: 50),
                  const Text(
                    'Licencia de conducir',
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text(
                    'Agrega una foto de tu licencia de conducir mostrando la cara frontal.',
                    style: TextStyle(
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : ElevatedButton(
                            onPressed: _image != null ? _continue : _pickImage,
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size(double.infinity, 50),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              backgroundColor: Colors.blue,
                            ),
                            child: Text(
                              _image != null ? 'Continuar' : 'Agregar foto',
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
