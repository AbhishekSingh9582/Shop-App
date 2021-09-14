import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/app_drawer.dart';
import '../providers/order.dart' show Order;
import '../widgets/order_item.dart';

class OrderScreen extends StatefulWidget {
  static final routeArgs = './Order-Screen';

  @override
  _OrderScreenState createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  Future _ordersFuture;

  Future _obtainOrdersFuture() {
    return Provider.of<Order>(context, listen: false).getAndFetch();
  }

  @override
  void initState() {
    // TODO: implement initState
    _ordersFuture = _obtainOrdersFuture();
    super.initState();
  }
  // var _isLoading = true;
  // @override
  // void initState() {
  //   // TODO: implement initState
  //   // setState(() {
  //   //   _isLoading = true;
  //   // });
  //   Provider.of<Order>(context, listen: false).getAndFetch().then((value) {
  //     setState(() {
  //       _isLoading = false;
  //     });
  //   });
  //   super.initState();
  // }

  @override
  Widget build(BuildContext context) {
    //final orderData = Provider.of<Order>(context);
    return Scaffold(
      drawer: AppDrawer(),
      appBar: AppBar(
        title: const Text('Your Orders'),
      ),
      body: FutureBuilder(
          future: _ordersFuture,
          builder: (ctx, currSnapshot) {
            if (currSnapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (currSnapshot.error != null) {
              return Center(
                child: Text('An error Occured '),
              );
            } else {
              return Consumer<Order>(
                  builder: (ctx, orderData, _) => ListView.builder(
                        itemBuilder: (ctx, i) {
                          return OrderItem(orderData.order[i]);
                        },
                        itemCount: orderData.order.length,
                      ));
            }
          }),
    );
  }
}
