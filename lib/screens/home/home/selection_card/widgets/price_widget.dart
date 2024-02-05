import 'package:be_fast/providers/map_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PriceWidget extends StatelessWidget {
  const PriceWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<MapProvider>(
        builder: (context, mapProvider, child) => Visibility(
              visible: mapProvider.destination.coordinates.isNotEmpty &&
                  mapProvider.origin.coordinates.isNotEmpty,
              child: ListTile(
                leading: Icon(Icons.motorcycle, color: Colors.grey[600]),
                title: Text(
                  "Costo del servicio",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Colors.grey[600], fontWeight: FontWeight.w600),
                ),
                trailing: Text(
                  '\$40',
                  style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                ),
              ),
            ));
  }
}
