import 'package:be_fast/api/delivery.dart';
import 'package:be_fast/models/delivery.dart';
import 'package:be_fast/screens/home/deliveries/delivery_card.dart';
import 'package:flutter/material.dart';

class UserDeliveries extends StatefulWidget {
  final String userId, name;

  const UserDeliveries({super.key, required this.userId, required this.name});

  @override
  State<UserDeliveries> createState() => _UserDeliveriesState();
}

class _UserDeliveriesState extends State<UserDeliveries> {
  List<Delivery> deliveries = [];
  bool isLoading = false;

  Future _handleGetUserDeliveries() async {
    setState(() => isLoading = true);
    try {
      deliveries = await getUserDeliveries(widget.userId);
    } finally {
      if (mounted) {
        setState(() {
          setState(() => isLoading = false);
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _handleGetUserDeliveries();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: deliveries.isEmpty ? Colors.white : Colors.grey[100],
      appBar: AppBar(
        surfaceTintColor: Colors.transparent,
        backgroundColor: Colors.teal[600],
        title: Text(widget.name),
      ),
      body: RefreshIndicator(
        onRefresh: _handleGetUserDeliveries,
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : deliveries.isEmpty
                ? ListView(
                    children: [
                      const SizedBox(height: 180),
                      Container(
                          margin: const EdgeInsets.symmetric(horizontal: 50),
                          child: Image.asset('assets/empty.png')),
                      const Center(
                          child: Text(
                        'Usuario sin servicios',
                        style: TextStyle(
                          color: Colors.black54,
                        ),
                      )),
                    ],
                  )
                : ListView.builder(
                    itemCount: deliveries.length,
                    itemBuilder: (context, index) {
                      final delivery = deliveries[index];
                      return DeliveryCard(
                        date: delivery.requestedDate,
                        destination: delivery.destination.title,
                        origin: delivery.origin.title,
                        price: delivery.price,
                      );
                    },
                  ),
      ),
    );
  }
}
