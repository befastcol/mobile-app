import 'package:be_fast/api/deliveries.dart';
import 'package:be_fast/models/delivery.dart';
import 'package:be_fast/providers/map.dart';
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
          try {
            setState(() => isLoading = true);
            mapProvider.setIsSearchingDeliveries(true);

            Delivery response = await DeliveriesAPI().createDelivery(
                origin: mapProvider.origin,
                destination: mapProvider.destination,
                price: 50);

            mapProvider.setCreateDeliveryResponse(response);
          } finally {
            if (mounted) {
              setState(() => isLoading = false);
            }
          }
        }

        if (isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        return Container(
          margin: EdgeInsets.only(top: isButtonEnabled ? 0 : 20),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: isButtonEnabled ? handleOnPressed : null,
              style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                  backgroundColor: Colors.blue),
              child: Text('Solicitar servicio',
                  style: TextStyle(
                      color: isButtonEnabled ? Colors.white : Colors.grey)),
            ),
          ),
        );
      },
    );
  }
}
