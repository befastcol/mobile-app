import 'package:be_fast/api/user.dart';
import 'package:be_fast/models/user.dart';
import 'package:be_fast/screens/home/couriers/courier_deliveries_screen.dart';
import 'package:flutter/material.dart';

class CourierRequests extends StatefulWidget {
  const CourierRequests({super.key});

  @override
  State<CourierRequests> createState() => _CourierRequestsState();
}

class _CourierRequestsState extends State<CourierRequests> {
  List<UserModel> pendingCouriers = [];
  bool isLoading = false;

  Future _loadPendingCouriers() async {
    try {
      setState(() => isLoading = true);
      pendingCouriers = await getPendingCouriers();
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  Future _refreshList() async {
    _loadPendingCouriers();
  }

  @override
  void initState() {
    super.initState();
    _loadPendingCouriers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          surfaceTintColor: Colors.transparent,
          backgroundColor: Colors.amber,
          title: const Text("Solicitudes"),
        ),
        body: RefreshIndicator(
          onRefresh: _refreshList,
          child: isLoading
              ? const Center(child: CircularProgressIndicator())
              : pendingCouriers.isEmpty
                  ? ListView(
                      children: [
                        const SizedBox(height: 180),
                        Container(
                            margin: const EdgeInsets.symmetric(horizontal: 50),
                            child: Image.asset('assets/empty.png')),
                        const Center(
                            child: Text(
                          'No hay solicitudes pendientes',
                          style: TextStyle(
                            color: Colors.black54,
                          ),
                        )),
                      ],
                    )
                  : ListView.builder(
                      itemCount: pendingCouriers.length,
                      itemBuilder: (context, index) {
                        final courier = pendingCouriers[index];
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
        ));
  }
}
