import 'package:be_fast/providers/delivery_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../screens/origin_and_destination_screen.dart';

class ServiceRequestCard extends StatelessWidget {
  const ServiceRequestCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<DeliveryProvider>(
        builder: (context, deliveryState, child) => Visibility(
              visible: deliveryState.origin.coordinates.isNotEmpty &&
                  deliveryState.destination.coordinates.isNotEmpty &&
                  deliveryState.id.isEmpty,
              child: Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Card(
                  surfaceTintColor: Colors.white,
                  margin: const EdgeInsets.all(20),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          child: Material(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(10),
                            child: InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        OriginAndDestinationScreen(
                                      isSelectingOrigin: true,
                                      originTitle: deliveryState.origin.title,
                                      destinationTitle:
                                          deliveryState.destination.title,
                                    ),
                                  ),
                                );
                              },
                              borderRadius: BorderRadius.circular(10),
                              child: Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(12, 16, 12, 16),
                                child: Row(
                                  children: [
                                    const Icon(Icons.location_on,
                                        color: Colors.blue),
                                    const SizedBox(width: 10),
                                    Text(deliveryState.origin.title),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          child: Material(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(10),
                            child: InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        OriginAndDestinationScreen(
                                      isSelectingOrigin: false,
                                      originTitle: deliveryState.origin.title,
                                      destinationTitle:
                                          deliveryState.destination.title,
                                    ),
                                  ),
                                );
                              },
                              borderRadius: BorderRadius.circular(10),
                              child: Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(12, 16, 12, 16),
                                child: Row(
                                  children: [
                                    const Icon(Icons.location_on,
                                        color: Colors.red),
                                    const SizedBox(width: 10),
                                    Text(deliveryState.destination.title),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: deliveryState.createDelivery,
                            style: ElevatedButton.styleFrom(
                                minimumSize: const Size(double.infinity, 50),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8)),
                                backgroundColor: Colors.blue),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text('Solicitar servicio',
                                    style: TextStyle(color: Colors.white)),
                                const SizedBox(
                                  width: 20,
                                ),
                                Visibility(
                                  visible: deliveryState.price > 0,
                                  child: Text(
                                    '\$${deliveryState.price}',
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ));
  }
}
