import 'package:be_fast/api/users.dart';
import 'package:be_fast/models/user.dart';
import 'package:be_fast/screens/home/couriers/deliveries.dart';
import 'package:flutter/material.dart';

class Couriers extends StatefulWidget {
  const Couriers({super.key});

  @override
  State<Couriers> createState() => _CouriersState();
}

class _CouriersState extends State<Couriers> {
  List<UserModel> _couriers = [];
  List<UserModel> _filteredCouriers = [];
  bool _isLoading = false;
  String _currentFilter = 'all';

  void _loadAcceptedCouriers() async {
    try {
      setState(() => _isLoading = true);
      _couriers = await UsersAPI().getAcceptedCouriers();
      _applyFilter();
    } catch (error) {
      debugPrint('_loadAcceptedCouriers: $error');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _applyFilter() {
    if (_currentFilter == 'all') {
      _filteredCouriers = List.from(_couriers);
    } else if (_currentFilter == 'disabled') {
      _filteredCouriers =
          _couriers.where((courier) => courier.isDisabled).toList();
    } else {
      _filteredCouriers = _couriers
          .where((courier) =>
              !courier.isDisabled && courier.status == _currentFilter)
          .toList();
    }

    setState(() {});
  }

  void _filterCouriers(String status) {
    _currentFilter = status;
    _applyFilter();
  }

  Future<void> _refreshList() async {
    _loadAcceptedCouriers();
  }

  @override
  void initState() {
    super.initState();
    _loadAcceptedCouriers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.amber,
        title: const Text("Repartidores"),
        actions: [
          PopupMenuButton(
            icon: const Icon(Icons.filter_alt),
            color: Colors.white,
            surfaceTintColor: Colors.white,
            onSelected: (String value) {
              _filterCouriers(value);
            },
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem(value: 'all', child: Text('Todos')),
              const PopupMenuItem(
                  value: 'available', child: Text('Disponibles')),
              const PopupMenuItem(value: 'inactive', child: Text('Inactivos')),
              const PopupMenuItem(value: 'busy', child: Text('Ocupados')),
              const PopupMenuItem(
                  value: 'disabled', child: Text('Desactivados')),
            ],
          )
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshList,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _filteredCouriers.isEmpty
                ? ListView(
                    children: [
                      const SizedBox(height: 180),
                      Container(
                          margin: const EdgeInsets.symmetric(horizontal: 50),
                          child: Image.asset('assets/images/empty.png')),
                      const Center(
                          child: Text(
                        'Lista de repartidores vacía',
                        style: TextStyle(
                          color: Colors.black54,
                        ),
                      )),
                    ],
                  )
                : ListView.builder(
                    itemCount: _filteredCouriers.length,
                    itemBuilder: (context, index) {
                      final courier = _filteredCouriers[index];
                      return ListTile(
                        leading: Icon(
                          Icons.person,
                          color: courier.isDisabled
                              ? Colors.red
                              : courier.status == "available"
                                  ? Colors.teal
                                  : courier.status == "busy"
                                      ? Colors.orange
                                      : Colors.blueGrey,
                        ),
                        trailing: const Icon(Icons.navigate_next),
                        title: Text(courier.name),
                        subtitle: Text(courier.phone),
                        onTap: () {
                          Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => CourierDeliveries(
                                            isDisabled: courier.isDisabled,
                                            name: courier.name,
                                            courierId: courier.id,
                                          )))
                              .then((value) => _loadAcceptedCouriers());
                        },
                      );
                    },
                  ),
      ),
    );
  }
}
