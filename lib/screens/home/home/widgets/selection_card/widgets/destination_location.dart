import 'package:be_fast/providers/map.dart';
import 'package:be_fast/screens/home/home/widgets/selection_card/widgets/location_item.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DestinationLocation extends StatelessWidget {
  const DestinationLocation({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<MapProvider>(builder: (context, mapProvider, child) {
      bool isDestinationEmpty = mapProvider.destination.title.isEmpty;
      return LocationItem(
        isSelectingOrigin: false,
        iconData: isDestinationEmpty ? Icons.search : Icons.location_on,
        iconColor: isDestinationEmpty ? Colors.black54 : Colors.red,
        text: isDestinationEmpty
            ? '¿A dónde vamos?'
            : mapProvider.destination.title,
      );
    });
  }
}
