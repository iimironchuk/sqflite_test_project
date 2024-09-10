import 'package:flutter/material.dart';
import 'package:shopping_cart/main.dart';
import 'package:shopping_cart/screens/history_screen.dart';
import 'package:shopping_cart/services/database_service.dart';

class CartScreen extends StatefulWidget {
  static const routeName = '/cart-screen';
  CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final DatabaseService _databaseService = DatabaseService();
  bool orderPlaced = false;
  double totalPrice = 0.0;

  @override
  Widget build(BuildContext context) {
    int? userId = selectedUserService.getUser();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Cart'),
      ),
      body: orderPlaced
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Order placed successfully!'),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pushNamed(HistoryScreen.routeName);
                    },
                    child: const Text('Show History'),
                  ),
                ],
              ),
            )
          : FutureBuilder(
              future: _databaseService.getCart(userId!),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Text('Your cart is empty.'),
                  );
                } else {
                  final cartItems = snapshot.data!;

                  return Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Expanded(
                        child: ListView.builder(
                          itemCount: cartItems.length,
                          itemBuilder: (context, index) {
                            var cartItem = cartItems[index];
                            return FutureBuilder(
                              future: _databaseService
                                  .getProductNameById(cartItem.productId),
                              builder: (context, productSnapshot) {
                                if (productSnapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const ListTile(
                                    title: CircularProgressIndicator(),
                                  );
                                } else if (productSnapshot.hasError) {
                                  return ListTile(
                                    title: Text(
                                        'Error loading product: ${productSnapshot.error}'),
                                  );
                                } else if (!productSnapshot.hasData) {
                                  return const ListTile(
                                    title: Text('Product not found'),
                                  );
                                } else {
                                  double price = productSnapshot.data!['price'];

                                  totalPrice += price * cartItem.quantity;
                                  return ListTile(
                                    title: Text(productSnapshot.data!['name']),
                                    subtitle:
                                        Text('Quantity: ${cartItem.quantity}'),
                                    trailing: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            '\$${productSnapshot.data!['price'] * cartItem.quantity}',
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.delete),
                                            onPressed: () {
                                              _databaseService
                                                  .deleteProductFromCart(
                                                      cartItem.id!);
                                              setState(() {});
                                            },
                                          ),
                                        ]),
                                  );
                                }
                              },
                            );
                          },
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          await _databaseService.addOrderToHistory(
                              userId, cartItems, totalPrice);
                          await _databaseService.clearCart(userId);
                          setState(() {
                            orderPlaced = true;
                          });
                        },
                        child: const Text('Make an order!'),
                      ),
                    ],
                  );
                }
              },
            ),
    );
  }
}