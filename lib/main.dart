import 'package:flutter/material.dart';
import 'package:shopping_cart/screens/cart_screen.dart';
import 'package:shopping_cart/screens/history_screen.dart';
import 'package:shopping_cart/screens/login_screen.dart';
import 'package:shopping_cart/screens/products_screen.dart';
import 'package:shopping_cart/screens/singup_screen.dart';
import 'package:shopping_cart/screens/users_screen.dart';
import 'package:shopping_cart/services/database_service.dart';
import 'package:shopping_cart/services/selected_user_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DatabaseService.instance.initDatabase();
  runApp(const MainApp());
}

var selectedUserService = AppNotifier();

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Shopping Cart',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: LoginScreen(),
      routes: {
        LoginScreen.routeName: (ctx) => LoginScreen(),
        SignUpScreen.routeName: (ctx) => const SignUpScreen(),
        ProductsScreen.routeName: (ctx) => const ProductsScreen(),
        UserScreen.routeName: (ctx) => UserScreen(),
        CartScreen.routeName: (ctx) => CartScreen(),
        HistoryScreen.routeName: (ctx) => HistoryScreen(),
      }
    );
  }
}
