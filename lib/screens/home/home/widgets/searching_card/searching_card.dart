import 'package:be_fast/providers/user.dart';
import 'package:be_fast/shared/utils/show_snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SearchingCard extends StatefulWidget {
  const SearchingCard({super.key});

  @override
  State<SearchingCard> createState() => _SearchingCardState();
}

class _SearchingCardState extends State<SearchingCard> {
  bool isCourierAssigned = false;
  bool isCancelingService = false;

  @override
  void initState() {
    super.initState();
    // channel = WebSocketChannel.connect(
    //   Uri.parse('ws://tu_servidor:puerto'),
    // );

    // channel.stream.listen((message) {
    //   final data = jsonDecode(message);

    //   if (data['courier'] != null) {
    //     setState(() => isCourierAssigned = true);
    //   }
    // });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(builder: (context, provider, child) {
      Future cancelService() async {
        try {
          setState(() => isCancelingService = true);
          await provider.cancelDelivery(
            onSuccess: () {
              if (mounted) {
                showSnackBar(context, "Servicio cancelado");
                provider.setIsSearchingDeliveries(false);
              }
            },
            onError: (String errorMessage) {
              if (mounted) {
                showSnackBar(context, "Error al cancelar el servicio");
              }
            },
          );
        } finally {
          setState(() => isCancelingService = false);
        }
      }

      return Card(
        surfaceTintColor: Colors.white,
        margin: const EdgeInsets.all(20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Text(
                isCancelingService
                    ? 'Cancelando servicio...'
                    : isCourierAssigned
                        ? 'Repartidor asignado!'
                        : 'Buscando repartidores...',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Container(
                  width: 80,
                  height: 80,
                  margin: const EdgeInsets.symmetric(vertical: 26),
                  child: CircularProgressIndicator(
                    color: !isCancelingService ? Colors.blueGrey : Colors.red,
                  )),
              Visibility(
                visible: !isCancelingService,
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: cancelService,
                    style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                        backgroundColor: Colors.red),
                    child: const Text('Cancelar servicio',
                        style: TextStyle(color: Colors.white)),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}
