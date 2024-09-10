import 'package:flutter/material.dart';
import 'package:shopping_cart/main.dart';
import 'package:shopping_cart/models/product.dart';
import 'package:shopping_cart/services/database_service.dart';

class ProductList extends StatefulWidget {
  const ProductList({super.key});

  @override
  State<ProductList> createState() => _ProductListState();
}

class _ProductListState extends State<ProductList> {
  final DatabaseService _databaseService = DatabaseService.instance;

  String? _name;
  String? _description;
  String? _price;

  void _editProduct(Product product) {
    setState(() {
      _name = product.name;
      _description = product.description;
      _price = product.price.toString();
    });

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Edit product:'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  _name = value;
                });
              },
              controller: TextEditingController(text: product.name),
            ),
            TextField(
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  _description = value;
                });
              },
              controller: TextEditingController(text: product.description),
            ),
            TextField(
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  _price = value;
                });
              },
              controller: TextEditingController(text: product.price.toString()),
            ),
            MaterialButton(
              onPressed: () {
                if (_name == null || _description == null || _price == null) {
                  return;
                }
                _databaseService.updateProduct(
                  product.id,
                  _name!,
                  _description!,
                  double.tryParse(_price!)!,
                );
                setState(() {
                  _name = null;
                  _description = null;
                  _price = null;
                });
                Navigator.pop(context);
              },
              color: Colors.red[200],
              child: const Text(
                'Save changes',
                style: TextStyle(color: Colors.white),
              ),
            )
          ],
        ),
      ),
    );
  }

  void _deleteProduct(Product product) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Do you want to delete this product?'),
        content: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            MaterialButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('No'),
            ),
            MaterialButton(
              onPressed: () {
                _databaseService.deleteProduct(product.id);
                setState(() {});
                Navigator.pop(context);
              },
              child: const Text('Yes'),
            ),
          ],
        ),
      ),
    );
  }

  void _addProductToCart(Product product) async {
    int? userId = selectedUserService.getUser();
    await _databaseService.addProductToCart(
      product.id,
      userId!,
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _databaseService.getProducts(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else if (snapshot.hasError) {
          return Center(
            child: Text('Error: ${snapshot.error}'),
          );
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(
            child: Text('No products available.'),
          );
        } else {
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              var product = snapshot.data![index];
              return ListTile(
                leading: Image.asset(
                  'assets/images/${product.image}',
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                  errorBuilder: (
                    context,
                    error,
                    stackTrace,
                  ) {
                    return const Icon(
                      Icons.broken_image,
                    );
                  },
                ),
                title: Text(
                  product.name,
                ),
                subtitle: Text(
                  product.description,
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '\$${product.price}',
                    ),
                    IconButton(
                      onPressed: () => _addProductToCart(product),
                      icon: const Icon(
                        Icons.shopping_cart,
                      ),
                    ),
                    IconButton(
                      onPressed: () => _editProduct(
                        product,
                      ),
                      icon: const Icon(
                        Icons.edit,
                      ),
                    ),
                    IconButton(
                      onPressed: () => _deleteProduct(
                        product,
                      ),
                      icon: const Icon(
                        Icons.delete,
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        }
      },
    );
  }
}
