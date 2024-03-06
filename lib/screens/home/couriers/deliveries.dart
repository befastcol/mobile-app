import 'package:be_fast/api/deliveries.dart';
import 'package:be_fast/api/users.dart';
import 'package:be_fast/models/delivery.dart';
import 'package:be_fast/screens/home/deliveries/delivery_card.dart';
import 'package:be_fast/utils/show_snack_bar.dart';
import 'package:flutter/material.dart';

class CourierDeliveries extends StatefulWidget {
  final String courierId, name;
  final bool isDisabled;

  const CourierDeliveries(
      {super.key,
      required this.courierId,
      required this.name,
      required this.isDisabled});

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
                  case 'call':
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
                          child: Image.asset('assets/images/empty.png')),
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
}
