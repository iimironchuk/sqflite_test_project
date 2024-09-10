import 'package:flutter/material.dart';
import 'package:shopping_cart/services/database_service.dart';

class AddProductDialog extends StatefulWidget {
  final VoidCallback onProductAdded;
  const AddProductDialog({required this.onProductAdded, super.key});

  @override
  State<AddProductDialog> createState() => _AddProductDialogState();
}

class _AddProductDialogState extends State<AddProductDialog> {
  final DatabaseService _databaseService = DatabaseService.instance;

  String? _name;
  String? _description;
  String? _price;
  String? _image;

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Add product'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  decoration: const InputDecoration(
                      border: OutlineInputBorder(), hintText: 'Enter name'),
                  onChanged: (value) {
                    setState(() {
                      _name = value;
                    });
                  },
                ),
                TextField(
                  decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Enter description'),
                  onChanged: (value) {
                    setState(() {
                      _description = value;
                    });
                  },
                ),
                TextField(
                  decoration: const InputDecoration(
                      border: OutlineInputBorder(), hintText: 'Enter price'),
                  onChanged: (value) {
                    setState(() {
                      _price = value;
                    });
                  },
                ),
                TextField(
                  decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Enter image name'),
                  onChanged: (value) {
                    setState(() {
                      _image = value;
                    });
                  },
                ),
                MaterialButton(
                  onPressed: () {
                    if (_name == null ||
                        _description == null ||
                        _price == null ||
                        _image == null) {
                      return;
                    }
                    _databaseService.addProduct(
                        _name!, _description!, _price!, _image!);
                    setState(() {
                      _name = null;
                      _description = null;
                      _price = null;
                    });

                    widget.onProductAdded();

                    Navigator.pop(context);
                    setState(() {});
                  },
                  color: Colors.red[200],
                  child: const Text(
                    'Add',
                    style: TextStyle(color: Colors.white),
                  ),
                )
              ],
            ),
          ),
        );
      },
      child: const Icon(Icons.add),
    );
  }
}
  