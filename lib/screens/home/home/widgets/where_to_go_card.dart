import 'package:be_fast/providers/user_provider.dart';
import 'package:be_fast/providers/delivery_provider.dart';
import 'package:be_fast/shared/utils/show_snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../screens/origin_and_destination_screen.dart';

class WhereToGoCard extends StatelessWidget {
  const WhereToGoCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<UserProvider, DeliveryProvider>(
        builder: (context, userState, deliveryState, child) => Visibility(
              visible: deliveryState.origin.coordinates.isEmpty ||
                  deliveryState.destination.coordinates.isEmpty &&
                      !deliveryState.isLoadingDeliveryDetails,
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
                        Column(
                          children: [
                            Material(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(10),
                              child: InkWell(
                                onTap: () {
                                  if (userState.isDisabled) {
                                    return showSnackBar(context,
                                        "No puedes crear más pedidos porque tu cuenta ha sido deshabilitada.");
                                  }
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
                                child: const Padding(
                                  padding: EdgeInsets.fromLTRB(12, 16, 12, 16),
                                  child: Row(
                                    children: [
                                      Icon(Icons.search,
                                          color: Colors.blueGrey),
                                      SizedBox(width: 10),
                                      Text("¿A dónde vamos?"),
                                    ],
                                  ),
                                ),
                              ),
                            )
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ));
  }
}
