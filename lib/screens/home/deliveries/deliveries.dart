import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:be_fast/api/deliveries.dart';
import 'package:be_fast/models/delivery.dart';
import 'package:be_fast/screens/home/deliveries/delivery_card.dart';
import 'package:be_fast/utils/user_session.dart';

class Deliveries extends StatefulWidget {
  const Deliveries({super.key});

  @override
  State<Deliveries> createState() => _DeliveriesState();
}

class _DeliveriesState extends State<Deliveries> {
  List<DeliveryModel> allDeliveries = [];
  List<DeliveryModel> filteredDeliveries = [];
  bool isLoading = false;
  DateTime selectedWeek = DateTime.now();

  void loadUserDeliveries() async {
    setState(() => isLoading = true);
    try {
      String? userId = await UserSession.getUserId();
      allDeliveries =
          await DeliveriesAPI().getUserDeliveries(userId: userId.toString());
      filterDeliveriesByWeek();
    } catch (error) {
      debugPrint('loadUserDeliveries: $error');
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
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

  void changeWeek(int days) {
    setState(() {
      selectedWeek = selectedWeek.add(Duration(days: days));
      filterDeliveriesByWeek();
    });
  }

  @override
  void initState() {
    super.initState();
    loadUserDeliveries();
  }

  @override
  Widget build(BuildContext context) {
    int totalDeliveries = filteredDeliveries.length;
    int totalAmount = totalDeliveries * 8; // $8 por entrega
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        surfaceTintColor: Colors.transparent,
        backgroundColor: Colors.teal[200],
        title: const Text("Mis pedidos"),
        actions: filteredDeliveries.isNotEmpty
            ? [
                IconButton(
                  icon: const Icon(Icons.info_outline),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text("Detalle del pago"),
                          content: RichText(
                            text: TextSpan(
                              style: const TextStyle(
                                  color: Colors.black, fontSize: 16),
                              children: <TextSpan>[
                                const TextSpan(
                                    text:
                                        'El total a pagar por los pedidos de esta semana es de '),
                                TextSpan(
                                  text: '\$$totalAmount MXN.',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                                const TextSpan(
                                  text: 'Se cobran ',
                                ),
                                const TextSpan(
                                  text: '\$8',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                const TextSpan(
                                  text: ' pesos por cada pedido realizado.',
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
              onRefresh: () async => loadUserDeliveries(),
              child: isLoading
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
            child: Image.asset('assets/empty.png')),
        const Center(
            child: Text(
          'Sin pedidos esta semana',
          style: TextStyle(
            color: Colors.black54,
          ),
        )),
      ],
    );
  }

  Widget buildDeliveriesListView() {
    return ListView.builder(
      itemCount: filteredDeliveries.length,
      itemBuilder: (context, index) {
        final delivery = filteredDeliveries[index];
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
