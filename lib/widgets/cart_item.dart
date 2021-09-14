import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart.dart';

class CartItem extends StatelessWidget {
  final String title;
  final String productId;
  final String id;
  final int quantity;
  final double price;

  CartItem({this.title, this.id, this.quantity, this.price, this.productId});
  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(id),
      background: Container(
        margin: EdgeInsets.all(8),
        color: Theme.of(context).errorColor,
        child: Icon(Icons.delete),
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 6),
      ),
      confirmDismiss: (direction) {
        return showDialog(
            barrierDismissible: false,
            context: context,
            builder: (ctx) => AlertDialog(
                  title: Text('Are You Sure!'),
                  content: Text(
                    'Do you want to delete the product?',
                    style: TextStyle(fontSize: 23),
                  ),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(60)),
                  actions: [
                    TextButton(
                      child: Text('YES'),
                      onPressed: () => Navigator.of(ctx).pop(true),
                    ),
                    TextButton(
                      child: Text('NO'),
                      onPressed: () => Navigator.of(ctx).pop(false),
                    )
                  ],
                ));
      },
      direction: DismissDirection.endToStart,
      onDismissed: (_) =>
          Provider.of<Cart>(context, listen: false).deleteItem(productId),
      child: Card(
        elevation: 5,
        margin: EdgeInsets.symmetric(
          vertical: 4,
          horizontal: 3,
        ),
        child: Padding(
          padding: EdgeInsets.all(5),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Theme.of(context).primaryColor,
              child: FittedBox(fit: BoxFit.contain, child: Text('\$$price')),
            ),
            title: Text(title),
            subtitle: Text('total \$${price * quantity}'),
            trailing: Text('${quantity}x'),
          ),
        ),
      ),
    );
  }
}
