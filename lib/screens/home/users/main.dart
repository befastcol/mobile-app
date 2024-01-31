import 'package:be_fast/api/user.dart';
import 'package:be_fast/models/user.dart';
import 'package:be_fast/screens/home/users/user_deliveries_screen.dart';
import 'package:flutter/material.dart';

class Users extends StatefulWidget {
  const Users({super.key});

  @override
  State<Users> createState() => _UsersState();
}

class _UsersState extends State<Users> {
  List<UserModel> users = [];
  bool isLoading = false;

  void loadAllUsers() async {
    setState(() {
      isLoading = true;
    });
    try {
      users = await getAllUsers();
    } catch (error) {
      debugPrint('Error: $error');
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> _refreshList() async {
    loadAllUsers();
  }

  @override
  void initState() {
    super.initState();
    loadAllUsers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        surfaceTintColor: Colors.transparent,
        backgroundColor: Colors.amber,
        title: const Text("Usuarios"),
      ),
      body: RefreshIndicator(
        onRefresh: _refreshList,
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : ListView.builder(
                itemCount: users.length,
                itemBuilder: (context, index) {
                  final user = users[index];
                  return ListTile(
                    leading: const Icon(Icons.person),
                    trailing: const Icon(Icons.navigate_next),
                    title: Text(user.name),
                    subtitle: Text(user.phone),
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => UserDeliveries(
                                    name: user.name,
                                    userId: user.id,
                                  )));
                    },
                  );
                },
              ),
      ),
    );
  }
}
