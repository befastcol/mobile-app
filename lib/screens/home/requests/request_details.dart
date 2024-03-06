import 'package:be_fast/api/users.dart';
import 'package:be_fast/models/custom/custom.dart';
import 'package:be_fast/shared/utils/show_snack_bar.dart';
import 'package:be_fast/shared/utils/user_session.dart';
import 'package:flutter/material.dart';

class RequestDetails extends StatefulWidget {
  final String courierId, name;
  final Documents documents;

  const RequestDetails({
    super.key,
    required this.courierId,
    required this.name,
    required this.documents,
  });

  @override
  State<RequestDetails> createState() => _RequestDetailsState();
}

class _RequestDetailsState extends State<RequestDetails> {
  Widget buildImageCard(String imageUrl, String title) {
    return Card(
      surfaceTintColor: Colors.white,
      child: Column(
        children: [
          ListTile(
            title: Text(title),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Image.network(imageUrl,
                fit: BoxFit
                    .cover), // Asumiendo que tienes URLs para las imágenes, de lo contrario usa `Image.asset`
          ),
        ],
      ),
    );
  }

  Future<void> _acceptCourierRequest() async {
    // Mostrar un cuadro de diálogo de confirmación
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Confirmar"),
          content: Text(
              "¿Estás seguro de que quieres aceptar a ${widget.name} como repartidor?"),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text("No"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: const Text("Sí"),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      try {
        String? userId = await UserSession.getUserId();
        await UsersAPI().updateUserRole(userId: userId, role: 'courier');

        if (mounted) {
          showSnackBar(context,
              "Has aceptado correctamente a ${widget.name} como repartidor.");
        }
      } catch (e) {
        if (mounted) {
          showSnackBar(context, "Ocurrió un error, intenta de nuevo.");
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        surfaceTintColor: Colors.transparent,
        backgroundColor: Colors.amber,
        title: Text(widget.name),
        actions: [
          PopupMenuButton(
            color: Colors.white,
            surfaceTintColor: Colors.white,
            onSelected: (String value) {
              switch (value) {
                case 'accept':
                  _acceptCourierRequest();
                  break;
                default:
                  break;
              }
            },
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem(value: 'accept', child: Text('Aceptar')),
              const PopupMenuItem(
                  value: 'decline',
                  child: Text('Rechazar', style: TextStyle(color: Colors.red))),
            ],
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            buildImageCard(widget.documents.ine.front, "INE (Frontal)"),
            buildImageCard(widget.documents.ine.back, "INE (Trasera)"),
            buildImageCard(
                widget.documents.driverLicense.front, "Licencia de Conducir"),
          ],
        ),
      ),
    );
  }
}
