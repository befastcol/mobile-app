import 'package:be_fast/providers/map_provider.dart';
import 'package:be_fast/screens/home/home/selection_card/widgets/location_item.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DestinationLocation extends StatelessWidget {
  const DestinationLocation({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<MapProvider>(
        builder: (context, value, child) => LocationItem(
              iconData: Icons.location_on,
              iconColor: Colors.red,
              text: value.destination.title.isEmpty
                  ? '¿A dónde vamos?'
                  : value.destination.title,
            ));
  }
}
