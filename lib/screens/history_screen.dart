import 'package:flutter/material.dart';
import 'package:shopping_cart/main.dart';
import 'package:shopping_cart/services/database_service.dart';

class HistoryScreen extends StatefulWidget {
  static const routeName = '/history-screen';

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final DatabaseService _databaseService = DatabaseService();

  void _deleteOrderFromHistory(Map<String, dynamic> order) {
    _databaseService.deleteOrderFromHistory(
      order['id'],
    );
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    int? userId = selectedUserService.getUser();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Order History'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _databaseService.getOrderHistory(userId!),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text('No order history found.'),
            );
          } else {
            final history = snapshot.data!;

            return ListView.builder(
              itemCount: history.length,
              itemBuilder: (context, index) {
                var order = history[index];
                return ListTile(
                  title: Text(
                    'Order #${order['id']} - ${order['date']}',
                  ),
                  subtitle: Text(
                    'Total Price: \$${order['totalPrice']}',
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'User Email: ${order['email']}',
                      ),
                      IconButton(
                        onPressed: () => _deleteOrderFromHistory(order),
                        icon: const Icon(
                          Icons.delete,
                        ),
                      )
                    ],
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
