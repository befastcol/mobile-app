import 'package:be_fast/api/users.dart';
import 'package:be_fast/models/user.dart';
import 'package:be_fast/screens/home/couriers/courier_deliveries_screen.dart';
import 'package:flutter/material.dart';

class Couriers extends StatefulWidget {
  const Couriers({super.key});

  @override
  State<Couriers> createState() => _CouriersState();
}

class _CouriersState extends State<Couriers> {
  List<UserModel> _couriers = [];
  bool _isLoading = false;

  void _loadAcceptedCouriers() async {
    try {
      setState(() => _isLoading = true);
      _couriers = await UsersApi().getAcceptedCouriers();
    } catch (error) {
      debugPrint('_loadAcceptedCouriers: $error');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
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
      ),
      body: RefreshIndicator(
        onRefresh: _refreshList,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _couriers.isEmpty
                ? ListView(
                    children: [
                      const SizedBox(height: 180),
                      Container(
                          margin: const EdgeInsets.symmetric(horizontal: 50),
                          child: Image.asset('assets/empty.png')),
                      const Center(
                          child: Text(
                        'No hay repartidores todavía',
                        style: TextStyle(
                          color: Colors.black54,
                        ),
                      )),
                    ],
                  )
                : ListView.builder(
                    itemCount: _couriers.length,
                    itemBuilder: (context, index) {
                      final courier = _couriers[index];
                      return ListTile(
                        leading: const Icon(Icons.person),
                        trailing: const Icon(Icons.navigate_next),
                        title: Text(courier.name),
                        subtitle: Text(courier.phone),
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => CourierDeliveries(
                                        name: courier.name,
                                        courierId: courier.id,
                                      )));
                        },
                      );
                    },
                  ),
      ),
    );
  }
}
