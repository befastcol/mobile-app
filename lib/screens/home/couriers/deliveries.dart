import 'package:be_fast/api/deliveries.dart';
import 'package:be_fast/api/users.dart';
import 'package:be_fast/models/delivery.dart';
import 'package:be_fast/shared/widgets/delivery_card.dart';
import 'package:be_fast/shared/utils/show_snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class CourierDeliveries extends StatefulWidget {
  final String courierId, name, phone;
  final bool isDisabled;
  final int credits;

  const CourierDeliveries(
      {super.key,
      required this.courierId,
      required this.name,
      required this.phone,
      required this.credits,
      required this.isDisabled});

  @override
  State<CourierDeliveries> createState() => _CourierDeliveriesState();
}

class _CourierDeliveriesState extends State<CourierDeliveries> {
  List<DeliveryModel> _deliveries = [];
  bool _isLoading = false;
  final TextEditingController _creditsController = TextEditingController();

  @override
  void initState() {
    _loadCourierDeliveries();
    super.initState();
  }

  Future _loadCourierDeliveries() async {
    try {
      setState(() => _isLoading = true);
      _deliveries =
          await DeliveriesAPI.getCourierDeliveries(courierId: widget.courierId);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );

    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      if (mounted) {
        showSnackBar(
            context, "Ocurrió un error al intentar marcar a este número.");
      }
    }
  }

  void _showAddCreditsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          surfaceTintColor: Colors.white,
          backgroundColor: Colors.white,
          title: const Column(
            children: [
              Text(
                'Agregar créditos',
                textAlign: TextAlign.center,
              ),
              SizedBox(
                height: 8,
              ),
              Text(
                "La cantidad de créditos será la cantidad existente más la nueva cantidad.",
                style: TextStyle(color: Colors.grey, fontSize: 14),
                textAlign: TextAlign.center,
              ),
              SizedBox(
                height: 20,
              )
            ],
          ),
          content: TextField(
            controller: _creditsController,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            decoration: const InputDecoration(
              hintText: 'Créditos',
              border: OutlineInputBorder(),
            ),
          ),
          actions: <Widget>[
            Center(
              child: ElevatedButton(
                onPressed: () async {
                  Navigator.pop(context);
                  _addCredits();
                },
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  backgroundColor: Colors.blue,
                ),
                child: const Text(
                  'Agregar',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _addCredits() async {
    showLoadingDialog(context); // Muestra un diálogo de carga

    try {
      await UsersAPI.updateCourierCredits(
        courierId: widget.courierId,
        credits: int.parse(_creditsController.text),
      );
      if (mounted) {
        showSnackBar(context, 'Créditos agregados correctamente');
      }
    } catch (e) {
      if (mounted) {
        showSnackBar(context, 'Error guardando los créditos');
      }
    } finally {
      if (mounted) {
        Navigator.of(context).pop();
        Navigator.of(context).pop();
      }
    }
  }

  void showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const AlertDialog(
          surfaceTintColor: Colors.white,
          backgroundColor: Colors.white,
          content: SizedBox(
              width: 100,
              height: 100,
              child: Center(child: CircularProgressIndicator())),
        );
      },
    );
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
                  case 'credits':
                    _showAddCreditsDialog();
                    break;
                  default:
                    break;
                }
              },
              itemBuilder: (BuildContext context) => [
                const PopupMenuItem(
                    value: 'credits', child: Text('➕ Agregar créditos')),
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
              onRefresh: () async => _loadCourierDeliveries(),
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
                _disableCourier(true);
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

  Widget buildEmptyListView() {
    return ListView(
      children: [
        const SizedBox(height: 180),
        Container(
            margin: const EdgeInsets.symmetric(horizontal: 50),
            child: Image.asset('assets/images/empty.png')),
        const Center(
            child: Text(
          'No hay pedidos realizados',
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
                "${widget.credits}",
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
      padding: const EdgeInsets.only(bottom: 70.0),
    );
  }
}
