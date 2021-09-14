import 'package:flutter/material.dart';

import 'package:intl/intl.dart';
import '../providers/order.dart' as ord;

class OrderItem extends StatefulWidget {
  final ord.OrderItem orderItem;
  OrderItem(this.orderItem);

  @override
  _OrderItemState createState() => _OrderItemState();
}

class _OrderItemState extends State<OrderItem> {
  bool expanded = false;
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 10,
      margin: EdgeInsets.all(10),
      child: Column(
        children: [
          ListTile(
            title: Text(
              '\$${widget.orderItem.amount.toStringAsFixed(2)}',
            ),
            subtitle: Text(
                DateFormat('dd/MM/yyy hh:mm').format(widget.orderItem.date)),
            trailing: IconButton(
              icon:
                  expanded ? Icon(Icons.expand_less) : Icon(Icons.expand_more),
              onPressed: () {
                setState(() {
                  expanded = !expanded;
                });
              },
            ),
          ),
          // if (expanded)
          AnimatedContainer(
            duration: Duration(milliseconds: 500),
            curve: Curves.easeIn,
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            height:
                expanded ? widget.orderItem.cartProducts.length * 10.0 + 50 : 0,
            child: ListView(
                children: widget.orderItem.cartProducts
                    .map((prod) => Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              prod.title,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  color: Colors.grey[700]),
                            ),
                            Text(
                              '${prod.quantity}x  \$${prod.price.toStringAsFixed(2)}',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  color: Colors.grey[700]),
                            )
                          ],
                        ))
                    .toList()),
          ),
        ],
      ),
    );
  }
}
