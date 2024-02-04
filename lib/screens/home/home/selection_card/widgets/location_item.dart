import 'package:be_fast/providers/map_provider.dart';
import 'package:be_fast/screens/home/home/selection_card/screens/location_selection_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LocationItem extends StatelessWidget {
  final IconData iconData;
  final Color iconColor;
  final String text;

  const LocationItem({
    Key? key,
    required this.iconData,
    required this.iconColor,
    required this.text,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<MapProvider>(
        builder: (context, value, child) => Material(
              color: Theme.of(context).colorScheme.surfaceVariant,
              borderRadius: BorderRadius.circular(20),
              child: InkWell(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LocationSelectionScreen(
                      originTitle: value.origin.title,
                      destinationTitle: value.destination.title,
                    ),
                  ),
                ),
                borderRadius: BorderRadius.circular(20),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 16, 12, 16),
                  child: Row(
                    children: [
                      Icon(iconData, color: iconColor),
                      const SizedBox(width: 10),
                      Text(text),
                    ],
                  ),
                ),
              ),
            ));
  }
}
