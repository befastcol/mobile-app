import 'package:be_fast/providers/map.dart';
import 'package:be_fast/utils/show_snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class SearchingCard extends StatefulWidget {
  const SearchingCard({super.key});

  @override
  State<SearchingCard> createState() => _SearchingCardState();
}

class _SearchingCardState extends State<SearchingCard> {
  late WebSocketChannel channel;
  bool isCourierAssigned = false;

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
    channel.sink.close();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MapProvider>(builder: (context, mapProvider, child) {
      Future cancelService() async {
        try {} finally {
          mapProvider.setIsSearchingDeliveries(false);
          showSnackBar(context, "Servicio cancelado");
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
                isCourierAssigned
                    ? 'Repartidor asignado!'
                    : 'Buscando repartidores...',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Container(
                  width: 80,
                  height: 80,
                  margin: const EdgeInsets.symmetric(vertical: 26),
                  child: const CircularProgressIndicator()),
              SizedBox(
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
            ],
          ),
        ),
      );
    });
  }
}
