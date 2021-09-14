import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart.dart' show Cart;
import '../widgets/cart_item.dart';

import '../providers/order.dart';

class CartScreen extends StatelessWidget {
  static final String routeArgs = '/cart-screen';
  @override
  Widget build(BuildContext context) {
    Cart cart = Provider.of<Cart>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('YOUR CART'),
      ),
      body: Column(
        children: [
          Card(
            elevation: 8.0,
            child: Row(
              children: [
                Text('Total Price', style: TextStyle(fontSize: 20)),
                SizedBox(width: 10),
                Chip(
                  backgroundColor: Theme.of(context).primaryColor,
                  label: Text(
                    '\$${cart.totalPrice.toStringAsFixed(3)}',
                    style: TextStyle(
                        color:
                            Theme.of(context).primaryTextTheme.subtitle1.color),
                  ),
                ),
                Spacer(),
                OrderButton(cart: cart),
              ],
            ),
          ),
          SizedBox(
            height: 7,
          ),
          Expanded(
              child: ListView.builder(
            itemBuilder: (ctx, i) => CartItem(
                price: cart.cartItem.values.elementAt(i).price,
                productId: cart.cartItem.keys.toList()[i],
                title: cart.cartItem.values.elementAt(i).title,
                quantity: cart.cartItem.values.toList()[i].quantity,
                id: cart.cartItem.values.toList()[i].id),
            itemCount: cart.noOfItems,
          ))
        ],
      ),
    );
  }
}

class OrderButton extends StatefulWidget {
  const OrderButton({
    Key key,
    @required this.cart,
  }) : super(key: key);
  final Cart cart;

  @override
  _OrderButtonState createState() => _OrderButtonState();
}

class _OrderButtonState extends State<OrderButton> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? Center(child: CircularProgressIndicator())
        : TextButton(
            child: Text(
              'ORDER NOW',
              //style: TextStyle(color: Theme.of(context).primaryColor),
            ),
            onPressed: (widget.cart.totalPrice <= 0 || _isLoading)
                ? null
                : () async {
                    setState(() {
                      _isLoading = true;
                    });
                    await Provider.of<Order>(context, listen: false).addOrder(
                        widget.cart.cartItem.values.toList(),
                        widget.cart.totalPrice);

                    setState(() {
                      _isLoading = false;
                    });
                    // Navigator.of(context).pushNamed(OrderScreen.routeArgs);
                    widget.cart.clearAllItem();
                  },
          );
  }
}
