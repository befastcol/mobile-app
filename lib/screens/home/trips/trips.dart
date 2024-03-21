import 'package:be_fast/api/deliveries.dart';
import 'package:be_fast/models/delivery.dart';
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

  void loadCourierTrips() async {
    setState(() {
      _isLoading = true;
    });
    try {
      String? userId = await UserSession.getUserId();
      _deliveries = await DeliveriesAPI.getCourierDeliveries(
          courierId: userId.toString());
    } catch (error) {
      debugPrint('loadCourierTrips: $error');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    loadCourierTrips();
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
                                      'Cada crédito representa un viaje que podrás realizar, si necesitas más créditos puedes recargar más.',
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
              onRefresh: () async => loadCourierTrips(),
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
              subtitle: const Text(
                "20",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
              ),
            ),
          );
        }

        return DeliveryCard(
          deliveyId: _deliveries[index].id,
          status: _deliveries[index].status,
          date: _deliveries[index].requestedDate,
          destination: _deliveries[index].destination.title,
          origin: _deliveries[index].origin.title,
          price: _deliveries[index].price,
        );
      },
      padding: const EdgeInsets.only(bottom: 70.0),
    );
  }
}
