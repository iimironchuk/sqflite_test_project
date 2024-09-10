import 'package:flutter/material.dart';
import 'package:shopping_cart/main.dart';
import 'package:shopping_cart/models/user.dart';
import 'package:shopping_cart/services/database_service.dart';

class UserList extends StatelessWidget {
  UserList({super.key});

  final DatabaseService _databaseService = DatabaseService();

  void _selectAnotherUser(User user) {
    selectedUserService.setUser(user.id);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _databaseService.getUsers(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No users found.'));
        } else {
          return Column(
            children: [
              const SizedBox(
                width: 16,
              ),
              const Text(
                'Users',
                style: TextStyle(fontSize: 24),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    var user = snapshot.data![index];
                    return ListTile(
                      title: Text(user.email),
                      onTap: () => _selectAnotherUser(user),
                    );
                  },
                ),
              ),
            ],
          );
        }
      },
    );
  }
}
