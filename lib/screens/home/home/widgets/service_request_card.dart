import 'package:be_fast/providers/delivery_provider.dart';
import 'package:be_fast/shared/utils/show_snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../screens/origin_and_destination_screen.dart';

class ServiceRequestCard extends StatefulWidget {
  const ServiceRequestCard({super.key});

  @override
  State<ServiceRequestCard> createState() => _ServiceRequestCardState();
}

class _ServiceRequestCardState extends State<ServiceRequestCard> {
  bool _isLoadingRequest = false;

  @override
  Widget build(BuildContext context) {
    return Consumer<DeliveryProvider>(
      builder: (context, deliveryState, child) => Visibility(
        visible: deliveryState.origin.coordinates.isNotEmpty &&
            deliveryState.destination.coordinates.isNotEmpty &&
            deliveryState.price > 0 &&
            deliveryState.id.isEmpty,
        child: Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: Card(
            surfaceTintColor: Colors.white,
            margin: const EdgeInsets.all(20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildLocationContainer(context, deliveryState, true),
                  _buildLocationContainer(context, deliveryState, false),
                  Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Expanded(
                          child: _vehicleSelectionButton(
                            context,
                            icon: Icons.motorcycle,
                            isSelected: deliveryState.isMotorcycleSelected,
                            onPressed: () =>
                                deliveryState.setIsMotorcycleSelected(true),
                          ),
                        ),
                        Expanded(
                          child: _vehicleSelectionButton(
                            context,
                            icon: Icons.directions_car,
                            isSelected: !deliveryState.isMotorcycleSelected,
                            onPressed: () =>
                                deliveryState.setIsMotorcycleSelected(false),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Visibility(
                      visible: _isLoadingRequest,
                      child: const Center(
                        child: LinearProgressIndicator(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                          color: Colors.blue,
                          minHeight: 50,
                        ),
                      )),
                  Visibility(
                    visible: !_isLoadingRequest,
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          try {
                            setState(() => _isLoadingRequest = true);
                            await deliveryState.createDelivery(
                                (message) => showSnackBar(context, message));
                          } finally {
                            setState(() => _isLoadingRequest = false);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          backgroundColor: Colors.blue,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              deliveryState.isMotorcycleSelected
                                  ? 'Solicitar moto'
                                  : 'Solicitar carro',
                              style: const TextStyle(color: Colors.white),
                            ),
                            const SizedBox(width: 20),
                            Text(
                              '\$${deliveryState.isMotorcycleSelected ? deliveryState.price : deliveryState.price + 20}', // Aumenta el precio en 20 si el carro está seleccionado
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _vehicleSelectionButton(BuildContext context,
      {required IconData icon,
      required bool isSelected,
      required VoidCallback onPressed}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.grey[100],
          side: BorderSide(
            color: isSelected ? Colors.blue : Colors.grey,
            width: 2,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: Icon(icon, color: isSelected ? Colors.blue : Colors.grey[700]),
      ),
    );
  }

  Widget _buildLocationContainer(
      BuildContext context, DeliveryProvider deliveryState, bool isOrigin) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => OriginAndDestinationScreen(
                  isSelectingOrigin: isOrigin,
                  originTitle: deliveryState.origin.title,
                  destinationTitle: deliveryState.destination.title,
                ),
              ),
            );
          },
          borderRadius: BorderRadius.circular(10),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 16, 12, 16),
            child: Row(
              children: [
                Icon(isOrigin ? Icons.location_on : Icons.location_on,
                    color: isOrigin ? Colors.blue : Colors.red),
                const SizedBox(width: 10),
                Text(isOrigin
                    ? deliveryState.origin.title
                    : deliveryState.destination.title),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
