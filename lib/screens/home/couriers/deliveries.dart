import 'package:be_fast/api/deliveries.dart';
import 'package:be_fast/models/delivery.dart';
import 'package:be_fast/screens/home/deliveries/delivery_card.dart';
import 'package:flutter/material.dart';

class CourierDeliveries extends StatefulWidget {
  final String courierId, name;

  const CourierDeliveries(
      {super.key, required this.courierId, required this.name});

  @override
  State<CourierDeliveries> createState() => _CourierDeliveriesState();
}

class _CourierDeliveriesState extends State<CourierDeliveries> {
  List<DeliveryModel> _deliveries = [];
  bool _isLoading = false;

  void loadCourierDeliveries() async {
    try {
      setState(() => _isLoading = true);
      _deliveries = await DeliveriesAPI()
          .getCourierDeliveries(courierId: widget.courierId);
    } catch (error) {
      debugPrint('loadCourierDeliveries: $error ${widget.courierId}');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
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
      backgroundColor: Colors.white,
      appBar: AppBar(
          surfaceTintColor: Colors.transparent,
          backgroundColor: Colors.amber,
          title: Text(widget.name),
          actions: [
            PopupMenuButton(
              color: Colors.white,
              surfaceTintColor: Colors.white,
              onSelected: (String value) {
                switch (value) {
                  case 'disable':
                    break;
                  case 'payed':
                    break;
                  default:
                    break;
                }
              },
              itemBuilder: (BuildContext context) => [
                const PopupMenuItem(value: 'call', child: Text('📞 Llamar')),
                const PopupMenuItem(value: 'call', child: Text('✅ Pagado')),
                const PopupMenuItem(
                    value: 'disable',
                    child: Text(
                      '🔒 Deshabilitar',
                      style: TextStyle(color: Colors.red),
                    )),
              ],
            )
          ]),
      body: RefreshIndicator(
        onRefresh: _refreshList,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _deliveries.isEmpty
                ? ListView(
                    children: [
                      const SizedBox(height: 180),
                      Container(
                          margin: const EdgeInsets.symmetric(horizontal: 50),
                          child: Image.asset('assets/empty.png')),
                      const Center(
                          child: Text(
                        'No hay pedidos realizados',
                        style: TextStyle(
                          color: Colors.black54,
                        ),
                      )),
                    ],
                  )
                : ListView.builder(
                    itemCount: _deliveries.length,
                    itemBuilder: (context, index) {
                      final delivery = _deliveries[index];
                      return DeliveryCard(
                        deliveyId: delivery.id,
                        status: delivery.status,
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
