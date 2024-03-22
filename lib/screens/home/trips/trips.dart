import 'package:be_fast/api/deliveries.dart';
import 'package:be_fast/api/users.dart';
import 'package:be_fast/models/delivery.dart';
import 'package:be_fast/models/user.dart';
import 'package:be_fast/shared/widgets/delivery_card.dart';
import 'package:be_fast/shared/utils/user_session.dart';
import 'package:flutter/material.dart';

class Trips extends StatefulWidget {
  const Trips({super.key});

  @override
  State<Trips> createState() => _TripsState();
}

class _TripsState extends State<Trips> {
  List<DeliveryModel> _deliveries = [];
  bool _isLoading = false;
  int _credits = 0;

  @override
  void initState() {
    _loadCourierTrips();
    super.initState();
  }

  Future _loadCourierTrips() async {
    try {
      setState(() => _isLoading = true);
      String? courierId = await UserSession.getUserId();
      _deliveries =
          await DeliveriesAPI.getCourierDeliveries(courierId: courierId);
      UserModel user = await UsersAPI.getUser(userId: courierId);
      _credits = user.credits;
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        surfaceTintColor: Colors.transparent,
        backgroundColor: Colors.amber,
        title: const Text("Mis viajes"),
        actions: _deliveries.isNotEmpty
            ? [
                IconButton(
                  icon: const Icon(Icons.info_outline),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          surfaceTintColor: Colors.white,
                          title: const Text("¿Qué son los créditos?"),
                          content: RichText(
                            text: const TextSpan(
                              style:
                                  TextStyle(color: Colors.black, fontSize: 16),
                              children: <TextSpan>[
                                TextSpan(
                                  text:
                                      'Cada crédito representa un viaje que podrás realizar, si necesitas más créditos contacta a un administrador.',
                                ),
                              ],
                            ),
                          ),
                          actions: <Widget>[
                            TextButton(
                              child: const Text("Cerrar"),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
              ]
            : [],
      ),
      body: SafeArea(
        child: Stack(
          children: [
            RefreshIndicator(
              onRefresh: () async => _loadCourierTrips(),
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _deliveries.isEmpty
                      ? buildEmptyListView()
                      : buildDeliveriesListView(),
            ),
          ],
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
          'Sin viajes',
          style: TextStyle(
            color: Colors.black54,
          ),
        )),
      ],
    );
  }

  Widget buildDeliveriesListView() {
    return ListView.builder(
      itemCount: _deliveries.length,
      itemBuilder: (context, index) {
        if (index == 0 && _deliveries.isNotEmpty) {
          return Card(
            surfaceTintColor: Colors.white,
            margin: const EdgeInsets.all(8.0),
            child: ListTile(
              title: Text(
                "Créditos restantes",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18.0, color: Colors.grey[600]),
              ),
              subtitle: Text(
                "$_credits",
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 16.0, fontWeight: FontWeight.bold),
              ),
            ),
          );
        }

        return DeliveryCard(
          deliveryId: _deliveries[index].id,
          status: _deliveries[index].status,
          date: _deliveries[index].requestedDate,
          destination: _deliveries[index].destination.title,
          origin: _deliveries[index].origin.title,
          price: _deliveries[index].price,
        );
      },
    );
  }
}
