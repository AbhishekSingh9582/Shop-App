import 'package:flutter/foundation.dart';

class CartItem {
  final String title;
  final String id;
  final double price;
  final int quantity;

  CartItem({
    @required this.title,
    @required this.id,
    @required this.price,
    @required this.quantity,
  });
}

class Cart with ChangeNotifier {
  Map<String, CartItem> _item = {};

  Map<String, CartItem> get cartItem {
    return {..._item};
  }

  int get noOfItems {
    return _item.length;
  }

  double get totalPrice {
    var total = 0.0;
    _item.forEach((id, cartItems) {
      total += cartItems.price * cartItems.quantity;
    });
    return total;
  }

  void deleteItem(String id) {
    _item.remove(id);
    notifyListeners();
  }

  void clearAllItem() {
    _item = {};
    notifyListeners();
  }

  void removeSingleItem(String prodId) {
    if (!_item.containsKey(prodId)) {
      return;
    }
    if (_item[prodId].quantity > 1) {
      _item.update(
          prodId,
          (existingProd) => CartItem(
              id: existingProd.id,
              price: existingProd.price,
              title: existingProd.title,
              quantity: existingProd.quantity - 1));
    } else {
      deleteItem(prodId);
    }
    notifyListeners();
  }

  void addItemInCart(String title, String productId, double price) {
    if (_item.containsKey(productId)) {
      _item.update(
          productId,
          (existingCartItem) => CartItem(
              id: existingCartItem.id,
              price: existingCartItem.price,
              quantity: existingCartItem.quantity + 1,
              title: existingCartItem.title));
    } else {
      _item.putIfAbsent(
          productId,
          () => CartItem(
              id: DateTime.now().toString(),
              price: price,
              quantity: 1,
              title: title));
    }
    notifyListeners();
  }
}
