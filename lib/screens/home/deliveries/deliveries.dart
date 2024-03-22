import 'package:be_fast/shared/utils/show_snack_bar.dart';
import 'package:be_fast/shared/widgets/delivery_card.dart';
import 'package:flutter/material.dart';
import 'package:be_fast/api/deliveries.dart';
import 'package:be_fast/models/delivery.dart';
import 'package:be_fast/shared/utils/user_session.dart';

class Deliveries extends StatefulWidget {
  const Deliveries({super.key});

  @override
  State<Deliveries> createState() => _DeliveriesState();
}

class _DeliveriesState extends State<Deliveries> {
  List<DeliveryModel> deliveries = [];
  bool _isLoading = false;

  @override
  void initState() {
    _loadUserDeliveries();
    super.initState();
  }

  Future _loadUserDeliveries() async {
    setState(() => _isLoading = true);
    try {
      String? userId = await UserSession.getUserId();
      deliveries =
          await DeliveriesAPI.getUserDeliveries(userId: userId.toString());
    } catch (error) {
      if (mounted) {
        showSnackBar(context, "Error al cargar los pedidos");
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        surfaceTintColor: Colors.transparent,
        backgroundColor: const Color.fromRGBO(172, 222, 80, 1),
        title: const Text("Mis pedidos"),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async => _loadUserDeliveries(),
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : deliveries.isEmpty
                  ? buildEmptyListView()
                  : buildDeliveriesListView(),
        ),
      ),
    );
  }

  Widget buildEmptyListView() {
    return ListView(
      children: [
        const SizedBox(height: 180),
        Container(
            margin: const EdgeInsets.symmetric(horizontal: 50),
            child: Image.asset('assets/images/empty.png')),
        const Center(
            child: Text(
          'Sin pedidos',
          style: TextStyle(
            color: Colors.black54,
          ),
        )),
      ],
    );
  }

  Widget buildDeliveriesListView() {
    return ListView.builder(
      itemCount: deliveries.length,
      itemBuilder: (context, index) {
        final delivery = deliveries[index];
        return DeliveryCard(
          deliveryId: delivery.id,
          status: delivery.status,
          date: delivery.requestedDate,
          destination: delivery.destination.title,
          origin: delivery.origin.title,
          price: delivery.price,
        );
      },
    );
  }
}
