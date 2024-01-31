import 'package:be_fast/api/delivery.dart';
import 'package:be_fast/models/delivery.dart';
import 'package:be_fast/screens/home/deliveries/delivery_card.dart';
import 'package:flutter/material.dart';

class CourierDeliveries extends StatefulWidget {
  final String userId;
  final String name;

  const CourierDeliveries(
      {super.key, required this.userId, required this.name});

  @override
  State<CourierDeliveries> createState() => _CourierDeliveriesState();
}

class _CourierDeliveriesState extends State<CourierDeliveries> {
  List<Delivery> deliveries = [];
  bool isLoading = false;

  void loadCourierDeliveries() async {
    setState(() {
      isLoading = true;
    });
    try {
      deliveries = await getUserDeliveries(widget.userId);
    } catch (error) {
      debugPrint('Error: $error');
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> _refreshList() async {
    loadCourierDeliveries();
  }

  @override
  void initState() {
    super.initState();
    loadCourierDeliveries();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        surfaceTintColor: Colors.transparent,
        backgroundColor: Colors.teal[600],
        title: Text(widget.name),
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
