import 'package:be_fast/api/deliveries.dart';
import 'package:be_fast/api/users.dart';
import 'package:be_fast/models/delivery.dart';
import 'package:be_fast/shared/widgets/delivery_card.dart';
import 'package:be_fast/shared/utils/show_snack_bar.dart';
import 'package:flutter/material.dart';

class UserDeliveries extends StatefulWidget {
  final String userId, name;
  final bool isDisabled;

  const UserDeliveries(
      {super.key,
      required this.userId,
      required this.name,
      required this.isDisabled});

  @override
  State<UserDeliveries> createState() => _UserDeliveriesState();
}

class _UserDeliveriesState extends State<UserDeliveries> {
  List<DeliveryModel> _deliveries = [];
  bool _isLoading = false;

  Future _handleGetUserDeliveries() async {
    setState(() => _isLoading = true);
    try {
      _deliveries =
          await DeliveriesAPI.getUserDeliveries(userId: widget.userId);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _handleGetUserDeliveries();
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
      itemCount: _deliveries.length,
      itemBuilder: (context, index) {
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
