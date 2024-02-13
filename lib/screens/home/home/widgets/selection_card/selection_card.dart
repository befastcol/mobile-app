import 'package:be_fast/providers/map.dart';
import 'package:be_fast/screens/home/home/widgets/selection_card/widgets/selection_card_content.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SelectionCard extends StatefulWidget {
  const SelectionCard({super.key});

  @override
  State<SelectionCard> createState() => _SelectionCardState();
}

class _SelectionCardState extends State<SelectionCard> {
  @override
  Widget build(BuildContext context) {
    final mapProvider = Provider.of<MapProvider>(context, listen: false);

    return FutureBuilder(
        future: mapProvider.getAddressLocation(),
        builder: (context, snapshot) {
          return Card(
            surfaceTintColor: Colors.white,
            margin: const EdgeInsets.all(20),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: const Padding(
              padding: EdgeInsets.all(20),
              child: SelectionCardContent(),
            ),
          );
        });
  }
}
