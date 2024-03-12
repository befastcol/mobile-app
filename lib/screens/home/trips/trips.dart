import 'package:be_fast/api/deliveries.dart';
import 'package:be_fast/models/delivery.dart';
import 'package:be_fast/shared/widgets/delivery_card.dart';
import 'package:be_fast/shared/utils/user_session.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Trips extends StatefulWidget {
  const Trips({super.key});

  @override
  State<Trips> createState() => _TripsState();
}

class _TripsState extends State<Trips> {
  List<DeliveryModel> allDeliveries = [];
  List<DeliveryModel> filteredDeliveries = [];
  bool _isLoading = false;
  DateTime selectedWeek = DateTime.now();

  void loadCourierTrips() async {
    setState(() {
      _isLoading = true;
    });
    try {
      String? userId = await UserSession.getUserId();
      allDeliveries = await DeliveriesAPI.getCourierDeliveries(
          courierId: userId.toString());
      filterDeliveriesByWeek();
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

  void changeWeek(int days) {
    setState(() {
      selectedWeek = selectedWeek.add(Duration(days: days));
      filterDeliveriesByWeek();
    });
  }

  void filterDeliveriesByWeek() {
    DateTime startOfWeek = startOfSelectedWeek();
    DateTime endOfWeek = startOfWeek.add(const Duration(days: 7));
    filteredDeliveries = allDeliveries.where((delivery) {
      return delivery.requestedDate.isAfter(startOfWeek) &&
          delivery.requestedDate.isBefore(endOfWeek);
    }).toList();
  }

  DateTime startOfSelectedWeek() {
    int dayOfWeek = selectedWeek.weekday;
    DateTime startOfWeek = selectedWeek.subtract(Duration(days: dayOfWeek - 1));
    return startOfWeek;
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
        actions: filteredDeliveries.isNotEmpty
            ? [
                IconButton(
                  icon: const Icon(Icons.info_outline),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          surfaceTintColor: Colors.white,
                          title: const Text("¿Cómo se calcula el cobro?"),
                          content: RichText(
                            text: TextSpan(
                              style: const TextStyle(
                                  color: Colors.black, fontSize: 16),
                              children: <TextSpan>[
                                const TextSpan(
                                  text: 'Se cobran ',
                                ),
                                const TextSpan(
                                  text: '\$8',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                const TextSpan(
                                  text: ' pesos por cada viaje realizado.',
                                ),
                                const TextSpan(
                                    text:
                                        ' Por lo que el total a pagar por los '),
                                TextSpan(
                                  text: '${filteredDeliveries.length}',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                                const TextSpan(
                                    text: ' viajes de esta semana es de '),
                                TextSpan(
                                  text:
                                      '\$${filteredDeliveries.length * 8} MXN.',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
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
                  : filteredDeliveries.isEmpty
                      ? buildEmptyListView()
                      : buildDeliveriesListView(),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: weekSelectorWidget(),
            ),
          ],
        ),
      ),
    );
  }

  Widget weekSelectorWidget() {
    DateTime startOfWeek = startOfSelectedWeek();
    DateTime endOfWeek = startOfWeek.add(const Duration(days: 6));

    String formattedStart =
        DateFormat('EEE dd MMM', 'es_MX').format(startOfWeek);
    String formattedEnd =
        DateFormat('EEE dd MMM, yyyy', 'es_MX').format(endOfWeek);
    String dateRange = '$formattedStart - $formattedEnd';

    bool isCurrentWeek = DateTime.now().difference(startOfWeek).inDays < 7;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Colors.grey[300]!, width: 1),
        ),
      ),
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(
                Icons.chevron_left), // Ícono más neutro para "anterior"
            onPressed: () => changeWeek(-7),
          ),
          Text(dateRange),
          IconButton(
            icon: const Icon(
                Icons.chevron_right), // Ícono más neutro para "siguiente"
            onPressed: isCurrentWeek ? null : () => changeWeek(7),
          ),
        ],
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
          'Sin viajes esta semana',
          style: TextStyle(
            color: Colors.black54,
          ),
        )),
      ],
    );
  }

  Widget buildDeliveriesListView() {
    int totalDeliveries = filteredDeliveries.length;
    int totalAmount = totalDeliveries * 8;

    return ListView.builder(
      itemCount: totalDeliveries > 0 ? totalDeliveries + 1 : totalDeliveries,
      itemBuilder: (context, index) {
        if (index == 0 && totalDeliveries > 0) {
          return Card(
            surfaceTintColor: Colors.white,
            margin: const EdgeInsets.all(8.0),
            child: ListTile(
              title: Text(
                "Total semanal a pagar",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18.0, color: Colors.grey[600]),
              ),
              subtitle: Text(
                "\$$totalAmount MXN",
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 16.0, fontWeight: FontWeight.bold),
              ),
            ),
          );
        }

        final deliveryIndex = index - 1;
        final delivery = filteredDeliveries[deliveryIndex];

        return DeliveryCard(
          deliveyId: delivery.id,
          status: delivery.status,
          date: delivery.requestedDate,
          destination: delivery.destination.title,
          origin: delivery.origin.title,
          price: delivery.price,
        );
      },
      padding: const EdgeInsets.only(bottom: 70.0),
    );
  }
}
