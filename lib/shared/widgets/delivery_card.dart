import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'delivery_map_location.dart';

class DeliveryCard extends StatelessWidget {
  final DateTime date;
  final int price;
  final String origin, destination, status, deliveryId;

  const DeliveryCard(
      {super.key,
      required this.deliveryId,
      required this.date,
      required this.destination,
      required this.origin,
      required this.status,
      required this.price});

  @override
  Widget build(BuildContext context) {
    return Card(
        surfaceTintColor: Colors.white,
        color: Colors.white,
        child: InkWell(
          onTap: status == "in_progress"
              ? () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => DeliveryMapLocation(
                                deliveryId: deliveryId,
                              )));
                }
              : null,
          child: Container(
            margin: const EdgeInsets.all(20),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.schedule,
                          color: Colors.grey[500],
                        ),
                        const SizedBox(width: 6),
                        Text(
                          DateFormat('d \'de\' MMMM', 'es_ES').format(date),
                          style: TextStyle(color: Colors.grey[700]),
                        )
                      ],
                    ),
                    Column(
                      children: [
                        Text(
                          "MXN \$$price",
                          style: TextStyle(color: Colors.grey[700]),
                        ),
                        Visibility(
                          visible: status == "in_progress",
                          child: const Text(
                            "En camino",
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                        Visibility(
                          visible: status == "completed",
                          child: const Text(
                            "Entregado",
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                        Visibility(
                          visible: status == "pending",
                          child: const Text(
                            "Pendiente",
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
                Row(
                  children: [
                    const Icon(
                      Icons.fmd_good,
                      color: Colors.blue,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      origin,
                      style: TextStyle(color: Colors.grey[700]),
                    )
                  ],
                ),
                Row(
                  children: [
                    const Icon(
                      Icons.fmd_good,
                      color: Colors.red,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      destination,
                      style: TextStyle(color: Colors.grey[700]),
                    )
                  ],
                )
              ],
            ),
          ),
        ));
  }
}
