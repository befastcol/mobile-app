import 'package:be_fast/api/user.dart';
import 'package:be_fast/models/user.dart';
import 'package:be_fast/screens/home/couriers/courier_deliveries_screen.dart';
import 'package:flutter/material.dart';

class Couriers extends StatefulWidget {
  const Couriers({super.key});

  @override
  State<Couriers> createState() => _CouriersState();
}

class _CouriersState extends State<Couriers> {
  List<UserModel> couriers = [];
  bool isLoading = false;

  void loadAcceptedCouriers() async {
    setState(() {
      isLoading = true;
    });
    try {
      couriers = await getAcceptedCouriers();
    } catch (error) {
      debugPrint('loadAcceptedCouriers: $error');
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> _refreshList() async {
    loadAcceptedCouriers();
  }

  @override
  void initState() {
    super.initState();
    loadAcceptedCouriers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        surfaceTintColor: Colors.transparent,
        backgroundColor: Colors.amber,
        title: const Text("Repartidores"),
      ),
      body: RefreshIndicator(
        onRefresh: _refreshList,
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : ListView.builder(
                itemCount: couriers.length,
                itemBuilder: (context, index) {
                  final courier = couriers[index];
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
                                    userId: courier.id,
                                  )));
                    },
                  );
                },
              ),
      ),
    );
  }
}
