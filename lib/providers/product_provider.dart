//https://images-na.ssl-images-amazon.com/images/I/61MAzfI%2B4vL._SL1000_.jpg
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'product.dart';
import '../models/http_exception.dart';

class ProductProvider with ChangeNotifier {
  List<Product> _items = [
    // Product(
    //   id: 'p1',
    //   title: 'Red Shirt',
    //   description: 'A red shirt - it is pretty red!',
    //   price: 29.99,
    //   imageUrl:
    //       'https://cdn.pixabay.com/photo/2016/10/02/22/17/red-t-shirt-1710578_1280.jpg',
    // ),
    // Product(
    //   id: 'p2',
    //   title: 'Trousers',
    //   description: 'A nice pair of trousers.',
    //   price: 59.99,
    //   imageUrl:
    //       'https://upload.wikimedia.org/wikipedia/commons/thumb/e/e8/Trousers%2C_dress_%28AM_1960.022-8%29.jpg/512px-Trousers%2C_dress_%28AM_1960.022-8%29.jpg',
    // ),
    // Product(
    //   id: 'p3',
    //   title: 'Yellow Scarf',
    //   description: 'Warm and cozy - exactly what you need for the winter.',
    //   price: 19.99,
    //   imageUrl:
    //       'https://live.staticflickr.com/4043/4438260868_cc79b3369d_z.jpg',
    // ),
    // Product(
    //   id: 'p4',
    //   title: 'A Pan',
    //   description: 'Prepare any meal you want.',
    //   price: 49.99,
    //   imageUrl:
    //       'https://upload.wikimedia.org/wikipedia/commons/thumb/1/14/Cast-Iron-Pan.jpg/1024px-Cast-Iron-Pan.jpg',
    // ),
  ];
  // bool _isFavorite = false;
  final _token;
  var _params;
  String userId;
  ProductProvider(this._token, this._items, this.userId) {
    _params = {
      'auth': _token,
    };
  }

  //final params = {'key': token};

  List<Product> get items {
    return [..._items];
  }

  List<Product> get favoriteItems {
    return _items.where((element) => element.isFavorite).toList();
  }
  // void showFavoriteOnly() {
  //   _isFavorite = true;
  //   notifyListeners();
  // }

  // void showAll() {
  //   _isFavorite = false;
  //   notifyListeners();
  // }

  Product findById(String productId) {
    return items.firstWhere((prod) => prod.id == productId);
  }

  Future<void> getandsetProduct([bool filterByUser = false]) async {
    var _param;
    filterByUser
        ? _param = {
            'auth': _token,
            'orderBy': json.encode("createrId"),
            'equalTo': json.encode(userId),
          }
        : _param = {
            'auth': _token,
          };

    final url = Uri.https(
        'shop-536d3-default-rtdb.firebaseio.com', '/product.json', _param);
    try {
      final response = await http.get(url);

      final extractData = json.decode(response.body) as Map<String, dynamic>;

      if (extractData == null || extractData['error'] != null) {
        return null; // if we delete data from the server and run it then there will no updation and we get null if we request for data from server.
      }
      final List<Product> loadedProduct = [];

      final ur = Uri.https('shop-536d3-default-rtdb.firebaseio.com',
          '/userFavorite/$userId.json', _params);
      final favoriteResponse = await http.get(ur);

      var favoriteData = json.decode(favoriteResponse.body);

      extractData.forEach((prodId, productData) {
        loadedProduct.add(Product(
          id: prodId,
          description: productData['description'],
          isFavorite:
              favoriteData == null ? false : favoriteData[prodId] ?? false,
          imageUrl: productData['imageUrl'],
          title: productData['title'],
          price: productData['price'],
        ));
      });
      _items = loadedProduct;

      notifyListeners();
    } catch (error) {
      print(error);
    }
  }

  Future<void> addProduct(Product product) async {
    final url = Uri.https(
        'shop-536d3-default-rtdb.firebaseio.com', '/product.json', _params);
    try {
      final response = await http.post(url,
          body: json.encode({
            'title': product.title,
            'description': product.description,
            'price': product.price,
            'id': product.id,
            'imageUrl': product.imageUrl,
            'createrId': userId,
          }));
      // print(json.decode(response.body));
      final Product addedProduct = Product(
        id: json.decode(response.body)['name'],
        title: product.title,
        description: product.description,
        price: product.price,
        imageUrl: product.imageUrl,
      );
      _items.add(addedProduct);
      // _items.add();
      notifyListeners();
    } catch (error) {
      print(error);
      throw error;
    }
    // .catchError((error) {
    //   throw error;
    // });
  }

  Future<void> updateProduct(String id, Product newProduct) async {
    print('update');
    final prodIndex = _items.indexWhere((element) => element.id == id);
    if (prodIndex >= 0) {
      final url = Uri.https('shop-536d3-default-rtdb.firebaseio.com',
          '/product/$id.json', _params);

      await http.patch(url,
          body: json.encode({
            'description': newProduct.description,
            'title': newProduct.title,
            'price': newProduct.price,
            'imageUrl': newProduct.imageUrl,
          }));
      _items[prodIndex] = newProduct;
      notifyListeners();
    } else {
      print('..');
    }
  }

  Future<void> deleteProduct(String id) async {
    final url = Uri.https(
        'shop-536d3-default-rtdb.firebaseio.com', '/product/$id.json', _params);
    var existingProductIndex = _items.indexWhere((prod) => prod.id == id);
    var existingProductDeleted = _items[existingProductIndex];
    _items.removeAt(existingProductIndex);
    notifyListeners();
    final response = await http.delete(url);
    print(response.statusCode);
    if (response.statusCode >= 400) {
      _items.insert(existingProductIndex, existingProductDeleted);
      notifyListeners();
      throw HttpException('Product could not deleted!');
    }
    existingProductDeleted = null;
  }

  Future<void> trackFavStatus(
      String id, bool curFav, Product currentProduct) async {
    final url = Uri.https('shop-536d3-default-rtdb.firebaseio.com',
        '/userFavorite/$userId/$id.json', _params);

    final response = await http.put(url, body: json.encode(curFav));
    print(response.statusCode);
    if (response.statusCode >= 400) {
      throw response;
    }
  }
}
