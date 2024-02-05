import 'package:be_fast/api/delivery.dart';
import 'package:be_fast/providers/map_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SearchButtonWidget extends StatefulWidget {
  const SearchButtonWidget({Key? key}) : super(key: key);

  @override
  State<SearchButtonWidget> createState() => _SearchButtonWidgetState();
}

class _SearchButtonWidgetState extends State<SearchButtonWidget> {
  bool isLoading = false;
  @override
  Widget build(BuildContext context) {
    return Consumer<MapProvider>(
      builder: (context, mapProvider, child) {
        bool isButtonEnabled = mapProvider.origin.coordinates.isNotEmpty &&
            mapProvider.destination.coordinates.isNotEmpty;

        Future handleOnPressed() async {
          setState(() => isLoading = true);
          try {
            final response = await createDelivery(
                origin: mapProvider.origin,
                destination: mapProvider.destination);
            debugPrint(response.courier);
          } finally {
            setState(() => isLoading = false);
          }
        }

        if (isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        return Container(
          margin: const EdgeInsets.only(top: 20),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: isButtonEnabled ? handleOnPressed : null,
              style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                  backgroundColor: Colors.blue),
              child: Text('Buscar repartidores',
                  style: TextStyle(
                      color: isButtonEnabled ? Colors.white : Colors.grey)),
            ),
          ),
        );
      },
    );
  }
}
