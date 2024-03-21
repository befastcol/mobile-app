import 'package:be_fast/api/users.dart';
import 'package:be_fast/models/user.dart';
import 'package:be_fast/screens/home/requests/request_details.dart';
import 'package:flutter/material.dart';

class Requests extends StatefulWidget {
  const Requests({super.key});

  @override
  State<Requests> createState() => _RequestsState();
}

class _RequestsState extends State<Requests> {
  List<UserModel> _pendingCouriers = [];
  bool _isLoading = false;

  Future _loadPendingCouriers() async {
    try {
      setState(() => _isLoading = true);
      _pendingCouriers = await UsersAPI.getPendingCouriers();
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
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
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _pendingCouriers.isEmpty
                  ? ListView(
                      children: [
                        const SizedBox(height: 180),
                        Container(
                            margin: const EdgeInsets.symmetric(horizontal: 50),
                            child: Image.asset('assets/images/empty.png')),
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
                      itemCount: _pendingCouriers.length,
                      itemBuilder: (context, index) {
                        final courier = _pendingCouriers[index];
                        return ListTile(
                          leading: const Icon(Icons.person),
                          trailing: const Icon(Icons.navigate_next),
                          title: Text(courier.name),
                          subtitle: Text(courier.phone),
                          onTap: () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => RequestDetails(
                                  name: courier.name,
                                  courierId: courier.id,
                                  documents: courier.documents,
                                ),
                              ),
                            );

                            if (result == true) {
                              _loadPendingCouriers();
                            }
                          },
                        );
                      },
                    ),
        ));
  }
}
