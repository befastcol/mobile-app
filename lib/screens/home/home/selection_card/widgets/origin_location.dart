import 'package:be_fast/providers/map_provider.dart';
import 'package:be_fast/screens/home/home/selection_card/widgets/location_item.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class OriginLocation extends StatelessWidget {
  const OriginLocation({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<MapProvider>(
        builder: (context, mapProvider, child) => Visibility(
              visible: mapProvider.destination.coordinates.isNotEmpty,
              child: Column(
                children: [
                  LocationItem(
                    isSelectingOrigin: true,
                    iconData: Icons.location_on,
                    iconColor: Colors.blue,
                    text: mapProvider.origin.title,
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ));
  }
}
