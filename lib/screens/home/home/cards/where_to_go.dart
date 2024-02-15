import 'package:be_fast/providers/map.dart';
import 'package:be_fast/screens/home/home/widgets/selection_card/screens/location_selection_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class WhereToGoCard extends StatelessWidget {
  const WhereToGoCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<MapProvider>(
        builder: (context, provider, child) => Visibility(
              visible: provider.destination.coordinates.isEmpty,
              child: Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Card(
                  surfaceTintColor: Colors.white,
                  color: Colors.white,
                  margin: const EdgeInsets.all(20),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                  child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Material(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(10),
                        child: InkWell(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => LocationSelectionScreen(
                                isSelectingOrigin: false,
                                originTitle: provider.origin.title,
                                destinationTitle: provider.destination.title,
                              ),
                            ),
                          ),
                          borderRadius: BorderRadius.circular(10),
                          child: const Padding(
                            padding: EdgeInsets.fromLTRB(12, 16, 12, 16),
                            child: Row(
                              children: [
                                Icon(Icons.search, color: Colors.black54),
                                SizedBox(width: 10),
                                Text(
                                  '¿A dónde vamos?',
                                  style: TextStyle(
                                      color: Colors.black54,
                                      fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                          ),
                        ),
                      )),
                ),
              ),
            ));
  }
}
