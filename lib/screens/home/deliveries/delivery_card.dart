import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DeliveryCard extends StatelessWidget {
  final DateTime date;
  final int price;
  final String origin;
  final String destination;

  const DeliveryCard(
      {super.key,
      required this.date,
      required this.destination,
      required this.origin,
      required this.price});

  @override
  Widget build(BuildContext context) {
    return Card(
        surfaceTintColor: Colors.white,
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
                  Text(
                    "MXN \$$price",
                    style: TextStyle(color: Colors.grey[700]),
                  ),
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
        ));
  }
}
