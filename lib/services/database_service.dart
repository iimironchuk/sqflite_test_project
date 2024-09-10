import 'package:intl/intl.dart';
import 'package:path/path.dart';
import 'package:shopping_cart/models/product.dart';
import 'package:shopping_cart/models/shopping_cart.dart';
import 'package:shopping_cart/models/user.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseService {
  Database? _db;
  static final DatabaseService instance = DatabaseService._constructor();

  factory DatabaseService() {
    return instance;
  }

  final String _productsTableName = 'products';
  final String _shoppingCartTableName = 'shopping_cart';
  final String _usersTableName = 'users';
  final String _historyTableName = 'history';

  DatabaseService._constructor();

  Future<Database> initDatabase() async {
    if (_db != null) return _db!;
    _db = await createDatabase();
    return _db!;
  }

  Future<Database> createDatabase() async {
    final databaseDirPath = await getDatabasesPath();
    final databasePath = join(databaseDirPath, "my_db.db");

    return await openDatabase(
      databasePath,
      version: 10,
      onCreate: (db, version) async {
        await db.execute('''
        CREATE TABLE $_productsTableName (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL,
          description TEXT NOT NULL,
          price REAL NOT NULL
        )
        ''');

        await db.execute('''
        CREATE TABLE $_shoppingCartTableName (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          productId INTEGER NOT NULL,
          quantity INTEGER NOT NULL,
          FOREIGN KEY(productId) REFERENCES $_productsTableName(id)
        )
        ''');

        await db.execute('''
        CREATE TABLE $_usersTableName (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          email TEXT NOT NULL UNIQUE,
          password TEXT NOT NULL
        )
        ''');

        await db.execute('''
        CREATE TABLE $_historyTableName (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          userId INTEGER NOT NULL,
          productId INTEGER NOT NULL,
          date TEXT NOT NULL,
          totalCount INTEGER NOT NULL,
          totalPrice INTEGER NOT NULL
          FOREIGN KEY(userId) REFERENCES $_usersTableName(id),
          FOREIGN KEY(productId) REFERENCES $_productsTableName(id)
        )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
      if (oldVersion < 10) {
        await db.execute('ALTER TABLE $_productsTableName ADD COLUMN photo TEXT');
      }
      }
    );
  }

  Future<void> addProduct(String name, String description, String price, String image,) async {
    await _db!.insert(
      _productsTableName,
      {
        'name': name,
        'description': description,
        'price': price,
        'photo': image,
      },
    );
  }

  Future<List<Product>> getProducts() async {
    final data = await _db?.query(_productsTableName);
    if (data == null) return [];
    List<Product> products = data
    .map((product) => Product(
        id: product['id'] as int,
        name: product['name'] as String,
        description: product['description'] as String,
        price: product['price'] as double,
        image: product['photo'] != null ? product['photo'] as String : 'default_image.jpg'
    ))
    .toList();

    return products;
  }

  void updateProduct(
      int id, String name, String description, double price) async {
    await _db?.update(
      _productsTableName,
      {
        'name': name,
        'description': description,
        'price': price,
      },
      where: 'id = ?',
      whereArgs: [
        id,
      ],
    );
  }

  void deleteProduct(int id) async {
    await _db!.delete(
      _productsTableName,
      where: 'id = ?',
      whereArgs: [
        id,
      ],
    );
  }

  Future<int> addUser(String email, String password) async {
    final int userId = await _db!.insert(
      _usersTableName,
      {'email': email, 'password': password},
    );
    return userId;
  }

  Future<bool> authenticateUser(String email, String password) async {
    final List<Map<String, dynamic>> users = await _db!.query(
      _usersTableName,
      where: 'email = ? AND password = ?',
      whereArgs: [email, password],
    );
    return users.isNotEmpty;
  }

  Future<int> getUserIdByEmail(String email) async {
    final data = await _db!.query(
      _usersTableName,
      where: 'email = ?',
      whereArgs: [email],
    );
    if (data.isNotEmpty) {
      return data.first['id'] as int;
    }

    return 0;
  }

  Future<List<User>> getUsers() async {
    final data = await _db!.query(_usersTableName);
    List<User> users = data
        .map((user) => User(
              id: user['id'] as int,
              email: user['email'] as String,
              password: user['password'] as String,
            ))
        .toList();
    print(users);
    return users;
  }

  Future<void> addProductToCart(int productId, int userId) async {
    final existingCartItem = await _db!.query(
      _shoppingCartTableName,
      where: 'productId = ? AND userId = ?',
      whereArgs: [productId, userId],
    );

    if (existingCartItem.isNotEmpty) {
      int currentQuantity = existingCartItem.first['quantity'] as int;
      await _db!.update(
        _shoppingCartTableName,
        {
          'quantity': currentQuantity + 1,
        },
        where: 'productId = ? AND userId = ?',
        whereArgs: [productId, userId],
      );
    } else {
      await _db!.insert(
        _shoppingCartTableName,
        {
          'quantity': 1,
          'productId': productId,
          'userId': userId,
        },
      );
    }
  }

  Future<List<ShoppingCart>> getCart(int userId) async {
    final data = await _db?.query(
      _shoppingCartTableName,
      where: 'userId = ?',
      whereArgs: [userId],
    );
    if (data == null) return [];
    List<ShoppingCart> cartItems = data
        .map(
          (item) => ShoppingCart(
              id: item['id'] as int?,
              productId: item['productId'] as int,
              userId: item['userId'] as int,
              quantity: item['quantity'] as int),
        )
        .toList();
    return cartItems;
  }

  Future<Map<String?, dynamic>> getProductNameById(int productId) async {
    final data = await _db!.query(
      _productsTableName,
      columns: ['name', 'price'],
      where: 'id = ?',
      whereArgs: [productId],
    );

    if (data.isNotEmpty) {
      return {
        'name': data.first['name'] as String?,
        'price': data.first['price'] as double?,
      };
    }
    return {};
  }

  void deleteProductFromCart(int id) async {
    await _db!.delete(
      _shoppingCartTableName,
      where: 'id = ?',
      whereArgs: [
        id,
      ],
    );
  }

  Future<void> addOrderToHistory(
      int userId, List<ShoppingCart> cartItems, double totalPrice) async {
    for (var item in cartItems) {
      await _db!.insert(
        _historyTableName,
        {
          'userId': userId,
          'productId': item.productId,
          'date': DateFormat('dd.MM.yyyy').format(DateTime.now()),
          'totalCount': item.quantity,
          'totalPrice': totalPrice,
        },
      );
    }
  }

  Future<void> clearCart(int userId) async {
    await _db!.delete(
      _shoppingCartTableName,
      where: 'userId = ?',
      whereArgs: [userId],
    );
  }

  Future<List<Map<String, dynamic>>> getOrderHistory(int userId) async {
    final data = await _db!.rawQuery('''
    SELECT h.id, h.date, h.totalPrice, u.email
    FROM $_historyTableName h
    INNER JOIN $_usersTableName u ON h.userId = u.id
    WHERE h.userId = ?
    ORDER BY h.date DESC
  ''', [userId]);

    return data;
  }

  Future<void> deleteOrderFromHistory(int orderId) async {
    await _db!.delete(
      _historyTableName,
      where: 'id = ?',
      whereArgs: [orderId],
    );
  }
}
