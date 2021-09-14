import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Screens/user_productScreen.dart';
import '../Screens/order_screen.dart';
import '../providers/auth.dart';

class AppDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
        child: Column(
      children: [
        AppBar(
          title: Text('HELLO FRIENDS!'),
          automaticallyImplyLeading: false,
        ),
        Divider(),
        ListTile(
          leading: Icon(Icons.shop),
          title: Text('Shop'),
          onTap: () {
            Navigator.of(context).pushReplacementNamed('/');
          },
        ),
        Divider(),
        ListTile(
          leading: Icon(Icons.payment),
          title: Text('Your Orders'),
          onTap: () =>
              Navigator.of(context).pushReplacementNamed(OrderScreen.routeArgs),
        ),
        Divider(),
        ListTile(
          leading: Icon(Icons.edit),
          title: Text('Manage Product'),
          onTap: () => Navigator.of(context)
              .pushReplacementNamed(UserProductScreen.routeArgs),
        ),
        Divider(),
        ListTile(
          leading: Icon(Icons.exit_to_app),
          title: Text('Log Out'),
          onTap: () {
            Navigator.of(context).pop();
            Navigator.of(context).pushReplacementNamed('/');
            Provider.of<Auth>(context, listen: false).logOut();
          },
        )
      ],
    ));
  }
}
