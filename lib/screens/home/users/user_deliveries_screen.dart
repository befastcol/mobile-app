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

  void loadUserDeliveries() async {
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
