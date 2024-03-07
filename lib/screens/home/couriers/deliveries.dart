import 'package:be_fast/api/deliveries.dart';
import 'package:be_fast/api/users.dart';
import 'package:be_fast/models/delivery.dart';
import 'package:be_fast/shared/widgets/delivery_card.dart';
import 'package:be_fast/shared/utils/show_snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class CourierDeliveries extends StatefulWidget {
  final String courierId, name, phone;
  final bool isDisabled;

  const CourierDeliveries(
      {super.key,
      required this.courierId,
      required this.name,
      required this.phone,
      required this.isDisabled});

  @override
  State<CourierDeliveries> createState() => _CourierDeliveriesState();
}

class _CourierDeliveriesState extends State<CourierDeliveries> {
  List<DeliveryModel> _allDeliveries = [];
  List<DeliveryModel> filteredDeliveries = [];
  bool _isLoading = false;
  DateTime selectedWeek = DateTime.now();

  void loadCourierDeliveries() async {
    try {
      setState(() => _isLoading = true);
      _allDeliveries =
          await DeliveriesAPI.getCourierDeliveries(courierId: widget.courierId);
      filterDeliveriesByWeek();
    } catch (error) {
      debugPrint('loadCourierDeliveries: $error ${widget.courierId}');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void filterDeliveriesByWeek() {
    DateTime startOfWeek = startOfSelectedWeek();
    DateTime endOfWeek = startOfWeek.add(const Duration(days: 7));
    filteredDeliveries = _allDeliveries.where((delivery) {
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

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      throw 'Could not launch $launchUri';
    }
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
                  case 'call':
                    _makePhoneCall(widget.phone);
                    break;
                  case 'disable':
                    _showDisableConfirmDialog();
                    break;
                  case 'enable':
                    _showEnableConfirmDialog();
                    break;
                  default:
                    break;
                }
              },
              itemBuilder: (BuildContext context) => [
                const PopupMenuItem(value: 'call', child: Text('📞 Llamar')),
                widget.isDisabled
                    ? const PopupMenuItem(
                        value: 'enable',
                        child: Text(
                          '✅ Habilitar',
                          style: TextStyle(color: Colors.teal),
                        ))
                    : const PopupMenuItem(
                        value: 'disable',
                        child: Text(
                          '🔒 Deshabilitar',
                          style: TextStyle(color: Colors.red),
                        ))
              ],
            )
          ]),
      body: SafeArea(
        child: Stack(
          children: [
            RefreshIndicator(
              onRefresh: () async => loadCourierDeliveries(),
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

  void _showDisableConfirmDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmación'),
          content: Text(
              '¿Estás seguro de que deseas deshabilitar a ${widget.name}?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop(); // Cierra el diálogo
              },
            ),
            TextButton(
              child: const Text('Deshabilitar'),
              onPressed: () {
                _disableCourier(true);
                Navigator.of(context).pop(); // Cierra el diálogo
              },
            ),
          ],
        );
      },
    );
  }

  void _showEnableConfirmDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmación'),
          content:
              Text('¿Estás seguro de que deseas habilitar a ${widget.name}?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Habilitar'),
              onPressed: () {
                _disableCourier(false);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _disableCourier(bool isDisabled) async {
    try {
      await UsersAPI.disableUser(
          userId: widget.courierId, isDisabled: isDisabled);
      if (mounted) {
        Navigator.pop(context);
        if (isDisabled) {
          showSnackBar(context, "Usuario deshabilitado correctamente");
        } else {
          showSnackBar(context, "Usuario habilitado correctamente");
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        showSnackBar(context, "Error deshabilitando el usuario");
      }
    }
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
          'Sin pedidos esta semana',
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
