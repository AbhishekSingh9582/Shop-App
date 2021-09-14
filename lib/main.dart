import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import './Screens/splash_screen.dart';
import './Screens/product_overview_screen.dart';
import './Screens/product_detail_screen.dart';
import './providers/cart.dart';
import './providers/product_provider.dart';
import './Screens/cart_screen.dart';
import './providers/order.dart';
import './Screens/order_screen.dart';
import './Screens/user_productScreen.dart';
import './Screens/edit_productScreen.dart';
import './Screens/auth_screen.dart';
import './providers/auth.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (ctx) => Auth()),
        ChangeNotifierProxyProvider<Auth, ProductProvider>(
          create: (ctx) => ProductProvider(null, [], null),
          update: (ctx, auth, previousProduct) => ProductProvider(
              auth.token,
              previousProduct.items == null ? [] : previousProduct.items,
              auth.userID),
        ),
        ChangeNotifierProvider(create: (ctx) => Cart()),
        ChangeNotifierProxyProvider<Auth, Order>(
          create: (ctx) => Order(null, [], null),
          update: (ctx, auth, previousOrder) => Order(
              auth.token,
              previousOrder.order == null ? [] : previousOrder.order,
              auth.userID),
        )
      ],
      child: Consumer<Auth>(
        builder: (context, authData, _) => MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'SHOP APP',
          theme: ThemeData(
            primaryColor: Colors.purple,
            accentColor: Colors.orange,
          ),
          home: authData.isAuth
              ? ProductOverviewScreen()
              : FutureBuilder(
                  future: authData.tryAutoLogin(),
                  builder: (context, currentSnapShot) =>
                      currentSnapShot.connectionState == ConnectionState.waiting
                          ? SplashScreen()
                          : AuthScreen()),
          routes: {
            ProductDetailScreen.routeArgs: (ctx) => ProductDetailScreen(),
            CartScreen.routeArgs: (ctx) => CartScreen(),
            OrderScreen.routeArgs: (ctx) => OrderScreen(),
            UserProductScreen.routeArgs: (ctx) => UserProductScreen(),
            EditProductScreen.routeArgs: (ctx) => EditProductScreen(),
          },
        ),
      ),
    );
  }
}
