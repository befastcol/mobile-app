import 'package:be_fast/api/user.dart';
import 'package:flutter/material.dart';

class Profile extends StatefulWidget {
  final String? name;
  final String? userId;
  final Function updateUserName;

  const Profile(
      {super.key,
      required this.name,
      required this.userId,
      required this.updateUserName});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late bool _isLoading;

  @override
  void initState() {
    _nameController = TextEditingController(text: widget.name);
    _isLoading = false;
    super.initState();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
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
        child: Form(
          key: _formKey,
          child: Center(
              child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 30),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Image(
                    image: AssetImage('assets/profile.png'),
                  ),
                  const SizedBox(height: 40),
                  Text(
                    _nameController.text,
                    textAlign: TextAlign.left,
                    style: const TextStyle(
                      color: Colors.black87,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text(
                    '¿Como quieres que te llamemos?',
                    style: TextStyle(
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _nameController,
                    keyboardType: TextInputType.text,
                    decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Nombre',
                        hintText: 'Nombre Apellido'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Introduce tu nombre por favor';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: __saveUser,
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size(double.infinity, 50),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              backgroundColor: Colors.blue,
                            ),
                            child: const Text(
                              'Guardar',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                ],
              ),
            ),
          )),
        ),
      ),
    );
  }

  void showSnackBar(BuildContext context, String message) {
    final snackBar = SnackBar(
      content: Text(message),
      duration: const Duration(seconds: 2),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void __saveUser() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      try {
        await updateUser(userId: widget.userId, name: _nameController.text);
        await widget.updateUserName(_nameController.text);
        if (mounted) showSnackBar(context, "Nombre guardado correctamente");
      } catch (e) {
        debugPrint("Error: $e");
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
