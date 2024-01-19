import 'package:be_fast/api/delivery.dart';
import 'package:be_fast/api/models/delivery.dart';
import 'package:be_fast/screens/home/deliveries/delivery_card.dart';
import 'package:flutter/material.dart';

class Deliveries extends StatefulWidget {
  const Deliveries({super.key});

  @override
  State<Deliveries> createState() => _DeliveriesState();
}

class _DeliveriesState extends State<Deliveries> {
  List<Delivery> deliveries = [];
  bool isLoading = false;

  void loadUserDeliveries() async {
    setState(() {
      isLoading = true;
    });
    try {
      String userId = "65a452775531c41d71aef08a";
      deliveries = await getUserDeliveries(userId);
    } catch (error) {
      debugPrint('Error: $error');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _refreshList() async {
    loadUserDeliveries();
  }

  @override
  void initState() {
    super.initState();
    loadUserDeliveries();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        surfaceTintColor: Colors.transparent,
        backgroundColor: Colors.teal[600],
        title: const Text("Mis pedidos"),
      ),
      body: RefreshIndicator(
        onRefresh: _refreshList,
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : ListView.builder(
                itemCount: deliveries.length,
                itemBuilder: (context, index) {
                  final delivery = deliveries[index];
                  return DeliveryCard(
                    date: delivery.requestedDate,
                    destination: delivery.destination.label,
                    origin: delivery.origin.label,
                    price: delivery.price,
                  );
                },
              ),
      ),
    );
  }
}
