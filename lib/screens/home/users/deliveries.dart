import 'package:be_fast/api/deliveries.dart';
import 'package:be_fast/api/users.dart';
import 'package:be_fast/models/custom/custom.dart';
import 'package:be_fast/models/delivery.dart';
import 'package:be_fast/shared/widgets/delivery_card.dart';
import 'package:be_fast/shared/utils/show_snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class UserDeliveries extends StatefulWidget {
  final String userId, name;
  final Point originLocation;
  final bool isDisabled;

  const UserDeliveries(
      {super.key,
      required this.userId,
      required this.name,
      required this.originLocation,
      required this.isDisabled});

  @override
  State<UserDeliveries> createState() => _UserDeliveriesState();
}

class _UserDeliveriesState extends State<UserDeliveries> {
  List<DeliveryModel> _deliveries = [];
  bool isLoading = false;
  DateTime selectedWeek = DateTime.now();
  List<DeliveryModel> _filteredDeliveries = [];

  Future _handleGetUserDeliveries() async {
    setState(() => isLoading = true);
    try {
      _deliveries =
          await DeliveriesAPI.getUserDeliveries(userId: widget.userId);
      filterDeliveriesByWeek();
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _handleGetUserDeliveries();
  }

  void _launchGoogleMaps() async {
    if (widget.originLocation.coordinates.isEmpty) return;
    String googleMapsUrl =
        'https://www.google.com/maps/dir/?api=1&destination=${widget.originLocation.coordinates[1]},${widget.originLocation.coordinates[0]}&travelmode=driving';

    if (await canLaunchUrl(Uri.parse(googleMapsUrl))) {
      await launchUrl(Uri.parse(googleMapsUrl));
    }
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
                  case 'googleMaps':
                    _launchGoogleMaps();
                    break;
                  case 'enable':
                    _showEnableConfirmDialog();
                    break;
                  case 'disable':
                    _showDisableConfirmDialog();
                    break;
                  default:
                    break;
                }
              },
              itemBuilder: (BuildContext context) => [
                if (widget.originLocation.coordinates.isNotEmpty)
                  const PopupMenuItem(
                      value: 'googleMaps', child: Text('📍 Visitar')),
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
              onRefresh: _handleGetUserDeliveries,
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _filteredDeliveries.isEmpty
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
          surfaceTintColor: Colors.white,
          title: const Text('Confirmación'),
          content: Text(
              '¿Estás seguro de que deseas deshabilitar a ${widget.name}?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Deshabilitar'),
              onPressed: () {
                _disableUser(true);
                Navigator.of(context).pop();
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
          surfaceTintColor: Colors.white,
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
                _disableUser(false);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _disableUser(bool isDisabled) async {
    try {
      await UsersAPI.disableUser(userId: widget.userId, isDisabled: isDisabled);
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
        showSnackBar(context, "Error deshabilitando el usuario");
      }
    }
  }

  void filterDeliveriesByWeek() {
    DateTime startOfWeek = startOfSelectedWeek();
    DateTime endOfWeek = startOfWeek.add(const Duration(days: 7));
    _filteredDeliveries = _deliveries.where((delivery) {
      return delivery.requestedDate
              .isAfter(startOfWeek.subtract(const Duration(days: 1))) &&
          delivery.requestedDate.isBefore(endOfWeek);
    }).toList();
  }

  DateTime startOfSelectedWeek() {
    int dayOfWeek = selectedWeek.weekday;
    DateTime startOfWeek = selectedWeek.subtract(Duration(days: dayOfWeek - 1));
    return startOfWeek;
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
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: () => changeWeek(-7),
          ),
          Text(dateRange),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: isCurrentWeek ? null : () => changeWeek(7),
          ),
        ],
      ),
    );
  }

  void changeWeek(int days) {
    setState(() {
      selectedWeek = selectedWeek.add(Duration(days: days));
      filterDeliveriesByWeek();
    });
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
    int totalDeliveries = _filteredDeliveries.length;
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
        final delivery = _filteredDeliveries[deliveryIndex];

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
