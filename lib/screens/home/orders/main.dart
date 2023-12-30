import 'package:flutter/material.dart';

class Orders extends StatefulWidget {
  const Orders({super.key});

  @override
  State<Orders> createState() => _OrdersState();
}

class _OrdersState extends State<Orders> {
  final orders = [1, 2, 3, 4, 5, 6, 7, 8, 9];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        surfaceTintColor: Colors.transparent,
        backgroundColor: Colors.yellow[600],
        title: const Text("Mis pedidos test"),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: orders.map((order) {
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
                                "20 de Diciembre",
                                style: TextStyle(color: Colors.grey[700]),
                              ),
                            ],
                          ),
                          Text(
                            "MXN \$39.00",
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
                            "Plaza Sanfernando",
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
                            "Plaza Sendera",
                            style: TextStyle(color: Colors.grey[700]),
                          )
                        ],
                      )
                    ],
                  ),
                ));
          }).toList(),
        ),
      ),
    );
  }
}
