import 'package:flutter/material.dart';
import 'package:shopping_cart/main.dart';
import 'package:shopping_cart/screens/cart_screen.dart';
import 'package:shopping_cart/screens/login_screen.dart';
import 'package:shopping_cart/screens/users_screen.dart';
import 'package:shopping_cart/widgets/add_product_dialog.dart';
import 'package:shopping_cart/widgets/product_list.dart';

class ProductsScreen extends StatefulWidget {
  static const routeName = '/products-screen';
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  void _refreshProducts() {
    setState(() {});
  }

  void _logOut() {
    selectedUserService.logOut();
    Navigator.of(context).pushNamed(LoginScreen.routeName);
  }

  void _goToCartScreen() {
    Navigator.of(context).pushNamed(CartScreen.routeName);
  }

  void _goToUserScreen() {
    Navigator.of(context).pushNamed(UserScreen.routeName);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Product List'),
        actions: [
          IconButton(
            onPressed: _goToCartScreen,
            icon: const Icon(
              Icons.shopping_cart,
            ),
          ),
          IconButton(
            onPressed: _goToUserScreen,
            icon: const Icon(Icons.person),
          ),
          TextButton(
            onPressed: _logOut,
            child: const Text(
              'Log Out',
              style: TextStyle(
                color: Colors.black,
              ),
            ),
          ),
          const SizedBox(
            width: 16,
          ),
        ],
      ),
      floatingActionButton: AddProductDialog(
        onProductAdded: _refreshProducts,
      ),
      body: const ProductList(),
    );
  }
}
