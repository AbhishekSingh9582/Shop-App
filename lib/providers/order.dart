import 'package:flutter/material.dart';
import 'dart:convert';
//import 'package:provider/provider.dart';
import 'cart.dart';
import 'package:http/http.dart' as http;

class OrderItem {
  final String id;
  final double amount;
  final DateTime date;
  final List<CartItem> cartProducts;

  OrderItem({
    @required this.id,
    @required this.amount,
    @required this.date,
    @required this.cartProducts,
  });
}

class Order with ChangeNotifier {
  List<OrderItem> _orders = [];

  List<OrderItem> get order {
    return [..._orders];
  }

  final _token;
  var _params;
  final userId;
  Order(this._token, this._orders, this.userId) {
    _params = {'auth': _token};
  }

  Future<void> getAndFetch() async {
    final url = Uri.https('shop-536d3-default-rtdb.firebaseio.com',
        '/order/$userId.json', _params);
    var response = await http.get(url);
    var loadedData = json.decode(response.body) as Map<String, dynamic>;

    List<OrderItem> tempOrderList = [];

    if (loadedData == null) {
      return;
    }
    loadedData.forEach((orderId, orderProductData) {
      tempOrderList.insert(
          0,
          OrderItem(
              amount: orderProductData['amount'],
              id: orderId,
              cartProducts:
                  (orderProductData['cartProductList'] as List<dynamic>)
                      .map((e) => CartItem(
                          id: e['id'],
                          quantity: e['quantity'],
                          price: e['price'],
                          title: e['title']))
                      .toList(),
              date: DateTime.parse(orderProductData['date'])));
    });

    _orders = tempOrderList;
    notifyListeners();
  }

  Future<void> addOrder(List<CartItem> cartProducts, double total) async {
    final url = Uri.https('shop-536d3-default-rtdb.firebaseio.com',
        '/order/$userId.json', _params);
    DateTime timestamp = DateTime.now();
    var response = await http.post(url,
        body: json.encode({
          'amount': total,
          'date': timestamp.toIso8601String(),
          'cartProductList': cartProducts
              .map((cp) => {
                    'id': cp.id,
                    'price': cp.price,
                    'quantity': cp.quantity,
                    'title': cp.title,
                  })
              .toList()
        }));
    print(json.decode(response.body));
    _orders.insert(
      0,
      OrderItem(
          amount: total,
          id: json.decode(response.body)['name'],
          date: timestamp,
          cartProducts: cartProducts),
    );
    notifyListeners();
  }
}
